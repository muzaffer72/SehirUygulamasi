package com.sikayetvar.sikayet_var;

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.media.RingtoneManager;
import android.net.Uri;
import android.os.Build;
import androidx.core.app.NotificationCompat;
import androidx.core.app.NotificationManagerCompat;

import com.google.firebase.messaging.RemoteMessage;

import io.flutter.Log;

public class FirebaseMessagingService extends com.google.firebase.messaging.FirebaseMessagingService {
    private static final String TAG = "FCMService";
    private static final String CHANNEL_ID = "sikayetvar_channel";
    private static final String CHANNEL_NAME = "ŞikayetVar Bildirimleri";
    private static final String CHANNEL_DESC = "ŞikayetVar uygulaması bildirimleri";

    @Override
    public void onMessageReceived(RemoteMessage remoteMessage) {
        super.onMessageReceived(remoteMessage);
        
        Log.d(TAG, "From: " + remoteMessage.getFrom());
        
        // Verileri kontrol et
        if (remoteMessage.getData().size() > 0) {
            Log.d(TAG, "Mesaj verileri: " + remoteMessage.getData());
        }

        // Bildirim içeriğini kontrol et
        if (remoteMessage.getNotification() != null) {
            Log.d(TAG, "Mesaj Bildirimi Başlık: " + remoteMessage.getNotification().getTitle());
            Log.d(TAG, "Mesaj Bildirimi İçerik: " + remoteMessage.getNotification().getBody());
            
            sendNotification(
                remoteMessage.getNotification().getTitle(),
                remoteMessage.getNotification().getBody()
            );
        }
    }

    @Override
    public void onNewToken(String token) {
        Log.d(TAG, "Yeni FCM token: " + token);
        // Token'ı sunucuya gönderme işlemi Flutter tarafında yapılacak
    }

    private void sendNotification(String title, String messageBody) {
        Intent intent = new Intent(this, MainActivity.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
        PendingIntent pendingIntent = PendingIntent.getActivity(this, 0, intent,
                PendingIntent.FLAG_IMMUTABLE);

        // Bildirim kanal oluşturma (Android 8.0+)
        createNotificationChannel();

        Uri defaultSoundUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION);
        NotificationCompat.Builder notificationBuilder =
                new NotificationCompat.Builder(this, CHANNEL_ID)
                        .setSmallIcon(R.drawable.ic_notification)
                        .setContentTitle(title)
                        .setContentText(messageBody)
                        .setAutoCancel(true)
                        .setSound(defaultSoundUri)
                        .setContentIntent(pendingIntent)
                        .setPriority(NotificationCompat.PRIORITY_HIGH);

        NotificationManagerCompat notificationManager = NotificationManagerCompat.from(this);
        
        // Bildirim izni kontrolü gerçek projeye göre düzenlenebilir
        try {
            notificationManager.notify(0, notificationBuilder.build());
        } catch (SecurityException e) {
            Log.e(TAG, "Bildirim gönderme izni yok: " + e.getMessage());
        }
    }

    private void createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel(
                    CHANNEL_ID,
                    CHANNEL_NAME,
                    NotificationManager.IMPORTANCE_HIGH
            );
            channel.setDescription(CHANNEL_DESC);
            
            NotificationManager notificationManager = getSystemService(NotificationManager.class);
            notificationManager.createNotificationChannel(channel);
        }
    }
}