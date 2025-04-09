import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sikayet_var/models/survey.dart';
import 'package:sikayet_var/utils/constants.dart';

class SurveyService {
  final String baseUrl = Constants.apiBaseUrl;
  final http.Client _client = http.Client();
  
  // Get active surveys
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
        throw Exception('Failed to load surveys');
      }
    } catch (e) {
      // For development/demo purposes
      if (e is SocketException || e is HttpException || e is TimeoutException) {
        await Future.delayed(const Duration(seconds: 1));
        return getMockSurveys();
      }
      throw Exception('Failed to load surveys: $e');
    }
  }
  
  // Vote on a survey
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
  
  // Mock data for development/testing
  List<Survey> getMockSurveys() {
    final now = DateTime.now();
    
    return [
      Survey(
        id: 'survey_1',
        title: 'Park alanları hakkında',
        description: 'Şehrimizdeki park alanlarının kullanımı hakkında görüşlerinizi paylaşın',
        question: 'Şehrimizdeki park alanlarını ne sıklıkla kullanıyorsunuz?',
        options: [
          SurveyOption(
            id: 'option_1_1',
            surveyId: 'survey_1',
            text: 'Her gün',
            voteCount: 156,
          ),
          SurveyOption(
            id: 'option_1_2',
            surveyId: 'survey_1',
            text: 'Haftada birkaç kez',
            voteCount: 287,
          ),
          SurveyOption(
            id: 'option_1_3',
            surveyId: 'survey_1',
            text: 'Ayda birkaç kez',
            voteCount: 142,
          ),
          SurveyOption(
            id: 'option_1_4',
            surveyId: 'survey_1',
            text: 'Çok nadir',
            voteCount: 83,
          ),
        ],
        startDate: now.subtract(const Duration(days: 10)),
        endDate: now.add(const Duration(days: 5)),
        isActive: true,
        voteCount: 668,
        cityId: 'city_1', // İstanbul
        districtId: null,
      ),
      Survey(
        id: 'survey_2',
        title: 'Toplu taşıma memnuniyeti',
        description: 'Toplu taşıma hizmetleri hakkında memnuniyetinizi değerlendirin',
        question: 'Belediyenin toplu taşıma hizmetlerinden ne kadar memnunsunuz?',
        options: [
          SurveyOption(
            id: 'option_2_1',
            surveyId: 'survey_2',
            text: 'Çok memnunum',
            voteCount: 94,
          ),
          SurveyOption(
            id: 'option_2_2',
            surveyId: 'survey_2',
            text: 'Memnunum',
            voteCount: 241,
          ),
          SurveyOption(
            id: 'option_2_3',
            surveyId: 'survey_2',
            text: 'Kararsızım',
            voteCount: 87,
          ),
          SurveyOption(
            id: 'option_2_4',
            surveyId: 'survey_2',
            text: 'Memnun değilim',
            voteCount: 175,
          ),
          SurveyOption(
            id: 'option_2_5',
            surveyId: 'survey_2',
            text: 'Hiç memnun değilim',
            voteCount: 138,
          ),
        ],
        startDate: now.subtract(const Duration(days: 15)),
        endDate: now.add(const Duration(days: 15)),
        isActive: true,
        voteCount: 735,
        cityId: 'city_1', // İstanbul
        districtId: null,
      ),
      Survey(
        id: 'survey_3',
        title: 'Çöp toplama hizmetleri',
        description: 'Kadıköy bölgesindeki çöp toplama hizmetleri hakkında anket',
        question: 'Kadıköy ilçesinde çöp toplama hizmetleri hangi sıklıkta yapılmalı?',
        options: [
          SurveyOption(
            id: 'option_3_1',
            surveyId: 'survey_3',
            text: 'Günde iki kez',
            voteCount: 78,
          ),
          SurveyOption(
            id: 'option_3_2',
            surveyId: 'survey_3',
            text: 'Günde bir kez',
            voteCount: 192,
          ),
          SurveyOption(
            id: 'option_3_3',
            surveyId: 'survey_3',
            text: 'İki günde bir',
            voteCount: 35,
          ),
        ],
        startDate: now.subtract(const Duration(days: 5)),
        endDate: now.add(const Duration(days: 25)),
        isActive: true,
        voteCount: 305,
        cityId: 'city_1', // İstanbul
        districtId: 'district_1', // Kadıköy
      ),
    ];
  }
}