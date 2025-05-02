import requests
from bs4 import BeautifulSoup
import re
import math
import json
from datetime import datetime
import os

# Önbellek süresi (saniye)
CACHE_DURATION = 3600
cache = {}

def clean_text(text):
    """Metni temizler, fazla boşlukları kaldırır."""
    if not text:
        return ""
    return re.sub(r'\s+', ' ', text).strip()

def get_on_duty_pharmacies(city, district=None):
    """Belirli bir şehir ve ilçe için nöbetçi eczaneleri getirir."""
    # Önbellekte var mı kontrol et
    cache_key = f"{city}_{district or ''}"
    now = datetime.now().timestamp()
    
    if cache_key in cache and (now - cache[cache_key]['timestamp'] < CACHE_DURATION):
        return cache[cache_key]['data']
    
    # Şehir ve ilçe adını düzenle
    city = city.strip().title()
    if district:
        district = district.strip().title()
    
    # Nöbetçi eczane verilerini çek
    try:
        pharmacies = fetch_pharmacy_data(city, district)
        
        # Önbelleğe al
        cache[cache_key] = {
            'timestamp': now,
            'data': pharmacies
        }
        
        return pharmacies
    except Exception as e:
        print(f"Eczane verisi alınırken hata: {str(e)}")
        raise Exception(f"Eczane verisi alınamadı: {str(e)}")

def get_closest_pharmacies(lat, lng, city, district=None, limit=10):
    """Belirli bir konuma en yakın nöbetçi eczaneleri sıralar."""
    pharmacies = get_on_duty_pharmacies(city, district)
    
    # Konum bilgisi olan eczaneleri filtrele
    pharmacies_with_location = []
    
    for pharmacy in pharmacies:
        if 'latitude' in pharmacy and 'longitude' in pharmacy and pharmacy['latitude'] and pharmacy['longitude']:
            # Mesafeyi hesapla
            distance = calculate_distance(
                lat, lng,
                float(pharmacy['latitude']),
                float(pharmacy['longitude'])
            )
            pharmacy['distance'] = distance
            pharmacies_with_location.append(pharmacy)
    
    # Mesafeye göre sırala
    pharmacies_with_location.sort(key=lambda x: x['distance'])
    
    # Maksimum eczane sayısını kontrol et
    return pharmacies_with_location[:limit]

def calculate_distance(lat1, lon1, lat2, lon2):
    """İki nokta arasındaki mesafeyi kilometre cinsinden hesaplar (Haversine formülü)."""
    R = 6371  # Dünya yarıçapı (km)
    
    # Açıları radyana çevir
    lat1_rad = math.radians(lat1)
    lon1_rad = math.radians(lon1)
    lat2_rad = math.radians(lat2)
    lon2_rad = math.radians(lon2)
    
    # Enlem ve boylam farkları
    d_lat = lat2_rad - lat1_rad
    d_lon = lon2_rad - lon1_rad
    
    # Haversine formülü
    a = math.sin(d_lat/2) * math.sin(d_lat/2) + math.cos(lat1_rad) * math.cos(lat2_rad) * math.sin(d_lon/2) * math.sin(d_lon/2)
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a))
    distance = R * c
    
    return distance

def fetch_pharmacy_data(city, district=None):
    """Nöbetçi eczane verilerini çekme fonksiyonu"""
    # Gerçek veri kaynağı: E-Devlet veya İl Sağlık Müdürlükleri
    # Bu fonksiyon, gerçek API olmadığı için örnek veri döndürür
    
    # Örnek veri (gerçek uygulamada burada sağlık bakanlığı veya il sağlık müdürlüğü API'si kullanılacak)
    sample_pharmacies = [
        {
            "name": "Merkez Eczanesi",
            "address": f"{city} Merkez, Atatürk Caddesi No:123",
            "phone": "0312 123 45 67",
            "latitude": "39.925533",
            "longitude": "32.866287"
        },
        {
            "name": "Şifa Eczanesi",
            "address": f"{city} {district or 'Merkez'}, Cumhuriyet Mahallesi, İnönü Caddesi No:45",
            "phone": "0312 234 56 78",
            "latitude": "39.920053",
            "longitude": "32.854227"
        },
        {
            "name": "Hayat Eczanesi",
            "address": f"{city} {district or 'Merkez'}, Kızılay Meydanı No:7",
            "phone": "0312 345 67 89",
            "latitude": "39.918077",
            "longitude": "32.848726"
        },
        {
            "name": "Yeni Eczane",
            "address": f"{city} {district or 'Merkez'}, Bahçelievler 7. Cadde No:12/A",
            "phone": "0312 456 78 90",
            "latitude": "39.911212",
            "longitude": "32.863092"
        },
        {
            "name": "Güven Eczanesi",
            "address": f"{city} {district or 'Merkez'}, ODTÜ Karşısı Çankaya Caddesi No:56",
            "phone": "0312 567 89 01",
            "latitude": "39.889977",
            "longitude": "32.780563"
        }
    ]
    
    # NOT: Gerçek uygulamada, bu fonksiyon e-devlet veya resmi sağlık kurumlarından veri çekecektir
    # Eğer gerçek veri API'si eklenirse, bu kısım değiştirilmelidir
    
    # Gerçek uygulamada veri yoksa boş liste döndür
    if city.lower() not in ["ankara", "istanbul", "izmir"]:
        return []
    
    return sample_pharmacies