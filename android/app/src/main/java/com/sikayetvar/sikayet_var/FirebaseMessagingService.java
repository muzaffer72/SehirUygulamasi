package com.sikayetvar.sikayet_var;

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.media.RingtoneManager;
import android.net.Uri;
import android.os.Build;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.core.app.NotificationCompat;

import com.google.firebase.messaging.RemoteMessage;

import java.util.Map;

public class FirebaseMessagingService extends com.google.firebase.messaging.FirebaseMessagingService {
    private static final String TAG = "FCMService";
    private static final String CHANNEL_ID = "sikayet_var_channel";
    private static final String CHANNEL_NAME = "ŞikayetVar Bildirimleri";
    private static final String CHANNEL_DESC = "ŞikayetVar uygulaması için bildirim kanalı";

    @Override
    public void onMessageReceived(@NonNull RemoteMessage remoteMessage) {
        Log.d(TAG, "Bildirim alındı: " + remoteMessage.getFrom());

        // Bildirim verisi kontrolü
        Map<String, String> data = remoteMessage.getData();
        if (data.size() > 0) {
            Log.d(TAG, "Bildirim verisi: " + data);
            sendNotification(data);
        }

        // Bildirim içeriği kontrolü
        if (remoteMessage.getNotification() != null) {
            Log.d(TAG, "Bildirim mesajı: " + remoteMessage.getNotification().getBody());
            sendNotification(
                remoteMessage.getNotification().getTitle(), 
                remoteMessage.getNotification().getBody()
            );
        }
    }

    @Override
    public void onNewToken(@NonNull String token) {
        Log.d(TAG, "Yeni FCM token: " + token);
        // Token'ı sunucuya göndermek için FlutterFire'a ilet
        // Bu işlem Flutter tarafında yapılır
    }

    private void sendNotification(Map<String, String> data) {
        String title = data.get("title");
        String message = data.get("message");
        sendNotification(title, message);
    }

    private void sendNotification(String title, String messageBody) {
        Intent intent = new Intent(this, MainActivity.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
        PendingIntent pendingIntent = PendingIntent.getActivity(
            this, 0, intent,
            PendingIntent.FLAG_ONE_SHOT | PendingIntent.FLAG_IMMUTABLE
        );

        Uri defaultSoundUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION);
        NotificationCompat.Builder notificationBuilder =
                new NotificationCompat.Builder(this, CHANNEL_ID)
                        .setSmallIcon(R.drawable.ic_notification)
                        .setContentTitle(title)
                        .setContentText(messageBody)
                        .setAutoCancel(true)
                        .setSound(defaultSoundUri)
                        .setContentIntent(pendingIntent)
                        .setColor(getResources().getColor(R.color.primary));

        NotificationManager notificationManager =
                (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);

        // Android Oreo üstü için bildirim kanalı oluşturma
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel(
                    CHANNEL_ID,
                    CHANNEL_NAME,
                    NotificationManager.IMPORTANCE_HIGH);
            channel.setDescription(CHANNEL_DESC);
            channel.enableLights(true);
            channel.setLightColor(Color.BLUE);
            channel.enableVibration(true);
            notificationManager.createNotificationChannel(channel);
        }

        notificationManager.notify(0, notificationBuilder.build());
    }
}