/**
 * ŞikayetVar Admin Panel - Anketler Sayfası Fonksiyonları
 */

document.addEventListener('DOMContentLoaded', function() {
    // Anket sayfası işlevleri
    initializeSurveyFilters();
    
    // Anket detay sayfasındaki grafikler
    initializeSurveyCharts();
    
    // Durum değiştirme toggle'ının etkinleştirilmesi
    initializeSurveyToggle();
    
    // Anket seçenekleri için fonksiyonları etkinleştir
    initializeOptionButtons();
});

// Anket filtreleme düğmesi ve içeriğini etkinleştir
function initializeSurveyFilters() {
    const toggleFiltersBtn = document.getElementById('toggle-filters');
    const filterContent = document.getElementById('filter-content');
    const filterToggleIcon = document.getElementById('filter-toggle-icon');
    
    if (toggleFiltersBtn && filterContent) {
        // URL'de herhangi bir filtre parametresi var mı kontrol et
        const urlParams = new URLSearchParams(window.location.search);
        let hasFilters = false;
        
        // Temel parametre olan 'page' dışındaki tüm parametreleri kontrol et
        for (const [key, value] of urlParams.entries()) {
            if (key !== 'page' && value) {
                hasFilters = true;
                break;
            }
        }
        
        // Eğer filtreler varsa, filtre bölümünü açık olarak göster
        if (hasFilters) {
            filterContent.style.display = 'block';
            if (filterToggleIcon) {
                filterToggleIcon.classList.replace('bi-chevron-down', 'bi-chevron-up');
            }
        } else {
            filterContent.style.display = 'none';
        }
        
        // Filtre düğmesi tıklandığında filtre bölümünü aç/kapat
        toggleFiltersBtn.addEventListener('click', function() {
            if (filterContent.style.display === 'none' || filterContent.style.display === '') {
                filterContent.style.display = 'block';
                if (filterToggleIcon) {
                    filterToggleIcon.classList.replace('bi-chevron-down', 'bi-chevron-up');
                }
            } else {
                filterContent.style.display = 'none';
                if (filterToggleIcon) {
                    filterToggleIcon.classList.replace('bi-chevron-up', 'bi-chevron-down');
                }
            }
        });
    }
}

// Anket ekranında kapsam değişikliğinde ilgili alanları göster/gizle
function toggleScopeOptions() {
    const scopeTypeSelect = document.getElementById('scope_type');
    const cityOptions = document.getElementById('city-options');
    const districtOptions = document.getElementById('district-options');
    
    if (scopeTypeSelect && cityOptions && districtOptions) {
        const selectedValue = scopeTypeSelect.value;
        
        // Tüm bölümleri önce gizle
        cityOptions.style.display = 'none';
        districtOptions.style.display = 'none';
        
        // Seçilen kapsama göre bölümleri göster
        if (selectedValue === 'city') {
            cityOptions.style.display = 'flex';
        } else if (selectedValue === 'district') {
            cityOptions.style.display = 'flex';
            districtOptions.style.display = 'flex';
        }
    }
}

// İl seçildiğinde ilçeleri getir
function loadDistricts() {
    const districtCityId = document.getElementById('district_city_id');
    const districtSelect = document.getElementById('district_id');
    
    if (districtCityId && districtSelect && districtCityId.value) {
        // İlçe seçimini aktif et
        districtSelect.disabled = false;
        districtSelect.innerHTML = '<option value="">Yükleniyor...</option>';
        
        // İlçeleri API'den getir
        fetch(`api/get_districts.php?city_id=${districtCityId.value}`)
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    districtSelect.innerHTML = '<option value="">İlçe Seçiniz...</option>';
                    
                    data.districts.forEach(district => {
                        const option = document.createElement('option');
                        option.value = district.id;
                        option.textContent = district.name;
                        districtSelect.appendChild(option);
                    });
                } else {
                    districtSelect.innerHTML = '<option value="">İlçe yüklenemedi</option>';
                    console.error('İlçeler alınırken hata oluştu:', data.error);
                }
            })
            .catch(error => {
                districtSelect.innerHTML = '<option value="">İlçe yüklenemedi</option>';
                console.error('İlçeler alınırken hata oluştu:', error);
            });
    } else {
        if (districtSelect) {
            districtSelect.disabled = true;
            districtSelect.innerHTML = '<option value="">Önce il seçiniz...</option>';
        }
    }
}

// Anket ekle sayfasında seçenek ekle
function addOption() {
    const optionsContainer = document.getElementById('optionsContainer');
    if (optionsContainer) {
        const optionCount = optionsContainer.children.length + 1;
        
        // Yeni bir seçenek satırı oluştur
        const optionDiv = document.createElement('div');
        optionDiv.className = 'input-group mb-2';
        optionDiv.innerHTML = `
            <input type="text" class="form-control" name="options[]" placeholder="Seçenek ${optionCount}" required>
            <button type="button" class="btn btn-outline-danger remove-option"><i class="bi bi-trash"></i></button>
        `;
        
        // Seçenek satırını container'a ekle
        optionsContainer.appendChild(optionDiv);
        
        // Silme düğmesini etkinleştir
        const removeBtn = optionDiv.querySelector('.remove-option');
        if (removeBtn) {
            removeBtn.addEventListener('click', function() {
                removeOption(removeBtn);
            });
        }
    }
}

