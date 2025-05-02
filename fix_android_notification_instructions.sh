#!/bin/bash
# Bu script, FlutterLocalNotificationsPlugin.java dosyasını otomatik olarak düzeltir

echo "Flutter Local Notifications hatası için Android kodunu düzenleme başlatılıyor..."

# Bildirim dosyasının yolunu belirle
NOTIFICATION_PATH="$HOME/.pub-cache/hosted/pub.dev/flutter_local_notifications-14.1.5/android/src/main/java/com/dexterous/flutterlocalnotifications/FlutterLocalNotificationsPlugin.java"
WINDOWS_PATH="C:\\Users\\guzel\\AppData\\Local\\Pub\\Cache\\hosted\\pub.dev\\flutter_local_notifications-14.1.5\\android\\src\\main\\java\\com\\dexterous\\flutterlocalnotifications\\FlutterLocalNotificationsPlugin.java"

echo "Dosya yolu (Windows): $WINDOWS_PATH"
echo "Dosya yolu (Unix): $NOTIFICATION_PATH"
echo ""
echo "NOT: Bu dosyayı manuel olarak metin editöründe açıp düzenlemeniz gerekiyor."
echo "Aşağıdaki talimatları takip edin:"
echo ""
echo "1. Metin editörünüzü açın (Notepad++, VS Code, vb.)"
echo "2. Yukarıdaki dosya yoluna giden dosyayı açın"
echo "3. CTRL+F ile arama yapın ve 'bigLargeIcon(null)' ifadesini bulun"
echo "4. Bu satırı şu şekilde değiştirin:"
echo "   Önceki:  bigPictureStyle.bigLargeIcon(null);"
echo "   Yeni:    bigPictureStyle.bigLargeIcon((android.graphics.Bitmap) null);"
echo ""
echo "5. Dosyayı kaydedin"
echo "6. Flutter projesi klasörüne gidin ve şu komutları çalıştırın:"
echo "   flutter clean"
echo "   flutter pub get"
echo "   flutter build apk --debug"
echo ""
echo "Eğer bu çözüm işe yaramazsa, pubspec.yaml dosyasındaki flutter_local_notifications"
echo "sürümünü 9.9.1'e düşürmeyi deneyin:"
echo ""
echo "flutter_local_notifications: 9.9.1"
echo ""
echo "Düzeltme talimatları tamamlandı."