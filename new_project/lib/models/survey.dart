class Survey {
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final List<SurveyOption> options;
  final int totalVotes;
  final int targetVotes;
  final SurveyStatus status;
  final String cityId;
  final String? districtId;
  final bool isActive;
  final bool isOfficial;
  final bool isPublished;
  final bool hasUserVoted;

  Survey({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.options,
    required this.totalVotes,
    required this.targetVotes,
    required this.status,
    required this.cityId,
    this.districtId,
    this.isActive = true,
    this.isOfficial = false,
    this.isPublished = true,
    this.hasUserVoted = false,
  });

  factory Survey.fromJson(Map<String, dynamic> json) {
    final optionsJson = json['options'] as List<dynamic>? ?? [];
    final options = optionsJson
        .map((optionJson) => SurveyOption.fromJson(optionJson))
        .toList();

    return Survey(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'])
          : DateTime.now(),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'])
          : DateTime.now().add(const Duration(days: 7)),
      options: options,
      totalVotes: json['total_votes'] ?? 0,
      targetVotes: json['target_votes'] ?? 1000,
      status: SurveyStatus.fromString(json['status']),
      cityId: json['city_id']?.toString() ?? '0',
      districtId: json['district_id']?.toString(),
      isActive: json['is_active'] ?? true,
      isOfficial: json['is_official'] ?? false,
      isPublished: json['is_published'] ?? true,
      hasUserVoted: json['has_user_voted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'options': options.map((option) => option.toJson()).toList(),
      'total_votes': totalVotes,
      'target_votes': targetVotes,
      'status': status.toString(),
      'city_id': cityId,
      'district_id': districtId,
      'is_active': isActive,
      'is_official': isOfficial,
      'is_published': isPublished,
      'has_user_voted': hasUserVoted,
    };
  }

  double get participationRate {
    if (targetVotes == 0) return 0.0;
    return (totalVotes / targetVotes) * 100;
  }

  String get formattedParticipationRate {
    return '${participationRate.toStringAsFixed(1)}%';
  }

  String get formattedParticipation {
    return '$totalVotes/$targetVotes';
  }

  // En çok oy alan seçeneği döndürür
  SurveyOption? get leadingOption {
    if (options.isEmpty) return null;
    return options.reduce((a, b) => a.votes > b.votes ? a : b);
  }

  // En az oy alan seçeneği döndürür
  SurveyOption? get trailingOption {
    if (options.isEmpty) return null;
    return options.reduce((a, b) => a.votes < b.votes ? a : b);
  }

  Survey copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    List<SurveyOption>? options,
    int? totalVotes,
    int? targetVotes,
    SurveyStatus? status,
    String? cityId,
    String? districtId,
    bool? isActive,
    bool? isOfficial,
    bool? isPublished,
    bool? hasUserVoted,
  }) {
    return Survey(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      options: options ?? this.options,
      totalVotes: totalVotes ?? this.totalVotes,
      targetVotes: targetVotes ?? this.targetVotes,
      status: status ?? this.status,
      cityId: cityId ?? this.cityId,
      districtId: districtId ?? this.districtId,
      isActive: isActive ?? this.isActive,
      isOfficial: isOfficial ?? this.isOfficial,
      isPublished: isPublished ?? this.isPublished,
      hasUserVoted: hasUserVoted ?? this.hasUserVoted,
    );
  }
}

class SurveyOption {
  final String id;
  final String text;
  final int votes;
  final double? percentage;

  SurveyOption({
    required this.id,
    required this.text,
    this.votes = 0,
    this.percentage,
  });

  factory SurveyOption.fromJson(Map<String, dynamic> json) {
    return SurveyOption(
      id: json['id'].toString(),
      text: json['text'] ?? '',
      votes: json['votes'] ?? 0,
      percentage: json['percentage']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'votes': votes,
      'percentage': percentage,
    };
  }

  SurveyOption copyWith({
    String? id,
    String? text,
    int? votes,
    double? percentage,
  }) {
    return SurveyOption(
      id: id ?? this.id,
      text: text ?? this.text,
      votes: votes ?? this.votes,
      percentage: percentage ?? this.percentage,
    );
  }
}

enum SurveyStatus {
  draft,
  active,
  completed,
  cancelled;

  @override
  String toString() {
    switch (this) {
      case SurveyStatus.draft:
        return 'draft';
      case SurveyStatus.active:
        return 'active';
      case SurveyStatus.completed:
        return 'completed';
      case SurveyStatus.cancelled:
        return 'cancelled';
    }
  }

  static SurveyStatus fromString(String? status) {
    if (status == null) return SurveyStatus.draft;

    switch (status.toLowerCase()) {
      case 'active':
        return SurveyStatus.active;
      case 'completed':
        return SurveyStatus.completed;
      case 'cancelled':
        return SurveyStatus.cancelled;
      default:
        return SurveyStatus.draft;
    }
  }
}