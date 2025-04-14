/**
 * ŞikayetVar Admin Panel - Bildirim Yönetimi JavaScript
 * 
 * Bu dosya, bildirim yönetim sayfası için gerekli olan JavaScript kodlarını içerir.
 * Şehir ve ilçe filtreleme, bildirim kapsamına göre form alanlarını gösterme/gizleme işlemleri.
 */

// Sayfa yüklendiğinde
document.addEventListener('DOMContentLoaded', function() {
    // İlk sayfa yüklendiğinde kapsamı kontrol et
    handleScopeChange();
    
    // İlçelerin şehre göre filtrelenmesi için hazırlık
    const districts = [];
    const districtSelect = document.getElementById('district_id');
    
    // Sayfa yüklendiğinde tüm ilçeleri topla
    if (districtSelect) {
        const districtOptions = document.querySelectorAll('#district_id option');
        districtOptions.forEach(option => {
            if (option.dataset.cityId) {
                districts.push({
                    id: option.value,
                    name: option.textContent,
                    cityId: option.dataset.cityId
                });
            }
        });
    }
    
    // İlçe seçenek listesini güncelle
    window.updateDistrictOptions = function() {
        const cityId = document.getElementById('city_id').value;
        const districtSelect = document.getElementById('district_id');
        
        if (!districtSelect) return;
        
        // Önceki seçenekleri temizle
        while (districtSelect.options.length > 1) {
            districtSelect.remove(1);
        }
        
        if (!cityId) {
            districtSelect.options[0].text = 'Önce Şehir Seçin';
            return;
        }
        
        // Şehre ait ilçeleri filtrele ve ekle
        const filteredDistricts = districts.filter(d => d.cityId === cityId);
        
        if (filteredDistricts.length === 0) {
            districtSelect.options[0].text = 'Bu şehirde ilçe bulunamadı';
            return;
        }
        
        districtSelect.options[0].text = 'İlçe Seçin';
        
        filteredDistricts.forEach(district => {
            const option = document.createElement('option');
            option.value = district.id;
            option.textContent = district.name;
            option.dataset.cityId = district.cityId;
            districtSelect.appendChild(option);
        });
    };
    
    // Bildirim kapsamına göre ilgili alanları göster/gizle
    window.handleScopeChange = function() {
        const scopeType = document.getElementById('scope_type').value;
        const userSelector = document.getElementById('user_selector_container');
        const citySelector = document.getElementById('city_selector_container');
        const districtSelector = document.getElementById('district_selector_container');
        
        // Tüm seçicileri gizle
        userSelector.style.display = 'none';
        citySelector.style.display = 'none';
        districtSelector.style.display = 'none';
        
        // Kapsam tipine göre gerekli seçiciyi göster
        switch(scopeType) {
            case 'user':
                userSelector.style.display = 'block';
                break;
            case 'city':
                citySelector.style.display = 'block';
                break;
            case 'district':
                citySelector.style.display = 'block';
                districtSelector.style.display = 'block';
                break;
            case 'all':
                // Tüm kullanıcılar için ek seçim gerekmez
                break;
        }
    };
});