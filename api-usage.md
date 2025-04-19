# API Kullanım Kılavuzu

Bu doküman, ŞikayetVar API'sinin nasıl kullanılacağına dair temel bilgileri içerir.

## API Erişim Noktası

API'ye erişim için ana URL:
```
https://workspace.guzelimbatmanli.repl.co/api
```

## API Anahtarı

API'ye erişim için admin panelinde oluşturulan API anahtarını kullanmanız gerekir. Bu anahtarı HTTP isteklerinin başlık (header) kısmında şu şekilde göndermelisiniz:

```
X-API-KEY: sizin_api_anahtariniz
```

## Endpoint Formatı

API'ye istek yaparken iki farklı format kullanabilirsiniz:

### 1. Query String Formatı (Önerilen)

```
/api?endpoint=cities&id=5
```

Bu formatta:
- `endpoint` parametresi zorunludur ve hangi API kaynağına erişmek istediğinizi belirtir
- Diğer parametreler (`id`, `limit`, `offset` vb.) isteğe bağlıdır

### 2. Path Formatı (Eski Stil)

```
/api/cities/5
```

## Kullanılabilir Endpointler

Aşağıdaki API endpointleri kullanılabilir:

| Endpoint | Açıklama | Örnek URL |
|----------|----------|-----------|
| cities | Şehir listesi veya detayları | `/api?endpoint=cities` |
| districts | İlçe listesi veya detayları | `/api?endpoint=districts&city_id=34` |
| categories | Kategori listesi veya detayları | `/api?endpoint=categories` |
| posts | Şikayet/öneri listesi veya detayları | `/api?endpoint=posts&limit=10&offset=0` |
| users | Kullanıcı işlemleri | `/api?endpoint=users&id=15` |
| parties | Siyasi parti bilgileri | `/api?endpoint=parties` |
| search_suggestions | Arama önerileri | `/api?endpoint=search_suggestions&term=park` |

## Örnek İstekler

### Şehir listesini almak

```
GET /api?endpoint=cities
```

### Belirli bir şehrin detaylarını almak

```
GET /api?endpoint=cities&id=34
```

### Bir şehre ait ilçeleri almak

```
GET /api?endpoint=districts&city_id=34
```

### Şikayetleri listelemek

```
GET /api?endpoint=posts&limit=10&offset=0
```

### Yeni şikayet eklemek

```
POST /api?endpoint=posts

{
  "title": "Park sorunu",
  "content": "Mahallemizde yeşil alan eksikliği var.",
  "city_id": 34,
  "district_id": 397,
  "category_id": 5,
  "user_id": 42
}
```

## Hata Kodları

| Kod | Açıklama |
|-----|----------|
| 200 | Başarılı |
| 400 | Geçersiz istek |
| 401 | Yetkilendirme hatası |
| 404 | Kaynak bulunamadı |
| 500 | Sunucu hatası |

## API Dokümantasyonu

Daha detaylı API dokümantasyonu için Admin Panel > API Ayarları bölümüne bakabilirsiniz.