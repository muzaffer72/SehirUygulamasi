import { pgTable, serial, text, varchar, boolean, integer, timestamp, date, decimal } from 'drizzle-orm/pg-core';
import { relations } from 'drizzle-orm';

// Enum değerlerini basit string olarak tanımlayalım
export type UserLevel = 'newUser' | 'contributor' | 'active' | 'expert' | 'master';
export type PostStatus = 'awaitingSolution' | 'inProgress' | 'solved' | 'rejected';
export type PostType = 'problem' | 'suggestion' | 'announcement' | 'general';
export type ScopeType = 'general' | 'city' | 'district';

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
  description: text('description'),
  population: integer('population'),
  latitude: text('latitude'),
  longitude: text('longitude'),
  imageUrl: text('image_url'),
  headerImageUrl: text('header_image_url'),
  mayorName: varchar('mayor_name', { length: 255 }),
  mayorParty: varchar('mayor_party', { length: 255 }),
  mayorSatisfactionRate: integer('mayor_satisfaction_rate'),
  mayorImageUrl: text('mayor_image_url'),
  mayorPartyLogo: text('mayor_party_logo'),
  contactEmail: varchar('contact_email', { length: 100 }),
  contactPhone: varchar('contact_phone', { length: 50 }),
  emergencyPhone: varchar('emergency_phone', { length: 50 }),
  website: varchar('website', { length: 100 }),
  // Sorunların çözüm oranı (%)
  problemSolvingRate: integer('problem_solving_rate').default(0),
  // Ayın Belediyesi özellikleri
  isBestOfMonth: boolean('is_best_of_month').default(false),
  awardMonth: varchar('award_month', { length: 20 }),
  awardScore: integer('award_score'),
  awardText: text('award_text'),
  createdAt: timestamp('created_at').defaultNow().notNull()
});

// İlçe tablosu
export const districts = pgTable('districts', {
  id: serial('id').primaryKey(),
  name: varchar('name', { length: 100 }).notNull(),
  cityId: integer('city_id').notNull().references(() => cities.id, { onDelete: 'cascade' }),
  // Sorunların çözüm oranı (%)
  problemSolvingRate: integer('problem_solving_rate').default(0),
  createdAt: timestamp('created_at').defaultNow().notNull()
});

