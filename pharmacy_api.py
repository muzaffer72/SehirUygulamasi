from flask import Flask, jsonify, request, render_template
from pharmacy_service import get_on_duty_pharmacies, get_closest_pharmacies
import json

app = Flask(__name__)

# CORS ayarlarını aktifleştir
@app.after_request
def add_cors_headers(response):
    response.headers.add('Access-Control-Allow-Origin', '*')
    response.headers.add('Access-Control-Allow-Headers', 'Content-Type,Authorization')
    response.headers.add('Access-Control-Allow-Methods', 'GET,POST,OPTIONS')
    return response

# Şehir listesi end-point'i
@app.route('/cities', methods=['GET'])
def get_cities():
    # Örnek şehir listesi - Gerçek uygulamada veritabanından alınmalı
    cities = [
        {"id": "1", "name": "Adana", "plate": "01"},
        {"id": "2", "name": "Adıyaman", "plate": "02"},
        {"id": "3", "name": "Afyonkarahisar", "plate": "03"},
        {"id": "4", "name": "Ağrı", "plate": "04"},
        {"id": "5", "name": "Amasya", "plate": "05"},
        {"id": "6", "name": "Ankara", "plate": "06"},
        {"id": "7", "name": "Antalya", "plate": "07"},
        {"id": "8", "name": "Artvin", "plate": "08"},
        {"id": "9", "name": "Aydın", "plate": "09"},
        {"id": "10", "name": "Balıkesir", "plate": "10"},
        {"id": "11", "name": "Bilecik", "plate": "11"},
        {"id": "12", "name": "Bingöl", "plate": "12"},
        {"id": "13", "name": "Bitlis", "plate": "13"},
        {"id": "14", "name": "Bolu", "plate": "14"},
        {"id": "15", "name": "Burdur", "plate": "15"},
        {"id": "16", "name": "Bursa", "plate": "16"},
        {"id": "17", "name": "Çanakkale", "plate": "17"},
        {"id": "18", "name": "Çankırı", "plate": "18"},
        {"id": "19", "name": "Çorum", "plate": "19"},
        {"id": "20", "name": "Denizli", "plate": "20"},
        {"id": "21", "name": "Diyarbakır", "plate": "21"},
        {"id": "22", "name": "Edirne", "plate": "22"},
        {"id": "23", "name": "Elazığ", "plate": "23"},
        {"id": "24", "name": "Erzincan", "plate": "24"},
        {"id": "25", "name": "Erzurum", "plate": "25"},
        {"id": "26", "name": "Eskişehir", "plate": "26"},
        {"id": "27", "name": "Gaziantep", "plate": "27"},
        {"id": "28", "name": "Giresun", "plate": "28"},
        {"id": "29", "name": "Gümüşhane", "plate": "29"},
        {"id": "30", "name": "Hakkari", "plate": "30"},
        {"id": "31", "name": "Hatay", "plate": "31"},
        {"id": "32", "name": "Isparta", "plate": "32"},
        {"id": "33", "name": "Mersin", "plate": "33"},
        {"id": "34", "name": "İstanbul", "plate": "34"},
        {"id": "35", "name": "İzmir", "plate": "35"},
        {"id": "36", "name": "Kars", "plate": "36"},
        {"id": "37", "name": "Kastamonu", "plate": "37"},
        {"id": "38", "name": "Kayseri", "plate": "38"},
        {"id": "39", "name": "Kırklareli", "plate": "39"},
        {"id": "40", "name": "Kırşehir", "plate": "40"},
        {"id": "41", "name": "Kocaeli", "plate": "41"},
        {"id": "42", "name": "Konya", "plate": "42"},
        {"id": "43", "name": "Kütahya", "plate": "43"},
        {"id": "44", "name": "Malatya", "plate": "44"},
        {"id": "45", "name": "Manisa", "plate": "45"},
        {"id": "46", "name": "Kahramanmaraş", "plate": "46"},
        {"id": "47", "name": "Mardin", "plate": "47"},
        {"id": "48", "name": "Muğla", "plate": "48"},
        {"id": "49", "name": "Muş", "plate": "49"},
        {"id": "50", "name": "Nevşehir", "plate": "50"},
        {"id": "51", "name": "Niğde", "plate": "51"},
        {"id": "52", "name": "Ordu", "plate": "52"},
        {"id": "53", "name": "Rize", "plate": "53"},
        {"id": "54", "name": "Sakarya", "plate": "54"},
        {"id": "55", "name": "Samsun", "plate": "55"},
        {"id": "56", "name": "Siirt", "plate": "56"},
        {"id": "57", "name": "Sinop", "plate": "57"},
        {"id": "58", "name": "Sivas", "plate": "58"},
        {"id": "59", "name": "Tekirdağ", "plate": "59"},
        {"id": "60", "name": "Tokat", "plate": "60"},
        {"id": "61", "name": "Trabzon", "plate": "61"},
        {"id": "62", "name": "Tunceli", "plate": "62"},
        {"id": "63", "name": "Şanlıurfa", "plate": "63"},
        {"id": "64", "name": "Uşak", "plate": "64"},
        {"id": "65", "name": "Van", "plate": "65"},
        {"id": "66", "name": "Yozgat", "plate": "66"},
        {"id": "67", "name": "Zonguldak", "plate": "67"},
        {"id": "68", "name": "Aksaray", "plate": "68"},
        {"id": "69", "name": "Bayburt", "plate": "69"},
        {"id": "70", "name": "Karaman", "plate": "70"},
        {"id": "71", "name": "Kırıkkale", "plate": "71"},
        {"id": "72", "name": "Batman", "plate": "72"},
        {"id": "73", "name": "Şırnak", "plate": "73"},
        {"id": "74", "name": "Bartın", "plate": "74"},
        {"id": "75", "name": "Ardahan", "plate": "75"},
        {"id": "76", "name": "Iğdır", "plate": "76"},
        {"id": "77", "name": "Yalova", "plate": "77"},
        {"id": "78", "name": "Karabük", "plate": "78"},
        {"id": "79", "name": "Kilis", "plate": "79"},
        {"id": "80", "name": "Osmaniye", "plate": "80"},
        {"id": "81", "name": "Düzce", "plate": "81"}
    ]
    
    return jsonify({
        'status': 'success',
        'message': 'Şehir listesi başarıyla alındı',
        'cities': cities
    })

