import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/search_suggestion.dart';
import '../config/api_config.dart';

class SearchService {
  final ApiConfig apiConfig;

  SearchService({required this.apiConfig});

  // Arama önerilerini getir
  Future<List<SearchSuggestion>> getSearchSuggestions() async {
    try {
      print('Arama önerileri alınıyor: ${apiConfig.baseUrl}/api/search_suggestions');
      
      final response = await http.get(
        Uri.parse('${apiConfig.baseUrl}/api/search_suggestions'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Arama önerileri API yanıtı: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print('API yanıt verisi: $data');
        
        if (data.containsKey('suggestions')) {
          final List<dynamic> suggestionsJson = data['suggestions'];
          print('${suggestionsJson.length} adet öneri bulundu');
          
          return suggestionsJson
              .map((json) => SearchSuggestion.fromJson(json))
              .toList();
        } else {
          print('API yanıtında "suggestions" anahtarı bulunamadı');
          return [];
        }
      } else {
        print('Arama önerileri alınamadı: ${response.statusCode}');
        print('Hata detay: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Arama önerileri getirme hatası: $e');
      return [];
    }
  }

  // Arama yapma işlevi
  Future<Map<String, dynamic>> search(String query) async {
    try {
      print('Arama yapılıyor: ${apiConfig.baseUrl}/api/search?q=${Uri.encodeComponent(query)}');
      
      final response = await http.get(
        Uri.parse('${apiConfig.baseUrl}/api/search?q=${Uri.encodeComponent(query)}'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Arama API yanıtı: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Arama sonuçları: $data');
        return data;
      } else {
        print('Arama sonuçları alınamadı: ${response.statusCode}');
        print('Hata detay: ${response.body}');
        return {
          'posts': [],
          'surveys': [],
          'cities': [],
          'users': []
        };
      }
    } catch (e) {
      print('Arama işlemi hatası: $e');
      return {
        'posts': [],
        'surveys': [],
        'cities': [],
        'users': []
      };
    }
  }
}