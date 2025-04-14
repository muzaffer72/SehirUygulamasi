<?php
/**
 * ŞikayetVar admin panel için yardımcı fonksiyonlar
 */

if (!function_exists('sendFirebaseNotification')) {
    /**
     * Firebase Cloud Messaging ile bildirim gönderir
     * 
     * @param string $title Bildirim başlığı
     * @param string $message Bildirim içeriği
     * @param string $target_type Hedef tipi ('all', 'user', 'city')
     * @param mixed $target_id Hedef ID (kullanıcı veya şehir ID'si)
     * @return bool Gönderim başarılı mı?
     */
    function sendFirebaseNotification($title, $message, $target_type = 'all', $target_id = null) {
        global $db_connection;
        
        // FCM API anahtarı
        $fcm_server_key = getenv('FIREBASE_SERVER_KEY');
        
        // Firebase API anahtarı yoksa, hata döndür
        if (empty($fcm_server_key)) {
            error_log("Firebase Server Key bulunamadı!");
            return false;
        }
        
        // FCM mesaj içeriği
        $notification = [
            'title' => $title,
            'body' => $message,
            'sound' => 'default',
            'badge' => '1',
            'icon' => 'ic_notification'
        ];
        
        // Ek veri alanları
        $data = [
            'title' => $title,
            'message' => $message,
            'type' => 'notification',
            'notification_id' => uniqid(),
            'timestamp' => time() * 1000,
            'target_type' => $target_type
        ];
        
        // Hedef ID'yi data kısmına ekle (eğer varsa)
        if (!empty($target_id)) {
            if ($target_type === 'user') {
                $data['user_id'] = $target_id;
            } else if ($target_type === 'city') {
                $data['city_id'] = $target_id;
            }
        }
        
        // Hedef türüne göre alıcıları belirle
        $to = null;
        $registration_ids = [];
        
        if ($target_type === 'all') {
            // Tüm kullanıcılara gönder (topic)
            $to = '/topics/all_users';
        } else if ($target_type === 'user' && !empty($target_id)) {
            // Belirli bir kullanıcıya gönder
            $query = "SELECT fcm_token FROM users WHERE id = $1 AND fcm_token IS NOT NULL";
            $result = pg_query_params($db_connection, $query, [$target_id]);
            
            if ($row = pg_fetch_assoc($result)) {
                $registration_ids[] = $row['fcm_token'];
            }
        } else if ($target_type === 'city' && !empty($target_id)) {
            // Belirli bir şehirdeki kullanıcılara gönder
            $to = '/topics/city_' . $target_id;
        }
        
        // FCM isteği için veri formatını oluştur
        $fields = [
            'notification' => $notification,
            'data' => $data,
            'android' => [
                'notification' => [
                    'sound' => 'default',
                    'icon' => 'ic_notification',
                    'color' => '#1976D2'
                ]
            ],
            'apns' => [
                'payload' => [
                    'aps' => [
                        'sound' => 'default'
                    ]
                ]
            ]
        ];
        
        // Hedef belirleme
        if (!empty($to)) {
            $fields['to'] = $to;
        } else if (!empty($registration_ids)) {
            $fields['registration_ids'] = $registration_ids;
        } else {
            // Hedef yoksa başarısız olarak işaretle
            return false;
        }
        
        // cURL isteği ile Firebase'e bildirim gönder
        $ch = curl_init();
        
        curl_setopt($ch, CURLOPT_URL, 'https://fcm.googleapis.com/fcm/send');
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_HTTPHEADER, [
            'Authorization: key=' . $fcm_server_key,
            'Content-Type: application/json'
        ]);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($fields));
        
        $result = curl_exec($ch);
        $http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        
        curl_close($ch);
        
        // Sonuçları logla
        error_log("Firebase bildirim gönderme sonucu: " . $result);
        
        // 200 OK yanıtı alındıysa başarılı kabul et
        return $http_code == 200;
    }
}

if (!function_exists('formatDate')) {
    /**
     * Tarihi Türkçe formata dönüştürür
     * 
     * @param string $date MySQL tarih formatı (Y-m-d H:i:s)
     * @param bool $showTime Saat gösterilsin mi?
     * @return string Formatlanmış tarih
     */
    function formatDate($date, $showTime = true) {
        if (empty($date)) {
            return '-';
        }
        
        $time = strtotime($date);
        $format = $showTime ? 'd.m.Y H:i' : 'd.m.Y';
        
        return date($format, $time);
    }
}

if (!function_exists('getStatusBadge')) {
    /**
     * Durum değeri için bootstrap badge HTML döndürür
     * 
     * @param string $status Durum değeri
     * @return string Badge HTML
     */
    function getStatusBadge($status) {
        $statusMap = [
            'active' => ['text' => 'Aktif', 'class' => 'success'],
            'pending' => ['text' => 'Beklemede', 'class' => 'warning'],
            'inactive' => ['text' => 'Pasif', 'class' => 'secondary'],
            'deleted' => ['text' => 'Silinmiş', 'class' => 'danger'],
            'solved' => ['text' => 'Çözüldü', 'class' => 'success'],
            'processing' => ['text' => 'İşleniyor', 'class' => 'primary'],
            'rejected' => ['text' => 'Reddedildi', 'class' => 'danger'],
            'error' => ['text' => 'Hata', 'class' => 'danger'],
            'sent' => ['text' => 'Gönderildi', 'class' => 'success']
        ];
        
        // Eğer durum haritada varsa, ilgili badge'i döndür
        if (isset($statusMap[$status])) {
            $statusInfo = $statusMap[$status];
            return '<span class="badge badge-' . $statusInfo['class'] . '">' . $statusInfo['text'] . '</span>';
        }
        
        // Varsayılan olarak durumu döndür
        return '<span class="badge badge-secondary">' . ucfirst($status) . '</span>';
    }
}

if (!function_exists('slugify')) {
    /**
     * Bir metni URL uyumlu slug formatına dönüştürür
     * 
     * @param string $text Dönüştürülecek metin
     * @return string Slug formatında metin
     */
    function slugify($text) {
        // Türkçe karakterleri dönüştür
        $text = str_replace(
            ['ı', 'ğ', 'ü', 'ş', 'ö', 'ç', 'İ', 'Ğ', 'Ü', 'Ş', 'Ö', 'Ç'], 
            ['i', 'g', 'u', 's', 'o', 'c', 'i', 'g', 'u', 's', 'o', 'c'], 
            $text
        );
        
        // Boşlukları tirelerle değiştir ve küçük harfe dönüştür
        $text = strtolower(trim($text));
        $text = preg_replace('/[^a-z0-9-]/', '-', $text);
        $text = preg_replace('/-+/', '-', $text);
        
        return trim($text, '-');
    }
}
?>