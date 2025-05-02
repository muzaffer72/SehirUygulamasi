<?php
/**
 * Nöbetçi Eczaneler Eklentisi Aktivasyon Dosyası
 * 
 * Bu dosya, eklenti etkinleştirildiğinde çalıştırılır.
 */

/**
 * Eklenti etkinleştirildiğinde çalıştırılacak fonksiyon
 */
function duty_pharmacies_activate($db) {
    // Aktivasyon işlemleri burada yapılabilir
    // Örneğin, eklenti için gerekli tabloları oluşturma
    
    // Eklenti ayarlarını varsayılan değerlerle kaydet
    $default_settings = [
        'google_maps_api_key' => '',
        'enable_directions' => true,
        'enable_proximity_search' => true,
        'max_results' => 20,
        'cache_time' => 3600,
        'display_phone' => true,
        'display_address' => true
    ];
    
    // Settings tablosuna ayarları ekle
    $settings_json = json_encode($default_settings);
    $db->query("INSERT INTO settings (name, value) VALUES ('pharmacy_settings', '" . $db->escape_string($settings_json) . "') ON CONFLICT (name) DO UPDATE SET value = '" . $db->escape_string($settings_json) . "'");
    
    // Web sayfalarına gerekli yönlendirmeleri ekle
    // ensure_mobile_pharmacy_page();
    
    // Bu fonksiyon, gerçek uygulamada mobil yönlendirmelerinin düzgün çalışmasını sağlar
    // Şimdilik bu işlemi atla
}