import { pgTable, serial, text, varchar, boolean, integer, timestamp } from 'drizzle-orm/pg-core';
import { relations } from 'drizzle-orm';

// Enum değerlerini basit string olarak tanımlayalım
export type UserLevel = 'newUser' | 'contributor' | 'active' | 'expert' | 'master';
export type PostStatus = 'awaitingSolution' | 'inProgress' | 'solved' | 'rejected';
export type PostType = 'problem' | 'suggestion' | 'announcement';

// Kategori tablosu
export const categories = pgTable('categories', {
  id: serial('id').primaryKey(),
  name: varchar('name', { length: 100 }).notNull(),
  iconName: varchar('icon_name', { length: 50 }),
  createdAt: timestamp('created_at').defaultNow().notNull()
});

// Şehir tablosu
export const cities = pgTable('cities', {
  id: serial('id').primaryKey(),
  name: varchar('name', { length: 100 }).notNull(),
  createdAt: timestamp('created_at').defaultNow().notNull()
});

// İlçe tablosu
export const districts = pgTable('districts', {
  id: serial('id').primaryKey(),
  name: varchar('name', { length: 100 }).notNull(),
  cityId: integer('city_id').notNull().references(() => cities.id, { onDelete: 'cascade' }),
  createdAt: timestamp('created_at').defaultNow().notNull()
});

// Kullanıcı tablosu
export const users = pgTable('users', {
  id: serial('id').primaryKey(),
  name: varchar('name', { length: 100 }).notNull(),
  email: varchar('email', { length: 255 }).notNull().unique(),
  password: varchar('password', { length: 255 }).notNull(),
  profileImageUrl: text('profile_image_url'),
  bio: text('bio'),
  cityId: integer('city_id').references(() => cities.id),
  districtId: integer('district_id').references(() => districts.id),
  isVerified: boolean('is_verified').default(false).notNull(),
  points: integer('points').default(0).notNull(),
  postCount: integer('post_count').default(0).notNull(),
  commentCount: integer('comment_count').default(0).notNull(),
  level: varchar('level', { length: 20 }).default('newUser').notNull(),
  createdAt: timestamp('created_at').defaultNow().notNull()
});

// Paylaşım (Şikayet/Öneri) tablosu
export const posts = pgTable('posts', {
  id: serial('id').primaryKey(),
  title: varchar('title', { length: 255 }).notNull(),
  content: text('content').notNull(),
  userId: integer('user_id').notNull().references(() => users.id, { onDelete: 'cascade' }),
  categoryId: integer('category_id').notNull().references(() => categories.id),
  cityId: integer('city_id').references(() => cities.id),
  districtId: integer('district_id').references(() => districts.id),
  status: varchar('status', { length: 20 }).default('awaitingSolution').notNull(),
  type: varchar('type', { length: 20 }).default('problem').notNull(),
  likes: integer('likes').default(0).notNull(),
  highlights: integer('highlights').default(0).notNull(),
  commentCount: integer('comment_count').default(0).notNull(),
  isAnonymous: boolean('is_anonymous').default(false).notNull(),
  createdAt: timestamp('created_at').defaultNow().notNull()
});

// Medya tablosu (Paylaşımlara eklenen görseller)
export const media = pgTable('media', {
  id: serial('id').primaryKey(),
  postId: integer('post_id').notNull().references(() => posts.id, { onDelete: 'cascade' }),
  url: text('url').notNull(),
  type: varchar('type', { length: 20 }).notNull(), // image, video
  createdAt: timestamp('created_at').defaultNow().notNull()
});

// Yorum tablosu
export const comments = pgTable('comments', {
  id: serial('id').primaryKey(),
  postId: integer('post_id').notNull().references(() => posts.id, { onDelete: 'cascade' }),
  userId: integer('user_id').notNull().references(() => users.id, { onDelete: 'cascade' }),
  content: text('content').notNull(),
  likeCount: integer('like_count').default(0).notNull(),
  isHidden: boolean('is_hidden').default(false).notNull(),
  createdAt: timestamp('created_at').defaultNow().notNull()
});

// Anket tablosu
export const surveys = pgTable('surveys', {
  id: serial('id').primaryKey(),
  title: varchar('title', { length: 255 }).notNull(),
  description: text('description').notNull(),
  cityId: integer('city_id').references(() => cities.id),
  categoryId: integer('category_id').notNull().references(() => categories.id),
  isActive: boolean('is_active').default(true).notNull(),
  startDate: timestamp('start_date').notNull(),
  endDate: timestamp('end_date').notNull(),
  totalVotes: integer('total_votes').default(0).notNull(),
  createdAt: timestamp('created_at').defaultNow().notNull()
});

// Anket seçenekleri tablosu
export const surveyOptions = pgTable('survey_options', {
  id: serial('id').primaryKey(),
  surveyId: integer('survey_id').notNull().references(() => surveys.id, { onDelete: 'cascade' }),
  text: text('text').notNull(),
  voteCount: integer('vote_count').default(0).notNull(),
  createdAt: timestamp('created_at').defaultNow().notNull()
});

// Küfür filtreleme tablosu
export const bannedWords = pgTable('banned_words', {
  id: serial('id').primaryKey(),
  word: varchar('word', { length: 100 }).notNull().unique(),
  createdAt: timestamp('created_at').defaultNow().notNull()
});

// İlişki tanımlamaları
export const usersRelations = relations(users, ({ many }) => ({
  posts: many(posts),
  comments: many(comments)
}));

export const postsRelations = relations(posts, ({ one, many }) => ({
  user: one(users, {
    fields: [posts.userId],
    references: [users.id]
  }),
  category: one(categories, {
    fields: [posts.categoryId],
    references: [categories.id]
  }),
  city: one(cities, {
    fields: [posts.cityId],
    references: [cities.id]
  }),
  district: one(districts, {
    fields: [posts.districtId],
    references: [districts.id]
  }),
  comments: many(comments),
  media: many(media)
}));

export const commentsRelations = relations(comments, ({ one }) => ({
  post: one(posts, {
    fields: [comments.postId],
    references: [posts.id]
  }),
  user: one(users, {
    fields: [comments.userId],
    references: [users.id]
  })
}));

export const mediaRelations = relations(media, ({ one }) => ({
  post: one(posts, {
    fields: [media.postId],
    references: [posts.id]
  })
}));

export const surveysRelations = relations(surveys, ({ one, many }) => ({
  category: one(categories, {
    fields: [surveys.categoryId],
    references: [categories.id]
  }),
  city: one(cities, {
    fields: [surveys.cityId],
    references: [cities.id]
  }),
  options: many(surveyOptions)
}));

export const surveyOptionsRelations = relations(surveyOptions, ({ one }) => ({
  survey: one(surveys, {
    fields: [surveyOptions.surveyId],
    references: [surveys.id]
  })
}));

export const districtsRelations = relations(districts, ({ one }) => ({
  city: one(cities, {
    fields: [districts.cityId],
    references: [cities.id]
  })
}));