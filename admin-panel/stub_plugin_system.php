<?php
/**
 * Bu dosya, eklenti sistemini geçici olarak taklit eder (stub).
 * PostgreSQL uyumluluk sorunları giderilene kadar kullanılacaktır.
 */

// Boş fonksiyonlar ve değişkenler tanımla

function initPluginSystem() {
    // Şimdilik hiçbir şey yapma
}

function isPluginActive($db, $slug) {
    // Her zaman false döndür
    return false;
}

function getActivePlugins($db) {
    // Boş dizi döndür
    return [];
}

// Menü ve sayfa yönetimi için boş fonksiyonlar
$menu_items = [];
$page_routes = [];
$api_route_actions = [];

function add_menu_item($item) {
    // Şimdilik hiçbir şey yapma
}

function get_menu_items() {
    return [];
}

function add_page_route($page, $callback) {
    // Şimdilik hiçbir şey yapma
}

function get_page_route($page) {
    return null;
}

function add_action($hook, $callback) {
    // Şimdilik hiçbir şey yapma
}

function do_action($hook) {
    // Şimdilik hiçbir şey yapma
}

// PluginManager sınıfını taklit et
class PluginManager {
    public function __construct($db) {
        // Hiçbir şey yapma
    }
    
    public function load_active_plugins_files() {
        // Hiçbir şey yapma
    }
}

// Boş bir eklenti yöneticisi oluştur
$plugin_manager = new PluginManager(null);