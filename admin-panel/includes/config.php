<?php
/**
 * Uygulama yapılandırma dosyası
 * 
 * Bu dosya, uygulama genelinde kullanılan sabitler ve yapılandırma ayarlarını içerir.
 */

// Zaman dilimini ayarla
date_default_timezone_set('Europe/Istanbul');

// Hata raporlama ayarları
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// Uygulama sabitleri
define('APP_NAME', 'ŞikayetVar Admin Panel');
define('APP_VERSION', '1.0.0');
define('APP_URL', 'https://workspace.guzelimbatmanli.repl.co/admin-panel');
define('API_URL', 'https://workspace.guzelimbatmanli.repl.co/api');

// Firebase yapılandırması
define('FIREBASE_SERVER_KEY', getenv('FIREBASE_SERVER_KEY'));
define('FIREBASE_API_KEY', getenv('FIREBASE_API_KEY'));

// Sayfalama için varsayılan değerler
define('DEFAULT_PAGE_SIZE', 20);

// Dosya yükleme limitleri
define('MAX_UPLOAD_SIZE', 5 * 1024 * 1024); // 5MB
define('ALLOWED_IMAGE_TYPES', ['image/jpeg', 'image/png', 'image/gif']);

// Kullanıcı rolleri
define('ROLE_ADMIN', 'admin');
define('ROLE_EDITOR', 'editor');
define('ROLE_USER', 'user');
?>