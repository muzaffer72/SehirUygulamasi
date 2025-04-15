import 'package:flutter/material.dart';
import '../services/search_service.dart';
import '../models/search_suggestion.dart';

class SearchProvider extends ChangeNotifier {
  final SearchService _searchService;
  
  // Arama önerileri
  List<SearchSuggestion> _suggestions = [];
  List<SearchSuggestion> get suggestions => _suggestions;

  // Yükleniyor durumu
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Arama sonuçları
  Map<String, dynamic> _searchResults = {
    'posts': [],
    'surveys': [],
    'cities': [],
    'users': []
  };
  Map<String, dynamic> get searchResults => _searchResults;

  // Son yapılan arama sorgusu
  String _lastQuery = '';
  String get lastQuery => _lastQuery;

  SearchProvider({required SearchService searchService})
      : _searchService = searchService {
    // Provider oluşturulduğunda arama önerilerini getir
    loadSuggestions();
  }

  // Arama önerilerini yükle
  Future<void> loadSuggestions() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      _suggestions = await _searchService.getSearchSuggestions();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      print('Arama önerileri yükleme hatası: $e');
      notifyListeners();
    }
  }

  // Arama yap
  Future<void> search(String query) async {
    if (query.isEmpty) {
      _searchResults = {
        'posts': [],
        'surveys': [],
        'cities': [],
        'users': []
      };
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      _lastQuery = query;
      notifyListeners();
      
      _searchResults = await _searchService.search(query);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      print('Arama hatası: $e');
      notifyListeners();
    }
  }

  // Arama sonuçlarını temizle
  void clearSearchResults() {
    _searchResults = {
      'posts': [],
      'surveys': [],
      'cities': [],
      'users': []
    };
    _lastQuery = '';
    notifyListeners();
  }
}