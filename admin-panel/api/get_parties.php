<?php
/**
 * Siyasi partileri döndüren API endpoint
 * 
 * GET /api/parties
 * Tüm partileri ve performans istatistiklerini döndürür
 * 
 * GET /api/parties/:id
 * Belirli bir partinin detaylarını döndürür
 */

// DB Bağlantısı
require_once __DIR__ . '/../db_connection.php';

// CORS ve içerik tipi ayarları
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json; charset=UTF-8");

// OPTIONS isteği ise, sadece CORS başlıklarını gönder ve çık
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Sadece GET isteklerini işle
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405); // Method Not Allowed
    echo json_encode(['error' => 'Sadece GET istekleri destekleniyor']);
    exit;
}

// URL path'inden parti ID'sini kontrol et (eğer varsa)
$path = $_SERVER['PATH_INFO'] ?? '';
$pathParts = array_filter(explode('/', $path));
$partyId = $pathParts[1] ?? null;

try {
    // Veritabanı bağlantısını kullan
    global $db;
    if (!isset($db)) {
        throw new Exception("Veritabanı bağlantısı kurulamadı");
    }
    // PDO bağlantısı için adaptörü yükle
    require_once '../includes/pg_pdo.php';
    $pdo = get_pdo_connection();

    // Parti bilgilerini al
    if ($partyId !== null) {
        // Belirli bir partinin detaylarını getir
        $sql = "SELECT p.*, 
                pp.city_count, pp.district_count, pp.complaint_count, 
                pp.solved_count, pp.problem_solving_rate, pp.last_updated
                FROM political_parties p
                LEFT JOIN party_performance pp ON p.id = pp.party_id
                WHERE p.id = :id";
        
        $stmt = $pdo->prepare($sql);
        $stmt->execute([':id' => $partyId]);
        $party = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$party) {
            http_response_code(404);
            echo json_encode(['error' => 'Parti bulunamadı']);
            exit;
        }
        
        // İlgili şehir ve ilçe bilgilerini getir
        $sql = "SELECT c.id, c.name 
                FROM cities c
                JOIN city_party_relations cpr ON c.id = cpr.city_id
                WHERE cpr.party_id = :party_id AND cpr.is_current = TRUE";
        
        $stmt = $pdo->prepare($sql);
        $stmt->execute([':party_id' => $partyId]);
        $party['cities'] = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        // Başarılı yanıt
        http_response_code(200);
        echo json_encode($party);
    } else {
        // Tüm partileri getir (performans bilgileriyle birlikte)
        $sql = "SELECT p.*, 
                pp.city_count, pp.district_count, pp.complaint_count, 
                pp.solved_count, pp.problem_solving_rate, pp.last_updated
                FROM political_parties p
                LEFT JOIN party_performance pp ON p.id = pp.party_id
                ORDER BY pp.problem_solving_rate DESC";
        
        $stmt = $pdo->query($sql);
        $parties = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        // Veri yoksa boş dizi döndür
        if (empty($parties)) {
            $parties = [];
        }
        
        // Başarılı yanıt
        http_response_code(200);
        echo json_encode($parties);
    }
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => 'Sunucu hatası', 'details' => $e->getMessage()]);
}