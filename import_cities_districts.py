import os
import csv
import psycopg2
from psycopg2.extras import execute_values

# Veritabanı bağlantısı
database_url = os.environ.get('DATABASE_URL')
if not database_url:
    raise ValueError("DATABASE_URL environment variable is not set")

# İl ve ilçe verileri
il_csv = 'il.csv'
ilce_csv = 'ilce.csv'

# Türkçe karakterleri düzeltme fonksiyonu
def fix_turkish_chars(text):
    return text.replace('İ', 'İ').replace('Ş', 'Ş').replace('Ğ', 'Ğ').replace('Ü', 'Ü').replace('Ö', 'Ö').replace('Ç', 'Ç')

try:
    # Veritabanına bağlan
    conn = psycopg2.connect(database_url)
    cursor = conn.cursor()
    
    # Mevcut verileri temizle (isteğe bağlı)
    print("Mevcut şehir ve ilçe verileri temizleniyor...")
    cursor.execute("DELETE FROM districts")
    cursor.execute("DELETE FROM cities")
    cursor.execute("ALTER SEQUENCE cities_id_seq RESTART WITH 1")
    cursor.execute("ALTER SEQUENCE districts_id_seq RESTART WITH 1")
    conn.commit()
    
    # İlleri içe aktar
    print("İller içe aktarılıyor...")
    cities_data = []
    city_id_mapping = {}  # plaka -> db_id eşleştirmesi için
    
    with open(il_csv, 'r', encoding='utf-8') as f:
        reader = csv.reader(f)
        for row in reader:
            plate_code = row[0].strip('"')
            city_name = fix_turkish_chars(row[1].strip('"'))
            cities_data.append((city_name,))
            city_id_mapping[plate_code] = len(cities_data)  # 1'den başlayan index
    
    # İlleri veritabanına ekle
    insert_sql = """
    INSERT INTO cities (name, created_at) 
    VALUES %s 
    RETURNING id, name
    """
    
    execute_values(
        cursor, 
        insert_sql, 
        cities_data,
        template="(%s, NOW())"
    )
    
    # İlçeleri içe aktar
    print("İlçeler içe aktarılıyor...")
    districts_data = []
    
    with open(ilce_csv, 'r', encoding='utf-8') as f:
        reader = csv.reader(f)
        for row in reader:
            # district_id = row[0].strip('"')
            city_plate = row[1].strip('"')
            district_name = fix_turkish_chars(row[2].strip('"'))
            
            # Şehir plaka kodunu veritabanı ID'sine dönüştür
            if city_plate in city_id_mapping:
                city_db_id = city_id_mapping[city_plate]
                districts_data.append((district_name, city_db_id))
            else:
                print(f"Uyarı: {city_plate} plaka kodlu il bulunamadı, ilçe '{district_name}' eklenemedi")
    
    # İlçeleri veritabanına ekle
    insert_sql = """
    INSERT INTO districts (name, city_id, created_at) 
    VALUES %s
    """
    
    execute_values(
        cursor, 
        insert_sql, 
        districts_data,
        template="(%s, %s, NOW())"
    )
    
    # İşlemi tamamla
    conn.commit()
    
    # Sonuçları göster
    cursor.execute("SELECT COUNT(*) FROM cities")
    city_count = cursor.fetchone()[0]
    
    cursor.execute("SELECT COUNT(*) FROM districts")
    district_count = cursor.fetchone()[0]
    
    print(f"Toplam {city_count} il ve {district_count} ilçe başarıyla içe aktarıldı.")
    
except Exception as e:
    print(f"Hata oluştu: {e}")
    if conn:
        conn.rollback()
finally:
    if cursor:
        cursor.close()
    if conn:
        conn.close()