<?php
/**
 * Parti performans verilerini yeniden hesaplayan API endpoint
 * 
 * POST /api/admin/parties/recalculate-stats
 * Tüm partilerin performans istatistiklerini yeniden hesaplar
 */

// DB Bağlantısı
require_once __DIR__ . '/../db_connection.php';

// CORS ve içerik tipi ayarları
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json; charset=UTF-8");

// OPTIONS isteği ise, sadece CORS başlıklarını gönder ve çık
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Sadece POST isteklerini işle
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405); // Method Not Allowed
    echo json_encode(['error' => 'Sadece POST istekleri destekleniyor']);
    exit;
}

try {
    // Veritabanı bağlantısını kontrol et
    if (!$pdo) {
        throw new Exception("Veritabanı bağlantısı kurulamadı");
    }

    // İlk olarak tabloların var olup olmadığını kontrol et
    $tables = ['political_parties', 'party_performance', 'city_party_relations', 'district_party_relations'];
    $missingTables = [];

    foreach ($tables as $table) {
        $sql = "SELECT 1 FROM information_schema.tables WHERE table_name = :table";
        $stmt = $pdo->prepare($sql);
        $stmt->bindParam(':table', $table, PDO::PARAM_STR);
        $stmt->execute();
        
        if ($stmt->rowCount() === 0) {
            $missingTables[] = $table;
        }
    }

    // Eksik tablolar varsa oluştur
    if (!empty($missingTables)) {
        // SQL dosyasından tablo oluşturma sorgularını çalıştır
        $sqlPath = __DIR__ . '/../../create_party_tables.sql';
        
        if (file_exists($sqlPath)) {
            $sqlContent = file_get_contents($sqlPath);
            $pdo->exec($sqlContent);
            
            $response = [
                'success' => true,
                'message' => 'Parti tabloları başarıyla oluşturuldu ve veriler eklendi',
                'created_tables' => $missingTables
            ];
        } else {
            throw new Exception("SQL dosyası bulunamadı: $sqlPath");
        }
    } else {
        // Parti performans istatistiklerini yeniden hesapla
        // Veritabanında tanımladığımız calculate_party_performance() fonksiyonunu çağır
        $stmt = $pdo->query("SELECT calculate_party_performance()");
        
        // Son hesaplama zamanını güncelle
        $pdo->query("UPDATE party_performance SET last_updated = NOW()");
        
        // Güncel parti performans verilerini al
        $stmt = $pdo->query("SELECT p.name, p.short_name, pp.problem_solving_rate, pp.city_count, pp.district_count, pp.complaint_count, pp.solved_count 
                            FROM political_parties p
                            JOIN party_performance pp ON p.id = pp.party_id
                            ORDER BY pp.problem_solving_rate DESC");
        
        $updatedStats = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        $response = [
            'success' => true,
            'message' => 'Parti performans istatistikleri başarıyla güncellendi',
            'updated_at' => date('Y-m-d H:i:s'),
            'stats' => $updatedStats
        ];
    }
    
    // Başarılı yanıt
    http_response_code(200);
    echo json_encode($response);
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => 'Sunucu hatası', 'details' => $e->getMessage()]);
}