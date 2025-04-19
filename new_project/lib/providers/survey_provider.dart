import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belediye_iletisim_merkezi/models/survey.dart';
import 'package:belediye_iletisim_merkezi/models/user.dart';
import 'package:belediye_iletisim_merkezi/providers/auth_provider.dart';
import 'package:belediye_iletisim_merkezi/providers/current_user_provider.dart';
import 'package:belediye_iletisim_merkezi/providers/user_provider.dart';
import 'package:belediye_iletisim_merkezi/services/survey_service.dart';

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
    survey.isVisibleToUser(user.cityId?.toString(), user.districtId?.toString())
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