# İlçe listesi end-point'i
@app.route('/districts/<city_id>', methods=['GET'])
def get_districts(city_id):
    # Örnek ilçe listesi - Gerçek uygulamada veritabanından alınmalı
    # Burada sadece bazı büyük şehirler için örnek ilçeler eklendi
    districts_by_city = {
        "34": [  # İstanbul
            {"id": "1", "name": "Adalar", "city_id": "34"},
            {"id": "2", "name": "Bakırköy", "city_id": "34"},
            {"id": "3", "name": "Beşiktaş", "city_id": "34"},
            {"id": "4", "name": "Beyoğlu", "city_id": "34"},
            {"id": "5", "name": "Fatih", "city_id": "34"},
            {"id": "6", "name": "Kadıköy", "city_id": "34"},
            {"id": "7", "name": "Kartal", "city_id": "34"},
            {"id": "8", "name": "Maltepe", "city_id": "34"},
            {"id": "9", "name": "Pendik", "city_id": "34"},
            {"id": "10", "name": "Ümraniye", "city_id": "34"},
            {"id": "11", "name": "Üsküdar", "city_id": "34"},
        ],
        "6": [  # Ankara
            {"id": "12", "name": "Altındağ", "city_id": "6"},
            {"id": "13", "name": "Çankaya", "city_id": "6"},
            {"id": "14", "name": "Etimesgut", "city_id": "6"},
            {"id": "15", "name": "Keçiören", "city_id": "6"},
            {"id": "16", "name": "Mamak", "city_id": "6"},
            {"id": "17", "name": "Sincan", "city_id": "6"},
            {"id": "18", "name": "Yenimahalle", "city_id": "6"},
        ],
        "35": [  # İzmir
            {"id": "19", "name": "Bayraklı", "city_id": "35"},
            {"id": "20", "name": "Bornova", "city_id": "35"},
            {"id": "21", "name": "Buca", "city_id": "35"},
            {"id": "22", "name": "Çiğli", "city_id": "35"},
            {"id": "23", "name": "Karşıyaka", "city_id": "35"},
            {"id": "24", "name": "Konak", "city_id": "35"},
        ],
        "16": [  # Bursa
            {"id": "25", "name": "Nilüfer", "city_id": "16"},
            {"id": "26", "name": "Osmangazi", "city_id": "16"},
            {"id": "27", "name": "Yıldırım", "city_id": "16"},
        ],
        "1": [  # Adana
            {"id": "28", "name": "Çukurova", "city_id": "1"},
            {"id": "29", "name": "Seyhan", "city_id": "1"},
            {"id": "30", "name": "Yüreğir", "city_id": "1"},
        ],
    }
    
    districts = districts_by_city.get(city_id, [])
    
    return jsonify({
        'status': 'success',
        'message': 'İlçe listesi başarıyla alındı',
        'districts': districts
    })

# Nöbetçi eczaneler API
@app.route('/pharmacies', methods=['GET'])
def get_pharmacies():
    city = request.args.get('city', '')
    district = request.args.get('district', None)
    lat = request.args.get('lat', None)
    lng = request.args.get('lng', None)
    
    if not city:
        return jsonify({
            'status': 'error',
            'message': 'Şehir parametresi gereklidir'
        }), 400
    
    # Konum bilgisi varsa, en yakın eczaneleri getir
    if lat and lng:
        try:
            lat = float(lat)
            lng = float(lng)
            limit = int(request.args.get('limit', 10))
            result = get_closest_pharmacies(lat, lng, city, district, limit)
        except ValueError:
            return jsonify({
                'status': 'error',
                'message': 'Geçersiz konum değeri'
            }), 400
    # Yoksa normal listele
    else:
        result = get_on_duty_pharmacies(city, district)
    
    return jsonify(result)

# En yakın eczaneler API (eski yöntem - geriye uyumluluk için)
@app.route('/api/pharmacies/closest', methods=['GET'])
def get_pharmacies_by_distance():
    city = request.args.get('city', '')
    district = request.args.get('district', None)
    lat = request.args.get('lat', None)
    lng = request.args.get('lng', None)
    limit = request.args.get('limit', 10)
    
    if not city:
        return jsonify({
            'status': 'error',
            'message': 'Şehir parametresi gereklidir'
        }), 400
    
    if not lat or not lng:
        return jsonify({
            'status': 'error',
            'message': 'Konum parametreleri (lat, lng) gereklidir'
        }), 400
    
    try:
        lat = float(lat)
        lng = float(lng)
        limit = int(limit)
    except ValueError:
        return jsonify({
            'status': 'error',
            'message': 'Geçersiz konum ya da limit değeri'
        }), 400
    
    result = get_closest_pharmacies(lat, lng, city, district, limit)
    return jsonify(result)

# Eski API endpoint'i (geriye uyumluluk için)
@app.route('/api/pharmacies', methods=['GET'])
def get_pharmacies_api_old():
    return get_pharmacies()

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5001)