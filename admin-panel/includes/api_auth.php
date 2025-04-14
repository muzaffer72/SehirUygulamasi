<?php
/**
 * API Kimlik Doğrulama
 * 
 * Bu dosya, API isteklerinin kimlik doğrulamasını sağlar.
 */

/**
 * API isteklerini doğrular
 * 
 * @return bool Kimlik doğrulama başarılı mı?
 */
function checkApiAuth() {
    // Header'dan API anahtarını al
    $api_key = isset($_SERVER['HTTP_X_API_KEY']) ? $_SERVER['HTTP_X_API_KEY'] : null;
    
    // Eğer API anahtarı yoksa veya geçersizse, hata döndür
    if (!$api_key || $api_key !== getenv('API_KEY')) {
        header('Content-Type: application/json');
        http_response_code(401);
        echo json_encode([
            'success' => false,
            'message' => 'Unauthorized'
        ]);
        exit;
    }
    
    return true;
}

/**
 * Sunucuya gelen isteklerin CORS politikasını yapılandırır
 */
function configureCors() {
    // İzin verilen kaynaklar
    $allowed_origins = [
        'https://workspace.guzelimbatmanli.repl.co',
        'http://localhost:3000',
        'http://localhost:5000'
    ];
    
    // İstemcinin origin'ini al
    $origin = isset($_SERVER['HTTP_ORIGIN']) ? $_SERVER['HTTP_ORIGIN'] : '';
    
    // Eğer izin verilen bir kaynak ise, CORS header'larını ekle
    if (in_array($origin, $allowed_origins)) {
        header("Access-Control-Allow-Origin: $origin");
        header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
        header("Access-Control-Allow-Headers: Content-Type, X-API-Key");
        header("Access-Control-Allow-Credentials: true");
    }
    
    // Options isteği ise (preflight), işlemi sonlandır
    if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
        exit(0);
    }
}

// CORS yapılandırması
configureCors();
?>