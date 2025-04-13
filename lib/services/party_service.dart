import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/political_party.dart';
import '../utils/api_helper.dart';
import 'api_service.dart';

class PartyService {
  final ApiService _apiService = ApiService();
  
  // Tüm partileri getir (problem çözme oranına göre sıralanmış)
  Future<List<PoliticalParty>> getParties() async {
    try {
      final response = await _apiService.get('/api/parties');
      
      if (response.statusCode == 200) {
        final List<dynamic> partiesJson = json.decode(response.body);
        return partiesJson.map((partyJson) => PoliticalParty.fromJson(partyJson)).toList();
      } else {
        throw Exception('Partiler yüklenirken bir hata oluştu: ${response.statusCode}');
      }
    } catch (e) {
      print('Parti servisi hatası: $e');
      // API henüz hazır değilse veya bir hata durumunda demo veriler kullan
      return PoliticalParty.getDemoParties();
    }
  }
  
  // Parti detaylarını getir
  Future<PoliticalParty> getPartyDetails(int partyId) async {
    try {
      final response = await _apiService.get('/api/parties/$partyId');
      
      if (response.statusCode == 200) {
        final dynamic partyJson = json.decode(response.body);
        return PoliticalParty.fromJson(partyJson);
      } else {
        throw Exception('Parti detayları yüklenirken bir hata oluştu: ${response.statusCode}');
      }
    } catch (e) {
      print('Parti detay servisi hatası: $e');
      // API henüz hazır değilse veya bir hata durumunda demo parti detayını döndür
      return PoliticalParty.getDemoParties().firstWhere(
        (party) => party.id == partyId,
        orElse: () => PoliticalParty.getDemoParties().first
      );
    }
  }
  
  // Performans istatistiklerini yeniden hesapla (admin paneli için)
  Future<bool> recalculatePerformanceStats() async {
    try {
      final response = await _apiService.post('/api/admin/parties/recalculate-stats', {});
      
      return response.statusCode == 200;
    } catch (e) {
      print('Performans istatistikleri hesaplama hatası: $e');
      return false;
    }
  }
}