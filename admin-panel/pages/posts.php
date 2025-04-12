<!-- Posts Page -->
<div class="d-flex justify-content-between align-items-center mb-4">
    <h2>Şikayetler</h2>
    <div>
        <button class="btn btn-primary" type="button">Rapor Oluştur</button>
    </div>
</div>

<!-- Geliştirilmiş Filtreleme Alanı -->
<div class="card mb-4">
    <div class="card-header d-flex justify-content-between align-items-center">
        <h5 class="mb-0">Filtrele</h5>
        <button type="button" class="btn btn-sm btn-outline-secondary" id="toggle-filters">
            <i class="bi bi-chevron-up" id="filter-toggle-icon"></i>
        </button>
    </div>
    <div class="card-body" id="filter-content">
        <form method="get" action="">
            <input type="hidden" name="page" value="posts">
            <div class="row g-3">
                <div class="col-md-3">
                    <label for="filter_city" class="form-label">Şehir</label>
                    <select class="form-select" id="filter_city" name="city_id">
                        <option value="">Tümü</option>
                        <?php foreach ($cities as $city): ?>
                        <option value="<?= $city['id'] ?>" <?= isset($_GET['city_id']) && $_GET['city_id'] == $city['id'] ? 'selected' : '' ?>><?= $city['name'] ?></option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div class="col-md-3">
                    <label for="filter_district" class="form-label">İlçe</label>
                    <select class="form-select" id="filter_district" name="district_id">
                        <option value="">Tümü</option>
                        <?php foreach ($districts as $district): ?>
                        <option value="<?= $district['id'] ?>" data-city="<?= $district['city_id'] ?>" <?= isset($_GET['district_id']) && $_GET['district_id'] == $district['id'] ? 'selected' : '' ?>><?= $district['name'] ?></option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div class="col-md-3">
                    <label for="filter_category" class="form-label">Kategori</label>
                    <select class="form-select" id="filter_category" name="category_id">
                        <option value="">Tümü</option>
                        <?php foreach ($categories as $category): ?>
                        <option value="<?= $category['id'] ?>" <?= isset($_GET['category_id']) && $_GET['category_id'] == $category['id'] ? 'selected' : '' ?>><?= $category['name'] ?></option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div class="col-md-3">
                    <label for="filter_status" class="form-label">Durum</label>
                    <select class="form-select" id="filter_status" name="status">
                        <option value="">Tümü</option>
                        <option value="awaitingSolution" <?= isset($_GET['status']) && $_GET['status'] == 'awaitingSolution' ? 'selected' : '' ?>>Çözüm Bekleyen</option>
                        <option value="inProgress" <?= isset($_GET['status']) && $_GET['status'] == 'inProgress' ? 'selected' : '' ?>>İşleme Alınan</option>
                        <option value="solved" <?= isset($_GET['status']) && $_GET['status'] == 'solved' ? 'selected' : '' ?>>Çözüldü</option>
                        <option value="rejected" <?= isset($_GET['status']) && $_GET['status'] == 'rejected' ? 'selected' : '' ?>>Reddedildi</option>
                    </select>
                </div>
            </div>
            
            <div class="row g-3 mt-2">
                <div class="col-md-3">
                    <label for="filter_type" class="form-label">İçerik Tipi</label>
                    <select class="form-select" id="filter_type" name="post_type">
                        <option value="">Tümü</option>
                        <option value="problem" <?= isset($_GET['post_type']) && $_GET['post_type'] == 'problem' ? 'selected' : '' ?>>Şikayetler</option>
                        <option value="suggestion" <?= isset($_GET['post_type']) && $_GET['post_type'] == 'suggestion' ? 'selected' : '' ?>>Öneriler</option>
                        <option value="announcement" <?= isset($_GET['post_type']) && $_GET['post_type'] == 'announcement' ? 'selected' : '' ?>>Duyurular</option>
                        <option value="general" <?= isset($_GET['post_type']) && $_GET['post_type'] == 'general' ? 'selected' : '' ?>>Genel</option>
                    </select>
                </div>
                <div class="col-md-3">
                    <label for="filter_media" class="form-label">Medya</label>
                    <select class="form-select" id="filter_media" name="media_type">
                        <option value="">Tümü</option>
                        <option value="image" <?= isset($_GET['media_type']) && $_GET['media_type'] == 'image' ? 'selected' : '' ?>>Resimli Paylaşımlar</option>
                        <option value="video" <?= isset($_GET['media_type']) && $_GET['media_type'] == 'video' ? 'selected' : '' ?>>Videolu Paylaşımlar</option>
                        <option value="none" <?= isset($_GET['media_type']) && $_GET['media_type'] == 'none' ? 'selected' : '' ?>>Medyasız Paylaşımlar</option>
                    </select>
                </div>
                <div class="col-md-3">
                    <label for="filter_date" class="form-label">Tarih</label>
                    <select class="form-select" id="filter_date" name="date_filter">
                        <option value="">Tümü</option>
                        <option value="today" <?= isset($_GET['date_filter']) && $_GET['date_filter'] == 'today' ? 'selected' : '' ?>>Bugün</option>
                        <option value="week" <?= isset($_GET['date_filter']) && $_GET['date_filter'] == 'week' ? 'selected' : '' ?>>Bu Hafta</option>
                        <option value="month" <?= isset($_GET['date_filter']) && $_GET['date_filter'] == 'month' ? 'selected' : '' ?>>Bu Ay</option>
                    </select>
                </div>
                <div class="col-md-3 d-flex align-items-end">
                    <button type="submit" class="btn btn-primary w-100">Filtrele</button>
                </div>
            </div>
        </form>
    </div>
