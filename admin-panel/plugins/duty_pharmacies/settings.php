<?php
/**
 * Nöbetçi Eczaneler Eklentisi - Ayarlar Dosyası
 */

// Eklenti ayarlarını yapılandırma
$plugin_settings = [
    'api_endpoint' => [
        'label' => 'API Endpoint',
        'type' => 'text',
        'default' => 'http://0.0.0.0:5001/pharmacies',
        'description' => 'Nöbetçi eczane verilerini alacağınız API adresi',
        'required' => true
    ],
    'google_maps_api_key' => [
        'label' => 'Google Maps API Anahtarı',
        'type' => 'text',
        'default' => '',
        'description' => 'Harita ve konum özellikleri için gerekli (opsiyonel)',
        'required' => false
    ],
    'display_count' => [
        'label' => 'Gösterilecek Eczane Sayısı',
        'type' => 'number',
        'default' => '10',
        'description' => 'Sayfada gösterilecek maksimum eczane sayısı',
        'required' => true
    ],
    'cache_time' => [
        'label' => 'Önbellek Süresi (dakika)',
        'type' => 'number',
        'default' => '60',
        'description' => 'Eczane verilerinin önbellekte saklanma süresi (dakika olarak)',
        'required' => true
    ],
    'show_distance' => [
        'label' => 'Mesafe Göster',
        'type' => 'checkbox',
        'default' => '1',
        'description' => 'Konum bilgisi varsa kullanıcıya eczane mesafesini göster',
        'required' => false
    ],
    'enable_directions' => [
        'label' => 'Yol Tarifi Etkinleştir',
        'type' => 'checkbox',
        'default' => '1',
        'description' => 'Google Maps entegrasyonu ile yol tarifi özelliğini etkinleştir',
        'required' => false
    ],
    'display_mode' => [
        'label' => 'Görüntüleme Modu',
        'type' => 'select',
        'options' => [
            'list' => 'Liste Görünümü',
            'map' => 'Harita Görünümü',
            'both' => 'İkisi Birlikte'
        ],
        'default' => 'both',
        'description' => 'Eczanelerin nasıl görüntüleneceği',
        'required' => true
    ]
];
?>