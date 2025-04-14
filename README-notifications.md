# ŞikayetVar - Firebase Bildirim Sistemi

Bu dokümantasyon, ŞikayetVar uygulamasında Firebase Cloud Messaging (FCM) kullanarak bildirim gönderme sisteminin nasıl çalıştığını açıklar.

## Bildirim Sistemi Özellikleri

- Push bildirimleri (anlık bildirimler)
- Bildirim hedefleri: tüm kullanıcılar, belirli kullanıcı veya belirli şehirdeki kullanıcılar
- Admin panelinden bildirim yönetimi
- Kullanıcı bazlı bildirim ayarları
- Bildirim geçmişi ve okundu/okunmadı durumu takibi

## Dosya Yapısı

### Android Tarafında

- `android/app/src/main/java/com/sikayetvar/sikayet_var/FirebaseMessagingService.java`: Android için FCM servis sınıfı
- `android/app/src/main/res/drawable/ic_notification.xml`: Bildirim ikonu
- `android/app/src/main/res/values/colors.xml`: Bildirim renkleri
- `android/app/google-services-template.json`: Firebase yapılandırma şablonu

### Flutter Tarafında

- `lib/services/firebase_service.dart`: Firebase çekirdek servisi
- `lib/services/firebase_notification_service.dart`: FCM ile ilgili tüm işlemleri yöneten servis
- `lib/services/notification_service.dart`: Uygulama için genel bildirim yönetim servisi
- `lib/models/notification_model.dart`: Bildirim veri modeli

### Sunucu Tarafında

- `admin-panel/pages/notifications.php`: Admin paneli bildirim yönetim sayfası
- `admin-panel/api/notifications.php`: Bildirim API'si
- `admin-panel/includes/functions.php`: Bildirim gönderme fonksiyonları

## Kullanım Kılavuzu

### 1. Firebase Projesi Kurulumu

1. Firebase Console'da (https://console.firebase.google.com/) yeni bir proje oluşturun
2. Android ve Web uygulamaları ekleyin
3. Firebase anahtarlarını Replit secrets olarak ekleyin:
   - FIREBASE_SERVER_KEY
   - FIREBASE_API_KEY

### 2. Android Yapılandırması

1. `android/app/google-services-template.json` dosyasını Firebase'den indirdiğiniz `google-services.json` ile değiştirin
2. Android paketini `com.sikayetvar.sikayet_var` olarak güncelleyin
3. `AndroidManifest.xml` izinlerini kontrol edin

### 3. Flutter Yapılandırması

1. `lib/main.dart` dosyasında Firebase servisini başlatma kodunu kontrol edin
2. `pubspec.yaml` dosyasında Firebase paketlerinin eklendiğinden emin olun

### 4. Bildirim Gönderme (Admin Panel)

1. Admin panelinde "Bildirimler" sayfasına gidin
2. "Yeni Bildirim Oluştur" formunu doldurun:
   - Başlık ve mesaj girin
   - Bildirim hedefini seçin (Tüm Kullanıcılar, Belirli Kullanıcı veya Belirli Şehir)
   - "Bildirim Gönder" düğmesine tıklayın

### 5. Bildirim Gönderme (API)

API üzerinden bildirim göndermek için:

```http
POST /api/notifications.php
Content-Type: application/json

{
  "title": "Bildirim Başlığı",
  "message": "Bildirim içeriği",
  "target_type": "all",  // all, user, city
  "target_id": null      // kullanıcı veya şehir ID'si
}
```

## Sorun Giderme

### Bildirim Gelmiyor

1. Firebase API anahtarlarını kontrol edin
2. Android cihazda bildirim izinlerinin verildiğinden emin olun
3. `adb shell dumpsys notification` komutuyla Android bildirim kanallarını kontrol edin
4. Logları kontrol edin:
   - Android logları: `adb logcat -s FCMService`
   - Sunucu logları: Error log içinde "Firebase" araması yapın

### Bildirim Görünmüyor

1. Bildirim kanalı ayarlarını kontrol edin
2. Bildirim ikonunun doğru yapılandırıldığından emin olun
3. Android 8+ için kanal izinlerini kontrol edin

## API Referansı

### Firebase Bildirim Servisi

```dart
// Firebase bildirim servisini başlatır
await FirebaseNotificationService.initialize();

// Belirli bir konuya abone olur
await FirebaseNotificationService.subscribeToTopic("topic_name");

// Bildirim token'ını sunucuya gönderir
// Bu işlem otomatik olarak gerçekleşir
```

### Bildirim Servisi

```dart
// Bildirim servisini başlatır
await NotificationService.initialize();

// Bildirim ekler (test için)
await NotificationService.addNotification(
  NotificationModel(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    title: "Test Bildirimi",
    message: "Bu bir test bildirimidir",
    timestamp: DateTime.now(),
    type: "test"
  )
);

// Bildirimi okundu olarak işaretler
await NotificationService.markAsRead("notification_id");

// Tüm bildirimleri okundu olarak işaretler
await NotificationService.markAllAsRead();
```