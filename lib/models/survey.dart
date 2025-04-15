class SurveyOption {
  final String id;
  final String? surveyId; // Hangi anket için olduğu
  final String text;      // Seçenek metni
  final int _voteCount;   // Oy sayısı (private)

  // Getter ekle
  int get voteCount => _voteCount;

  SurveyOption({
    required this.id,
    this.surveyId,
    required this.text,
    required int voteCount,
  }) : _voteCount = voteCount;

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
      'vote_count': _voteCount,
    };
  }
  
  // Yüzde hesapla
  double getPercentage(int totalVotes) {
    if (totalVotes == 0) return 0;
    return (_voteCount / totalVotes) * 100;
  }
}

class Survey {
  final String id;
  final String title;
  final String shortTitle;  // Anasayfada gösterilecek kısa başlık
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
  final int _totalVotes;     // Toplam oy sayısı (private)
  final int totalUsers;     // Görüntülenen toplam kullanıcı sayısı
  final List<SurveyOption> options; // Anket seçenekleri

  // Getter ekle
  int get totalVotes => _totalVotes;
  
  // Hesaplanmış toplam oyları döndüren getter
  int get calculatedTotalVotes {
    return options.fold(0, (sum, option) => sum + option.voteCount);
  }

  Survey({
    required this.id,
    required this.title,
    required this.shortTitle,
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
    required int totalVotes,
    required this.totalUsers,
    required this.options,
  }) : _totalVotes = totalVotes;

  factory Survey.fromJson(Map<String, dynamic> json) {
    return Survey(
      id: json['id'].toString(),
      title: json['title'],
      shortTitle: json['short_title'] ?? json['title'].toString().substring(0, json['title'].toString().length > 40 ? 40 : json['title'].toString().length),
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
      totalUsers: json['total_users'] ?? 1000, // Varsayılan olarak 1000 kullanıcı
      options: (json['options'] as List<dynamic>)
          .map((option) => SurveyOption.fromJson(option))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'short_title': shortTitle,
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
      'total_users': totalUsers,
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
  
  // Anket katılım oranını hesaplar (0.0 - 1.0 arası)
  double getParticipationRate() {
    if (totalUsers <= 0) return 0.0;
    return totalVotes / totalUsers;
  }
  
  // Kalan gün sayısını hesaplar
  int getRemainingDays() {
    final now = DateTime.now();
    return endDate.difference(now).inDays;
  }
  
  // Kalan süreyi saat, dakika ve saniye cinsinden hesaplar
  String getRemainingTimeText() {
    final now = DateTime.now();
    final difference = endDate.difference(now);
    
    if (difference.isNegative) {
      return "Anket sona erdi";
    }
    
    final days = difference.inDays;
    final hours = difference.inHours % 24;
    final minutes = difference.inMinutes % 60;
    
    if (days > 0) {
      return "$days gün kaldı";
    } else if (hours > 0) {
      return "$hours saat $minutes dakika";
    } else {
      return "$minutes dakika";
    }
  }
}