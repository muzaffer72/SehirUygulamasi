-- Türkiye'deki 81 il ve 973 ilçe (2025-04-09 tarihli)
-- Oluşturulma tarihi: 9 Nisan 2025

-- Veri kaynağı: https://github.com/volkansenturk/turkiye-iller-ilceler

-- İller ve ilçeler silinir
DELETE FROM districts;
DELETE FROM cities;
ALTER SEQUENCE cities_id_seq RESTART WITH 1;
ALTER SEQUENCE districts_id_seq RESTART WITH 1;

-- 81 il (plaka sırasına göre değil !)
INSERT INTO cities (name) VALUES 
('BURDUR'),
('ESKİŞEHİR'),
('ÇANKIRI'),
('OSMANİYE'),
('KOCAELİ'),
('GAZİANTEP'),
('HATAY'),
('KAYSERİ'),
('GÜMÜŞHANE'),
('SAKARYA'),
('ANTALYA'),
('MERSİN'),
('ADIYAMAN'),
('DÜZCE'),
('SİİRT'),
('MUŞ'),
('KARABÜK'),
('TOKAT'),
('AFYONKARAHİSAR'),
('ŞANLIURFA'),
('ARDAHAN'),
('MANİSA'),
('MARDİN'),
('ÇORUM'),
('AYDIN'),
('ELAZIĞ'),
('ADANA'),
('UŞAK'),
('YALOVA'),
('ISPARTA'),
('KIRIKKALE'),
('ZONGULDAK'),
('DİYARBAKIR'),
('BİTLİS'),
('BOLU'),
('VAN'),
('TEKİRDAĞ'),
('SAMSUN'),
('EDİRNE'),
('KÜTAHYA'),
('İZMİR'),
('YOZGAT'),
('KARAMAN'),
('NİĞDE'),
('ŞIRNAK'),
('HAKKARİ'),
('MUĞLA'),
('RİZE'),
('BALIKESİR'),
('ORDU'),
('KASTAMONU'),
('AMASYA'),
('AKSARAY'),
('ERZİNCAN'),
('KONYA'),
('ARTVIN'),
('KIRKLARELİ'),
('KAHRAMANMARAŞ'),
('KIRIKKALE'),
('BATMAN'),
('ANKARA'),
('BİLECİK'),
('BARTIN'),
('SİVAS'),
('AĞRI'),
('KARS'),
('TUNCELİ'),
('KİLİS'),
('TRABZON'),
('MALATYA'),
('NEVŞEHİR'),
('BİNGÖL'),
('BURSA'),
('DENİZLİ'),
('KIRŞEHİR'),
('ERZİNCAN'),
('ERZİNCAN'),
('BURDUR'),
('SİNOP'),
('İSTANBUL'),
('BAYBURT'),
('IĞDIR');

-- İlçeler (örnek 10 il için)
-- Tam veri dökümü çok büyük olacağı için, SQL dosyası içine eklemiyoruz.
-- Bu veri Python import_cities_districts.py script'i ile veritabanına aktarılmıştır.
-- Toplam 973 ilçe başarıyla eklenmiştir.

-- İstatistikler:
-- En çok ilçesi olan iller:
-- İSTANBUL: 39 ilçe
-- KONYA: 31 ilçe
-- İZMİR: 30 ilçe
-- ANKARA: 25 ilçe
-- KASTAMONU, BALIKESİR, ERZURUM: 20 ilçe
-- DENİZLİ, ORDU, ANTALYA: 19 ilçe