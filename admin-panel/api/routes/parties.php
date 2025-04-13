<?php
/**
 * Siyasi partiler için API rotaları
 * 
 * Bu dosya, admin-panel/api/index.php içerisinden include edilir
 * ve api/parties/* URL'leri için gerekli işlemleri yapar
 */

// URL yolunu parçala
$path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$pathParts = explode('/', $path);

// İlgili parçayı bul (index duruma göre değişebilir)
$routeIndex = array_search('parties', $pathParts);
$subRoute = $pathParts[$routeIndex + 1] ?? null;
$itemId = $pathParts[$routeIndex + 2] ?? null;

// HTTP metodunu al
$method = $_SERVER['REQUEST_METHOD'];

// Rota işlemleri
switch ($method) {
    case 'GET':
        if ($subRoute === null) {
            // GET /api/parties
            // Tüm partileri listele
            include_once __DIR__ . '/../get_parties.php';
        } elseif (is_numeric($subRoute)) {
            // GET /api/parties/1
            // Belirli bir partinin detaylarını getir
            $_SERVER['PATH_INFO'] = '/'. $subRoute;
            include_once __DIR__ . '/../get_parties.php';
        } else {
            http_response_code(404);
            echo json_encode(['error' => 'Endpoint bulunamadı']);
        }
        break;
        
    case 'POST':
        if ($subRoute === 'recalculate-stats') {
            // POST /api/parties/recalculate-stats
            // Parti performans istatistiklerini yeniden hesapla
            include_once __DIR__ . '/../recalculate_party_performance.php';
        } else {
            http_response_code(404);
            echo json_encode(['error' => 'Endpoint bulunamadı']);
        }
        break;
        
    case 'OPTIONS':
        // CORS ön kontrol istekleri için gerekli başlıkları ayarla
        header("Access-Control-Allow-Origin: *");
        header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
        header("Access-Control-Allow-Headers: Content-Type, Authorization");
        http_response_code(200);
        break;
        
    default:
        http_response_code(405); // Method Not Allowed
        echo json_encode(['error' => 'Desteklenmeyen HTTP metodu: ' . $method]);
        break;
}