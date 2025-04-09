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
  Future<List<Survey>> getSurveys() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');
      
      final response = await _client.get(
        Uri.parse('$baseUrl/surveys'),
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(Constants.networkTimeout);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        return data.map((json) => Survey.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load surveys');
      }
    } catch (e) {
      // For development/demo purposes
      if (e is SocketException || e is HttpException || e is TimeoutException) {
        await Future.delayed(const Duration(seconds: 1));
        return _getMockSurveys();
      }
      throw Exception('Failed to load surveys: $e');
    }
  }
  
  // Vote on a survey
  Future<bool> voteOnSurvey(String surveyId, String optionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');
      
      final response = await _client.post(
        Uri.parse('$baseUrl/surveys/$surveyId/vote'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'option_id': optionId,
        }),
      ).timeout(Constants.networkTimeout);
      
      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to vote on survey');
      }
    } catch (e) {
      // For development/demo purposes
      if (e is SocketException || e is HttpException || e is TimeoutException) {
        await Future.delayed(const Duration(seconds: 1));
        return true; // Simulate success
      }
      throw Exception('Failed to vote on survey: $e');
    }
  }
  
  // Mock data for development/demo
  List<Survey> _getMockSurveys() {
    return [
      Survey(
        id: 'survey_1',
        title: 'Belediye Memnuniyet Anketi',
        question: 'Belediyenin hizmetlerinden genel olarak memnun musunuz?',
        options: [
          SurveyOption(
            id: 'option_1',
            text: 'Evet, memnunum',
            voteCount: 156,
            percentage: 58.2,
          ),
          SurveyOption(
            id: 'option_2',
            text: 'Hayır, memnun değilim',
            voteCount: 87,
            percentage: 32.5,
          ),
          SurveyOption(
            id: 'option_3',
            text: 'Kararsızım',
            voteCount: 25,
            percentage: 9.3,
          ),
        ],
        startDate: DateTime.now().subtract(const Duration(days: 7)),
        endDate: DateTime.now().add(const Duration(days: 14)),
        status: SurveyStatus.active,
        cityId: 'city_1', // İstanbul
        districtId: 'district_1', // Kadıköy
        totalVotes: 268,
        result: SurveyResult(
          type: SurveyResultType.positive,
          message: 'Vatandaşların çoğunluğu belediye hizmetlerinden memnun.',
          isCritical: false,
        ),
      ),
      Survey(
        id: 'survey_2',
        title: 'Çöp Toplama Anketi',
        question: 'Çöplerin toplanma sıklığı yeterli mi?',
        options: [
          SurveyOption(
            id: 'option_1',
            text: 'Evet, yeterli',
            voteCount: 67,
            percentage: 24.8,
          ),
          SurveyOption(
            id: 'option_2',
            text: 'Hayır, yetersiz',
            voteCount: 175,
            percentage: 64.8,
          ),
          SurveyOption(
            id: 'option_3',
            text: 'Kararsızım',
            voteCount: 28,
            percentage: 10.4,
          ),
        ],
        startDate: DateTime.now().subtract(const Duration(days: 12)),
        endDate: DateTime.now().add(const Duration(days: 3)),
        status: SurveyStatus.active,
        cityId: 'city_2', // Ankara
        districtId: 'district_5', // Çankaya
        totalVotes: 270,
        result: SurveyResult(
          type: SurveyResultType.negative,
          message: 'Çöp toplama hizmetinde iyileştirme gerekli.',
          isCritical: true,
        ),
      ),
      Survey(
        id: 'survey_3',
        title: 'Ulaşım Anketi',
        question: 'Toplu taşıma hizmetleri ihtiyaçlarınızı karşılıyor mu?',
        options: [
          SurveyOption(
            id: 'option_1',
            text: 'Evet, karşılıyor',
            voteCount: 120,
            percentage: 42.1,
          ),
          SurveyOption(
            id: 'option_2',
            text: 'Hayır, karşılamıyor',
            voteCount: 135,
            percentage: 47.4,
          ),
          SurveyOption(
            id: 'option_3',
            text: 'Kararsızım',
            voteCount: 30,
            percentage: 10.5,
          ),
        ],
        startDate: DateTime.now().subtract(const Duration(days: 5)),
        endDate: DateTime.now().add(const Duration(days: 25)),
        status: SurveyStatus.active,
        cityId: 'city_3', // İzmir
        districtId: null, // Tüm şehir
        totalVotes: 285,
        result: SurveyResult(
          type: SurveyResultType.neutral,
          message: 'Toplu taşıma hizmetlerinde karışık görüşler var.',
          isCritical: false,
        ),
      ),
    ];
  }
}