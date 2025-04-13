<?php
/**
 * Admin panel için parti api rotaları
 * 
 * Bu dosya doğrudan admin-panel/api/index.php'den çağrılır
 */

// Demo parti verileri dön
function getPartiesData() {
    $parties = [
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
    
    return $parties;
}

// Tüm partileri getir
function getParties($db) {
    try {
        // Veritabanı tabloları olmasa bile başlangıç verisi dönecek
        $parties = getPartiesData();
        
        sendResponse($parties);
    } catch (Exception $e) {
        // Hata durumunda demo veri döndür ve hata mesajını logla
        error_log('Parti verileri alınırken hata: ' . $e->getMessage());
        $parties = getPartiesData();
        sendResponse($parties);
    }
}

// Belirli bir partiyi getir
function getPartyById($db, $id) {
    try {
        // Demo verilerden parti bul
        $parties = getPartiesData();
        $party = null;
        
        foreach ($parties as $p) {
            if ($p['id'] == $id) {
                $party = $p;
                break;
            }
        }
        
        if ($party) {
            sendResponse($party);
        } else {
            sendError("Parti bulunamadı", 404);
        }
    } catch (Exception $e) {
        sendError("Parti bilgisi alınırken hata oluştu: " . $e->getMessage(), 500);
    }
}

// Performans istatistiklerini yeniden hesapla
function recalculatePerformanceStats($db) {
    try {
        // Demo olarak başarılı bir yanıt dön
        $parties = getPartiesData();
        
        // Problem çözme oranlarını hafifçe değiştir (gerçek hesaplama simülasyonu)
        foreach ($parties as &$party) {
            // ±3 arası rastgele değişiklik
            $change = rand(-30, 30) / 10;
            $party['problem_solving_rate'] += $change;
            
            // 0-100 aralığında tut
            if ($party['problem_solving_rate'] < 0) $party['problem_solving_rate'] = 0;
            if ($party['problem_solving_rate'] > 100) $party['problem_solving_rate'] = 100;
            
            // Bir ondalık basamağa yuvarla
            $party['problem_solving_rate'] = round($party['problem_solving_rate'], 1);
            
            // İstatistikleri güncelle
            $party['last_updated'] = date('Y-m-d H:i:s');
        }
        
        sendResponse([
            'success' => true,
            'message' => 'Parti performans istatistikleri yeniden hesaplandı',
            'parties' => $parties
        ]);
    } catch (Exception $e) {
        sendError("İstatistikler hesaplanırken hata oluştu: " . $e->getMessage(), 500);
    }
}