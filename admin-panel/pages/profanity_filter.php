<?php
// Küfür ve hakaret filtresi sayfası

// Veritabanı bağlantısını yükle
require_once __DIR__ . '/../db_config.php';

// Yasaklı kelimeleri veritabanından çek
try {
    $stmt = $pdo->query("SELECT word FROM banned_words ORDER BY word");
    $bannedWordsResult = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    $bannedWords = [];
    foreach ($bannedWordsResult as $row) {
        $bannedWords[] = $row['word'];
    }
} catch (PDOException $e) {
    // Veritabanı bağlantı hatası - boş array ile devam et
    $bannedWords = [];
}

// Form gönderildi mi kontrolü
$message = '';
$type = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (isset($_POST['add_word'])) {
        // Yeni kelime ekleme
        $newWord = trim($_POST['new_word']);
        if (!empty($newWord)) {
            try {
                // Önce varsa kontrol et
                $checkStmt = $pdo->prepare("SELECT COUNT(*) FROM banned_words WHERE word = ?");
                $checkStmt->execute([$newWord]);
                $wordExists = $checkStmt->fetchColumn() > 0;
                
                if (!$wordExists) {
                    // Kelimeyi veritabanına ekle
                    $insertStmt = $pdo->prepare("INSERT INTO banned_words (word) VALUES (?)");
                    $insertStmt->execute([$newWord]);
                    
                    // Kelimeyi listeye de ekle (sayfa yenilenmeden önce görmek için)
                    $bannedWords[] = $newWord;
                    
                    $message = "\"$newWord\" yasaklı kelimeler listesine eklendi.";
                    $type = 'success';
                } else {
                    $message = "\"$newWord\" zaten yasaklı kelimeler listesinde bulunuyor.";
                    $type = 'warning';
                }
            } catch (PDOException $e) {
                $message = "Veritabanı hatası: " . $e->getMessage();
                $type = 'error';
            }
        } else {
            $message = "Lütfen bir kelime girin.";
            $type = 'error';
        }
    } elseif (isset($_POST['remove_word']) && isset($_POST['selected_words'])) {
        // Kelimeleri kaldırma
        $selectedWords = $_POST['selected_words'];
        $removedCount = 0;
        
        if (!empty($selectedWords)) {
            try {
                // Seçilen kelimeleri veritabanından sil
                foreach ($selectedWords as $word) {
                    $stmt = $pdo->prepare("DELETE FROM banned_words WHERE word = ?");
                    $stmt->execute([$word]);
                    $removedCount += $stmt->rowCount();
                }
                
                // Kelimeyi listeden de kaldır (sayfa yenilenmeden önce görmek için)
                $bannedWords = array_diff($bannedWords, $selectedWords);
                
                if ($removedCount > 0) {
                    $message = "$removedCount kelime yasaklı listeden kaldırıldı.";
                    $type = 'success';
                } else {
                    $message = "Hiçbir kelime listeden kaldırılamadı.";
                    $type = 'warning';
                }
            } catch (PDOException $e) {
                $message = "Veritabanı hatası: " . $e->getMessage();
                $type = 'error';
            }
        } else {
            $message = "Hiçbir kelime seçilmedi.";
            $type = 'warning';
        }
    } elseif (isset($_POST['test_filter'])) {
        // Filtreleme testi
        $testText = $_POST['test_text'];
        
        if (!empty($testText)) {
            $containsProfanity = false;
            $censoredText = $testText;
            
            foreach ($bannedWords as $word) {
                if (stripos($testText, $word) !== false) {
                    $containsProfanity = true;
                    // Yasaklı kelimeyi *** ile değiştir
                    $replacement = str_repeat('*', strlen($word));
                    $censoredText = str_ireplace($word, $replacement, $censoredText);
                }
            }
            
            if ($containsProfanity) {
                $message = "Test metni yasaklı kelimeler içeriyor. Sansürlenmiş metin: <br><strong>$censoredText</strong>";
                $type = 'warning';
            } else {
                $message = "Test metni yasaklı kelimeler içermiyor.";
                $type = 'success';
            }
        } else {
            $message = "Lütfen test için bir metin girin.";
            $type = 'error';
        }
    }
}

// Yasaklı kelimeleri alfabetik sırala
sort($bannedWords);
?>

