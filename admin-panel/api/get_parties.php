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
    // Veritabanı bağlantısını kontrol et
    if (!isset($pdo) || !$pdo) {
        // Admin panel içinden çağrılıyorsa $conn kullan
        global $conn;
        if (isset($conn)) {
            $pdo = $conn;
        } else {
            throw new Exception("Veritabanı bağlantısı kurulamadı");
        }
    }

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
        $stmt->bindParam(':id', $partyId, PDO::PARAM_INT);
        $stmt->execute();
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
        $stmt->bindParam(':party_id', $partyId, PDO::PARAM_INT);
        $stmt->execute();
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

        // Tablo yoksa veya veri yoksa, demo verileri döndür
        if (empty($parties)) {
            $parties = getDemoParties();
        }
        
        // Başarılı yanıt
        http_response_code(200);
        echo json_encode($parties);
    }
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => 'Sunucu hatası', 'details' => $e->getMessage()]);
}

/**
 * Veritabanında parti verisi yoksa kullanılacak demo veriler
 */
function getDemoParties() {
    return [
        [
            'id' => 1,
            'name' => 'Adalet ve Kalkınma Partisi',
            'short_name' => 'AK Parti',
            'color' => '#FFA500',
            'logo_url' => 'assets/images/parties/akp.png',
            'problem_solving_rate' => 68.5,
            'city_count' => 45,
            'district_count' => 562,
            'complaint_count' => 12750,
            'solved_count' => 8734,
            'last_updated' => date('Y-m-d H:i:s')
        ],
        [
            'id' => 2,
            'name' => 'Cumhuriyet Halk Partisi',
            'short_name' => 'CHP',
            'color' => '#FF0000',
            'logo_url' => 'assets/images/parties/chp.png',
            'problem_solving_rate' => 71.2,
            'city_count' => 22,
            'district_count' => 234,
            'complaint_count' => 8540,
            'solved_count' => 6080,
            'last_updated' => date('Y-m-d H:i:s')
        ],
        [
            'id' => 3,
            'name' => 'Milliyetçi Hareket Partisi',
            'short_name' => 'MHP',
            'color' => '#FF4500',
            'logo_url' => 'assets/images/parties/mhp.png',
            'problem_solving_rate' => 57.8,
            'city_count' => 8,
            'district_count' => 102,
            'complaint_count' => 3240,
            'solved_count' => 1872,
            'last_updated' => date('Y-m-d H:i:s')
        ],
        [
            'id' => 4,
            'name' => 'İyi Parti',
            'short_name' => 'İYİ Parti',
            'color' => '#1E90FF',
            'logo_url' => 'assets/images/parties/iyi.png',
            'problem_solving_rate' => 63.4,
            'city_count' => 3,
            'district_count' => 25,
            'complaint_count' => 980,
            'solved_count' => 621,
            'last_updated' => date('Y-m-d H:i:s')
        ],
        [
            'id' => 5,
            'name' => 'Demokratik Sol Parti',
            'short_name' => 'DSP',
            'color' => '#FF69B4',
            'logo_url' => 'assets/images/parties/dsp.png',
            'problem_solving_rate' => 52.1,
            'city_count' => 1,
            'district_count' => 5,
            'complaint_count' => 320,
            'solved_count' => 167,
            'last_updated' => date('Y-m-d H:i:s')
        ],
        [
            'id' => 6,
            'name' => 'Yeniden Refah Partisi',
            'short_name' => 'YRP',
            'color' => '#006400',
            'logo_url' => 'assets/images/parties/yrp.png',
            'problem_solving_rate' => 44.3,
            'city_count' => 0,
            'district_count' => 3,
            'complaint_count' => 85,
            'solved_count' => 38,
            'last_updated' => date('Y-m-d H:i:s')
        ],
    ];
}