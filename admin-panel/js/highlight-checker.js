/**
 * Süresi dolmuş öne çıkarmaları kontrol eden ve kaldıran script
 * Bu script otomatik olarak süresi dolmuş öne çıkarmaları kontrol eder ve kaldırır.
 */

// Arkaplanda çalışacak kontrol fonksiyonu
function checkExpiredHighlights() {
    console.log('Süresi dolmuş öne çıkarma kontrolü yapılıyor...');
    
    fetch('/api/highlight_actions.php', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'action=check_expired'
    })
    .then(response => response.json())
    .then(data => {
        if (data.status === 'success') {
            if (data.expired_count > 0) {
                console.log(`${data.expired_count} adet süresi dolmuş öne çıkarma işlemi kaldırıldı.`);
                
                // Eğer admin sayfası açıksa bildirim göster
                if (document.getElementById('toast-container')) {
                    const message = `${data.expired_count} adet süresi dolmuş öne çıkarma işlemi otomatik olarak kaldırıldı.`;
                    
                    // Toast container yoksa oluştur
                    const toastContainer = document.getElementById('toast-container');
                    if (!toastContainer) {
                        const container = document.createElement('div');
                        container.id = 'toast-container';
                        container.className = 'toast-container position-fixed bottom-0 end-0 p-3';
                        document.body.appendChild(container);
                    }
                    
                    const toastId = 'toast-' + Date.now();
                    const toastHtml = `
                        <div id="${toastId}" class="toast" role="alert" aria-live="assertive" aria-atomic="true">
                            <div class="toast-header bg-info text-white">
                                <strong class="me-auto">Sistem Bildirimi</strong>
                                <button type="button" class="btn-close" data-bs-dismiss="toast" aria-label="Kapat"></button>
                            </div>
                            <div class="toast-body">
                                ${message}
                            </div>
                        </div>
                    `;
                    
                    document.getElementById('toast-container').insertAdjacentHTML('beforeend', toastHtml);
                    const toastElement = document.getElementById(toastId);
                    const toast = new bootstrap.Toast(toastElement);
                    toast.show();
                    
                    // 5 saniye sonra otomatik kaldır
                    setTimeout(() => {
                        toast.hide();
                        setTimeout(() => {
                            toastElement.remove();
                        }, 500);
                    }, 5000);
                }
            } else {
                console.log('Süresi dolmuş öne çıkarma bulunamadı.');
            }
        } else {
            console.error('Öne çıkarma kontrolü sırasında hata:', data.message);
        }
    })
    .catch(error => {
        console.error('Öne çıkarma kontrolü sırasında hata:', error);
    });
}

// Sayfa yüklendiğinde ve her 30 dakikada bir kontrol et
document.addEventListener('DOMContentLoaded', function() {
    // Sayfa yüklendiğinde ilk kontrolü yap
    checkExpiredHighlights();
    
    // Her 30 dakikada bir kontrol et (1800000 ms)
    setInterval(checkExpiredHighlights, 1800000);
});