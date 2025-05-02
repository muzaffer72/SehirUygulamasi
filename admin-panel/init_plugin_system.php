<?php
/**
 * Eklenti sistemini başlatır
 * 
 * Bu dosya, eklenti sisteminin düzgün çalışması için gerekli fonksiyonları tanımlar.
 */

/**
 * Eklenti sistemini başlatır
 */
function initPluginSystem() {
    global $db, $plugin_manager;
    
    // Eklenti yöneticisini zaten oluşturduysak yeniden oluşturma
    if (isset($plugin_manager)) {
        return;
    }
    
    // PostgreSQL uyumlu plugin manager'ı dahil et
    require_once __DIR__ . '/pg_plugin_manager.php';
    
    // Eklenti sistemini başlat
    $plugin_manager->load_active_plugins_files();
    
    // Menüleri yükle
    $admin_menu = get_menu_items();
}