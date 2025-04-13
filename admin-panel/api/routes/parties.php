<?php
/**
 * Siyasi partiler için API rotaları
 * 
 * Bu dosya, admin-panel/api/index.php içerisinden include edilir
 * ve api/parties/* URL'leri için gerekli işlemleri yapar
 */

// Admin panel için hazırlanmış fonksiyonları dahil et
require_once __DIR__ . '/admin_parties.php';

// URL yolunu ve HTTP metodunu al
$id = $segments[1] ?? null;
$action = $segments[2] ?? null;

// Rota işlemleri
switch ($method) {
    case 'GET':
        if ($id !== null && is_numeric($id)) {
            // GET /api/parties/1
            getPartyById($db, $id);
        } else {
            // GET /api/parties
            getParties($db);
        }
        break;
        
    case 'POST':
        if ($id === 'recalculate-stats') {
            // POST /api/parties/recalculate-stats
            recalculatePerformanceStats($db);
        } else {
            sendError("Endpoint bulunamadı", 404);
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
        sendError("Desteklenmeyen HTTP metodu: $method", 405);
}