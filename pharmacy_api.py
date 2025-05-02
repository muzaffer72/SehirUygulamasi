from flask import Flask, jsonify, request
from pharmacy_service import get_on_duty_pharmacies, get_closest_pharmacies
import json

app = Flask(__name__)

@app.route('/api/pharmacies', methods=['GET'])
def get_pharmacies():
    city = request.args.get('city', '')
    district = request.args.get('district', None)
    
    if not city:
        return jsonify({
            'status': 'error',
            'message': 'Şehir parametresi gereklidir'
        }), 400
    
    result = get_on_duty_pharmacies(city, district)
    return jsonify(result)

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

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5001)