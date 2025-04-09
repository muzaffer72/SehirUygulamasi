class Survey {
  final String id;
  final String title;
  final String description;
  final List<SurveyOption> options;
  final DateTime startDate;
  final DateTime endDate;
  final String? imageUrl;
  final String? cityId;
  final String? districtId;
  final String? categoryId;
  final int totalVotes;
  final bool isActive;
  
  Survey({
    required this.id,
    required this.title,
    required this.description,
    required this.options,
    required this.startDate,
    required this.endDate,
    this.imageUrl,
    this.cityId,
    this.districtId,
    this.categoryId,
    required this.totalVotes,
    required this.isActive,
  });
  
  factory Survey.fromJson(Map<String, dynamic> json) {
    return Survey(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      options: (json['options'] as List)
          .map((option) => SurveyOption.fromJson(option))
          .toList(),
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      imageUrl: json['image_url'],
      cityId: json['city_id'],
      districtId: json['district_id'],
      categoryId: json['category_id'],
      totalVotes: json['total_votes'] ?? 0,
      isActive: json['is_active'] ?? false,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'options': options.map((option) => option.toJson()).toList(),
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'image_url': imageUrl,
      'city_id': cityId,
      'district_id': districtId,
      'category_id': categoryId,
      'total_votes': totalVotes,
      'is_active': isActive,
    };
  }
}

class SurveyOption {
  final String id;
  final String text;
  final int voteCount;
  
  SurveyOption({
    required this.id,
    required this.text,
    required this.voteCount,
  });
  
  factory SurveyOption.fromJson(Map<String, dynamic> json) {
    return SurveyOption(
      id: json['id'],
      text: json['text'],
      voteCount: json['vote_count'] ?? 0,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'vote_count': voteCount,
    };
  }
  
  // Calculate percentage based on total votes
  double getPercentage(int totalVotes) {
    if (totalVotes == 0) return 0;
    return (voteCount / totalVotes) * 100;
  }
}

class SurveyVote {
  final String id;
  final String surveyId;
  final String optionId;
  final String userId;
  final DateTime votedAt;
  
  SurveyVote({
    required this.id,
    required this.surveyId,
    required this.optionId,
    required this.userId,
    required this.votedAt,
  });
  
  factory SurveyVote.fromJson(Map<String, dynamic> json) {
    return SurveyVote(
      id: json['id'],
      surveyId: json['survey_id'],
      optionId: json['option_id'],
      userId: json['user_id'],
      votedAt: DateTime.parse(json['voted_at']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'survey_id': surveyId,
      'option_id': optionId,
      'user_id': userId,
      'voted_at': votedAt.toIso8601String(),
    };
  }
}