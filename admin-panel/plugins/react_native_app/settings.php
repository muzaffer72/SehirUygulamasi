<?php
/**
 * React Native Mobil Uygulama Eklentisi - Ayarlar Dosyası
 */

// Eklenti ayarlarını yapılandırma
$plugin_settings = [
    'app_name' => [
        'label' => 'Uygulama Adı',
        'type' => 'text',
        'default' => 'ŞikayetVar',
        'description' => 'Mobil uygulamanın adı',
        'required' => true
    ],
    'app_version' => [
        'label' => 'Uygulama Versiyonu',
        'type' => 'text',
        'default' => '1.0.0',
        'description' => 'Mobil uygulamanın sürüm numarası',
        'required' => true
    ],
    'api_url' => [
        'label' => 'API URL',
        'type' => 'text',
        'default' => 'https://workspace.mail852.repl.co/api',
        'description' => 'Mobil uygulamanın bağlanacağı API URL adresi',
        'required' => true
    ],
    'primary_color' => [
        'label' => 'Ana Renk',
        'type' => 'text',
        'default' => '#1976d2',
        'description' => 'Uygulamanın ana rengi (HEX formatında)',
        'required' => true
    ],
    'enable_push_notifications' => [
        'label' => 'Push Bildirimleri',
        'type' => 'checkbox',
        'default' => '1',
        'description' => 'Push bildirimlerini etkinleştir',
        'required' => false
    ],
    'firebase_config' => [
        'label' => 'Firebase Konfigürasyonu',
        'type' => 'textarea',
        'default' => '{}',
        'description' => 'Firebase yapılandırması için JSON (push bildirimleri için)',
        'required' => false
    ],
    'map_type' => [
        'label' => 'Harita Tipi',
        'type' => 'select',
        'options' => [
            'google' => 'Google Maps',
            'mapbox' => 'Mapbox',
            'osm' => 'OpenStreetMap'
        ],
        'default' => 'google',
        'description' => 'Uygulamada kullanılacak harita servisi',
        'required' => true
    ],
    'google_maps_api_key' => [
        'label' => 'Google Maps API Anahtarı',
        'type' => 'text',
        'default' => '',
        'description' => 'Android için Google Maps API anahtarı',
        'required' => false
    ],
    'debug_mode' => [
        'label' => 'Debug Modu',
        'type' => 'checkbox',
        'default' => '1',
        'description' => 'Geliştirme aşamasında hata ayıklama özelliklerini aktifleştirir',
        'required' => false
    ],
    'features' => [
        'label' => 'Aktif Özellikler',
        'type' => 'textarea',
        'default' => 'complaints,surveys,pharmacies,profile',
        'description' => 'Uygulamada aktif olacak özellikler (virgülle ayrılmış liste)',
        'required' => true
    ]
];
?>