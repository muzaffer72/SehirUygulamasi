// BU DOSYA DOĞRUDAN ANDROID KODUNDA YAPILACAK DEĞİŞİKLİĞİ GÖSTERİR
// C:\Users\guzel\AppData\Local\Pub\Cache\hosted\pub.dev\flutter_local_notifications-14.1.5\android\src\main\java\com\dexterous\flutterlocalnotifications\FlutterLocalNotificationsPlugin.java

// ***************************************************************************************
// ÖNEMLİ: Bu dosya, sorunlu dosyada bulunması gereken tam kodun bir örneğidir. 
// Lütfen FlutterLocalNotificationsPlugin.java dosyasını bir metin editörüyle açın ve
// aşağıdaki gibi düzenleyin.
// ***************************************************************************************

// ... diğer kodlar ...

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

    // HATA OLAN SATIR - ORİJİNAL KOD:
    // if (bigPictureStyleInformation.hideExpandedLargeIcon) {
    //     bigPictureStyle.bigLargeIcon(null);  // BURADA HATA VAR
    // }

    // DÜZELTME - BURAYI DEĞİŞTİRİN:
    if (bigPictureStyleInformation.hideExpandedLargeIcon) {
        bigPictureStyle.bigLargeIcon((android.graphics.Bitmap) null);  // TİP DÖNÜŞÜMÜ EKLENDİ
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

// ... diğer kodlar ...