# ŞikayetVar Uygulama API Endpoint Listesi

Bu belge, uygulamanın kullandığı tüm API endpoint'lerini ve durumlarını gösterir.

## 1. Mevcut API Endpoint'leri

### 1.1. API Proxy Tarafından Desteklenen Endpointler:
- `/api/cities` - Şehir listesi
- `/api/districts` - İlçe listesi (şehre göre)
- `/api/categories` - Kategori listesi
- `/api/posts` - İçerik/şikayet listesi
- `/api/users` - Kullanıcı listesi/işlemleri
- `/api/parties` - Parti listesi/performans (Mock veri ile)
- `/api/search_suggestions` - Arama önerileri
- `/api/pharmacies` - Nöbetçi eczaneler
- `/api/pharmacies/closest` - En yakın nöbetçi eczaneler

### 1.2. Pharmacy API (Python) Tarafından Desteklenen Endpointler:
- `/cities` - Şehir listesi
- `/districts/<city_id>` - İlçe listesi (şehre göre)
- `/pharmacies` - Nöbetçi eczaneler
- `/api/pharmacies` - Nöbetçi eczaneler (Geriye uyumlu)
- `/api/pharmacies/closest` - En yakın nöbetçi eczaneler

## 2. Eksik API Endpoint'leri Analizi

### 2.1. Kimlik Doğrulama ve Kullanıcı İşlemleri
- `/api/login` - Kullanıcı girişi endpointi eksik
- `/api/register` - Kullanıcı kaydı endpointi eksik
- `/api/logout` - Çıkış yapma endpointi eksik
- `/api/profile` - Profil bilgisi alma endpointi eksik
- `/api/profile/update` - Profil güncelleme endpointi eksik

### 2.2. İçerik ve Etkileşim Endpointleri
- `/api/posts/create` - Yeni şikayet oluşturma endpointi eksik
- `/api/posts/update` - Şikayet güncelleme endpointi eksik
- `/api/posts/delete` - Şikayet silme endpointi eksik
- `/api/comments` - Yorum listesi endpointi eksik
- `/api/comments/create` - Yorum oluşturma endpointi eksik
- `/api/likes` - Beğeni işlemleri endpointi eksik

### 2.3. Bildirim ve Mesajlaşma
- `/api/notifications` - Bildirimleri alma endpointi eksik
- `/api/notifications/mark-read` - Bildirimleri okundu işaretleme endpointi eksik
- `/api/messages` - Mesajlaşma endpointi eksik

### 2.4. Mobil Uygulamaya Özel
- `/api/device/register` - Cihaz kaydı endpointi eksik (bildirimler için)
- `/api/settings` - Uygulama ayarları endpointi eksik

## 3. Eklenmesi Gereken Öncelikli API Endpoint'leri

1. Kimlik doğrulama endpointleri: `/api/login`, `/api/register`, `/api/logout`
2. Profil işlemleri: `/api/profile`, `/api/profile/update`
3. İçerik oluşturma/düzenleme: `/api/posts/create`, `/api/comments/create`
4. Bildirim yönetimi: `/api/notifications`, `/api/notifications/mark-read`
5. Cihaz kaydı: `/api/device/register`