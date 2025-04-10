import { 
  users, cities, districts, categories, posts, comments, 
  surveys, surveyOptions, media, bannedWords
} from "../shared/schema";
import { db } from "./db";
import { eq, like, and, or, desc, asc, sql } from "drizzle-orm";

// Type aliases for better code readability
type User = typeof users.$inferSelect;
type Post = typeof posts.$inferSelect;
type Comment = typeof comments.$inferSelect;
type Survey = typeof surveys.$inferSelect;
type Category = typeof categories.$inferSelect;
type City = typeof cities.$inferSelect;
type District = typeof districts.$inferSelect;
type SurveyOption = typeof surveyOptions.$inferSelect;

export interface IStorage {
  // Kullanıcı işlemleri
  getUsers(): Promise<User[]>;
  getUserById(id: number): Promise<User | undefined>;
  getUserByUsername(username: string): Promise<User | undefined>;
  createUser(user: Partial<User>): Promise<User>;
  updateUser(id: number, data: Partial<User>): Promise<User>;
  
  // Paylaşım işlemleri
  getPosts(filters?: Partial<Post>): Promise<Post[]>;
  getPostById(id: number): Promise<Post | undefined>;
  createPost(post: Partial<Post>): Promise<Post>;
  updatePost(id: number, data: Partial<Post>): Promise<Post>;
  deletePost(id: number): Promise<void>;
  
  // Yorum işlemleri
  getCommentsByPostId(postId: number): Promise<Comment[]>;
  addComment(comment: Partial<Comment>): Promise<Comment>;
  
  // Anket işlemleri
  getSurveys(filters?: Partial<Survey>): Promise<Survey[]>;
  getSurveyById(id: number): Promise<Survey | undefined>;
  
  // Kategori işlemleri
  getCategories(): Promise<Category[]>;
  
  // Şehir ve ilçe işlemleri
  getCities(): Promise<City[]>;
  getDistrictsByCityId(cityId: number): Promise<District[]>;
  
  // Yasak kelimeler işlemleri
  getBannedWords(): Promise<string[]>;
  addBannedWord(word: string): Promise<any>;
  removeBannedWord(word: string): Promise<void>;
}

// PostgreSQL veritabanı tabanlı depolama sınıfı
export class DatabaseStorage implements IStorage {
  // Kullanıcı işlemleri
  async getUsers(): Promise<User[]> {
    return db.select().from(users).orderBy(desc(users.createdAt));
  }
  
  async getUserById(id: number): Promise<User | undefined> {
    const results = await db.select().from(users).where(eq(users.id, id));
    return results.length > 0 ? results[0] : undefined;
  }
  
  async getUserByUsername(username: string): Promise<User | undefined> {
    const results = await db.select().from(users).where(eq(users.email, username));
    return results.length > 0 ? results[0] : undefined;
  }
  
  async createUser(user: any): Promise<User> {
    // TypeScript hatalarını önlemek için gerekli alanların varlığını doğrula
    if (!user.name || !user.email || !user.password) {
      throw new Error('Kullanıcı oluşturmak için ad, e-posta ve şifre gereklidir');
    }
    
    const result = await db.insert(users).values(user as any).returning();
    return result[0];
  }
  
  async updateUser(id: number, data: Partial<User>): Promise<User> {
    const result = await db.update(users).set(data as any).where(eq(users.id, id)).returning();
    return result[0];
  }
  
  // Paylaşım işlemleri
  async getPosts(filters?: Partial<Post>): Promise<Post[]> {
    let query = db.select().from(posts);
    
    if (filters) {
      const conditions = [];
      
      if (filters.categoryId) {
        conditions.push(eq(posts.categoryId, filters.categoryId));
      }
      
      if (filters.cityId) {
        conditions.push(eq(posts.cityId, filters.cityId));
      }
      
      if (filters.status) {
        conditions.push(eq(posts.status, filters.status));
      }
      
      // Handle custom search functionality
      if ((filters as any).search) {
        const searchTerm = (filters as any).search;
        conditions.push(
          or(
            like(posts.title, `%${searchTerm}%`),
            like(posts.content, `%${searchTerm}%`)
          )
        );
      }
      
      if (conditions.length > 0) {
        query = query.where(and(...conditions));
      }
    }
    
    return query.orderBy(desc(posts.createdAt));
  }
  
