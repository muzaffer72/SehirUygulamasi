# ŞikayetVar API Entegrasyon Rehberi

Bu belge, ŞikayetVar API'sinin entegrasyon adımlarını ve mevcut endpoint'leri detaylı bir şekilde açıklar.

## 1. Genel Bakış

ŞikayetVar API sistemi, şu bileşenlerden oluşur:

1. **API Proxy** (`api-connect.js`): Tüm API isteklerini yönlendiren ve gerekli kimlik doğrulama kontrollerini yapan ana proxy sistemi.
2. **Eczane API** (`pharmacy_api.py`): Nöbetçi eczane verilerini sağlayan Python tabanlı API.
3. **Yeni API Endpointleri** (`new-api-endpoints/`): Kimlik doğrulama, içerik ve bildirim yönetimi için yeni geliştirilen API'ler.

## 2. API Entegrasyon Adımları

### 2.1. Bağımlılıkları Yükleme

```bash
# API sistemi için gerekli Node.js paketleri
npm install express cors pg bcrypt jsonwebtoken dotenv

# Eczane API için gerekli Python paketleri
pip install flask beautifulsoup4 requests
```

### 2.2. Yeni API Sistemini Entegre Etme

1. `api-connect.js` dosyasını güncelleyerek yeni API endpoint'lerini ekleyin:

```javascript
// Mevcut API yönlendirmelerine yeni API'leri ekle
if (req.url.startsWith('/auth/')) {
  targetUrl = `http://0.0.0.0:9000${req.url}`;
} else if (req.url.startsWith('/posts/')) {
  targetUrl = `http://0.0.0.0:9000${req.url}`;
} else if (req.url.startsWith('/comments/')) {
  targetUrl = `http://0.0.0.0:9000${req.url}`;
} else if (req.url.startsWith('/notifications/')) {
  targetUrl = `http://0.0.0.0:9000${req.url}`;
}
```

2. Yeni API sistemini başlatın:

```bash
cd new-api-endpoints
node index.js
```

## 3. API Endpoint'leri

### 3.1. Kimlik Doğrulama API'leri

| Endpoint | Method | Açıklama | Parametreler |
|----------|--------|----------|--------------|
| `/api/auth/login` | POST | Kullanıcı girişi | `username`, `password` veya `email`, `password` |
| `/api/auth/register` | POST | Kullanıcı kaydı | `username`, `email`, `password`, `name` (opsiyonel), `city_id` (opsiyonel), `district_id` (opsiyonel) |
| `/api/auth/profile` | GET | Profil bilgisi alma | Token gerekli |
| `/api/auth/profile` | PUT | Profil güncelleme | Token gerekli, `name`, `email`, `bio`, `city_id`, `district_id`, `profile_image_url` (herhangi biri) |
| `/api/auth/change-password` | PUT | Şifre değiştirme | Token gerekli, `current_password`, `new_password` |

### 3.2. İçerik (Şikayet) API'leri

| Endpoint | Method | Açıklama | Parametreler |
|----------|--------|----------|--------------|
| `/api/posts` | GET | Şikayetleri listele | `category_id`, `city_id`, `district_id`, `user_id`, `page`, `limit`, `sort_by`, `sort_order` (hepsi opsiyonel) |
| `/api/posts/:id` | GET | Şikayet detayı | `id` (URL parametresi) |
| `/api/posts` | POST | Şikayet oluştur | Token gerekli, `title`, `content`, `category_id`, `city_id`, `district_id` (opsiyonel), `latitude` (opsiyonel), `longitude` (opsiyonel), `media_urls` (opsiyonel) |
| `/api/posts/:id` | PUT | Şikayet güncelle | Token gerekli, `id` (URL parametresi), `title`, `content`, `category_id`, `status` (herhangi biri) |
| `/api/posts/:id` | DELETE | Şikayet sil | Token gerekli, `id` (URL parametresi) |
| `/api/posts/:id/like` | POST | Şikayeti beğen/beğeniyi kaldır | Token gerekli, `id` (URL parametresi) |

### 3.3. Yorum API'leri

| Endpoint | Method | Açıklama | Parametreler |
|----------|--------|----------|--------------|
| `/api/comments/post/:postId` | GET | Gönderi yorumlarını listele | `postId` (URL parametresi), `page`, `limit` (opsiyonel) |
| `/api/comments` | POST | Yorum ekle | Token gerekli, `post_id`, `content`, `parent_comment_id` (opsiyonel) |
| `/api/comments/:id` | PUT | Yorum düzenle | Token gerekli, `id` (URL parametresi), `content` |
| `/api/comments/:id` | DELETE | Yorum sil | Token gerekli, `id` (URL parametresi) |

### 3.4. Bildirim API'leri

| Endpoint | Method | Açıklama | Parametreler |
|----------|--------|----------|--------------|
| `/api/notifications` | GET | Bildirimleri listele | Token gerekli, `page`, `limit` (opsiyonel) |
| `/api/notifications/unread-count` | GET | Okunmamış bildirim sayısı | Token gerekli |
| `/api/notifications/:id/mark-read` | PUT | Bildirimi okundu işaretle | Token gerekli, `id` (URL parametresi) |
| `/api/notifications/mark-all-read` | PUT | Tüm bildirimleri okundu işaretle | Token gerekli |
| `/api/notifications/:id` | DELETE | Bildirimi sil | Token gerekli, `id` (URL parametresi) |
| `/api/notifications/all` | DELETE | Tüm bildirimleri sil | Token gerekli |
| `/api/notifications/settings` | GET | Bildirim ayarlarını al | Token gerekli |
| `/api/notifications/settings` | PUT | Bildirim ayarlarını güncelle | Token gerekli, `comments_enabled`, `likes_enabled`, `mentions_enabled`, `replies_enabled`, `system_notifications_enabled`, `marketing_notifications_enabled` (herhangi biri) |
| `/api/notifications/device/register` | POST | Cihaz kaydı (FCM) | Token gerekli, `token`, `device_type`, `device_name` (opsiyonel) |

### 3.5. Nöbetçi Eczane API'leri

| Endpoint | Method | Açıklama | Parametreler |
|----------|--------|----------|--------------|
| `/cities` | GET | Şehir listesi | Parametre yok |
| `/districts/:city_id` | GET | İlçe listesi | `city_id` (URL parametresi) |
| `/pharmacies` | GET | Nöbetçi eczaneler | `city` (zorunlu), `district` (opsiyonel), `lat`, `lng` (opsiyonel) |
| `/api/pharmacies/closest` | GET | En yakın eczaneler | `city` (zorunlu), `lat`, `lng` (zorunlu), `district` (opsiyonel), `limit` (opsiyonel) |

## 4. Kimlik Doğrulama

API'ye erişim için iki farklı kimlik doğrulama yöntemi kullanılmaktadır:

1. **API Anahtarı**: Tüm genel API istekleri için gereklidir. `X-API-Key` başlığında veya `api_key` query parametresinde gönderilmelidir.

2. **JWT Token**: Kullanıcı kimlik doğrulaması gerektiren işlemler için kullanılır. `/api/auth/login` veya `/api/auth/register` endpoint'lerinden alınan token, `Authorization` başlığında `Bearer {token}` formatında gönderilmelidir.

### 4.1. API Anahtarı Alma

API anahtarı, veritabanındaki `settings` tablosunda `api_key` anahtarı ile saklanır. Mevcut API anahtarı: `440bf0009c749943b440f7f5c6c2fd26`.

### 4.2. JWT Token Alma

```javascript
// Örnek Login İsteği
fetch('/api/auth/login', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'X-API-Key': '440bf0009c749943b440f7f5c6c2fd26'
  },
  body: JSON.stringify({
    username: 'kullanici',
    password: 'sifre123'
  })
}).then(res => res.json())
  .then(data => {
    // Token'ı kaydet
    localStorage.setItem('token', data.token);
  });
