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
  
  // Mock data for development/testing
  List<Survey> getMockSurveys() {
    final now = DateTime.now();
    
    return [
      // Genel anket - Tüm Türkiye için geçerli
      Survey(
        id: 'survey_1',
        title: 'Ulusal bayramlar hakkında',
        shortTitle: 'Bayram Etkinlikleri',
        description: 'Ulusal bayramlarımızla ilgili etkinliklere katılımınızı değerlendirin',
        question: 'Ulusal bayramlarda düzenlenen etkinliklere ne sıklıkla katılıyorsunuz?',
        imageUrl: 'https://example.com/images/bayram.jpg',
        scopeType: 'general', // Genel kapsam - tüm Türkiye çapında gösterilecek
        totalUsers: 5000,
        options: [
          SurveyOption(
            id: 'option_1_1',
            surveyId: 'survey_1',
            text: 'Her zaman katılırım',
            voteCount: 356,
          ),
          SurveyOption(
            id: 'option_1_2',
            surveyId: 'survey_1',
            text: 'Çoğunlukla katılırım',
            voteCount: 487,
          ),
          SurveyOption(
            id: 'option_1_3',
            surveyId: 'survey_1',
            text: 'Bazen katılırım',
            voteCount: 242,
          ),
          SurveyOption(
            id: 'option_1_4',
            surveyId: 'survey_1',
            text: 'Nadiren katılırım',
            voteCount: 183,
          ),
          SurveyOption(
            id: 'option_1_5',
            surveyId: 'survey_1',
            text: 'Hiç katılmam',
            voteCount: 83,
          ),
        ],
        startDate: now.subtract(const Duration(days: 10)),
        endDate: now.add(const Duration(days: 20)),
        isActive: true,
        totalVotes: 1351,
        categoryId: 'category_1', // Etkinlikler kategorisi
      ),
      
      // İl bazlı anket - Tüm Türkiye seçeneği ile
      Survey(
        id: 'survey_2',
        title: 'Toplu taşıma memnuniyeti',
        shortTitle: 'Toplu Taşıma',
        description: 'Belediyelerin sunduğu toplu taşıma hizmetleri hakkında memnuniyetinizi değerlendirin',
        question: 'Yaşadığınız şehirdeki toplu taşıma hizmetlerinden ne kadar memnunsunuz?',
        imageUrl: 'https://example.com/images/toplu_tasima.jpg',
        scopeType: 'city', // İl bazlı anket
        cityId: 'all', // "Tüm Türkiye" seçeneği - her il için ayrı sonuçlar
        totalUsers: 8500,
        options: [
          SurveyOption(
            id: 'option_2_1',
            surveyId: 'survey_2',
            text: 'Çok memnunum',
            voteCount: 194,
          ),
          SurveyOption(
            id: 'option_2_2',
            surveyId: 'survey_2',
            text: 'Memnunum',
            voteCount: 341,
          ),
          SurveyOption(
            id: 'option_2_3',
            surveyId: 'survey_2',
            text: 'Kararsızım',
            voteCount: 187,
          ),
          SurveyOption(
            id: 'option_2_4',
            surveyId: 'survey_2',
            text: 'Memnun değilim',
            voteCount: 275,
          ),
          SurveyOption(
            id: 'option_2_5',
            surveyId: 'survey_2',
            text: 'Hiç memnun değilim',
            voteCount: 238,
          ),
        ],
        startDate: now.subtract(const Duration(days: 15)),
        endDate: now.add(const Duration(days: 15)),
        isActive: true,
        totalVotes: 1235,
        categoryId: 'category_2', // Ulaşım kategorisi
      ),
      
      // İl bazlı anket - Belirli bir şehre özel
      Survey(
        id: 'survey_3',
        title: 'Park alanları hakkında',
        shortTitle: 'Park Kullanımı',
        description: 'İstanbul\'daki park alanlarının kullanımı hakkında görüşlerinizi paylaşın',
        question: 'İstanbul\'daki park alanlarını ne sıklıkla kullanıyorsunuz?',
        scopeType: 'city', // İl bazlı anket
        cityId: 'city_1', // İstanbul
        totalUsers: 3200,
        options: [
          SurveyOption(
            id: 'option_3_1',
            surveyId: 'survey_3',
            text: 'Her gün',
            voteCount: 156,
          ),
          SurveyOption(
            id: 'option_3_2',
            surveyId: 'survey_3',
            text: 'Haftada birkaç kez',
            voteCount: 287,
          ),
          SurveyOption(
            id: 'option_3_3',
            surveyId: 'survey_3',
            text: 'Ayda birkaç kez',
            voteCount: 142,
          ),
          SurveyOption(
            id: 'option_3_4',
            surveyId: 'survey_3',
            text: 'Çok nadir',
            voteCount: 83,
          ),
        ],
        startDate: now.subtract(const Duration(days: 10)),
        endDate: now.add(const Duration(days: 5)),
        isActive: true,
        totalVotes: 668,
        categoryId: 'category_3', // Çevre ve yeşil alanlar kategorisi
      ),
      
      // İlçe bazlı anket - belirli bir ilçeye özel
      Survey(
        id: 'survey_4',
        title: 'Çöp toplama hizmetleri',
        shortTitle: 'Çöp Toplama',
        description: 'Kadıköy ilçesindeki çöp toplama hizmetleri hakkında anket',
        question: 'Kadıköy ilçesinde çöp toplama hizmetleri hangi sıklıkta yapılmalı?',
        scopeType: 'district', // İlçe bazlı anket
        cityId: 'city_1', // İstanbul
        districtId: 'district_1', // Kadıköy
        totalUsers: 1200,
        options: [
          SurveyOption(
            id: 'option_4_1',
            surveyId: 'survey_4',
            text: 'Günde iki kez',
            voteCount: 78,
          ),
          SurveyOption(
            id: 'option_4_2',
            surveyId: 'survey_4',
            text: 'Günde bir kez',
            voteCount: 192,
          ),
          SurveyOption(
            id: 'option_4_3',
            surveyId: 'survey_4',
            text: 'İki günde bir',
            voteCount: 35,
          ),
        ],
        startDate: now.subtract(const Duration(days: 5)),
        endDate: now.add(const Duration(days: 25)),
        isActive: true,
        totalVotes: 305,
        categoryId: 'category_4', // Temizlik hizmetleri kategorisi
      ),
    ];
  }
}