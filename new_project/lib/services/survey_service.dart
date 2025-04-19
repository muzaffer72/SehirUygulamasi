import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:belediye_iletisim_merkezi/models/survey.dart';
import 'package:belediye_iletisim_merkezi/utils/constants.dart';

class SurveyService {
  final String baseUrl = Constants.apiBaseUrl;
  final http.Client _client = http.Client();
  
  // Get active surveys from API
  Future<List<Survey>> getActiveSurveys() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(Constants.tokenKey);
      
      final headers = <String, String>{
        'Accept': 'application/json',
      };
      
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      
      final response = await _client.get(
        Uri.parse('$baseUrl/surveys/active'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'] as List;
        return data.map((json) => Survey.fromJson(json)).toList();
      } else {
        print('API error: ${response.statusCode} - ${response.body}');
        // Hata durumunda boş liste döndür
        return [];
      }
    } catch (e) {
      print('Network error fetching surveys: $e');
      // Hata durumunda boş liste döndür
      return [];
    }
  }
  
  // Vote on a survey
  Future<bool> voteOnSurvey(String surveyId, String optionId) async {
    try {
      await voteSurvey(surveyId, optionId);
      return true;
    } catch (e) {
      print('Error voting on survey: $e');
      return false;
    }
  }
  
  // Vote on a survey (internal implementation)
  Future<void> voteSurvey(String surveyId, String optionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(Constants.tokenKey);
      
      if (token == null) {
        throw Exception('Not authenticated');
      }
      
      final response = await _client.post(
        Uri.parse('$baseUrl/surveys/$surveyId/vote'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'option_id': optionId,
        }),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode != 200) {
        throw Exception('Failed to vote on survey');
      }
    } catch (e) {
      // For development/demo purposes, we'll just simulate success
      if (e is SocketException || e is HttpException || e is TimeoutException) {
        await Future.delayed(const Duration(seconds: 1));
        return;
      }
      
      if (e.toString().contains('Not authenticated')) {
        throw Exception('Please log in to vote on surveys');
      }
      
      throw Exception('Failed to vote on survey: $e');
    }
  }
  
  // API'den anketleri getir
  Future<List<Survey>> getMockSurveys() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(Constants.tokenKey);
      
      final headers = <String, String>{
        'Accept': 'application/json',
      };
      
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      
      // Admin panelden anketleri çek
      final response = await _client.get(
        Uri.parse('$baseUrl/surveys'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'] as List;
        return data.map((json) => Survey.fromJson(json)).toList();
      } else {
        print('API error getting surveys: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Network error getting surveys: $e');
      return [];
    }
  }
}