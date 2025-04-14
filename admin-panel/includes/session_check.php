<?php
/**
 * Admin Panel için oturum kontrolü
 * 
 * Bu dosya, admin paneline erişim için oturum kontrolü yapar.
 * Eğer kullanıcı oturum açmamışsa, login sayfasına yönlendirir.
 */

// Oturum başlat
session_start();

// Eğer bu dosya, index.php veya login.php'den başka bir sayfada çağrılıyorsa ve
// kullanıcı giriş yapmamışsa, giriş sayfasına yönlendir
$current_page = basename($_SERVER['PHP_SELF']);
$allowed_pages = ['index.php', 'login.php'];

if (!in_array($current_page, $allowed_pages) && (!isset($_SESSION['user_id']) || empty($_SESSION['user_id']))) {
    // Kullanıcı girişi yapılmamış, giriş sayfasına yönlendir
    header('Location: login.php');
    exit;
}

// Admin paneline erişim kontrolü
if (isset($_SESSION['user_role']) && $_SESSION['user_role'] !== 'admin') {
    // Sadece admin rolündeki kullanıcılar erişebilir
    header('Location: ../index.php?error=no_permission');
    exit;
}
?>