// Kullanıcı tablosu
export const users = pgTable('users', {
  id: serial('id').primaryKey(),
  name: varchar('name', { length: 100 }).notNull(),
  username: varchar('username', { length: 100 }).unique(),
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
  // Konum bilgileri
  latitude: text('latitude'), // Enlem
  longitude: text('longitude'), // Boylam
  address: text('address'), // Tam adres
  neighborhood: varchar('neighborhood', { length: 100 }), // Mahalle
  street: varchar('street', { length: 100 }), // Sokak
  locationDetails: text('location_details'), // Konum ile ilgili ek detaylar
  // Memnuniyet seviyesi (çözülmüş şikayetler için)
  satisfactionRating: integer('satisfaction_rating'), // 1-5 arası puan
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

// Yorum tablosu - declare without self-referencing first
export const comments = pgTable('comments', {
  id: serial('id').primaryKey(),
  postId: integer('post_id').notNull().references(() => posts.id, { onDelete: 'cascade' }),
  userId: integer('user_id').notNull().references(() => users.id, { onDelete: 'cascade' }),
  content: text('content').notNull(),
  likeCount: integer('like_count').default(0).notNull(),
  isHidden: boolean('is_hidden').default(false).notNull(),
  isAnonymous: boolean('is_anonymous').default(false).notNull(),
  parentId: integer('parent_id'),
  createdAt: timestamp('created_at').defaultNow().notNull()
});

// Anket tablosu
export const surveys = pgTable('surveys', {
  id: serial('id').primaryKey(),
  title: varchar('title', { length: 255 }).notNull(),
  shortTitle: varchar('short_title', { length: 40 }),
  description: text('description').notNull(),
  scopeType: varchar('scope_type', { length: 20 }).default('general').notNull(),
  cityId: integer('city_id').references(() => cities.id),
  districtId: integer('district_id').references(() => districts.id),
  categoryId: integer('category_id').notNull().references(() => categories.id),
  isActive: boolean('is_active').default(true).notNull(),
  startDate: timestamp('start_date').notNull(),
  endDate: timestamp('end_date').notNull(),
  totalVotes: integer('total_votes').default(0).notNull(),
  totalUsers: integer('total_users').default(0),
  sortOrder: integer('sort_order').default(0).notNull(),
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

// Bölgesel anket sonuçları tablosu
export const surveyRegionalResults = pgTable('survey_regional_results', {
  id: serial('id').primaryKey(),
  surveyId: integer('survey_id').notNull().references(() => surveys.id, { onDelete: 'cascade' }),
  optionId: integer('option_id').notNull().references(() => surveyOptions.id, { onDelete: 'cascade' }),
  cityId: integer('city_id').references(() => cities.id),
  districtId: integer('district_id').references(() => districts.id),
  voteCount: integer('vote_count').default(0).notNull(),
  createdAt: timestamp('created_at').defaultNow().notNull()
});

// Küfür filtreleme tablosu
export const bannedWords = pgTable('banned_words', {
  id: serial('id').primaryKey(),
  word: varchar('word', { length: 100 }).notNull().unique(),
  createdAt: timestamp('created_at').defaultNow().notNull()
});

// Şehir Hizmetleri tablosu
export const cityServices = pgTable('city_services', {
  id: serial('id').primaryKey(),
  name: varchar('name', { length: 100 }).notNull(),
  description: text('description'),
  iconUrl: text('icon_url'),
  type: varchar('type', { length: 50 }).notNull(), // online, emergency, contact, etc.
  url: text('url'),
  createdAt: timestamp('created_at').defaultNow().notNull()
});

// Şehir-Hizmet İlişki Tablosu
export const citiesServices = pgTable('cities_services', {
  id: serial('id').primaryKey(),
  cityId: integer('city_id').notNull().references(() => cities.id, { onDelete: 'cascade' }),
  serviceId: integer('service_id').notNull().references(() => cityServices.id, { onDelete: 'cascade' }),
  createdAt: timestamp('created_at').defaultNow().notNull()
});

// Şehir Proje tablosu
export const cityProjects = pgTable('city_projects', {
  id: serial('id').primaryKey(),
  cityId: integer('city_id').notNull().references(() => cities.id, { onDelete: 'cascade' }),
  title: varchar('title', { length: 255 }).notNull(),
  description: text('description'),
  imageUrl: text('image_url'),
  startDate: timestamp('start_date'),
  endDate: timestamp('end_date'),
  status: varchar('status', { length: 30 }).notNull(), // planned, inProgress, completed
  likes: integer('likes').default(0).notNull(),
  dislikes: integer('dislikes').default(0).notNull(),
  createdAt: timestamp('created_at').defaultNow().notNull()
});

// Kullanıcı beğenileri tablosu
export const userLikes = pgTable('user_likes', {
  id: serial('id').primaryKey(),
  userId: integer('user_id').notNull().references(() => users.id, { onDelete: 'cascade' }),
  postId: integer('post_id').references(() => posts.id, { onDelete: 'cascade' }),
  commentId: integer('comment_id').references(() => comments.id, { onDelete: 'cascade' }),
  createdAt: timestamp('created_at').defaultNow().notNull()
});

// Kullanıcı bildirimleri tablosu
export const notifications = pgTable('notifications', {
  id: serial('id').primaryKey(),
  userId: integer('user_id').notNull().references(() => users.id, { onDelete: 'cascade' }),
  title: varchar('title', { length: 255 }).notNull(),
  content: text('content').notNull(),
  type: varchar('type', { length: 50 }).notNull(), // 'like', 'comment', 'reply', 'status_update', 'system'
  isRead: boolean('is_read').default(false).notNull(),
  sourceId: integer('source_id'), // İlgili kaynak ID (post, comment vb.)
  sourceType: varchar('source_type', { length: 50 }), // 'post', 'comment', 'reply'
  data: text('data'), // JSON olarak ek veriler
  isArchived: boolean('is_archived').default(false).notNull(), // Bildirimin arşivlenip arşivlenmediği
  groupId: varchar('group_id', { length: 100 }), // Benzer bildirimleri gruplamak için kullanılır (ör. aynı gönderi için tüm yorumlar)
  createdAt: timestamp('created_at').defaultNow().notNull()
});

// Şehir Etkinlikleri tablosu
export const cityEvents = pgTable('city_events', {
  id: serial('id').primaryKey(),
  cityId: integer('city_id').notNull().references(() => cities.id, { onDelete: 'cascade' }),
  title: varchar('title', { length: 255 }).notNull(),
  description: text('description'),
  imageUrl: text('image_url'),
  location: varchar('location', { length: 255 }),
  eventDate: timestamp('event_date').notNull(),
  isActive: boolean('is_active').default(true).notNull(),
  createdAt: timestamp('created_at').defaultNow().notNull()
});

// Şehir İstatistikleri Tablosu
export const cityStats = pgTable('city_stats', {
  id: serial('id').primaryKey(),
  cityId: integer('city_id').notNull().references(() => cities.id, { onDelete: 'cascade' }),
  type: varchar('type', { length: 50 }).notNull(), // economy, tourism, education, environment
  iconUrl: text('icon_url'),
  title: varchar('title', { length: 100 }).notNull(),
  description: text('description'),
  value: varchar('value', { length: 50 }),
  createdAt: timestamp('created_at').defaultNow().notNull()
});

// Çözülen Sorunların Öncesi ve Sonrası Tablosu
export const beforeAfterRecords = pgTable('before_after_records', {
  id: serial('id').primaryKey(),
  postId: integer('post_id').notNull().references(() => posts.id, { onDelete: 'cascade' }),
  beforeImageUrl: text('before_image_url').notNull(), // Öncesini gösteren görsel
  afterImageUrl: text('after_image_url').notNull(), // Sonrasını gösteren görsel
  description: text('description'), // Değişiklik ile ilgili açıklama
  recordedBy: integer('recorded_by').references(() => users.id), // Kaydeden kullanıcı
  recordDate: timestamp('record_date').defaultNow().notNull(), // Kayıt tarihi
  createdAt: timestamp('created_at').defaultNow().notNull()
});

// Ödül Türleri Tablosu
export const awardTypes = pgTable('award_types', {
  id: serial('id').primaryKey(),
  name: varchar('name', { length: 100 }).notNull(),
  description: text('description'),
  iconUrl: text('icon_url'),
  badgeUrl: text('badge_url'),
  color: varchar('color', { length: 20 }),
  points: integer('points').default(0).notNull(),
  createdAt: timestamp('created_at').defaultNow().notNull()
});

// Belediye Ödülleri Tablosu
export const cityAwards = pgTable('city_awards', {
  id: serial('id').primaryKey(),
  cityId: integer('city_id').notNull().references(() => cities.id, { onDelete: 'cascade' }),
  awardTypeId: integer('award_type_id').notNull().references(() => awardTypes.id),
  title: varchar('title', { length: 255 }).notNull(),
  description: text('description'),
  awardDate: date('award_date').notNull(),
  issuer: varchar('issuer', { length: 100 }), // kim tarafından verildiği
  certificateUrl: text('certificate_url'), // sertifika görseli
  featured: boolean('featured').default(false).notNull(), // öne çıkan ödül mü?
  projectId: integer('project_id').references(() => cityProjects.id), // hangi projeyle ilgili (opsiyonel)
  createdAt: timestamp('created_at').defaultNow().notNull()
});

// Siyasi Partiler Tablosu
export const politicalParties = pgTable('political_parties', {
  id: serial('id').primaryKey(),
  name: varchar('name', { length: 255 }).notNull().unique(),
  shortName: varchar('short_name', { length: 50 }).notNull().unique(), // Kısa isim, örn: AK Parti, CHP, MHP
  description: text('description'),
  logoUrl: text('logo_url').notNull(), // Parti logosu
  color: varchar('color', { length: 20 }).notNull(), // Parti rengi (hex code)
  isActive: boolean('is_active').default(true).notNull(),
  foundedYear: integer('founded_year'), // Kuruluş yılı
  website: varchar('website', { length: 255 }),
  sortOrder: integer('sort_order').default(0).notNull(), // Sıralama için
  createdAt: timestamp('created_at').defaultNow().notNull(),
  updatedAt: timestamp('updated_at').defaultNow().notNull()
});

// Parti Performans Tablosu
export const partyPerformance = pgTable('party_performance', {
  id: serial('id').primaryKey(),
  partyId: integer('party_id').notNull().references(() => politicalParties.id, { onDelete: 'cascade' }).unique(),
  cityCount: integer('city_count').default(0).notNull(), // Yönetilen şehir sayısı
  districtCount: integer('district_count').default(0).notNull(), // Yönetilen ilçe sayısı
  complaintCount: integer('complaint_count').default(0).notNull(), // Toplam şikayet sayısı
  solvedCount: integer('solved_count').default(0).notNull(), // Çözülen şikayet sayısı
  problemSolvingRate: decimal('problem_solving_rate', { precision: 5, scale: 2 }).default('0').notNull(), // Çözüm oranı (%)
  lastUpdated: timestamp('last_updated').defaultNow().notNull(), // En son güncelleme zamanı
});

// Şehir-Parti İlişki Tablosu
export const cityPartyRelations = pgTable('city_party_relations', {
  id: serial('id').primaryKey(),
  cityId: integer('city_id').notNull().references(() => cities.id, { onDelete: 'cascade' }),
  partyId: integer('party_id').notNull().references(() => politicalParties.id, { onDelete: 'cascade' }),
  startDate: date('start_date').notNull(), // Göreve başlama tarihi
  endDate: date('end_date'), // Görev bitiş tarihi (null ise hala görevde)
  isCurrent: boolean('is_current').default(true).notNull(), // Şu anda görevde mi?
  createdAt: timestamp('created_at').defaultNow().notNull(),
});

// İlçe-Parti İlişki Tablosu
export const districtPartyRelations = pgTable('district_party_relations', {
  id: serial('id').primaryKey(),
  districtId: integer('district_id').notNull().references(() => districts.id, { onDelete: 'cascade' }),
  partyId: integer('party_id').notNull().references(() => politicalParties.id, { onDelete: 'cascade' }),
  startDate: date('start_date').notNull(), // Göreve başlama tarihi
  endDate: date('end_date'), // Görev bitiş tarihi (null ise hala görevde)
  isCurrent: boolean('is_current').default(true).notNull(), // Şu anda görevde mi?
  createdAt: timestamp('created_at').defaultNow().notNull(),
});

// İlişki tanımlamaları
export const userLikesRelations = relations(userLikes, ({ one }) => ({
  user: one(users, {
    fields: [userLikes.userId],
    references: [users.id]
  }),
  post: one(posts, {
    fields: [userLikes.postId],
    references: [posts.id]
  }),
  comment: one(comments, {
    fields: [userLikes.commentId],
    references: [comments.id]
  })
}));

export const notificationsRelations = relations(notifications, ({ one }) => ({
  user: one(users, {
    fields: [notifications.userId],
    references: [users.id]
  })
}));

export const usersRelations = relations(users, ({ many }) => ({
  posts: many(posts),
  comments: many(comments),
  likes: many(userLikes),
  notifications: many(notifications)
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
  media: many(media),
  likes: many(userLikes)
}));

export const commentsRelations = relations(comments, ({ one, many }) => ({
  post: one(posts, {
    fields: [comments.postId],
    references: [posts.id]
  }),
  user: one(users, {
    fields: [comments.userId],
    references: [users.id]
  }),
  parent: one(comments, {
    fields: [comments.parentId],
    references: [comments.id]
  }),
  replies: many(comments),
  likes: many(userLikes)
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
  district: one(districts, {
    fields: [surveys.districtId],
    references: [districts.id]
  }),
  options: many(surveyOptions),
  regionalResults: many(surveyRegionalResults)
}));

export const surveyOptionsRelations = relations(surveyOptions, ({ one, many }) => ({
  survey: one(surveys, {
    fields: [surveyOptions.surveyId],
    references: [surveys.id]
  }),
  regionalResults: many(surveyRegionalResults, { relationName: 'optionResults' })
}));

export const surveyRegionalResultsRelations = relations(surveyRegionalResults, ({ one }) => ({
  survey: one(surveys, {
    fields: [surveyRegionalResults.surveyId],
    references: [surveys.id]
  }),
  option: one(surveyOptions, {
    fields: [surveyRegionalResults.optionId],
    references: [surveyOptions.id],
    relationName: 'optionResults'
  }),
  city: one(cities, {
    fields: [surveyRegionalResults.cityId],
    references: [cities.id]
  }),
  district: one(districts, {
    fields: [surveyRegionalResults.districtId],
    references: [districts.id]
  })
}));

export const districtsRelations = relations(districts, ({ one, many }) => ({
  city: one(cities, {
    fields: [districts.cityId],
    references: [cities.id]
  }),
  partyRelations: many(districtPartyRelations)
}));

export const citiesRelations = relations(cities, ({ many }) => ({
  districts: many(districts),
  services: many(citiesServices),
  projects: many(cityProjects),
  events: many(cityEvents),
  stats: many(cityStats),
  awards: many(cityAwards),
  partyRelations: many(cityPartyRelations)
}));

export const cityServicesRelations = relations(cityServices, ({ many }) => ({
  cities: many(citiesServices)
}));

export const citiesServicesRelations = relations(citiesServices, ({ one }) => ({
  city: one(cities, {
    fields: [citiesServices.cityId],
    references: [cities.id]
  }),
  service: one(cityServices, {
    fields: [citiesServices.serviceId],
    references: [cityServices.id]
  })
}));

export const cityProjectsRelations = relations(cityProjects, ({ one }) => ({
  city: one(cities, {
    fields: [cityProjects.cityId],
    references: [cities.id]
  })
}));

export const cityEventsRelations = relations(cityEvents, ({ one }) => ({
  city: one(cities, {
    fields: [cityEvents.cityId],
    references: [cities.id]
  })
}));

export const cityStatsRelations = relations(cityStats, ({ one }) => ({
  city: one(cities, {
    fields: [cityStats.cityId],
    references: [cities.id]
  })
}));

export const awardTypesRelations = relations(awardTypes, ({ many }) => ({
  awards: many(cityAwards)
}));

export const cityAwardsRelations = relations(cityAwards, ({ one }) => ({
  city: one(cities, {
    fields: [cityAwards.cityId],
    references: [cities.id]
  }),
  awardType: one(awardTypes, {
    fields: [cityAwards.awardTypeId],
    references: [awardTypes.id]
  }),
  project: one(cityProjects, {
    fields: [cityAwards.projectId],
    references: [cityProjects.id]
  })
}));

// Siyasi Parti İlişkileri
export const politicalPartiesRelations = relations(politicalParties, ({ one, many }) => ({
  performance: one(partyPerformance, {
    fields: [politicalParties.id],
    references: [partyPerformance.partyId]
  }),
  cityRelations: many(cityPartyRelations),
  districtRelations: many(districtPartyRelations)
}));

// Parti Performans İlişkileri
export const partyPerformanceRelations = relations(partyPerformance, ({ one }) => ({
  party: one(politicalParties, {
    fields: [partyPerformance.partyId],
    references: [politicalParties.id]
  })
}));

// Şehir-Parti İlişkileri
export const cityPartyRelationsRelations = relations(cityPartyRelations, ({ one }) => ({
  city: one(cities, {
    fields: [cityPartyRelations.cityId],
    references: [cities.id]
  }),
  party: one(politicalParties, {
    fields: [cityPartyRelations.partyId],
    references: [politicalParties.id]
  })
}));

// İlçe-Parti İlişkileri
export const districtPartyRelationsRelations = relations(districtPartyRelations, ({ one }) => ({
  district: one(districts, {
    fields: [districtPartyRelations.districtId],
    references: [districts.id]
  }),
  party: one(politicalParties, {
    fields: [districtPartyRelations.partyId],
    references: [politicalParties.id]
  })
}));