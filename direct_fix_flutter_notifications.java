/**
 * Bu dosya, flutter_local_notifications paketi için doğrudan düzeltme içerir.
 * 
 * KULLANIM:
 * 1. Bu dosyayı doğrudan aşağıdaki yola kopyalayın:
 *    C:\Users\guzel\AppData\Local\Pub\Cache\hosted\pub.dev\flutter_local_notifications-14.1.5\android\src\main\java\com\dexterous\flutterlocalnotifications\FlutterLocalNotificationsPlugin.java
 * 
 * 2. VEYA aşağıdaki düzeltmeyi belirtilen satıra uygulayın
 */

/* 1019. satırda - şu satırı bulun: */
bigPictureStyle.bigLargeIcon(null);

/* Ve aşağıdaki satırla değiştirin: */
bigPictureStyle.bigLargeIcon((Bitmap) null);

/* 
 * Bu düzeltme, bir belirsizlik giderir ve derleyiciye parametrenin Bitmap türünde
 * bir null olduğunu belirtir. Bu şekilde, hangi metot overload'ının kullanılacağı
 * konusundaki belirsizlik giderilmiş olur.
 */

// -----------------------------------------------------------------
// VEYA bu alternatif düzeltme kullanılabilir:
// -----------------------------------------------------------------

/**
 * Alternatif olarak, aşağıdaki çözümü uygulamak için pubspec.yaml dosyasını düzenleyin:
 * 1. pubspec.yaml dosyasında flutter_local_notifications paketini bulun
 * 2. Sürümü 13.0.0'a düşürün (veya 14.0.0'dan önceki bir sürüm)
 * 3. Aşağıdaki gibi güncelleyin:
 */

// pubspec.yaml'da:
// flutter_local_notifications: ^13.0.0  # 14.1.5 yerine