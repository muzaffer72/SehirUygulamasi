import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sikayet_var/models/survey.dart';
import 'package:sikayet_var/services/survey_service.dart';

final surveyServiceProvider = Provider<SurveyService>((ref) {
  return SurveyService();
});

final surveysProvider = FutureProvider<List<Survey>>((ref) async {
  final surveyService = ref.watch(surveyServiceProvider);
  return surveyService.getSurveys();
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