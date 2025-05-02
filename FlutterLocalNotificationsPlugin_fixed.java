/*
 * Copyright (C) 2017 Dexterous, Inc.
 * Sorunlu kodun düzeltmesiyle ilgili kısım
 * bigPictureStyle.bigLargeIcon(null) satırının düzeltilmesi
 */

    private void configureNotificationStyle(Notification.Builder notificationBuilder, NotificationStyle notificationStyle, Map<String, Object> styleInformation) {
        if (styleInformation != null) {
            if (notificationStyle == NotificationStyle.BigPicture) {
                configureBigPictureStyle(notificationBuilder, styleInformation);
            } else if (notificationStyle == NotificationStyle.BigText) {
                configureBigTextStyle(notificationBuilder, styleInformation);
            } else if (notificationStyle == NotificationStyle.Inbox) {
                configureInboxStyle(notificationBuilder, styleInformation);
            } else if (notificationStyle == NotificationStyle.Messaging) {
                configureMessagingStyle(notificationBuilder, styleInformation);
            } else if (notificationStyle == NotificationStyle.Media) {
                configureMediaStyle(notificationBuilder, styleInformation);
            }
        }
    }

    private void configureBigPictureStyle(Notification.Builder notificationBuilder, Map<String, Object> styleInformation) {
        BigPictureStyleInformation bigPictureStyleInformation = BigPictureStyleInformation.fromMap(styleInformation);
        Notification.BigPictureStyle bigPictureStyle = new Notification.BigPictureStyle();
        if (bigPictureStyleInformation.contentTitle != null) {
            CharSequence contentTitle = HtmlUtils.fromHtml(bigPictureStyleInformation.contentTitle);
            bigPictureStyle = bigPictureStyle.setBigContentTitle(contentTitle);
        }
        if (bigPictureStyleInformation.summaryText != null) {
            CharSequence summaryText = HtmlUtils.fromHtml(bigPictureStyleInformation.summaryText);
            bigPictureStyle = bigPictureStyle.setSummaryText(summaryText);
        }

        if (bigPictureStyleInformation.hideExpandedLargeIcon) {
            // ÖNEMLİ: Sorunlu satır - düzeltilmiş versiyonu:
            bigPictureStyle.bigLargeIcon((Bitmap) null);
        }
        
        if (bigPictureStyleInformation.largeIcon != null) {
            if (bigPictureStyleInformation.largeIcon instanceof byte[]) {
                bigPictureStyle.bigLargeIcon(getBitmapFromSource(bigPictureStyleInformation.largeIcon, styleInformation));
            }
        }

        if (bigPictureStyleInformation.bigPicture != null) {
            if (bigPictureStyleInformation.bigPicture instanceof byte[]) {
                bigPictureStyle.bigPicture(getBitmapFromSource(bigPictureStyleInformation.bigPicture, styleInformation));
            }
        }

        notificationBuilder.setStyle(bigPictureStyle);
    }

// Bu dosya, FlutterLocalNotificationsPlugin.java dosyasındaki sorunlu kısmı düzeltilmiş şekliyle gösterir.
// Düzeltilmiş satır: bigPictureStyle.bigLargeIcon((Bitmap) null); şeklindedir.
// Bu satır bigLargeIcon metodu çağrısında kullanılan null değerin Bitmap türünde olduğunu belirtir.