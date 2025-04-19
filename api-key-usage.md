# ŞikayetVar API Anahtarı Kullanımı

Bu doküman, ŞikayetVar API'sinde API anahtarı kullanımı ile ilgili bilgileri içerir.

## API Anahtarı Nedir?

API anahtarı, uygulamanızın API'ye güvenli bir şekilde erişmesini sağlayan benzersiz bir tanımlayıcıdır. Bu anahtar, yetkisiz erişimleri önlemek ve API kullanımını izlemek için kullanılır.

## API Anahtarı Nasıl Alınır?

1. Admin paneline giriş yapın (`http://0.0.0.0:3001` adresinde çalışır)
2. Ayarlar sayfasına gidin
3. API Ayarları bölümünde "Yeni API Anahtarı Oluştur" butonuna tıklayın
4. Oluşturulan API anahtarını kopyalayın

## API Anahtarı Nasıl Kullanılır?

Flutter uygulamasında API anahtarını kullanmak için iki farklı yöntem vardır:

### 1. Dahili API Anahtarı Saklama Sistemi Üzerinden

Uygulamada oluşturulan "API Anahtarı Ayarları" ekranını kullanarak:

1. Uygulamada Ayarlar -> API Anahtarı Ayarları sayfasına gidin
2. Admin panelinden kopyaladığınız API anahtarını girin
3. "Kaydet" butonuna tıklayın

Bu işlemden sonra API anahtarı, uygulamanın SharedPreferences veritabanında güvenli bir şekilde saklanır ve tüm API isteklerinde otomatik olarak kullanılır.

### 2. Manuel Olarak API Anahtarını İsteklere Ekleme

Eğer doğrudan API anahtarını kullanmak isterseniz, HTTP isteklerinizde `X-API-KEY` başlığını ekleyin:

```dart
final response = await http.get(
  uri,
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'X-API-KEY': 'sizin_api_anahtariniz',
  },
);
```

## API İstek Formatı

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

## API Hatalarını Anlama

API anahtarı geçersiz veya eksik olduğunda:

- HTTP 401 Unauthorized yanıtı alırsınız
- Yanıt gövdesinde `{ "error": "Geçersiz API anahtarı" }` şeklinde bir hata mesajı olacaktır

Bu durumlarda:
1. API anahtarınızın doğru olduğundan emin olun
2. API anahtarının HTTP başlığında doğru şekilde gönderildiğini kontrol edin
3. Gerekirse admin panelinden yeni bir API anahtarı oluşturun