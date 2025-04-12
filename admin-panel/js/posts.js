// Global olarak aktif post ID'sini takip etmek için değişken
let currentPostId = null;
// Beğeni ve yorum listelerini global olarak tutuyoruz
let currentPostLikes = [];
let currentPostComments = [];

// İstatistik grafikleri için fonksiyon
function initializeCharts() {
    // İstatistik grafiklerini göster
    const ctx1 = document.getElementById('statusChart');
    const ctx2 = document.getElementById('categoryChart');

    if (ctx1 && ctx2) {
        // Durum grafiği
        new Chart(ctx1, {
            type: 'pie',
            data: {
                labels: ['Çözüm Bekliyor', 'İşleme Alındı', 'Çözüldü', 'Reddedildi'],
                datasets: [{
                    label: 'Durum Dağılımı',
                    data: [35, 28, 17, 8],
                    backgroundColor: [
                        'rgba(255, 193, 7, 0.8)',
                        'rgba(13, 110, 253, 0.8)',
                        'rgba(25, 135, 84, 0.8)',
                        'rgba(220, 53, 69, 0.8)'
                    ],
                    borderColor: [
                        'rgba(255, 193, 7, 1)',
                        'rgba(13, 110, 253, 1)',
                        'rgba(25, 135, 84, 1)',
                        'rgba(220, 53, 69, 1)'
                    ],
                    borderWidth: 1
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: {
                        position: 'bottom',
                    },
                    title: {
                        display: true,
                        text: 'İçerik Durumu Dağılımı'
                    }
                }
            }
        });

        // Kategori grafiği
        new Chart(ctx2, {
            type: 'bar',
            data: {
                labels: ['Altyapı', 'Çevre', 'Ulaşım', 'Güvenlik', 'Sağlık', 'Diğer'],
                datasets: [{
                    label: 'Kategori Dağılımı',
                    data: [22, 17, 25, 10, 12, 8],
                    backgroundColor: [
                        'rgba(13, 110, 253, 0.8)',
                        'rgba(25, 135, 84, 0.8)',
                        'rgba(255, 193, 7, 0.8)',
                        'rgba(220, 53, 69, 0.8)',
                        'rgba(111, 66, 193, 0.8)',
                        'rgba(108, 117, 125, 0.8)'
                    ],
                    borderWidth: 1
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: {
                        display: false
                    },
                    title: {
                        display: true,
                        text: 'Kategori Bazlı Dağılım'
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true
                    }
                }
            }
        });
    }
    
    // İstatistik panelini açılır/kapanır yapma
    const toggleStatsBtn = document.getElementById('toggle-stats');
    const statsContent = document.getElementById('stats-content');
    const statsToggleIcon = document.getElementById('stats-toggle-icon');
    
    if (toggleStatsBtn && statsContent) {
        toggleStatsBtn.addEventListener('click', function() {
            if (statsContent.style.display === 'none') {
                statsContent.style.display = 'block';
                statsToggleIcon.classList.remove('bi-chevron-down');
                statsToggleIcon.classList.add('bi-chevron-up');
            } else {
                statsContent.style.display = 'none';
                statsToggleIcon.classList.remove('bi-chevron-up');
                statsToggleIcon.classList.add('bi-chevron-down');
            }
        });
    }
}

// Ana sayfa işlevleri için fonksiyon
function initializePostsPage() {
    // Filtre panelini açılır/kapanır yapmak için
    const toggleFiltersBtn = document.getElementById('toggle-filters');
    const filterContent = document.getElementById('filter-content');
    const filterToggleIcon = document.getElementById('filter-toggle-icon');
    
    if (toggleFiltersBtn && filterContent) {
        // İlk durumu ayarlamak için kod ekleyelim
        filterContent.style.display = filterContent.style.display || 'block';
        
        console.log('Filtreleme toggle butonu bulundu');
        toggleFiltersBtn.addEventListener('click', function() {
            console.log('Filtreleme toggle butonuna tıklandı');
            console.log('Mevcut display durumu:', filterContent.style.display);
            
            if (filterContent.style.display === 'none') {
                filterContent.style.display = 'block';
                filterToggleIcon.classList.remove('bi-chevron-down');
                filterToggleIcon.classList.add('bi-chevron-up');
                console.log('Filtreleme içeriği gösterildi');
            } else {
                filterContent.style.display = 'none';
                filterToggleIcon.classList.remove('bi-chevron-up');
                filterToggleIcon.classList.add('bi-chevron-down');
                console.log('Filtreleme içeriği gizlendi');
            }
        });
    } else {
        console.error('Filtreleme elemanları bulunamadı:', { toggleFiltersBtn, filterContent });
    }
    
    // Pagination linklerini düzenle - özel stil ekleyerek daha belirgin yap
    const paginationLinks = document.querySelectorAll('.pagination .page-link');
    paginationLinks.forEach(link => {
        link.classList.add('fw-bold');
        
        const icon = link.querySelector('i');
        if (icon) {
            // Daha büyük fontlu ikonlar için
            icon.classList.add('fs-5');
        }
    });
    
    // İlçe filtresini şehire göre filtreleme
    const citySelect = document.getElementById('filter_city');
    const districtSelect = document.getElementById('filter_district');
    
    if (citySelect && districtSelect) {
        citySelect.addEventListener('change', function() {
            const selectedCityId = this.value;
            const districtOptions = districtSelect.querySelectorAll('option');
            
            // Önce tüm ilçeleri gizle
            districtOptions.forEach(option => {
                if (option.value === '') {
                    option.style.display = 'block'; // "Tümü" seçeneği her zaman görünür
                } else {
                    option.style.display = 'none';
                }
            });
            
            // Seçilen şehre ait ilçeleri göster
            if (selectedCityId !== '') {
                districtOptions.forEach(option => {
                    if (option.dataset.city === selectedCityId) {
                        option.style.display = 'block';
                    }
                });
            } else {
                // Eğer "Tümü" seçiliyse, tüm ilçeleri göster
                districtOptions.forEach(option => {
                    option.style.display = 'block';
                });
            }
            
            // İlçe seçimini sıfırla
            districtSelect.value = '';
        });
    }
    
    // Post detay modalı işlevselliği
    const postDetailModal = document.getElementById('postDetailModal');
    if (postDetailModal) {
        postDetailModal.addEventListener('show.bs.modal', function(event) {
            const button = event.relatedTarget;
            const postId = button.getAttribute('data-post-id');
            const postTitle = button.getAttribute('data-post-title');
            const postContent = button.getAttribute('data-post-content');
            const postStatus = button.getAttribute('data-post-status');
            const postType = button.getAttribute('data-post-type');
            const postCity = button.getAttribute('data-post-city');
            const postDistrict = button.getAttribute('data-post-district');
            const postCategory = button.getAttribute('data-post-category');
            const postUser = button.getAttribute('data-post-user');
            const postLikes = button.getAttribute('data-post-likes');
            const postHighlights = button.getAttribute('data-post-highlights');
            const postDate = button.getAttribute('data-post-date');
            
            // Global post ID'sini güncelle
            currentPostId = postId;
            
            // Düzenleme formlarını da güncelle
            document.getElementById('edit-post-title').value = postTitle;
            document.getElementById('edit-post-content').value = postContent;
            
            // Modal içeriğini doldur
            document.getElementById('modal-post-title').textContent = postTitle;
            document.getElementById('modal-post-content').textContent = postContent;
            document.getElementById('modal-post-user').textContent = postUser;
            document.getElementById('modal-post-location').textContent = `${postCity}, ${postDistrict}`;
            document.getElementById('modal-post-category').textContent = postCategory;
            document.getElementById('modal-post-date').textContent = postDate;
            document.getElementById('modal-post-type').textContent = getPostTypeText(postType);
            document.getElementById('modal-post-likes').textContent = postLikes;
            document.getElementById('modal-post-highlights').textContent = postHighlights;
            
            // Durum badgei güncelle
            const statusBadge = document.getElementById('modal-post-status');
            statusBadge.textContent = getStatusText(postStatus);
            statusBadge.className = `badge text-bg-${getStatusClass(postStatus)}`;
            
            // Durum güncelleme butonuna post ID'sini ekle
            const updateStatusBtn = document.getElementById('update-post-status-btn');
            updateStatusBtn.setAttribute('data-post-id', postId);
            
            // Medya içeriklerini getir
            loadPostMedia(postId);
            
            // Yorum ve beğeni verilerini getir
            loadPostComments(postId);
            loadPostLikes(postId);
            
            // İstatistik verilerini güncelle
            document.getElementById('post-like-count').textContent = postLikes || '0';
            document.getElementById('post-comment-count').textContent = button.getAttribute('data-post-comment-count') || '0';
            document.getElementById('post-view-count').textContent = button.getAttribute('data-post-view-count') || '0';
        });
    }
    
    // Yorum verilerini getir ve listele
    function loadPostComments(postId) {
        const commentsContainer = document.getElementById('comments-list');
        const loadingSpinner = document.getElementById('comments-loading');
        const noCommentsMessage = document.getElementById('no-comments');
        
        if (!commentsContainer || !loadingSpinner || !noCommentsMessage) {
            console.error('Yorum konteyner elemanları bulunamadı');
            return;
        }
        
        // Yükleniyor durumunu göster
        loadingSpinner.style.display = 'block';
        commentsContainer.innerHTML = '';
        noCommentsMessage.style.display = 'none';
        
        // API'den verileri getir
        fetch(`/api/get_post_comments.php?post_id=${postId}`)
            .then(response => response.json())
            .then(data => {
                loadingSpinner.style.display = 'none';
                
                if (!data.success || data.count === 0) {
                    noCommentsMessage.style.display = 'block';
                    return;
                }
                
                // Yorumları listele
                data.comments.forEach(comment => {
                    const commentHtml = createCommentElement(comment);
                    commentsContainer.insertAdjacentHTML('beforeend', commentHtml);
                });
                
                // Yorum etkileşim butonları için event listener ekle
                attachCommentEventListeners();
                
                // Kullanıcı seçim kutusunu doldur
                populateCommentUserSelect();
            })
            .catch(error => {
                console.error('Yorumlar yüklenirken hata:', error);
                loadingSpinner.style.display = 'none';
                noCommentsMessage.style.display = 'block';
                noCommentsMessage.textContent = 'Yorumlar yüklenirken bir hata oluştu.';
            });
    }
    
    // Beğeni verilerini getir ve listele
    function loadPostLikes(postId) {
        const likesContainer = document.getElementById('likes-list');
        const loadingSpinner = document.getElementById('likes-loading');
        const noLikesMessage = document.getElementById('no-likes');
        
        if (!likesContainer || !loadingSpinner || !noLikesMessage) {
            console.error('Beğeni konteyner elemanları bulunamadı');
            return;
        }
        
        // Yükleniyor durumunu göster
        loadingSpinner.style.display = 'block';
        likesContainer.innerHTML = '';
        noLikesMessage.style.display = 'none';
        
        // API'den verileri getir
        fetch(`/api/get_post_likes.php?post_id=${postId}`)
            .then(response => response.json())
            .then(data => {
                loadingSpinner.style.display = 'none';
                
                if (!data.success || data.count === 0) {
                    noLikesMessage.style.display = 'block';
                    return;
                }
                
                // Beğeni sayısını güncelle
                document.getElementById('post-like-count').textContent = data.count;
                
                // Beğenileri listele
                const likesList = document.createElement('div');
                likesList.className = 'row';
                
                data.likes.forEach(like => {
                    const likeHtml = `
                        <div class="col-md-6 mb-2">
                            <div class="card">
                                <div class="card-body p-2">
                                    <div class="d-flex align-items-center">
                                        <div class="flex-shrink-0">
                                            <img src="${like.user_image || '/img/default-user.png'}" 
                                                 class="rounded-circle" alt="${like.user_name}" 
                                                 width="40" height="40">
                                        </div>
                                        <div class="flex-grow-1 ms-3">
                                            <p class="m-0 fw-bold">${like.user_name || 'Bilinmeyen Kullanıcı'}</p>
                                            <small class="text-muted">@${like.user_username || 'bilinmeyen'}</small>
                                        </div>
                                        <div class="flex-shrink-0">
                                            <button class="btn btn-sm btn-outline-danger remove-like-btn" 
                                                    data-like-id="${like.id}" data-bs-toggle="tooltip" title="Beğeniyi Sil">
                                                <i class="bi bi-trash"></i>
                                            </button>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    `;
                    likesList.insertAdjacentHTML('beforeend', likeHtml);
                });
                
                likesContainer.appendChild(likesList);
                
                // Beğeni silme butonları için event listener ekle
                attachLikeEventListeners();
            })
            .catch(error => {
                console.error('Beğeniler yüklenirken hata:', error);
                loadingSpinner.style.display = 'none';
                noLikesMessage.style.display = 'block';
                noLikesMessage.textContent = 'Beğeniler yüklenirken bir hata oluştu.';
            });
    }
    
    // Durum metni dönüştürme fonksiyonu
    function getStatusText(status) {
        switch(status) {
            case 'awaitingSolution': return 'Çözüm Bekliyor';
            case 'inProgress': return 'İşleme Alındı';
            case 'solved': return 'Çözüldü';
            case 'rejected': return 'Reddedildi';
            default: return 'Bilinmiyor';
        }
    }
    
    // Durum sınıfı dönüştürme fonksiyonu
    function getStatusClass(status) {
        switch(status) {
            case 'awaitingSolution': return 'warning';
            case 'inProgress': return 'info';
            case 'solved': return 'success';
            case 'rejected': return 'danger';
            default: return 'secondary';
        }
    }
    
    // Post tipi dönüştürme fonksiyonu
    function getPostTypeText(type) {
        switch(type) {
            case 'problem': return 'Şikayet';
            case 'suggestion': return 'Öneri';
            case 'announcement': return 'Duyuru';
            case 'general': return 'Genel';
            default: return type || 'Bilinmiyor';
        }
    }
    
    // Medya içeriklerini getirme fonksiyonu (API kullanarak)
    function loadPostMedia(postId) {
        // Medya yükleme durumunu göster
        document.getElementById('media-loading').style.display = 'block';
        document.getElementById('no-media').style.display = 'none';
        
        // Önceki medya içeriklerini temizle
        const mediaContainer = document.getElementById('post-media-container');
        const mediaItems = mediaContainer.querySelectorAll('.media-item');
        mediaItems.forEach(item => item.remove());
        
        // API'den medya verilerini al
        fetch(`api/get_post_media.php?post_id=${postId}`)
            .then(response => response.json())
            .then(data => {
                document.getElementById('media-loading').style.display = 'none';
                
                if (data.error) {
                    document.getElementById('no-media').textContent = `Hata: ${data.error}`;
                    document.getElementById('no-media').style.display = 'block';
                    return;
                }
                
                if (data.media && data.media.length > 0) {
                    // Medya öğelerini ekranda göster
                    data.media.forEach(media => {
                        const mediaElement = document.createElement('div');
                        mediaElement.className = 'media-item';
                        
                        if (media.type === 'image') {
                            mediaElement.innerHTML = `
                                <div class="card">
                                    <div class="card-header p-2 d-flex justify-content-between align-items-center">
                                        <span class="badge bg-primary">Resim</span>
                                        <button type="button" class="btn btn-sm btn-danger delete-media-btn" data-media-id="${media.id}">
                                            <i class="bi bi-trash"></i>
                                        </button>
                                    </div>
                                    <div class="card-body p-2 text-center">
                                        <img src="${media.url}" class="img-fluid rounded" alt="Medya içeriği" style="max-height: 400px;">
                                    </div>
                                </div>
                            `;
                        } else if (media.type === 'video') {
                            // Video URL'sini işle (YouTube embed kodu için)
                            let videoUrl = media.url;
                            
                            // Eğer YouTube linki ise embed formatına çevir
                            if (videoUrl.includes('youtube.com/watch') || videoUrl.includes('youtu.be')) {
                                const videoId = extractYouTubeId(videoUrl);
                                if (videoId) {
                                    videoUrl = `https://www.youtube.com/embed/${videoId}`;
                                }
                            }
                            
                            mediaElement.innerHTML = `
                                <div class="card">
                                    <div class="card-header p-2 d-flex justify-content-between align-items-center">
                                        <span class="badge bg-danger">Video</span>
                                        <button type="button" class="btn btn-sm btn-danger delete-media-btn" data-media-id="${media.id}">
                                            <i class="bi bi-trash"></i>
                                        </button>
                                    </div>
                                    <div class="card-body p-2">
                                        <div class="ratio ratio-16x9">
                                            <iframe src="${videoUrl}" title="Video" allowfullscreen></iframe>
                                        </div>
                                    </div>
                                </div>
                            `;
                        }
                        
                        document.getElementById('post-media-container').appendChild(mediaElement);
                    });
                    
                    // Medya silme butonlarını etkinleştir
                    attachMediaDeleteHandlers();
                } else {
                    document.getElementById('no-media').style.display = 'block';
                }
            })
            .catch(error => {
                console.error('Medya yükleme hatası:', error);
                document.getElementById('media-loading').style.display = 'none';
                document.getElementById('no-media').textContent = 'Medya yüklenirken bir hata oluştu';
                document.getElementById('no-media').style.display = 'block';
            });
    }
    
    // YouTube video ID'sini URL'den çıkaran yardımcı fonksiyon
    function extractYouTubeId(url) {
        const regExp = /^.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|&v=)([^#&?]*).*/;
        const match = url.match(regExp);
        return (match && match[2].length === 11) ? match[2] : null;
    }
    
    // Yorum HTML öğesini oluşturan fonksiyon
    function createCommentElement(comment) {
        const isReply = comment.parent_id !== null;
        const parentInfo = comment.parent_username ? 
            `<div class="mb-2 p-2 bg-light rounded">
                <small class="text-muted">
                    <i class="bi bi-reply"></i> 
                    <strong>@${comment.parent_username}</strong> yorumuna yanıt:
                </small>
                <div class="text-truncate">${comment.parent_content || 'Bu yorum silinmiş'}</div>
            </div>` : '';
        
        // Kullanıcı bilgisi
        const userInfo = comment.is_anonymous ? 
            `<span class="badge bg-warning text-dark me-1">Anonim</span>` :
            `<strong>${comment.user_name || 'Bilinmeyen Kullanıcı'}</strong> 
            <small class="text-muted">(@${comment.user_username || 'bilinmeyen'})</small>`;
        
        // Yorum karşı
        return `
            <div class="card mb-3 ${isReply ? 'ms-4 border-start border-info' : ''}" id="comment-${comment.id}">
                <div class="card-header p-2 d-flex justify-content-between align-items-center">
                    <div>
                        ${userInfo}
                        ${comment.is_hidden ? '<span class="badge bg-danger ms-1">Gizli</span>' : ''}
                    </div>
                    <small class="text-muted">${new Date(comment.created_at).toLocaleString()}</small>
                </div>
                <div class="card-body p-3">
                    ${parentInfo}
                    <p class="mb-0">${comment.content}</p>
                </div>
                <div class="card-footer p-2 d-flex justify-content-between">
                    <div>
                        <span class="badge bg-primary me-1">
                            <i class="bi bi-heart-fill"></i> ${comment.like_count || 0}
                        </span>
                    </div>
                    <div class="btn-group btn-group-sm">
                        <button class="btn btn-sm btn-outline-primary reply-comment-btn" 
                                data-comment-id="${comment.id}" data-comment-username="${comment.user_username}">
                            <i class="bi bi-reply"></i> Yanıtla
                        </button>
                        <button class="btn btn-sm ${comment.is_hidden ? 'btn-success' : 'btn-warning'} toggle-comment-btn" 
                                data-comment-id="${comment.id}">
                            <i class="bi ${comment.is_hidden ? 'bi-eye' : 'bi-eye-slash'}"></i> 
                            ${comment.is_hidden ? 'Göster' : 'Gizle'}
                        </button>
                        <button class="btn btn-sm btn-danger delete-comment-btn" data-comment-id="${comment.id}">
                            <i class="bi bi-trash"></i> Sil
                        </button>
                        <button class="btn btn-sm btn-danger ban-user-btn" data-comment-id="${comment.id}"
                                data-user-id="${comment.user_id}" data-username="${comment.user_username}">
                            <i class="bi bi-shield-exclamation"></i> Yasakla
                        </button>
                    </div>
                </div>
            </div>
        `;
    }
    
    // Yorum butonları için olay dinleyicilerini ekle
    function attachCommentEventListeners() {
        // Yanıtlama butonu
        document.querySelectorAll('.reply-comment-btn').forEach(button => {
            button.addEventListener('click', function() {
                const commentId = this.getAttribute('data-comment-id');
                const username = this.getAttribute('data-comment-username');
                
                // Yorum formunu göster
                const formCard = document.getElementById('comment-form-card');
                formCard.style.display = 'block';
                
                // Form alanlarını doldur
                document.getElementById('comment-content').value = `@${username} `;
                document.getElementById('comment-content').focus();
                
                // Form gönderildiğinde parent_id eklemek için form elementini işaretle
                const form = document.getElementById('add-comment-form');
                form.setAttribute('data-parent-id', commentId);
                
                // Scroll to form
                formCard.scrollIntoView({ behavior: 'smooth' });
            });
        });
        
        // Gizle/Göster butonu
        document.querySelectorAll('.toggle-comment-btn').forEach(button => {
            button.addEventListener('click', function() {
                const commentId = this.getAttribute('data-comment-id');
                const commentCard = document.getElementById(`comment-${commentId}`);
                
                // Butonun yükleniyor durumunu göster
                const originalHtml = this.innerHTML;
                this.innerHTML = '<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span>';
                this.disabled = true;
                
                // API isteği gönder
                fetch('/api/comment_actions.php', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded'
                    },
                    body: `action=toggle_visibility&comment_id=${commentId}`
                })
                .then(response => response.json())
                .then(data => {
                    // Butonun normal durumuna geri dön
                    this.disabled = false;
                    
                    if (data.success) {
                        // Yorum durumunu güncelle
                        const isHidden = data.is_hidden;
                        
                        // Yorum kartını güncelle
                        const statusBadge = commentCard.querySelector('.card-header span.badge.bg-danger');
                        if (isHidden) {
                            if (!statusBadge) {
                                commentCard.querySelector('.card-header div').innerHTML += '<span class="badge bg-danger ms-1">Gizli</span>';
                            }
                        } else {
                            if (statusBadge) {
                                statusBadge.remove();
                            }
                        }
                        
                        // Butonu güncelle
                        this.innerHTML = `<i class="bi ${isHidden ? 'bi-eye' : 'bi-eye-slash'}"></i> ${isHidden ? 'Göster' : 'Gizle'}`;
                        this.className = `btn btn-sm ${isHidden ? 'btn-success' : 'btn-warning'} toggle-comment-btn`;
                    } else {
                        // Hata mesajı göster
                        alert('Hata: ' + (data.error || 'Bilinmeyen bir hata oluştu'));
                        this.innerHTML = originalHtml;
                    }
                })
                .catch(error => {
                    console.error('İşlem hatası:', error);
                    alert('İşlem sırasında bir hata oluştu');
                    this.disabled = false;
                    this.innerHTML = originalHtml;
                });
            });
        });
        
        // Silme butonu
        document.querySelectorAll('.delete-comment-btn').forEach(button => {
            button.addEventListener('click', function() {
                if (!confirm('Bu yorumu silmek istediğinize emin misiniz? Bu işlem geri alınamaz.')) {
                    return;
                }
                
                const commentId = this.getAttribute('data-comment-id');
                const commentCard = document.getElementById(`comment-${commentId}`);
                
                // Butonun yükleniyor durumunu göster
                const originalHtml = this.innerHTML;
                this.innerHTML = '<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span>';
                this.disabled = true;
                
                // API isteği gönder
                fetch('/api/comment_actions.php', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded'
                    },
                    body: `action=delete&comment_id=${commentId}`
                })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        // Yorum kartını kaldır
                        commentCard.style.opacity = '0';
                        commentCard.style.transition = 'opacity 0.3s';
                        setTimeout(() => {
                            commentCard.remove();
                            
                            // Eğer hiç yorum kalmadıysa, bilgi mesajını göster
                            const remainingComments = document.querySelectorAll('#comments-list .card');
                            if (remainingComments.length === 0) {
                                document.getElementById('no-comments').style.display = 'block';
                            }
                            
                            // Yorum sayısını güncelle
                            const countElement = document.getElementById('post-comment-count');
                            const currentCount = parseInt(countElement.textContent) || 0;
                            countElement.textContent = Math.max(0, currentCount - 1);
                        }, 300);
                    } else {
                        // Hata mesajı göster
                        alert('Hata: ' + (data.error || 'Bilinmeyen bir hata oluştu'));
                        this.disabled = false;
                        this.innerHTML = originalHtml;
                    }
                })
                .catch(error => {
                    console.error('İşlem hatası:', error);
                    alert('İşlem sırasında bir hata oluştu');
                    this.disabled = false;
                    this.innerHTML = originalHtml;
                });
            });
        });
        
        // Yasaklama butonu
        document.querySelectorAll('.ban-user-btn').forEach(button => {
            button.addEventListener('click', function() {
                const commentId = this.getAttribute('data-comment-id');
                const userId = this.getAttribute('data-user-id');
                const username = this.getAttribute('data-username');
                
                if (!confirm(`@${username} kullanıcısını yasaklamak istediğinize emin misiniz? Bu işlem kullanıcının tüm yorumlarını gizleyecek ve yeni yorum/beğeni yapmasını engelleyecektir.`)) {
                    return;
                }
                
                // Butonun yükleniyor durumunu göster
                const originalHtml = this.innerHTML;
                this.innerHTML = '<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span>';
                this.disabled = true;
                
                // API isteği gönder
                fetch('/api/comment_actions.php', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded'
                    },
                    body: `action=ban_user&comment_id=${commentId}`
                })
                .then(response => response.json())
                .then(data => {
                    // Butonun normal durumuna geri dön
                    this.disabled = false;
                    
                    if (data.success) {
                        alert(`Kullanıcı @${username} başarıyla yasaklandı ve tüm yorumları gizlendi.`);
                        
                        // Yorumları yeniden yükle
                        loadPostComments(currentPostId);
                    } else {
                        // Hata mesajı göster
                        alert('Hata: ' + (data.error || 'Bilinmeyen bir hata oluştu'));
                        this.innerHTML = originalHtml;
                    }
                })
                .catch(error => {
                    console.error('İşlem hatası:', error);
                    alert('İşlem sırasında bir hata oluştu');
                    this.disabled = false;
                    this.innerHTML = originalHtml;
                });
            });
        });
    }
    
    // Beğeni işlemleri için olay dinleyicileri
    function attachLikeEventListeners() {
        // Beğeni silme butonu
        document.querySelectorAll('.remove-like-btn').forEach(button => {
            button.addEventListener('click', function() {
                if (!confirm('Bu beğeniyi silmek istediğinize emin misiniz?')) {
                    return;
                }
                
                const likeId = this.getAttribute('data-like-id');
                const likeCard = this.closest('.col-md-6');
                
                // Butonun yükleniyor durumunu göster
                const originalHtml = this.innerHTML;
                this.innerHTML = '<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span>';
                this.disabled = true;
                
                // API isteği gönder
                fetch('/api/like_actions.php', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded'
                    },
                    body: `action=remove_like&like_id=${likeId}&post_id=${currentPostId}`
                })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        // Beğeni kartını kaldır
                        likeCard.style.opacity = '0';
                        likeCard.style.transition = 'opacity 0.3s';
                        setTimeout(() => {
                            likeCard.remove();
                            
                            // Eğer hiç beğeni kalmadıysa, bilgi mesajını göster
                            const remainingLikes = document.querySelectorAll('#likes-list .col-md-6');
                            if (remainingLikes.length === 0) {
                                document.getElementById('no-likes').style.display = 'block';
                            }
                            
                            // Beğeni sayısını güncelle
                            const countElement = document.getElementById('post-like-count');
                            const currentCount = parseInt(countElement.textContent) || 0;
                            countElement.textContent = Math.max(0, currentCount - 1);
                        }, 300);
                    } else {
                        // Hata mesajı göster
                        alert('Hata: ' + (data.error || 'Bilinmeyen bir hata oluştu'));
                        this.disabled = false;
                        this.innerHTML = originalHtml;
                    }
                })
                .catch(error => {
                    console.error('İşlem hatası:', error);
                    alert('İşlem sırasında bir hata oluştu');
                    this.disabled = false;
                    this.innerHTML = originalHtml;
                });
            });
        });
        
        // Tüm beğenileri temizleme butonu
        const clearLikesBtn = document.getElementById('clear-likes-btn');
        if (clearLikesBtn) {
            clearLikesBtn.addEventListener('click', function() {
                if (!confirm('Bu paylaşıma ait TÜM beğenileri silmek istediğinize emin misiniz? Bu işlem geri alınamaz.')) {
                    return;
                }
                
                // Butonun yükleniyor durumunu göster
                const originalHtml = this.innerHTML;
                this.innerHTML = '<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span>';
                this.disabled = true;
                
                // API isteği gönder
                fetch('/api/like_actions.php', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded'
                    },
                    body: `action=clear_likes&post_id=${currentPostId}`
                })
                .then(response => response.json())
                .then(data => {
                    this.disabled = false;
                    
                    if (data.success) {
                        // Beğeni listesini temizle
                        document.getElementById('likes-list').innerHTML = '';
                        document.getElementById('no-likes').style.display = 'block';
                        
                        // Beğeni sayısını sıfırla
                        document.getElementById('post-like-count').textContent = '0';
                        
                        this.innerHTML = '<i class="bi bi-check"></i> Temizlendi';
                        setTimeout(() => {
                            this.innerHTML = originalHtml;
                        }, 2000);
                    } else {
                        // Hata mesajı göster
                        alert('Hata: ' + (data.error || 'Bilinmeyen bir hata oluştu'));
                        this.innerHTML = originalHtml;
                    }
                })
                .catch(error => {
                    console.error('İşlem hatası:', error);
                    alert('İşlem sırasında bir hata oluştu');
                    this.disabled = false;
                    this.innerHTML = originalHtml;
                });
            });
        }
    }
    
    // Yorum için kullanıcı seçim kutusunu doldur
    function populateCommentUserSelect() {
        console.log("Kullanıcı seçim kutusunu doldurma fonksiyonu çağrıldı");
        
        const userSelect = document.getElementById('comment-user');
        if (!userSelect) {
            console.error("comment-user ID'li bir element bulunamadı!");
            return;
        }
        
        // Seçim kutusunu temizle
        userSelect.innerHTML = '<option value="">Kullanıcı Seçin</option>';
        
        // API'den kullanıcıları getir
        console.log("API'den kullanıcılar getiriliyor...");
        fetch('/api/get_users.php')
            .then(response => {
                if (!response.ok) {
                    throw new Error(`HTTP error! Status: ${response.status}`);
                }
                return response.json();
            })
            .then(data => {
                console.log("API yanıtı alındı:", data);
                if (data.success && data.users && data.users.length > 0) {
                    console.log(`${data.users.length} kullanıcı bulundu`);
                    // Admin kullanıcısını seçili yap
                    let adminFound = false;
                    
                    data.users.forEach(user => {
                        const option = document.createElement('option');
                        option.value = user.id;
                        option.textContent = `${user.name} (@${user.username})`;
                        
                        // Admin kullanıcısını seçili yap (id=1 varsayılan admin)
                        if (user.id == 1) {
                            option.selected = true;
                            adminFound = true;
                        }
                        
                        userSelect.appendChild(option);
                    });
                    
                    // Admin bulunamadıysa en az bir kullanıcı seçili olsun
                    if (!adminFound && data.users.length > 0) {
                        userSelect.options[1].selected = true;
                    }
                }
                else {
                    console.warn("API başarılı yanıt döndürmedi veya kullanıcı bulunamadı:", data);
                }
            })
            .catch(error => {
                console.error('Kullanıcılar yüklenirken hata:', error);
            });
    }
    
    // Medya silme işlevini bağlayan fonksiyon
    function attachMediaDeleteHandlers() {
        console.log('Medya silme butonları etkinleştiriliyor...');
        const deleteButtons = document.querySelectorAll('.delete-media-btn');
        
        // Butonların boş olup olmadığını kontrol et
        console.log('Bulunan silme butonları:', deleteButtons.length);
        
        deleteButtons.forEach(button => {
            // Silme butonu dinleyicisini ekle
            button.addEventListener('click', function(event) {
                event.preventDefault();
                console.log('Medya silme fonksiyonu çağrıldı.');
                
                // Buton referansını al
                const btn = this;
                const mediaId = btn.getAttribute('data-media-id');
                
                if (!mediaId) {
                    alert('Medya ID bulunamadı');
                    return;
                }
                
                if (!confirm('Bu medya öğesini silmek istediğinizden emin misiniz?')) {
                    return;
                }
                
                // Silme işlemi başladığında buton görünümünü güncelle
                btn.innerHTML = '<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span>';
                btn.disabled = true;
                
                console.log('Medya silme isteği gönderiliyor, ID:', mediaId);
                
                // API'ye silme isteği gönder
                fetch('api/delete_media.php', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify({
                        media_id: mediaId
                    })
                })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        // Silme başarılı, medya öğesini gizle ve sonra kaldır
                        const mediaItem = btn.closest('.media-item');
                        if (mediaItem) {
                            mediaItem.style.opacity = '0';
                            mediaItem.style.transition = 'opacity 0.3s';
                            setTimeout(() => {
                                mediaItem.remove();
                                
                                // Eğer hiç medya kalmadıysa, bilgi mesajını göster
                                const remainingMedia = document.querySelectorAll('.media-item');
                                if (remainingMedia.length === 0) {
                                    document.getElementById('no-media').style.display = 'block';
                                }
                            }, 300);
                        }
                    } else {
                        // Hata mesajını göster
                        alert('Hata: ' + (data.error || 'Bilinmeyen bir hata oluştu'));
                        // Butonun orijinal haline geri dönmesi
                        btn.innerHTML = '<i class="bi bi-trash"></i>';
                        btn.disabled = false;
                    }
                })
                .catch(error => {
                    console.error('Medya silme hatası:', error);
                    alert('Medya silinirken bir hata oluştu');
                    btn.innerHTML = '<i class="bi bi-trash"></i>';
                    btn.disabled = false;
                });
            });
        });
    }
    
    // Durum güncelleme butonu işlevselliği
    const updateStatusBtn = document.getElementById('update-post-status-btn');
    if (updateStatusBtn) {
        updateStatusBtn.addEventListener('click', function() {
            const postId = this.getAttribute('data-post-id');
            const statusSelect = document.getElementById('modal-status-select');
            const newStatus = statusSelect.value;
            
            // Kullanıcıya işlem bilgisi ver
            this.innerHTML = '<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Güncelleniyor...';
            this.disabled = true;
            
            // API'ye durum güncelleme isteği gönder
            fetch('api/update_post_status.php', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    post_id: postId,
                    status: newStatus
                }),
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    // Başarılı güncelleme
                    const statusBadge = document.getElementById('modal-post-status');
                    statusBadge.textContent = getStatusText(newStatus);
                    statusBadge.className = `badge text-bg-${getStatusClass(newStatus)}`;
                    
                    // Kart görünümünde de güncelleme yap
                    const cards = document.querySelectorAll('.post-card');
                    cards.forEach(card => {
                        const cardButton = card.querySelector('.view-details');
                        if (cardButton && cardButton.getAttribute('data-post-id') === postId) {
                            const cardStatus = card.querySelector('.card-header .badge');
                            if (cardStatus) {
                                cardStatus.textContent = getStatusText(newStatus);
                                cardStatus.className = `badge text-bg-${getStatusClass(newStatus)}`;
                            }
                            
                            // Kartın durum dropdown'ını da güncelle
                            const statusDropdown = card.querySelector('select[name="status"]');
                            if (statusDropdown) {
                                statusDropdown.value = newStatus;
                            }
                            
                            // Veri özniteliğini güncelle
                            cardButton.setAttribute('data-post-status', newStatus);
                        }
                    });
                    
                    // Başarı mesajı göster
                    alert('Şikayet durumu başarıyla güncellendi');
                } else {
                    // Hata mesajı göster
                    alert('Hata: ' + (data.error || 'Bilinmeyen bir hata oluştu'));
                }
            })
            .catch(error => {
                console.error('Durum güncelleme hatası:', error);
                alert('Durum güncellenirken bir hata oluştu. Lütfen tekrar deneyin.');
            })
            .finally(() => {
                // Butonun orijinal haline dönmesi
                this.innerHTML = 'Durum Güncelle';
                this.disabled = false;
            });
        });
    }

    // İçerik düzenleme işlevleri
    const editPostBtn = document.getElementById('edit-post-btn');
    const savePostBtn = document.getElementById('save-post-btn');
    const cancelEditBtn = document.getElementById('cancel-edit-btn');
    
    // Düzenleme modunu aç
    if (editPostBtn) {
        editPostBtn.addEventListener('click', function() {
            document.querySelectorAll('.view-mode').forEach(el => el.style.display = 'none');
            document.querySelectorAll('.edit-mode').forEach(el => el.style.display = 'block');
        });
    }
    
    // Düzenleme modundan çık
    if (cancelEditBtn) {
        cancelEditBtn.addEventListener('click', function() {
            document.querySelectorAll('.view-mode').forEach(el => el.style.display = 'block');
            document.querySelectorAll('.edit-mode').forEach(el => el.style.display = 'none');
        });
    }
    
    // Değişiklikleri kaydet
    if (savePostBtn) {
        savePostBtn.addEventListener('click', function() {
            // İşlem başladığında buton görünümünü güncelle
            this.innerHTML = '<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Kaydediliyor...';
            this.disabled = true;
            
            const title = document.getElementById('edit-post-title').value;
            const content = document.getElementById('edit-post-content').value;
            
            // Veri kontrolü
            if (!title.trim() || !content.trim()) {
                alert('Başlık ve içerik alanları boş olamaz');
                this.innerHTML = '<i class="bi bi-check me-1"></i> Kaydet';
                this.disabled = false;
                return;
            }
            
            // API'ye güncelleme isteği gönder
            fetch('api/update_post_content.php', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    post_id: currentPostId,
                    title: title,
                    content: content
                }),
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    // Başarılı güncelleme
                    document.getElementById('modal-post-title').textContent = title;
                    document.getElementById('modal-post-content').textContent = content;
                    
                    // Görünüm moduna geri dön
                    document.querySelectorAll('.view-mode').forEach(el => el.style.display = 'block');
                    document.querySelectorAll('.edit-mode').forEach(el => el.style.display = 'none');
                    
                    // Başarı mesajı göster
                    alert('İçerik başarıyla güncellendi');
                    
                    // Kart görünümünde de güncelleme yap (eğer aynı sayfada ise)
                    const cardButton = document.querySelector(`.view-details[data-post-id="${currentPostId}"]`);
                    if (cardButton) {
                        cardButton.setAttribute('data-post-title', title);
                        cardButton.setAttribute('data-post-content', content);
                        
                        // En yakın kart başlığını güncelle
                        const card = cardButton.closest('.post-card');
                        if (card) {
                            const cardTitle = card.querySelector('.card-title');
                            if (cardTitle) {
                                cardTitle.textContent = title;
                            }
                        }
                    }
                } else {
                    // Hata mesajı göster
                    alert('Hata: ' + (data.error || 'İçerik güncellenirken bir hata oluştu'));
                }
            })
            .catch(error => {
                console.error('İçerik güncelleme hatası:', error);
                alert('İçerik güncellenirken bir hata oluştu');
            })
            .finally(() => {
                // Butonun orijinal haline dönmesi
                this.innerHTML = '<i class="bi bi-check me-1"></i> Kaydet';
                this.disabled = false;
            });
        });
    }
    
    // Dosya yükleme işlemleri
    const uploadMediaBtn = document.getElementById('upload-media-btn');
    const cancelUploadBtn = document.getElementById('cancel-upload-btn');
    const submitUploadBtn = document.getElementById('submit-upload-btn');
    const mediaUploadForm = document.getElementById('media-upload-form');
    
    // Dosya yükleme formunu göster
    if (uploadMediaBtn) {
        uploadMediaBtn.addEventListener('click', function() {
            mediaUploadForm.style.display = 'block';
            this.style.display = 'none';
        });
    }
    
    // Dosya yükleme formunu kapat
    if (cancelUploadBtn) {
        cancelUploadBtn.addEventListener('click', function() {
            mediaUploadForm.style.display = 'none';
            uploadMediaBtn.style.display = 'inline-block';
        });
    }
    
    // Dosya yükleme işlemini başlat
    if (submitUploadBtn) {
        submitUploadBtn.addEventListener('click', function() {
            const fileInput = document.getElementById('media-file');
            const mediaTypeSelect = document.getElementById('media-type-select');
            
            if (!fileInput.files || fileInput.files.length === 0) {
                alert('Lütfen bir dosya seçin');
                return;
            }
            
            const file = fileInput.files[0];
            const maxSize = 10 * 1024 * 1024; // 10MB
            
            if (file.size > maxSize) {
                alert('Dosya çok büyük (maksimum 10MB)');
                return;
            }
            
            // Dosya türü kontrolü
            const mediaType = mediaTypeSelect.value;
            const allowedImageTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
            const allowedVideoTypes = ['video/mp4', 'video/webm', 'video/ogg'];
            
            if (mediaType === 'image' && !allowedImageTypes.includes(file.type)) {
                alert('Geçersiz resim formatı. Kabul edilen formatlar: JPG, PNG, GIF, WEBP');
                return;
            } else if (mediaType === 'video' && !allowedVideoTypes.includes(file.type)) {
                alert('Geçersiz video formatı. Kabul edilen formatlar: MP4, WEBM, OGG');
                return;
            }
            
            // FormData hazırla
            const formData = new FormData();
            formData.append('post_id', currentPostId);
            formData.append('media_type', mediaType);
            formData.append('media', file);
            
            // Yükleme durumunu göster
            submitUploadBtn.innerHTML = '<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Yükleniyor...';
            submitUploadBtn.disabled = true;
            
            // API'ye yükleme isteği gönder
            fetch('api/upload_media.php', {
                method: 'POST',
                body: formData
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    // Başarılı yükleme
                    mediaUploadForm.style.display = 'none';
                    uploadMediaBtn.style.display = 'inline-block';
                    
                    // Formu temizle
                    fileInput.value = '';
                    
                    // Medya içeriklerini yeniden yükle
                    loadPostMedia(currentPostId);
                    
                    alert('Medya başarıyla yüklendi');
                } else {
                    // Hata mesajları
                    if (data.errors && data.errors.length > 0) {
                        alert('Hata: ' + data.errors.join('\n'));
                    } else {
                        alert('Hata: ' + (data.error || 'Bilinmeyen bir hata oluştu'));
                    }
                }
            })
            .catch(error => {
                console.error('Dosya yükleme hatası:', error);
                alert('Dosya yüklenirken bir hata oluştu');
            })
            .finally(() => {
                // Butonu orijinal haline döndür
                submitUploadBtn.innerHTML = 'Yükle';
                submitUploadBtn.disabled = false;
            });
        });
    }
}

// Sayfa yüklendiğinde JavaScript'i başlat
document.addEventListener('DOMContentLoaded', function() {
    // İstatistik grafikleri başlat
    initializeCharts();
    
    // Sayfa işlevlerini başlat
    initializePostsPage();
});