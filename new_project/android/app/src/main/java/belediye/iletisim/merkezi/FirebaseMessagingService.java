package belediye.iletisim.merkezi;

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.media.RingtoneManager;
import android.net.Uri;
import android.os.Build;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.core.app.NotificationCompat;

import com.google.firebase.messaging.RemoteMessage;

import java.util.Map;

public class FirebaseMessagingService extends com.google.firebase.messaging.FirebaseMessagingService {
    private static final String TAG = "FirebaseMsgService";
    private static final String CHANNEL_ID = "high_importance_channel";

    @Override
    public void onMessageReceived(@NonNull RemoteMessage remoteMessage) {
        try {
            Log.d(TAG, "Bildirim alındı. Kaynak: " + remoteMessage.getFrom());
    
            // Kontrol: veri yükü var mı?
            if (remoteMessage.getData().size() > 0) {
                Log.d(TAG, "Mesaj veri yükü: " + remoteMessage.getData());
                Map<String, String> data = remoteMessage.getData();
                
                // Önce title/message kontrolü, sonra body kontrolü yap
                String title = data.get("title");
                String message = data.get("message");
                String body = data.get("body");
                
                // message ve body alanlarını birlikte kontrol et
                if (title != null) {
                    if (message != null) {
                        sendNotification(title, message, data);
                    } else if (body != null) {
                        // Bazı FCM mesajlarında body kullanılıyor olabilir
                        sendNotification(title, body, data);
                    } else {
                        // Başlık var ama mesaj yok
                        sendNotification(title, "Yeni bildirim", data);
                    }
                } else if (data.containsKey("notification_id")) {
                    // Eğer title yoksa ama bildirim ID'si varsa, varsayılan başlık kullan
                    String content = message != null ? message : (body != null ? body : "Yeni bildirim");
                    sendNotification("Belediye İletişim", content, data);
                }
            }
    
            // Kontrol: bildirim yükü var mı?
            if (remoteMessage.getNotification() != null) {
                RemoteMessage.Notification notification = remoteMessage.getNotification();
                Log.d(TAG, "Bildirim gövdesi: " + notification.getBody());
                
                String title = notification.getTitle();
                String body = notification.getBody();
                
                if (title != null || body != null) {
                    sendNotification(title, body, remoteMessage.getData());
                }
            }
        } catch (Exception e) {
            Log.e(TAG, "Bildirim işlenirken beklenmeyen hata: " + e.getMessage());
        }
    }

    @Override
    public void onNewToken(@NonNull String token) {
        Log.d(TAG, "Refreshed token: " + token);
        // Token'ı sunucuya gönderme işlemi Flutter tarafında yapılacak
    }

    private void sendNotification(String title, String messageBody, Map<String, String> data) {
        Intent intent = new Intent(this, MainActivity.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
        
        // Veri ekleyelim (null check ekleyerek)
        if (data != null) {
            for (Map.Entry<String, String> entry : data.entrySet()) {
                intent.putExtra(entry.getKey(), entry.getValue());
            }
        }
        
        // Bildirime tıklanınca açılacak
        PendingIntent pendingIntent = PendingIntent.getActivity(this, 0, intent,
                PendingIntent.FLAG_IMMUTABLE);

        // Bildirim sesi
        Uri defaultSoundUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION);
        
        // Bildirim oluştur
        NotificationCompat.Builder notificationBuilder =
                new NotificationCompat.Builder(this, CHANNEL_ID)
                        .setSmallIcon(android.R.drawable.ic_dialog_info)
                        .setContentTitle(title != null ? title : "Belediye İletişim")
                        .setContentText(messageBody != null ? messageBody : "Yeni bildirim")
                        .setAutoCancel(true)
                        .setSound(defaultSoundUri)
                        .setPriority(NotificationCompat.PRIORITY_HIGH)
                        .setContentIntent(pendingIntent);

        NotificationManager notificationManager =
                (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);

        // Android Oreo ve üstü için bildirim kanalı oluştur
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel(
                    CHANNEL_ID,
                    "Belediye İletişim Bildirimleri",
                    NotificationManager.IMPORTANCE_HIGH);
            channel.setDescription("Belediye iletişim bildirimleri");
            channel.enableVibration(true);
            notificationManager.createNotificationChannel(channel);
        }

        // Benzersiz bildirim ID'si oluştur
        int notificationId = 0;
        if (data != null && data.containsKey("notification_id")) {
            try {
                notificationId = Integer.parseInt(data.get("notification_id"));
            } catch (NumberFormatException e) {
                Log.e(TAG, "Bildirim ID'si sayıya çevrilemedi: " + e.getMessage());
                // Hash kodunu kullanarak benzersiz bir ID oluştur
                notificationId = (data.get("notification_id")).hashCode();
            }
        }

        // Bildirimi göster
        notificationManager.notify(notificationId, notificationBuilder.build());
    }
}