import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/political_party.dart';
import 'api_service.dart';

class PartyService {
  final ApiService _apiService = ApiService();

  // Tüm partileri getir
  Future<List<PoliticalParty>> getParties() async {
    try {
      final response = await _apiService.get('parties');
      
      if (response.statusCode == 200) {
        final List<dynamic> partiesJson = json.decode(response.body);
        return partiesJson.map((json) => PoliticalParty.fromJson(json)).toList();
      } else {
        throw Exception('Partiler alınamadı: ${response.statusCode}');
      }
    } catch (e) {
      // Hata durumunda boş liste yerine hatayı yukarı fırlat
      throw Exception('Parti verisi alınamadı: $e');
    }
  }

  // Belirli bir partiyi ID'ye göre getir
  Future<PoliticalParty> getParty(int id) async {
    try {
      final response = await _apiService.get('parties/$id');
      
      if (response.statusCode == 200) {
        return PoliticalParty.fromJson(json.decode(response.body));
      } else {
        throw Exception('Parti bulunamadı: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Parti bilgisi alınamadı: $e');
    }
  }

  // Tüm parti istatistiklerini yeniden hesapla (admin fonksiyonu)
  Future<Map<String, dynamic>> recalculatePartyStats() async {
    try {
      final response = await _apiService.post('parties/recalculate-stats', {});
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('İstatistikler yeniden hesaplanamadı: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('İstatistik hesaplama hatası: $e');
    }
  }
}