class SurveyOption {
  final String id;
  final String? surveyId; // Hangi anket için olduğu
  final String text;      // Seçenek metni
  int voteCount;          // Oy sayısı

  SurveyOption({
    required this.id,
    this.surveyId,
    required this.text,
    required this.voteCount,
  });

  factory SurveyOption.fromJson(Map<String, dynamic> json) {
    return SurveyOption(
      id: json['id'].toString(),
      surveyId: json['survey_id']?.toString(),
      text: json['text'],
      voteCount: json['vote_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'survey_id': surveyId,
      'text': text,
      'vote_count': voteCount,
    };
  }
  
  // Yüzde hesapla
  double getPercentage(int totalVotes) {
    if (totalVotes == 0) return 0;
    return (voteCount / totalVotes) * 100;
  }
}

class Survey {
  final String id;
  final String title;
  final String description;
  final String? question;   // Anket sorusu
  final String? imageUrl;   // Anket görseli URL'i (opsiyonel)
  final String? cityId;     // İl ID (opsiyonel, genel anketlerde null)
  final String? districtId; // İlçe ID (opsiyonel, il veya genel anketlerde null)
  final String? categoryId; // Kategori ID
  final String scopeType;   // Anket kapsamı: 'general', 'city', 'district'
  final bool isActive;      // Anket aktif mi
  final DateTime startDate; // Başlangıç tarihi
  final DateTime endDate;   // Bitiş tarihi
  int totalVotes;           // Toplam oy sayısı
  final List<SurveyOption> options; // Anket seçenekleri

  Survey({
    required this.id,
    required this.title,
    required this.description,
    this.question,
    this.imageUrl,
    this.cityId,
    this.districtId,
    this.categoryId,
    required this.scopeType,
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
      question: json['question'],
      imageUrl: json['image_url'],
      cityId: json['city_id']?.toString(),
      districtId: json['district_id']?.toString(),
      categoryId: json['category_id']?.toString(),
      scopeType: json['scope_type'] ?? 'general', // Varsayılan olarak genel
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
      'question': question,
      'image_url': imageUrl,
      'city_id': cityId,
      'district_id': districtId,
      'category_id': categoryId,
      'scope_type': scopeType,
      'is_active': isActive,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'total_votes': totalVotes,
      'options': options.map((option) => option.toJson()).toList(),
    };
  }
  
  // Anket kapsamına göre kullanıcının görebildiği anket mi kontrol et
  bool isVisibleToUser(String? userCityId, String? userDistrictId) {
    switch (scopeType) {
      case 'general':
        // Genel anketler herkes tarafından görülebilir
        return true;
      case 'city':
        // Şehir bazlı anketler, ya "Tüm Türkiye" (cityId = all) seçiliyse
        // veya kullanıcının şehri ile eşleşiyorsa görülebilir
        if (cityId == 'all') return true;
        return cityId == userCityId;
      case 'district':
        // İlçe bazlı anketler, kullanıcının ilçesi ile eşleşiyorsa görülebilir
        // Aynı ilde farklı ilçedeki kullanıcılar göremez
        return cityId == userCityId && districtId == userDistrictId;
      default:
        return false;
    }
  }
}