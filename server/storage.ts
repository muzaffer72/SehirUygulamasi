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
  async getUsers(): Promise<any[]> {
    return db.select().from(users).orderBy(desc(users.createdAt));
  }
  
  async getUserById(id: number): Promise<any | undefined> {
    const results = await db.select().from(users).where(eq(users.id, id));
    return results.length > 0 ? results[0] : undefined;
  }
  
  async getUserByUsername(email: string): Promise<any | undefined> {
    const results = await db.select().from(users).where(eq(users.email, email));
    return results.length > 0 ? results[0] : undefined;
  }
  
  async createUser(user: any): Promise<any> {
    const result = await db.insert(users).values(user).returning();
    return result[0];
  }
  
  async updateUser(id: number, data: any): Promise<any> {
    const result = await db.update(users).set(data).where(eq(users.id, id)).returning();
    return result[0];
  }
  
  // Paylaşım işlemleri
  async getPosts(filters?: any): Promise<any[]> {
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
      
      if (filters.search) {
        conditions.push(
          or(
            like(posts.title, `%${filters.search}%`),
            like(posts.content, `%${filters.search}%`)
          )
        );
      }
      
      if (conditions.length > 0) {
        query = query.where(and(...conditions));
      }
    }
    
    return query.orderBy(desc(posts.createdAt));
  }
  
  async getPostById(id: number): Promise<any | undefined> {
    const results = await db.select().from(posts).where(eq(posts.id, id));
    
    if (results.length > 0) {
      const post = results[0];
      // Görselleri getir
      const mediaItems = await db.select().from(media).where(eq(media.postId, id));
      
      return {
        ...post,
        imageUrls: mediaItems.filter(m => m.type === 'image').map(m => m.url),
        videoUrl: mediaItems.find(m => m.type === 'video')?.url
      };
    }
    
    return undefined;
  }
  
  async createPost(postData: any): Promise<any> {
    const { imageUrls, videoUrl, ...post } = postData;
    
    // Önce paylaşımı oluştur
    const result = await db.insert(posts).values(post).returning();
    const newPost = result[0];
    
    // Görselleri ekle
    if (imageUrls && imageUrls.length > 0) {
      const mediaValues = imageUrls.map((url: string) => ({
        postId: newPost.id,
        url,
        type: 'image'
      }));
      
      await db.insert(media).values(mediaValues);
    }
    
    // Video ekle
    if (videoUrl) {
      await db.insert(media).values({
        postId: newPost.id,
        url: videoUrl,
        type: 'video'
      });
    }
    
    // Kullanıcının paylaşım sayısını güncelle
    await db
      .update(users)
      .set({ 
        postCount: sql`${users.postCount} + 1` 
      })
      .where(eq(users.id, post.userId));
    
    return this.getPostById(newPost.id);
  }
  
  async updatePost(id: number, data: any): Promise<any> {
    const { imageUrls, videoUrl, ...updateData } = data;
    
    // Paylaşımı güncelle
    await db
      .update(posts)
      .set(updateData)
      .where(eq(posts.id, id));
    
    // Medya güncellemesi varsa
    if (imageUrls !== undefined || videoUrl !== undefined) {
      // Mevcut medyayı sil
      await db.delete(media).where(eq(media.postId, id));
      
      // Yeni görselleri ekle
      if (imageUrls && imageUrls.length > 0) {
        const mediaValues = imageUrls.map((url: string) => ({
          postId: id,
          url,
          type: 'image'
        }));
        
        await db.insert(media).values(mediaValues);
      }
      
      // Yeni video ekle
      if (videoUrl) {
        await db.insert(media).values({
          postId: id,
          url: videoUrl,
          type: 'video'
        });
      }
    }
    
    return this.getPostById(id);
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
  async getCommentsByPostId(postId: number): Promise<any[]> {
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
      if (!acc[parentId]) {
        acc[parentId] = [];
      }
      acc[parentId].push(reply);
      return acc;
    }, {} as Record<number, any[]>);
    
    // Attach replies to their parent comments
    return topLevelComments.map(comment => ({
      ...comment,
      replies: repliesByParentId[comment.id] || []
    }));
  }
  
  async addComment(comment: any): Promise<any> {
    // Yorumu ekle
    const result = await db.insert(comments).values(comment).returning();
    const newComment = result[0];
    
    // Kullanıcının yorum sayısını ve puanını artır
    await db
      .update(users)
      .set({ 
        commentCount: sql`${users.commentCount} + 1`,
        points: sql`${users.points} + 5` // Her yorum 5 puan kazandırır
      })
      .where(eq(users.id, comment.userId));
    
    // Paylaşımın yorum sayısını artır
    await db
      .update(posts)
      .set({ 
        commentCount: sql`${posts.commentCount} + 1` 
      })
      .where(eq(posts.id, comment.postId));
    
    return newComment;
  }
  
  // Anket işlemleri
  async getSurveys(filters?: any): Promise<any[]> {
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
    
    // Her anket için seçenekleri ekle
    const enrichedSurveys = [];
    
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
    
    return enrichedSurveys;
  }
  
  async getSurveyById(id: number): Promise<any | undefined> {
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
      };
    }
    
    return undefined;
  }
  
  // Kategori işlemleri
  async getCategories(): Promise<any[]> {
    return db.select().from(categories).orderBy(asc(categories.name));
  }
  
  // Şehir ve ilçe işlemleri
  async getCities(): Promise<any[]> {
    return db.select().from(cities).orderBy(asc(cities.name));
  }
  
  async getDistrictsByCityId(cityId: number): Promise<any[]> {
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
      // Muhtemelen kelime zaten var
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