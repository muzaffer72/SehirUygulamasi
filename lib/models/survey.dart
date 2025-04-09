enum SurveyStatus { active, completed }

class Survey {
  final String id;
  final String title;
  final String question;
  final List<SurveyOption> options;
  final DateTime startDate;
  final DateTime endDate;
  final SurveyStatus status;
  final String cityId;
  final String? districtId;
  final String? categoryId;
  final int totalVotes;
  final SurveyResult? result;

  Survey({
    required this.id,
    required this.title,
    required this.question,
    required this.options,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.cityId,
    this.districtId,
    this.categoryId,
    required this.totalVotes,
    this.result,
  });

  factory Survey.fromJson(Map<String, dynamic> json) {
    return Survey(
      id: json['id'],
      title: json['title'],
      question: json['question'],
      options: (json['options'] as List)
          .map((option) => SurveyOption.fromJson(option))
          .toList(),
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      status: json['status'] == 'completed'
          ? SurveyStatus.completed
          : SurveyStatus.active,
      cityId: json['city_id'],
      districtId: json['district_id'],
      categoryId: json['category_id'],
      totalVotes: json['total_votes'],
      result: json['result'] != null
          ? SurveyResult.fromJson(json['result'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'question': question,
      'options': options.map((option) => option.toJson()).toList(),
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'status': status == SurveyStatus.completed ? 'completed' : 'active',
      'city_id': cityId,
      'district_id': districtId,
      'category_id': categoryId,
      'total_votes': totalVotes,
      'result': result?.toJson(),
    };
  }
}

class SurveyOption {
  final String id;
  final String text;
  final int voteCount;
  final double percentage;

  SurveyOption({
    required this.id,
    required this.text,
    required this.voteCount,
    required this.percentage,
  });

  factory SurveyOption.fromJson(Map<String, dynamic> json) {
    return SurveyOption(
      id: json['id'],
      text: json['text'],
      voteCount: json['vote_count'],
      percentage: json['percentage'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'vote_count': voteCount,
      'percentage': percentage,
    };
  }
}

enum SurveyResultType { positive, negative, neutral }

class SurveyResult {
  final SurveyResultType type;
  final String message;
  final bool isCritical;

  SurveyResult({
    required this.type,
    required this.message,
    required this.isCritical,
  });

  factory SurveyResult.fromJson(Map<String, dynamic> json) {
    SurveyResultType type;
    switch (json['type']) {
      case 'positive':
        type = SurveyResultType.positive;
        break;
      case 'negative':
        type = SurveyResultType.negative;
        break;
      default:
        type = SurveyResultType.neutral;
    }

    return SurveyResult(
      type: type,
      message: json['message'],
      isCritical: json['is_critical'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    String typeString;
    switch (type) {
      case SurveyResultType.positive:
        typeString = 'positive';
        break;
      case SurveyResultType.negative:
        typeString = 'negative';
        break;
      case SurveyResultType.neutral:
        typeString = 'neutral';
        break;
    }

    return {
      'type': typeString,
      'message': message,
      'is_critical': isCritical,
    };
  }
}