  async getPostById(id: number): Promise<Post | undefined> {
    const results = await db.select().from(posts).where(eq(posts.id, id));
    
    if (results.length > 0) {
      const post = results[0];
      // Get related media
      const mediaItems = await db.select().from(media).where(eq(media.postId, id));
      
      return {
        ...post,
        imageUrls: mediaItems.filter(m => m.type === 'image').map(m => m.url),
        videoUrl: mediaItems.find(m => m.type === 'video')?.url
      } as Post;
    }
    
    return undefined;
  }
  
  async createPost(postData: Partial<Post>): Promise<Post> {
    const { imageUrls, videoUrl, ...post } = postData as any;
    
    // Create post first
    const result = await db.insert(posts).values(post).returning();
    const newPost = result[0];
    
    // Add images if present
    if (imageUrls && imageUrls.length > 0) {
      const mediaValues = imageUrls.map((url: string) => ({
        postId: newPost.id,
        url,
        type: 'image'
      }));
      
      await db.insert(media).values(mediaValues);
    }
    
    // Add video if present
    if (videoUrl) {
      await db.insert(media).values({
        postId: newPost.id,
        url: videoUrl,
        type: 'video'
      });
    }
    
    // Increment user's post count
    await db
      .update(users)
      .set({ 
        postCount: sql`${users.postCount} + 1` 
      })
      .where(eq(users.id, post.userId));
    
    return this.getPostById(newPost.id) as Promise<Post>;
  }
  
  async updatePost(id: number, data: Partial<Post>): Promise<Post> {
    const { imageUrls, videoUrl, ...updateData } = data as any;
    
    // Update post
    await db
      .update(posts)
      .set(updateData)
      .where(eq(posts.id, id));
    
    // If media is being updated
    if (imageUrls !== undefined || videoUrl !== undefined) {
      // Delete existing media
      await db.delete(media).where(eq(media.postId, id));
      
      // Add new images
      if (imageUrls && imageUrls.length > 0) {
        const mediaValues = imageUrls.map((url: string) => ({
          postId: id,
          url,
          type: 'image'
        }));
        
        await db.insert(media).values(mediaValues);
      }
      
      // Add new video
      if (videoUrl) {
        await db.insert(media).values({
          postId: id,
          url: videoUrl,
          type: 'video'
        });
      }
    }
    
    return this.getPostById(id) as Promise<Post>;
  }
  
  async deletePost(id: number): Promise<void> {
    // Paylaşıma ait tüm yorum ve medyalar cascade ile silinecek
    const results = await db.select().from(posts).where(eq(posts.id, id));
    
    if (results.length > 0) {
      const post = results[0];
      // Kullanıcının paylaşım sayısını azalt
      await db
        .update(users)
        .set({ 
          postCount: sql`${users.postCount} - 1` 
        })
        .where(eq(users.id, post.userId));
    }
    
    await db.delete(posts).where(eq(posts.id, id));
  }
  
  // Yorum işlemleri
  async getCommentsByPostId(postId: number): Promise<Comment[]> {
    // First get the top-level comments (ones without parentId)
    const topLevelComments = await db
      .select()
      .from(comments)
      .where(and(
        eq(comments.postId, postId),
        sql`${comments.parentId} IS NULL` // Only get top-level comments
      ))
      .orderBy(asc(comments.createdAt));
    
    // Get all replies for this post
    const replies = await db
      .select()
      .from(comments)
      .where(and(
        eq(comments.postId, postId),
        sql`${comments.parentId} IS NOT NULL` // Only get replies
      ))
      .orderBy(asc(comments.createdAt));
    
    // Group replies by their parent comment
    const repliesByParentId = replies.reduce((acc, reply) => {
      const parentId = reply.parentId;
      if (parentId !== null && parentId !== undefined) {
        if (!acc[parentId]) {
          acc[parentId] = [];
        }
        acc[parentId].push(reply);
      }
      return acc;
    }, {} as Record<number, Comment[]>);
    
    // Attach replies to their parent comments
    return topLevelComments.map(comment => ({
      ...comment,
      replies: repliesByParentId[comment.id] || []
    })) as Comment[];
  }
  