<div class="container-fluid">
    <h1 class="h3 mb-4 text-gray-800">Küfür ve Hakaret Filtresi</h1>
    
    <?php if (!empty($message)): ?>
        <div class="alert alert-<?php 
            echo $type === 'success' ? 'success' : ($type === 'warning' ? 'warning' : 'danger'); 
        ?> alert-dismissible fade show" role="alert">
            <?php echo $message; ?>
            <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                <span aria-hidden="true">&times;</span>
            </button>
        </div>
    <?php endif; ?>
    
    <div class="row">
        <!-- Filtreleme Bilgisi -->
        <div class="col-lg-12 mb-4">
            <div class="card shadow mb-4">
                <div class="card-header py-3">
                    <h6 class="m-0 font-weight-bold text-primary">Filtre Hakkında</h6>
                </div>
                <div class="card-body">
                    <p>Bu filtre, kullanıcılar tarafından gönderilen yorumları ve içerikleri otomatik olarak denetler. Yasaklı kelimeler içeren içerikler otomatik olarak gizlenir ve moderatörlere bildirilir.</p>
                    <p>Sisteme yeni yasaklı kelimeler ekleyebilir, var olanları kaldırabilir ve filtrenin etkinliğini test edebilirsiniz.</p>
                </div>
            </div>
        </div>
        
        <!-- Yasaklı Kelimeler Listesi -->
        <div class="col-lg-6">
            <div class="card shadow mb-4">
                <div class="card-header py-3 d-flex flex-row align-items-center justify-content-between">
                    <h6 class="m-0 font-weight-bold text-primary">Yasaklı Kelimeler Listesi</h6>
                    <span class="badge badge-danger"><?php echo count($bannedWords); ?> kelime</span>
                </div>
                <div class="card-body">
                    <form method="post" action="">
                        <div class="form-group">
                            <div class="custom-control custom-checkbox small">
                                <input type="checkbox" class="custom-control-input" id="selectAll">
                                <label class="custom-control-label" for="selectAll">Tümünü Seç</label>
                            </div>
                        </div>
                        
                        <div class="banned-words-list">
                            <?php if (empty($bannedWords)): ?>
                                <p class="text-center">Yasaklı kelime bulunamadı.</p>
                            <?php else: ?>
                                <?php foreach ($bannedWords as $word): ?>
                                    <div class="custom-control custom-checkbox">
                                        <input type="checkbox" class="custom-control-input word-checkbox" id="word_<?php echo md5($word); ?>" name="selected_words[]" value="<?php echo htmlspecialchars($word); ?>">
                                        <label class="custom-control-label" for="word_<?php echo md5($word); ?>"><?php echo htmlspecialchars($word); ?></label>
                                    </div>
                                <?php endforeach; ?>
                            <?php endif; ?>
                        </div>
                        
                        <button type="submit" name="remove_word" class="btn btn-danger btn-icon-split mt-3">
                            <span class="icon text-white-50">
                                <i class="fas fa-trash"></i>
                            </span>
                            <span class="text">Seçilenleri Kaldır</span>
                        </button>
                    </form>
                </div>
            </div>
        </div>
        
        <!-- Filtreleme İşlemleri -->
        <div class="col-lg-6">
            <div class="card shadow mb-4">
                <div class="card-header py-3">
                    <h6 class="m-0 font-weight-bold text-primary">Yeni Kelime Ekle</h6>
                </div>
                <div class="card-body">
                    <form method="post" action="">
                        <div class="form-group">
                            <input type="text" class="form-control" name="new_word" placeholder="Yasaklanacak kelimeyi girin">
                        </div>
                        <button type="submit" name="add_word" class="btn btn-primary btn-icon-split">
                            <span class="icon text-white-50">
                                <i class="fas fa-plus"></i>
                            </span>
                            <span class="text">Kelime Ekle</span>
                        </button>
                    </form>
                </div>
            </div>
            
            <!-- Filtre Testi -->
            <div class="card shadow mb-4">
                <div class="card-header py-3">
                    <h6 class="m-0 font-weight-bold text-primary">Filtre Testi</h6>
                </div>
                <div class="card-body">
                    <form method="post" action="">
                        <div class="form-group">
                            <textarea class="form-control" name="test_text" rows="3" placeholder="Filtreyi test etmek için bir metin girin"></textarea>
                        </div>
                        <button type="submit" name="test_filter" class="btn btn-info btn-icon-split">
                            <span class="icon text-white-50">
                                <i class="fas fa-search"></i>
                            </span>
                            <span class="text">Metni Test Et</span>
                        </button>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
    // Tümünü seç/kaldır fonksiyonu
    const selectAllCheckbox = document.getElementById('selectAll');
    const wordCheckboxes = document.querySelectorAll('.word-checkbox');
    
    if (selectAllCheckbox) {
        selectAllCheckbox.addEventListener('change', function() {
            const isChecked = this.checked;
            
            wordCheckboxes.forEach(function(checkbox) {
                checkbox.checked = isChecked;
            });
        });
    }
    
    // Herhangi bir kutu değiştiğinde "Tümünü Seç" durumunu kontrol et
    wordCheckboxes.forEach(function(checkbox) {
        checkbox.addEventListener('change', function() {
            const allChecked = Array.from(wordCheckboxes).every(function(cb) {
                return cb.checked;
            });
            
            if (selectAllCheckbox) {
                selectAllCheckbox.checked = allChecked;
            }
        });
    });
});
</script>

<style>
.banned-words-list {
    max-height: 300px;
    overflow-y: auto;
    padding-right: 10px;
}
</style>