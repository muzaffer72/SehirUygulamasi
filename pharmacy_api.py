import flask
from flask import Flask, jsonify, request
from pharmacy_service import get_on_duty_pharmacies, get_closest_pharmacies
import os

app = Flask(__name__)

@app.route('/status')
def status():
    """Servis durum bilgisini döndürür"""
    return jsonify({
        'status': 'running',
        'version': '1.0.0'
    })

@app.route('/pharmacies')
def get_pharmacies():
    """
    Belirli bir şehir ve ilçeye göre nöbetçi eczaneleri döndürür
    
    İsteğe bağlı parametreler:
    - city: Şehir adı (zorunlu)
    - district: İlçe adı (opsiyonel)
    """
    city = request.args.get('city')
    district = request.args.get('district')
    
    if not city:
        return jsonify({
            'error': 'Şehir adı belirtilmedi',
            'pharmacies': []
        })
    
    try:
        pharmacies = get_on_duty_pharmacies(city, district)
        return jsonify({
            'city': city,
            'district': district,
            'pharmacies': pharmacies
        })
    except Exception as e:
        return jsonify({
            'error': str(e),
            'pharmacies': []
        })

@app.route('/pharmacies/by_distance')
def get_pharmacies_by_distance():
    """
    Belirli bir konuma göre en yakın nöbetçi eczaneleri döndürür
    
    İsteğe bağlı parametreler:
    - city: Şehir adı (zorunlu)
    - lat: Enlem (zorunlu)
    - lng: Boylam (zorunlu)
    - district: İlçe adı (opsiyonel)
    - limit: Maksimum eczane sayısı (opsiyonel, varsayılan: 10)
    """
    city = request.args.get('city')
    lat = request.args.get('lat')
    lng = request.args.get('lng')
    district = request.args.get('district')
    limit = request.args.get('limit', 10, type=int)
    
    if not city or not lat or not lng:
        return jsonify({
            'error': 'Şehir ve konum bilgileri eksik',
            'pharmacies': []
        })
    
    try:
        pharmacies = get_closest_pharmacies(
            float(lat), float(lng), city, district, limit
        )
        return jsonify({
            'city': city,
            'district': district,
            'location': {'lat': float(lat), 'lng': float(lng)},
            'pharmacies': pharmacies
        })
    except Exception as e:
        return jsonify({
            'error': str(e),
            'pharmacies': []
        })

@app.after_request
def add_cors_headers(response):
    """CORS header'larını ekler"""
    response.headers['Access-Control-Allow-Origin'] = '*'
    response.headers['Access-Control-Allow-Methods'] = 'GET, POST, OPTIONS'
    response.headers['Access-Control-Allow-Headers'] = 'Content-Type'
    return response

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5001))
    app.run(host='0.0.0.0', port=port, debug=True)