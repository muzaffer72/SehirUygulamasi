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
      final response = await http.get(
        Uri.parse('${apiConfig.baseUrl}/search_suggestions'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> suggestionsJson = data['suggestions'];

        return suggestionsJson
            .map((json) => SearchSuggestion.fromJson(json))
            .toList();
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
      final response = await http.get(
        Uri.parse('${apiConfig.baseUrl}/search?q=${Uri.encodeComponent(query)}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Arama sonuçları alınamadı: ${response.statusCode}');
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