  async addComment(comment: Partial<Comment>): Promise<Comment> {
    // TypeScript hatalarını önlemek için gerekli alanların varlığını doğrula
    if (!comment.content || !comment.userId || !comment.postId) {
      throw new Error('Yorum eklemek için içerik, kullanıcı ve paylaşım ID gereklidir');
    }
    
    // Add the comment
    const result = await db.insert(comments).values(comment as any).returning();
    const newComment = result[0];
    
    // Increment user's comment count and points
    await db
      .update(users)
      .set({ 
        commentCount: sql`${users.commentCount} + 1`,
        points: sql`${users.points} + 5` // Each comment gives 5 points
      })
      .where(eq(users.id, comment.userId));
    
    // Increment post's comment count
    await db
      .update(posts)
      .set({ 
        commentCount: sql`${posts.commentCount} + 1` 
      })
      .where(eq(posts.id, comment.postId));
    
    return newComment;
  }
  
  // Anket işlemleri
  async getSurveys(filters?: Partial<Survey>): Promise<Survey[]> {
    let query = db.select().from(surveys);
    
    if (filters) {
      const conditions = [];
      
      if (filters.isActive !== undefined) {
        conditions.push(eq(surveys.isActive, filters.isActive));
      }
      
      if (filters.categoryId) {
        conditions.push(eq(surveys.categoryId, filters.categoryId));
      }
      
      if (filters.cityId) {
        conditions.push(eq(surveys.cityId, filters.cityId));
      }
      
      if (conditions.length > 0) {
        query = query.where(and(...conditions));
      }
    }
    
    const surveyResults = await query.orderBy(desc(surveys.createdAt));
    
    // Add options to each survey
    const enrichedSurveys: Array<Survey & { options: SurveyOption[] }> = [];
    
    for (const survey of surveyResults) {
      const options = await db
        .select()
        .from(surveyOptions)
        .where(eq(surveyOptions.surveyId, survey.id));
      
      enrichedSurveys.push({
        ...survey,
        options
      });
    }
    
    return enrichedSurveys as Survey[];
  }
  
  async getSurveyById(id: number): Promise<Survey | undefined> {
    const results = await db.select().from(surveys).where(eq(surveys.id, id));
    
    if (results.length > 0) {
      const survey = results[0];
      const options = await db
        .select()
        .from(surveyOptions)
        .where(eq(surveyOptions.surveyId, id));
      
      return {
        ...survey,
        options
      } as Survey;
    }
    
    return undefined;
  }
  
  // Kategori işlemleri
  async getCategories(): Promise<Category[]> {
    return db.select().from(categories).orderBy(asc(categories.name));
  }
  
  // Şehir ve ilçe işlemleri
  async getCities(): Promise<City[]> {
    return db.select().from(cities).orderBy(asc(cities.name));
  }
  
  async getDistrictsByCityId(cityId: number): Promise<District[]> {
    return db
      .select()
      .from(districts)
      .where(eq(districts.cityId, cityId))
      .orderBy(asc(districts.name));
  }
  
  // Küfür filtreleme işlemleri
  async getBannedWords(): Promise<string[]> {
    const words = await db.select().from(bannedWords);
    return words.map(w => w.word);
  }
  
  async addBannedWord(word: string): Promise<any> {
    try {
      const result = await db
        .insert(bannedWords)
        .values({ word })
        .returning();
      return result[0];
    } catch (error) {
      // Probably word already exists
      return null;
    }
  }
  
  async removeBannedWord(word: string): Promise<void> {
    await db
      .delete(bannedWords)
      .where(eq(bannedWords.word, word));
  }
}

// Uygulama genelinde kullanılacak tek bir depolama örneği
export const storage = new DatabaseStorage();