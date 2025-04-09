class SurveyOption {
  final String id;
  final String text;
  int voteCount;

  SurveyOption({
    required this.id,
    required this.text,
    required this.voteCount,
  });

  factory SurveyOption.fromJson(Map<String, dynamic> json) {
    return SurveyOption(
      id: json['id'].toString(),
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
}

class Survey {
  final String id;
  final String title;
  final String description;
  final String? cityId;
  final String categoryId;
  final bool isActive;
  final DateTime startDate;
  final DateTime endDate;
  int totalVotes;
  final List<SurveyOption> options;

  Survey({
    required this.id,
    required this.title,
    required this.description,
    this.cityId,
    required this.categoryId,
    required this.isActive,
    required this.startDate,
    required this.endDate,
    required this.totalVotes,
    required this.options,
  });

  factory Survey.fromJson(Map<String, dynamic> json) {
    return Survey(
      id: json['id'].toString(),
      title: json['title'],
      description: json['description'],
      cityId: json['city_id']?.toString(),
      categoryId: json['category_id'].toString(),
      isActive: json['is_active'] ?? false,
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'])
          : DateTime.now(),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'])
          : DateTime.now().add(const Duration(days: 30)),
      totalVotes: json['total_votes'] ?? 0,
      options: (json['options'] as List<dynamic>)
          .map((option) => SurveyOption.fromJson(option))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'city_id': cityId,
      'category_id': categoryId,
      'is_active': isActive,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'total_votes': totalVotes,
      'options': options.map((option) => option.toJson()).toList(),
    };
  }
}