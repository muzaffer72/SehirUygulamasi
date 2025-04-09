import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sikayet_var/models/survey.dart';
import 'package:sikayet_var/models/user.dart';
import 'package:sikayet_var/providers/auth_provider.dart';
import 'package:sikayet_var/providers/user_provider.dart';
import 'package:sikayet_var/services/survey_service.dart';

final surveyServiceProvider = Provider<SurveyService>((ref) {
  return SurveyService();
});

// Anketleri getiren provider
final surveysProvider = FutureProvider<List<Survey>>((ref) async {
  final surveyService = ref.watch(surveyServiceProvider);
  return surveyService.getActiveSurveys();
});

// Kullanıcının konumuna göre filtrelenmiş anketleri getiren provider
final filteredSurveysProvider = FutureProvider<List<Survey>>((ref) async {
  final surveyService = ref.watch(surveyServiceProvider);
  final userAsync = ref.watch(currentUserProvider);
  
  // Anketleri al
  final surveys = await surveyService.getActiveSurveys();
  
  // Kullanıcı bilgisi yoksa tüm anketleri döndür
  if (userAsync is! AsyncData<User?> || userAsync.value == null) {
    return surveys;
  }
  
  final user = userAsync.value!;
  
  // Kullanıcının konumuna göre anketleri filtrele
  return surveys.where((survey) => 
    survey.isVisibleToUser(user.cityId, user.districtId)
  ).toList();
});

final selectedSurveyProvider = StateProvider<Survey?>((ref) => null);

final voteSurveyProvider = FutureProvider.family<bool, VoteParams>((ref, params) async {
  final surveyService = ref.watch(surveyServiceProvider);
  return surveyService.voteOnSurvey(params.surveyId, params.optionId);
});

class VoteParams {
  final String surveyId;
  final String optionId;
  
  VoteParams({required this.surveyId, required this.optionId});
}