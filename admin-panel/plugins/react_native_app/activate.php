<?php
/**
 * React Native Mobil Uygulama Eklentisi Aktivasyon Dosyası
 * 
 * Bu dosya, eklenti etkinleştirildiğinde çalıştırılır.
 */

/**
 * Eklenti etkinleştirildiğinde çalıştırılacak fonksiyon
 */
function react_native_app_activate($db) {
    // Aktivasyon işlemleri burada yapılabilir
    // Örneğin, eklenti için gerekli tabloları oluşturma
    
    // Eklenti ayarlarını varsayılan değerlerle kaydet
    $default_settings = [
        'app_name' => 'ŞikayetVar',
        'app_version' => '1.0.0',
        'api_url' => 'https://workspace.mail852.repl.co/api',
        'primary_color' => '#1976d2',
        'features' => 'complaints,surveys,pharmacies,profile',
        'enable_push_notifications' => '1',
        'debug_mode' => '1'
    ];
    
    // Settings tablosuna ayarları ekle
    $settings_json = json_encode($default_settings);
    $db->query("INSERT INTO settings (name, value) VALUES ('react_native_app_settings', '" . $db->escape_string($settings_json) . "') ON CONFLICT (name) DO UPDATE SET value = '" . $db->escape_string($settings_json) . "'");
    
    // React Native proje klasörünü oluştur
    // ensure_react_native_project_folder();
    
    // Bu fonksiyon, gerçek uygulamada React Native proje klasörünün oluşturulmasını sağlar
    // Şimdilik bu işlemi atla, proje manuel olarak oluşturulacak
}