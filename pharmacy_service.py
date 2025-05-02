import requests
from bs4 import BeautifulSoup
import json
import time
import os
import re
from datetime import datetime
import random

# Geçici önbellek sistemi
cache = {}
cache_time = {}
CACHE_DURATION = 60 * 60  # 1 saat (saniye cinsinden)

def clean_text(text):
    """Metni temizler, fazla boşlukları kaldırır."""
    if text is None:
        return ""
    text = re.sub(r'\s+', ' ', text)
    return text.strip()

def get_on_duty_pharmacies(city, district=None):
    """Belirli bir şehir ve ilçe için nöbetçi eczaneleri getirir."""
    cache_key = f"{city}_{district}"
    current_time = time.time()
    
    # Önbellekteki verileri kontrol et
    if cache_key in cache and (current_time - cache_time.get(cache_key, 0)) < CACHE_DURATION:
        return cache[cache_key]

    try:
        headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
            'Accept-Language': 'tr-TR,tr;q=0.9,en-US;q=0.8,en;q=0.7',
            'Referer': 'https://www.google.com/'
        }
        
        # Şehir ve ilçe adlarını URL formatına uyarla
        city_formatted = city.lower().replace(' ', '-').replace('ı', 'i').replace('ö', 'o').replace('ü', 'u').replace('ş', 's').replace('ç', 'c').replace('ğ', 'g')
        
        # Alternatif kaynaklar kullan:
        # 1. Kaynak: nobetci-eczane.org
        try:
            if district:
                district_formatted = district.lower().replace(' ', '-').replace('ı', 'i').replace('ö', 'o').replace('ü', 'u').replace('ş', 's').replace('ç', 'c').replace('ğ', 'g')
                url = f"https://www.nobetci-eczane.org/{city_formatted}/{district_formatted}"
            else:
                url = f"https://www.nobetci-eczane.org/{city_formatted}"
            
            response = requests.get(url, headers=headers, timeout=10)
            response.raise_for_status()
            
            soup = BeautifulSoup(response.content, 'html.parser')
            pharmacy_cards = soup.select('.card.pharmacyCard')
            
            pharmacies = []
            for card in pharmacy_cards:
                name_elem = card.select_one('.card-title')
                address_elem = card.select_one('.card-text.address')
                phone_elem = card.select_one('.card-text.phone')
                
                # Konum bilgilerini çıkar
                location_elem = card.select_one('a.pharmacy-detail-link')
                lat, lng = None, None
                if location_elem and location_elem.has_attr('data-latitude') and location_elem.has_attr('data-longitude'):
                    try:
                        lat_val = location_elem['data-latitude']
                        lng_val = location_elem['data-longitude']
                        if isinstance(lat_val, str) and isinstance(lng_val, str):
                            lat = float(lat_val)
                            lng = float(lng_val)
                    except (ValueError, TypeError):
                        lat, lng = None, None
                
                # Maps URL oluştur
                maps_url = None
                if lat and lng:
                    maps_url = f"https://www.google.com/maps/search/?api=1&query={lat},{lng}"
                
                pharmacy = {
                    'name': clean_text(name_elem.text) if name_elem else 'İsim Bulunamadı',
                    'address': clean_text(address_elem.text) if address_elem else 'Adres Bulunamadı',
                    'phone': clean_text(phone_elem.text) if phone_elem else 'Telefon Bulunamadı',
                    'location': {
                        'latitude': lat,
                        'longitude': lng,
                        'maps_url': maps_url
                    }
                }
                pharmacies.append(pharmacy)
            
            if len(pharmacies) > 0:
                result = {
                    'status': 'success',
                    'city': city,
                    'district': district,
                    'date': datetime.now().strftime('%d.%m.%Y'),
                    'count': len(pharmacies),
                    'pharmacies': pharmacies
                }
                
                # Sonucu önbelleğe kaydet
                cache[cache_key] = result
                cache_time[cache_key] = current_time
                
                return result
        except Exception as e:
            print(f"Kaynak 1 başarısız: {str(e)}")
        
        # 2. Kaynak: aeo.org.tr (Ankara Eczacı Odası - çalışmayabilir)
        try:
            url = "https://www.aeo.org.tr/nobetci-eczane-listesi"
            response = requests.get(url, headers=headers, timeout=10)
            # Burada farklı bir parse etme mantığı gerekebilir
            # ...
        except Exception as e:
            print(f"Kaynak 2 başarısız: {str(e)}")
        
        # Başka Kaynak Denemeleri...
        
        # Demo veri
        # Not: Gerçek bir API bağlantısı olmadığında, kullanıcıları demo/örnek verilerle 
        # karşılamak yerine, açık bir şekilde verilerin çekilemediğini belirtmek daha doğrudur
        return {
            'status': 'error',
            'message': 'Nöbetçi eczane verileri şu anda çekilemiyor. Lütfen doğrudan Sağlık Bakanlığı web sitesini kontrol edin.',
            'city': city,
            'district': district
        }
        
    except Exception as e:
        error_result = {
            'status': 'error',
            'message': str(e),
            'city': city,
            'district': district
        }
        return error_result

def get_closest_pharmacies(lat, lng, city, district=None, limit=10):
    """Belirli bir konuma en yakın nöbetçi eczaneleri sıralar."""
    from math import radians, sin, cos, sqrt, atan2
    
    pharmacies_data = get_on_duty_pharmacies(city, district)
    
    if pharmacies_data['status'] != 'success':
        return pharmacies_data
    
    def calculate_distance(lat1, lon1, lat2, lon2):
        # Haversine formülü ile iki nokta arası mesafe hesaplama
        R = 6371  # Dünya yarıçapı km
        dLat = radians(lat2 - lat1)
        dLon = radians(lon2 - lon1)
        a = sin(dLat/2) * sin(dLat/2) + cos(radians(lat1)) * cos(radians(lat2)) * sin(dLon/2) * sin(dLon/2)
        c = 2 * atan2(sqrt(a), sqrt(1-a))
        distance = R * c
        return distance
    
    pharmacies = pharmacies_data['pharmacies']
    
    # Mesafe hesapla ve eczanelere ekle
    for pharmacy in pharmacies:
        if pharmacy['location']['latitude'] and pharmacy['location']['longitude']:
            distance = calculate_distance(
                lat, lng, 
                pharmacy['location']['latitude'], 
                pharmacy['location']['longitude']
            )
            pharmacy['distance'] = round(distance, 2)
        else:
            pharmacy['distance'] = 9999  # Konum bilgisi olmayanlar için büyük değer
    
    # Mesafeye göre sırala
    sorted_pharmacies = sorted(pharmacies, key=lambda x: x.get('distance', 9999))
    
    # Limit uygula
    limited_pharmacies = sorted_pharmacies[:limit]
    
    result = {
        'status': 'success',
        'city': city,
        'district': district,
        'date': pharmacies_data['date'],
        'count': len(limited_pharmacies),
        'pharmacies': limited_pharmacies
    }
    
    return result

if __name__ == "__main__":
    # Test amaçlı
    result = get_on_duty_pharmacies("Istanbul", "Kadikoy")
    print(json.dumps(result, indent=2, ensure_ascii=False))
    
    # Konum bazlı test
    # Istanbul Kadıköy koordinatları
    lat = 40.9896
    lng = 29.0399
    
    closest = get_closest_pharmacies(lat, lng, "Istanbul", "Kadikoy", limit=5)
    print("\nEn yakın 5 eczane:")
    print(json.dumps(closest, indent=2, ensure_ascii=False))