```

### 4.3. Token Kullanımı

```javascript
// Token ile istek örneği
fetch('/api/posts', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'X-API-Key': '440bf0009c749943b440f7f5c6c2fd26',
    'Authorization': `Bearer ${localStorage.getItem('token')}`
  },
  body: JSON.stringify({
    title: 'Başlık',
    content: 'İçerik',
    category_id: 1,
    city_id: 34
  })
}).then(res => res.json());
```

## 5. Hata Kodları

| Kod | Açıklama |
|-----|----------|
| 200 | Başarılı istek |
| 201 | Başarılı oluşturma işlemi |
| 400 | Geçersiz istek (eksik veya hatalı parametreler) |
| 401 | Kimlik doğrulama hatası (geçersiz API anahtarı veya token) |
| 403 | Yetki hatası (işlem için yetki yok) |
| 404 | Kayıt bulunamadı |
| 500 | Sunucu hatası |

## 6. Yanıt Formatı

Tüm API yanıtları aşağıdaki JSON formatındadır:

```json
{
  "status": "success" veya "error",
  "message": "İşlem açıklaması",
  "data": { ... } // Başarılı işlemlerde veri objesi
}
```

Hata durumunda:

```json
{
  "status": "error",
  "message": "Hata açıklaması",
  "details": "Detaylı hata mesajı" // Opsiyonel
}
```