// Anket ekle sayfasında seçenek sil
function removeOption(button) {
    const optionsContainer = document.getElementById('optionsContainer');
    if (optionsContainer && button) {
        // En az 2 seçenek olmalı
        if (optionsContainer.children.length > 2) {
            // Bu düğmeye ait satırı sil
            const optionRow = button.closest('.input-group');
            if (optionRow) {
                optionRow.remove();
                
                // Kalan seçeneklerin placeholder'larını güncelle
                const remainingOptions = optionsContainer.querySelectorAll('input[name="options[]"]');
                remainingOptions.forEach((input, index) => {
                    input.placeholder = `Seçenek ${index + 1}`;
                });
            }
        } else {
            alert('Anket için en az 2 seçenek gereklidir.');
        }
    }
}

// Anket sayfasındaki grafikleri oluştur
function initializeSurveyCharts() {
    // Anket seçeneklerinin pasta grafiği
    const optionsChartCanvas = document.getElementById('options-chart');
    if (optionsChartCanvas && window.surveyOptions) {
        const labels = window.surveyOptions.map(option => option.text);
        const data = window.surveyOptions.map(option => option.vote_count);
        const backgroundColors = [
            'rgba(54, 162, 235, 0.8)',
            'rgba(255, 99, 132, 0.8)',
            'rgba(255, 206, 86, 0.8)',
            'rgba(75, 192, 192, 0.8)',
            'rgba(153, 102, 255, 0.8)',
            'rgba(255, 159, 64, 0.8)',
            'rgba(199, 199, 199, 0.8)',
            'rgba(83, 102, 255, 0.8)'
        ];
        
        new Chart(optionsChartCanvas, {
            type: 'pie',
            data: {
                labels: labels,
                datasets: [{
                    data: data,
                    backgroundColor: backgroundColors.slice(0, data.length),
                    borderWidth: 1
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: {
                        position: 'bottom',
                        labels: {
                            boxWidth: 12,
                            font: {
                                size: 11
                            }
                        }
                    },
                    tooltip: {
                        callbacks: {
                            label: function(context) {
                                const total = context.dataset.data.reduce((a, b) => a + b, 0);
                                const value = context.raw;
                                const percentage = Math.round((value / total * 100) * 10) / 10 + '%';
                                return `${context.label}: ${value} oy (${percentage})`;
                            }
                        }
                    }
                }
            }
        });
    }
    
    // Bölgesel dağılım grafiği
    const regionalChartCanvas = document.getElementById('regional-chart');
    if (regionalChartCanvas && window.surveyRegionalData) {
        const labels = window.surveyRegionalData.map(item => item.name);
        const data = window.surveyRegionalData.map(item => item.vote_count);
        
        new Chart(regionalChartCanvas, {
            type: 'bar',
            data: {
                labels: labels,
                datasets: [{
                    label: 'Katılım Sayısı',
                    data: data,
                    backgroundColor: 'rgba(75, 192, 192, 0.7)',
                    borderColor: 'rgba(75, 192, 192, 1)',
                    borderWidth: 1
                }]
            },
            options: {
                indexAxis: 'y',
                responsive: true,
                plugins: {
                    legend: {
                        display: false
                    }
                },
                scales: {
                    x: {
                        beginAtZero: true
                    }
                }
            }
        });
    }
}

// Anket durum değiştirme toggle'ı
function initializeSurveyToggle() {
    const toggleSwitch = document.getElementById('toggle-active-status');
    if (toggleSwitch) {
        const surveyId = window.surveyId || new URLSearchParams(window.location.search).get('view_survey');
        
        if (surveyId) {
            toggleSwitch.addEventListener('change', function() {
                const isActive = toggleSwitch.checked;
                
                // API'ye istek gönder
                fetch('/api/toggle_survey_status.php', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify({
                        survey_id: surveyId,
                        is_active: isActive
                    })
                })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        // Başarılı işlem
                        const statusBadge = document.querySelector('.badge');
                        if (statusBadge) {
                            if (data.is_active) {
                                statusBadge.className = 'badge text-bg-success';
                                statusBadge.textContent = 'Aktif';
                            } else {
                                statusBadge.className = 'badge text-bg-danger';
                                statusBadge.textContent = 'Pasif';
                            }
                        }
                        
                        // Kullanıcıya bildirim ver
                        alert('Anket durumu başarıyla güncellendi: ' + (isActive ? 'Aktif' : 'Pasif'));
                    } else {
                        // Hata durumunda switch'i eski konumuna getir
                        toggleSwitch.checked = !isActive;
                        alert('Durum değiştirilemedi: ' + (data.error || 'Bilinmeyen hata'));
                    }
                })
                .catch(error => {
                    // Hata durumunda switch'i eski konumuna getir
                    toggleSwitch.checked = !isActive;
                    alert('Durum değiştirilemedi: ' + error);
                    console.error('Toggle error:', error);
                });
            });
        }
    }
}

// Anket seçenekleri için düğmeleri etkinleştir
function initializeOptionButtons() {
    // Ekle düğmesi
    const addOptionBtn = document.getElementById('add-option-btn');
    if (addOptionBtn) {
        addOptionBtn.addEventListener('click', addOption);
    }
    
    // Sil düğmeleri
    const removeOptionBtns = document.querySelectorAll('.remove-option');
    removeOptionBtns.forEach(button => {
        // İlk seçenek silinemez, o yüzden disabled özelliğini kontrol et
        if (!button.disabled) {
            button.addEventListener('click', function() {
                removeOption(button);
            });
        }
    });
}