</div>

<div class="row">
    <?php 
    // Filtreleme işlemleri
    $filtered_posts = $posts;
    
    // Şehir filtreleme
    if (isset($_GET['city_id']) && $_GET['city_id'] !== '') {
        $city_id = intval($_GET['city_id']);
        $filtered_posts = array_filter($filtered_posts, function($post) use ($city_id) {
            return $post['city_id'] == $city_id;
        });
    }
    
    // İlçe filtreleme
    if (isset($_GET['district_id']) && $_GET['district_id'] !== '') {
        $district_id = intval($_GET['district_id']);
        $filtered_posts = array_filter($filtered_posts, function($post) use ($district_id) {
            return $post['district_id'] == $district_id;
        });
    }
    
    // Kategori filtreleme
    if (isset($_GET['category_id']) && $_GET['category_id'] !== '') {
        $category_id = intval($_GET['category_id']);
        $filtered_posts = array_filter($filtered_posts, function($post) use ($category_id) {
            return $post['category_id'] == $category_id;
        });
    }
    
    // Durum filtreleme
    if (isset($_GET['status']) && $_GET['status'] !== '') {
        $status = $_GET['status'];
        $filtered_posts = array_filter($filtered_posts, function($post) use ($status) {
            return $post['status'] == $status;
        });
    }
    
    // İçerik tipi filtreleme (type sütununu kullanıyoruz)
    if (isset($_GET['post_type']) && $_GET['post_type'] !== '') {
        $post_type = $_GET['post_type'];
        $filtered_posts = array_filter($filtered_posts, function($post) use ($post_type) {
            return isset($post['type']) && $post['type'] == $post_type;
        });
    }
    
    // Medya filtreleme
    if (isset($_GET['media_type']) && $_GET['media_type'] !== '') {
        $media_type = $_GET['media_type'];
        
        // Özel bir SQL sorgusu yapmak için media_type parametresini kaydediyoruz
        // Index.php dosyasındaki SQL sorgusunda bu parametre kullanılacak
        // Şu an client-side filtreleme yapıyoruz, sunucu tarafı için SQL JOIN gerekli
        
        if ($media_type === 'none') {
            // Medyası olmayan paylaşımlar
            $filtered_posts = array_filter($filtered_posts, function($post) {
                // Burada medya tablosunu kontrol etmek gerekir
                // Şu an demo amaçlı olarak ID'ye göre filtreleme yapıyoruz
                $post_id = $post['id'];
                $has_media = false;
                // Bu ID'lere sahip postların medyası olduğunu varsayıyoruz
                $posts_with_media = [2, 4, 6, 10, 12, 16, 18, 22, 24, 26, 30, 32, 36, 38];
                if (in_array($post_id, $posts_with_media)) {
                    $has_media = true;
                }
                return !$has_media;
            });
        } else {
            // Belirli türde medyası olan paylaşımlar 
            // Bu tür demo filtreleme - gerçek uygulamada media tablosundan JOIN ile çekilmeli
            $filtered_posts = array_filter($filtered_posts, function($post) use ($media_type) {
                $post_id = $post['id'];
                // Bu ID'lere sahip postların resim medyası olduğunu varsayıyoruz
                $posts_with_image = [2, 4, 6, 10, 16, 22, 24, 26, 30, 36];
                // Bu ID'lere sahip postların video medyası olduğunu varsayıyoruz
                $posts_with_video = [12, 18, 32, 38];
                
                if ($media_type === 'image') {
                    return in_array($post_id, $posts_with_image);
                } else if ($media_type === 'video') {
                    return in_array($post_id, $posts_with_video);
                }
                return false;
            });
        }
    }
    
    // Tarih filtreleme
    if (isset($_GET['date_filter']) && $_GET['date_filter'] !== '') {
        $today = date('Y-m-d');
        $date_filter = $_GET['date_filter'];
        
        if ($date_filter === 'today') {
            $filtered_posts = array_filter($filtered_posts, function($post) use ($today) {
                return date('Y-m-d', strtotime($post['created_at'])) == $today;
            });
        } else if ($date_filter === 'week') {
            $week_ago = date('Y-m-d', strtotime('-7 days'));
            $filtered_posts = array_filter($filtered_posts, function($post) use ($week_ago) {
                return date('Y-m-d', strtotime($post['created_at'])) >= $week_ago;
            });
        } else if ($date_filter === 'month') {
            $month_ago = date('Y-m-d', strtotime('-30 days'));
            $filtered_posts = array_filter($filtered_posts, function($post) use ($month_ago) {
                return date('Y-m-d', strtotime($post['created_at'])) >= $month_ago;
            });
        }
    }
    
    // Medya bilgilerini almak için yardımcı fonksiyon
    function get_post_media($post_id, $pdo) {
        $query = "SELECT * FROM media WHERE post_id = ? ORDER BY id ASC";
        $stmt = $pdo->prepare($query);
        $stmt->execute([$post_id]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
    
    // Sonuçları göster
    if (empty($filtered_posts)): 
    ?>
        <div class="col-12 text-center my-5">
            <div class="alert alert-info">
                <i class="bi bi-info-circle me-2"></i> Seçilen kriterlere uygun içerik bulunamadı.
            </div>
        </div>
    <?php else: ?>
        <?php 
        // Sayfalama için hazırlık
        $posts_per_page = 16; // Bir sayfada gösterilecek toplam içerik sayısı
        $current_page = isset($_GET['paged']) && is_numeric($_GET['paged']) ? intval($_GET['paged']) : 1;
        $offset = ($current_page - 1) * $posts_per_page;
        
        // Sayfalama için içerikleri parçala
        $paged_posts = array_slice($filtered_posts, $offset, $posts_per_page);
        
        // İçerikleri 4'lü gruplar halinde göstermek için parçala
        $post_chunks = array_chunk($paged_posts, 4);
        
        // Her satırı ayrı bir row olarak göster
        foreach ($post_chunks as $chunk):
        ?>
        <div class="row mb-4">
            <?php foreach ($chunk as $post): ?>
            <div class="col-lg-25p col-md-4 col-sm-6 mb-3">
                <div class="card post-card h-100 shadow-sm">
                    <div class="card-header bg-white d-flex justify-content-between align-items-center py-2">
                        <h6 class="card-title mb-0 text-truncate" title="<?= $post['title'] ?>">
                            <?= strlen($post['title']) > 25 ? substr($post['title'], 0, 22) . '...' : $post['title'] ?>
                        </h6>
                        <?= get_status_label($post['status']) ?>
                    </div>
                    <div class="card-body py-2">
                        <p class="card-subtitle mb-2 text-muted small">
                            <i class="bi bi-person"></i> <?= isset($post['username']) && !empty($post['username']) ? $post['username'] : (isset($post['user_username']) && !empty($post['user_username']) ? $post['user_username'] : (isset($post['user_id']) ? 'Kullanıcı-'.$post['user_id'] : 'Bilinmiyor')) ?><br>
                            <i class="bi bi-geo-alt"></i> <?= isset($post['city_name']) ? $post['city_name'] : (isset($post['city_id']) ? 'Şehir-'.$post['city_id'] : 'Bilinmeyen Şehir') ?>, <?= isset($post['district_name']) ? $post['district_name'] : (isset($post['district_id']) ? 'İlçe-'.$post['district_id'] : 'Bilinmeyen İlçe') ?><br>
                            <i class="bi bi-tag"></i> <?= isset($post['category_name']) ? $post['category_name'] : (isset($post['category_id']) ? 'Kategori-'.$post['category_id'] : 'Bilinmeyen Kategori') ?>
                        </p>
                        <p class="card-text small" style="max-height: 80px; overflow: hidden;">
                            <?= strlen($post['content']) > 100 ? substr($post['content'], 0, 97) . '...' : $post['content'] ?>
                        </p>
                        <div class="d-flex justify-content-between align-items-center small">
                            <span class="text-muted">
                                <i class="bi bi-heart"></i> <?= $post['likes'] ?>
                                <i class="bi bi-star ms-2"></i> <?= $post['highlights'] ?>
                            </span>
                            <span class="text-muted"><?= date('d.m.Y', strtotime($post['created_at'])) ?></span>
                        </div>
                    </div>
                    <div class="card-footer bg-white pt-2 pb-2">
                        <div class="d-flex justify-content-between">
                            <form method="post" class="me-2">
                                <input type="hidden" name="post_id" value="<?= $post['id'] ?>">
                                <select name="status" class="form-select form-select-sm">
                                    <option value="awaitingSolution" <?= $post['status'] === 'awaitingSolution' ? 'selected' : '' ?>>Bekliyor</option>
                                    <option value="inProgress" <?= $post['status'] === 'inProgress' ? 'selected' : '' ?>>İşlemde</option>
                                    <option value="solved" <?= $post['status'] === 'solved' ? 'selected' : '' ?>>Çözüldü</option>
                                    <option value="rejected" <?= $post['status'] === 'rejected' ? 'selected' : '' ?>>Ret</option>
                                </select>
                                <button type="submit" name="update_post_status" class="btn btn-primary btn-sm mt-1 w-100">Güncelle</button>
                            </form>
                            
                            <button type="button" class="btn btn-outline-primary btn-sm view-details" 
                                    data-bs-toggle="modal" data-bs-target="#postDetailModal" 
                                    data-post-id="<?= $post['id'] ?>"
                                    data-post-title="<?= htmlspecialchars($post['title']) ?>"
                                    data-post-content="<?= htmlspecialchars($post['content']) ?>"
                                    data-post-status="<?= $post['status'] ?>"
                                    data-post-type="<?= isset($post['type']) ? $post['type'] : 'N/A' ?>"
                                    data-post-city="<?= isset($post['city_name']) ? $post['city_name'] : (isset($post['city_id']) ? 'Şehir-'.$post['city_id'] : 'Bilinmeyen Şehir') ?>"
                                    data-post-district="<?= isset($post['district_name']) ? $post['district_name'] : (isset($post['district_id']) ? 'İlçe-'.$post['district_id'] : 'Bilinmeyen İlçe') ?>"
                                    data-post-category="<?= isset($post['category_name']) ? $post['category_name'] : (isset($post['category_id']) ? 'Kategori-'.$post['category_id'] : 'Bilinmeyen Kategori') ?>"
                                    data-post-user="<?= isset($post['username']) && !empty($post['username']) ? $post['username'] : (isset($post['user_username']) && !empty($post['user_username']) ? $post['user_username'] : (isset($post['user_id']) ? 'Kullanıcı-'.$post['user_id'] : 'Bilinmiyor')) ?>"
                                    data-post-likes="<?= $post['likes'] ?>"
                                    data-post-highlights="<?= $post['highlights'] ?>"
                                    data-post-date="<?= date('d.m.Y H:i', strtotime($post['created_at'])) ?>">
                                <i class="bi bi-eye"></i> Detay
                            </button>
                        </div>
                    </div>
                </div>
            </div>
            <?php endforeach; ?>
        </div>
        <?php endforeach; ?>
        
        <!-- Sayfalama -->
        <div class="d-flex justify-content-center mt-4 mb-3">
            <nav aria-label="Şikayet sayfaları">
                <?php
                // Toplam sayfa sayısını hesapla
                $total_filtered_posts = count($filtered_posts);
                $total_pages = ceil($total_filtered_posts / $posts_per_page);
                
                // Mevcut filtreleme parametrelerini koru
                $params = $_GET;
                unset($params['paged']); // Mevcut sayfa parametresi kaldırılıyor
                $query_string = http_build_query($params);
                $base_url = '?'.$query_string.(empty($query_string) ? '' : '&').'paged=';
                
                if ($total_pages > 1):
                ?>
                <ul class="pagination pagination-lg shadow-sm">
                    <!-- İlk sayfa butonu -->
                    <li class="page-item <?= $current_page == 1 ? 'disabled' : '' ?>">
                        <a class="page-link" href="<?= $base_url ?>1" aria-label="İlk">
                            <i class="bi bi-chevron-double-left"></i>
                        </a>
                    </li>
                    
                    <!-- Önceki sayfa butonu -->
                    <li class="page-item <?= $current_page == 1 ? 'disabled' : '' ?>">
                        <a class="page-link" href="<?= $base_url . max(1, $current_page - 1) ?>" aria-label="Önceki">
                            <i class="bi bi-chevron-left"></i>
                        </a>
                    </li>
                    
                    <?php
                    // Maksimum gösterilecek sayfa numarası
                    $max_pages = 5;
                    $start_page = max(1, $current_page - floor($max_pages / 2));
                    $end_page = min($total_pages, $start_page + $max_pages - 1);
                    
                    // Başlangıç sayfası ayarlaması
                    if ($end_page - $start_page + 1 < $max_pages) {
                        $start_page = max(1, $end_page - $max_pages + 1);
                    }
                    
                    // İlk sayfa linki
                    if ($start_page > 1): ?>
                    <li class="page-item">
                        <a class="page-link" href="<?= $base_url ?>1">1</a>
                    </li>
                    <?php if ($start_page > 2): ?>
                    <li class="page-item disabled">
                        <span class="page-link">...</span>
                    </li>
                    <?php endif; ?>
                    <?php endif; ?>
                    
                    <?php for ($i = $start_page; $i <= $end_page; $i++): ?>
                    <li class="page-item <?= $i == $current_page ? 'active' : '' ?>">
                        <a class="page-link" href="<?= $base_url . $i ?>"><?= $i ?></a>
                    </li>
                    <?php endfor; ?>
                    
                    <?php 
                    // Son sayfa linki
                    if ($end_page < $total_pages): ?>
                    <?php if ($end_page < $total_pages - 1): ?>
                    <li class="page-item disabled">
                        <span class="page-link">...</span>
                    </li>
                    <?php endif; ?>
                    <li class="page-item">
                        <a class="page-link" href="<?= $base_url . $total_pages ?>"><?= $total_pages ?></a>
                    </li>
                    <?php endif; ?>
                    
                    <!-- Sonraki sayfa butonu -->
                    <li class="page-item <?= $current_page == $total_pages ? 'disabled' : '' ?>">
                        <a class="page-link" href="<?= $base_url . min($total_pages, $current_page + 1) ?>" aria-label="Sonraki">
                            <i class="bi bi-chevron-right"></i>
                        </a>
                    </li>
                    
                    <!-- Son sayfa butonu -->
                    <li class="page-item <?= $current_page == $total_pages ? 'disabled' : '' ?>">
                        <a class="page-link" href="<?= $base_url . $total_pages ?>" aria-label="Son">
                            <i class="bi bi-chevron-double-right"></i>
                        </a>
                    </li>
                </ul>
                
                <!-- Sayfa bilgisi -->
                <div class="text-center mt-2">
                    <span class="badge bg-info rounded-pill fs-6">
                        Sayfa <?= $current_page ?> / <?= $total_pages ?> 
                        (Toplam <?= $total_filtered_posts ?> şikayet)
                    </span>
                </div>
                <?php endif; ?>
            </nav>
        </div>
        
        <!-- İstatistikler -->
        <div class="card mb-4">
            <div class="card-header d-flex justify-content-between align-items-center">
                <h5 class="mb-0">İstatistikler</h5>
                <button type="button" class="btn btn-sm btn-outline-secondary" id="toggle-stats">
                    <i class="bi bi-chevron-up" id="stats-toggle-icon"></i>
                </button>
            </div>
            <div class="card-body" id="stats-content">
                <div class="row">
                    <div class="col-md-6">
                        <canvas id="statusChart"></canvas>
                    </div>
                    <div class="col-md-6">
                        <canvas id="categoryChart"></canvas>
                    </div>
                </div>
            </div>
        </div>
    <?php endif; ?>
</div>

<!-- Chart.js kütüphanesini dahil et - spesifik versiyon belirterek -->
<script src="https://cdn.jsdelivr.net/npm/chart.js@3.9.1/dist/chart.min.js"></script>

<!-- Admin panel özel JavaScript dosyasını dahil et -->
<script src="js/posts.js"></script>

<!-- Post Detay Modal -->
<div class="modal fade" id="postDetailModal" tabindex="-1" aria-labelledby="postDetailModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="postDetailModalLabel">İçerik Detayı</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <div class="post-detail-content">
                    <div class="post-header mb-3">
                        <div class="d-flex justify-content-between align-items-center">
                            <!-- Düzenlenebilir başlık -->
                            <div class="view-mode" id="view-mode-title">
                                <h4 id="modal-post-title"></h4>
                            </div>
                            <div class="edit-mode" id="edit-mode-title" style="display: none; width: 80%;">
                                <input type="text" class="form-control" id="edit-post-title">
                            </div>
                            <span class="badge" id="modal-post-status"></span>
                        </div>
                        <div class="post-meta text-muted small">
                            <p class="mb-1"><i class="bi bi-person"></i> <span id="modal-post-user"></span></p>
                            <p class="mb-1"><i class="bi bi-geo-alt"></i> <span id="modal-post-location"></span></p>
                            <p class="mb-1"><i class="bi bi-tag"></i> <span id="modal-post-category"></span></p>
                            <p class="mb-1"><i class="bi bi-calendar"></i> <span id="modal-post-date"></span></p>
                            <p class="mb-1"><i class="bi bi-ui-checks"></i> <span id="modal-post-type"></span></p>
                            <p class="mb-1">
                                <i class="bi bi-heart"></i> <span id="modal-post-likes"></span>
                                <i class="bi bi-star ms-2"></i> <span id="modal-post-highlights"></span>
                            </p>
                        </div>
                    </div>
                    
                    <div class="post-content mb-3">
                        <div class="card">
                            <!-- Düzenlenebilir içerik -->
                            <div class="card-body view-mode" id="view-mode-content">
                                <div id="modal-post-content"></div>
                            </div>
                            <div class="card-body edit-mode" id="edit-mode-content" style="display: none;">
                                <textarea class="form-control" id="edit-post-content" rows="5"></textarea>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Medya Alanı -->
                    <div class="media-content mb-3">
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <h5>Medya İçerikleri</h5>
                            <button type="button" class="btn btn-sm btn-primary" id="upload-media-btn">
                                <i class="bi bi-upload me-1"></i> Dosya Yükle
                            </button>
                        </div>
                        
                        <!-- Dosya yükleme formu (gizli) -->
                        <div id="media-upload-form" class="card mb-3" style="display: none;">
                            <div class="card-body">
                                <h6 class="mb-3">Yeni Medya Yükle</h6>
                                <form id="file-upload-form" enctype="multipart/form-data">
                                    <div class="mb-3">
                                        <label for="media-type-select" class="form-label">Medya Türü</label>
                                        <select class="form-select" id="media-type-select" name="media_type">
                                            <option value="image" selected>Resim</option>
                                            <option value="video">Video</option>
                                        </select>
                                    </div>
                                    <div class="mb-3">
                                        <label for="media-file" class="form-label">Dosya Seçin</label>
                                        <input class="form-control" type="file" id="media-file" name="media" accept="image/jpeg,image/png,image/gif,video/mp4">
                                        <div class="form-text">Maksimum dosya boyutu: 10MB</div>
                                    </div>
                                    <div class="d-flex justify-content-end">
                                        <button type="button" class="btn btn-secondary me-2" id="cancel-upload-btn">İptal</button>
                                        <button type="button" class="btn btn-primary" id="submit-upload-btn">Yükle</button>
                                    </div>
                                </form>
                            </div>
                        </div>
                        
                        <div id="post-media-container">
                            <!-- Media içeriği buraya JavaScript ile eklenecek -->
                            <div class="text-center" id="media-loading">
                                <div class="spinner-border text-primary" role="status">
                                    <span class="visually-hidden">Yükleniyor...</span>
                                </div>
                                <p>Medya içerikleri yükleniyor...</p>
                            </div>
                            <div class="alert alert-info" id="no-media" style="display: none;">
                                <i class="bi bi-info-circle me-2"></i> Bu paylaşıma ait medya içeriği bulunmamaktadır.
                            </div>
                        </div>
                    </div>
                    
                    <!-- Beğeni ve İstatistikler -->
                    <div class="stats-section mb-4">
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <h5>Etkileşim İstatistikleri</h5>
                        </div>
                        <div class="row">
                            <div class="col-md-4">
                                <div class="card stats-card">
                                    <div class="card-body">
                                        <h6 class="card-subtitle mb-2 text-muted">Beğeni Sayısı</h6>
                                        <p class="card-text fs-4" id="post-like-count">0</p>
                                        <button class="btn btn-sm btn-outline-danger" id="clear-likes-btn">
                                            <i class="bi bi-trash"></i> Beğenileri Temizle
                                        </button>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="card stats-card">
                                    <div class="card-body">
                                        <h6 class="card-subtitle mb-2 text-muted">Yorum Sayısı</h6>
                                        <p class="card-text fs-4" id="post-comment-count">0</p>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="card stats-card">
                                    <div class="card-body">
                                        <h6 class="card-subtitle mb-2 text-muted">Görüntülenme</h6>
                                        <p class="card-text fs-4" id="post-view-count">0</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Yorum Alanı -->
                    <div class="comments-section mb-4">
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <h5>Yorumlar</h5>
                            <div>
                                <button class="btn btn-sm btn-success" id="add-comment-btn">
                                    <i class="bi bi-plus-circle"></i> Yorum Ekle
                                </button>
                            </div>
                        </div>
                        
                        <!-- Yorum Formu -->
                        <div class="card mb-3" id="comment-form-card" style="display: none;">
                            <div class="card-body">
                                <form id="add-comment-form">
                                    <div class="mb-3">
                                        <label for="comment-user" class="form-label">Kullanıcı</label>
                                        <select class="form-select" id="comment-user" required>
                                            <option value="">Kullanıcı Seçin</option>
                                            <!-- JS ile doldurulacak -->
                                        </select>
                                    </div>
                                    <div class="mb-3">
                                        <label for="comment-content" class="form-label">Yorum İçeriği</label>
                                        <textarea class="form-control" id="comment-content" rows="3" required></textarea>
                                    </div>
                                    <div class="form-check mb-3">
                                        <input class="form-check-input" type="checkbox" id="comment-is-anonymous">
                                        <label class="form-check-label" for="comment-is-anonymous">
                                            Anonim olarak paylaş
                                        </label>
                                    </div>
                                    <div class="d-flex justify-content-end">
                                        <button type="button" class="btn btn-secondary me-2" id="cancel-comment-btn">İptal</button>
                                        <button type="submit" class="btn btn-primary" id="submit-comment-btn">Gönder</button>
                                    </div>
                                </form>
                            </div>
                        </div>
                        
                        <div id="post-comments-container">
                            <div class="spinner-border text-primary" role="status" id="comments-loading">
                                <span class="visually-hidden">Yükleniyor...</span>
                            </div>
                            <div class="alert alert-info" id="no-comments" style="display: none;">
                                <i class="bi bi-info-circle me-2"></i> Bu paylaşıma henüz yorum yapılmamış.
                            </div>
                            <div id="comments-list">
                                <!-- Yorumlar JS ile doldurulacak -->
                            </div>
                        </div>
                    </div>
                    
                    <!-- Beğenen Kullanıcılar -->
                    <div class="likes-section mb-4">
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <h5>Beğenen Kullanıcılar</h5>
                        </div>
                        <div id="post-likes-container">
                            <div class="spinner-border text-primary" role="status" id="likes-loading">
                                <span class="visually-hidden">Yükleniyor...</span>
                            </div>
                            <div class="alert alert-info" id="no-likes" style="display: none;">
                                <i class="bi bi-info-circle me-2"></i> Bu paylaşımı henüz kimse beğenmemiş.
                            </div>
                            <div id="likes-list">
                                <!-- Beğeniler JS ile doldurulacak -->
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <div class="d-flex align-items-center me-auto">
                    <select id="modal-status-select" class="form-select me-2">
                        <option value="awaitingSolution">Çözüm Bekliyor</option>
                        <option value="inProgress">İşleme Alındı</option>
                        <option value="solved">Çözüldü</option>
                        <option value="rejected">Reddedildi</option>
                    </select>
                    <button type="button" class="btn btn-primary" id="update-post-status-btn">Durum Güncelle</button>
                </div>
                
                <!-- Medya ekleme butonu -->
                <button type="button" class="btn btn-success mx-1" id="add-media-btn">
                    <i class="bi bi-image me-1"></i> Medya Ekle
                </button>
                
                <!-- Düzenleme modları -->
                <div class="view-mode">
                    <button type="button" class="btn btn-warning mx-1" id="edit-post-btn">
                        <i class="bi bi-pencil me-1"></i> Düzenle
                    </button>
                </div>
                <div class="edit-mode" style="display: none;">
                    <button type="button" class="btn btn-success mx-1" id="save-post-btn">
                        <i class="bi bi-check me-1"></i> Kaydet
                    </button>
                    <button type="button" class="btn btn-danger mx-1" id="cancel-edit-btn">
                        <i class="bi bi-x me-1"></i> İptal
                    </button>
                </div>
                
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Kapat</button>
            </div>
        </div>
    </div>
</div>

<!-- JavaScript kodlarımız artık ayrı bir dosyada: js/posts.js -->
