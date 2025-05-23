class CityProfile {
  final String id;
  final String cityId;
  final String name;
  final String? description;
  final String? logoUrl;
  final String? websiteUrl;
  final String? mayor;
  final String? mayorPhoto;
  final String? contactPhone;
  final String? contactEmail;
  final String? address;
  final int? populationCount;
  final int? totalPosts;
  final int? totalSolvedIssues;
  final double? averageResponseTime;
  final String? foundedYear;
  final double? area;
  final List<String>? photos;
  final List<String>? socialAccounts;
  final List<String>? services;
  final List<String>? achievements;
  final List<String>? importantPlaces;
  final int? totalComplaints;
  final int? solvedComplaints;
  final double? responseDuration;  // Ortalama yanıt süresi (saat)
  final int? totalInProgressIssues;
  final int? totalWaitingIssues;
  final int? totalRejectedIssues;
  final double? satisfactionRate;
  final double? problemSolvingRate;
  final double? responseRate;
  final double? solutionRate;
  final String? twitterAccount;
  final String? instagramAccount;
  final String? facebookAccount;
  final String? youtubeAccount;
  // City profile screen için gerekli eklenen alanlar
  final String? politicalParty; // Parti adı
  final String? politicalPartyLogoUrl; // Parti logosu
  final String? info; // Şehir hakkında bilgi
  final String? website; // Websitesi (websiteUrl ile aynı)
  final int activeComplaints; // Aktif şikayet sayısı
  
  // CitiesListScreen için gerekli eklenen alanlar
  final int complaintCount;  // Toplam şikayet sayısı
  final int districtCount;   // İlçe sayısı
  
  // Eksik alanlar için varsayılan değerler
  final String? awardText; // Ödül metni
  final String? awardMonth; // Ödül ayı
  final double? awardScore; // Ödül puanı
  final String? demoCoverImageUrl; // Kapak fotoğrafı
  final String? demoImageUrl; // Tanıtım fotoğrafı
  final String? demoMayorImageUrl; // Başkan fotoğrafı
  final String? demoMayorName; // Başkan adı
  final int? population; // Nüfus
  final String? performanceMonth; // Performans ayı
  final int? performanceYear; // Performans yılı
  final List<double>? monthlyPerformance; // Aylık performans
  final String? emergencyPhone; // Acil telefon
  final String? demoProjectImageUrl; // Proje görseli
  final String? demoEventImageUrl; // Etkinlik görseli
  final List<Map<String, dynamic>>? projects; // Projeler
  final List<Map<String, dynamic>>? events; // Etkinlikler
  final List<Map<String, dynamic>>? stats; // İstatistikler

  CityProfile({
    required this.id,
    required this.cityId, 
    required this.name,
    this.description,
    this.logoUrl,
    this.websiteUrl,
    this.mayor,
    this.mayorPhoto,
    this.contactPhone,
    this.contactEmail,
    this.address,
    this.populationCount,
    this.totalPosts,
    this.totalSolvedIssues,
    this.averageResponseTime,
    this.foundedYear,
    this.area,
    this.photos,
    this.socialAccounts,
    this.services,
    this.achievements,
    this.importantPlaces,
    this.totalComplaints,
    this.solvedComplaints,
    this.responseDuration,
    this.totalInProgressIssues,
    this.totalWaitingIssues,
    this.totalRejectedIssues,
    this.satisfactionRate,
    this.problemSolvingRate,
    this.responseRate,
    this.solutionRate,
    this.twitterAccount,
    this.instagramAccount,
    this.facebookAccount,
    this.youtubeAccount,
    this.politicalParty,
    this.politicalPartyLogoUrl,
    this.info,
    this.website,
    this.activeComplaints = 0,
    this.complaintCount = 0,
    this.districtCount = 0,
    // Yeni eklenen alanlar
    this.awardText,
    this.awardMonth,
    this.awardScore,
    this.demoCoverImageUrl,
    this.demoImageUrl,
    this.demoMayorImageUrl,
    this.demoMayorName,
    this.population,
    this.performanceMonth,
    this.performanceYear,
    this.monthlyPerformance,
    this.emergencyPhone,
    this.demoProjectImageUrl,
    this.demoEventImageUrl,
    this.projects,
    this.events,
    this.stats,
  });

  factory CityProfile.fromJson(Map<String, dynamic> json) {
    // Fotoğrafları dönüştür
    List<String>? photos;
    if (json['photos'] != null) {
      photos = List<String>.from(json['photos']);
    }

    // Sosyal hesapları dönüştür
    List<String>? socialAccounts;
    if (json['social_accounts'] != null) {
      socialAccounts = List<String>.from(json['social_accounts']);
    }

    // Hizmetleri dönüştür
    List<String>? services;
    if (json['services'] != null) {
      services = List<String>.from(json['services']);
    }

    // Başarıları dönüştür
    List<String>? achievements;
    if (json['achievements'] != null) {
      achievements = List<String>.from(json['achievements']);
    }

    // Önemli yerleri dönüştür
    List<String>? importantPlaces;
    if (json['important_places'] != null) {
      importantPlaces = List<String>.from(json['important_places']);
    }

    // Aylık performans verileri dönüştür
    List<double>? monthlyPerformance;
    if (json['monthly_performance'] != null && json['monthly_performance'] is List) {
      monthlyPerformance = List<double>.from(
        (json['monthly_performance'] as List).map((item) => (item is num) ? item.toDouble() : 0.0)
      );
    }
    
    // Proje verileri dönüştür
    List<Map<String, dynamic>>? projects;
    if (json['projects'] != null && json['projects'] is List) {
      projects = List<Map<String, dynamic>>.from(
        (json['projects'] as List).map((item) => 
          (item is Map) ? Map<String, dynamic>.from(item as Map) : <String, dynamic>{})
      );
    }
    
    // Etkinlik verileri dönüştür
    List<Map<String, dynamic>>? events;
    if (json['events'] != null && json['events'] is List) {
      events = List<Map<String, dynamic>>.from(
        (json['events'] as List).map((item) => 
          (item is Map) ? Map<String, dynamic>.from(item as Map) : <String, dynamic>{})
      );
    }
    
    // İstatistik verileri dönüştür
    List<Map<String, dynamic>>? stats;
    if (json['stats'] != null && json['stats'] is List) {
      stats = List<Map<String, dynamic>>.from(
        (json['stats'] as List).map((item) => 
          (item is Map) ? Map<String, dynamic>.from(item as Map) : <String, dynamic>{})
      );
    }
    
    return CityProfile(
      id: json['id'].toString(),
      cityId: json['city_id'].toString(),
      name: json['name'] ?? '',
      description: json['description'],
      logoUrl: json['logo_url'],
      websiteUrl: json['website_url'],
      mayor: json['mayor'],
      mayorPhoto: json['mayor_photo'],
      contactPhone: json['contact_phone'],
      contactEmail: json['contact_email'],
      address: json['address'],
      populationCount: json['population_count'],
      totalPosts: json['total_posts'],
      totalSolvedIssues: json['total_solved_issues'],
      averageResponseTime: json['average_response_time']?.toDouble(),
      foundedYear: json['founded_year'],
      area: json['area']?.toDouble(),
      photos: photos,
      socialAccounts: socialAccounts,
      services: services,
      achievements: achievements,
      importantPlaces: importantPlaces,
      totalComplaints: json['total_complaints'],
      solvedComplaints: json['solved_complaints'],
      responseDuration: json['response_duration']?.toDouble(),
      totalInProgressIssues: json['total_in_progress_issues'],
      totalWaitingIssues: json['total_waiting_issues'],
      totalRejectedIssues: json['total_rejected_issues'],
      satisfactionRate: json['satisfaction_rate']?.toDouble(),
      problemSolvingRate: json['problem_solving_rate']?.toDouble(),
      responseRate: json['response_rate']?.toDouble(),
      solutionRate: json['solution_rate']?.toDouble(),
      twitterAccount: json['twitter_account'],
      instagramAccount: json['instagram_account'],
      facebookAccount: json['facebook_account'],
      youtubeAccount: json['youtube_account'],
      // Yeni eklenen alanlar
      politicalParty: json['political_party'] ?? json['mayor_party'],
      politicalPartyLogoUrl: json['political_party_logo_url'] ?? json['mayor_party_logo'],
      info: json['info'] ?? json['description'],
      website: json['website'] ?? json['website_url'],
      activeComplaints: json['active_complaints'] ?? json['total_waiting_issues'] ?? 0,
      // CitiesListScreen için gerekli alanlar
      complaintCount: json['complaint_count'] ?? json['total_complaints'] ?? 0,
      districtCount: json['district_count'] ?? 0,
      // City Profile Screen için gerekli eklenen alanlar
      awardText: json['award_text'],
      awardMonth: json['award_month'],
      awardScore: json['award_score']?.toDouble(),
      demoCoverImageUrl: json['demo_cover_image_url'] ?? json['cover_image_url'],
      demoImageUrl: json['demo_image_url'] ?? (photos != null && photos.isNotEmpty ? photos[0] : null),
      demoMayorImageUrl: json['demo_mayor_image_url'] ?? json['mayor_photo'],
      demoMayorName: json['demo_mayor_name'] ?? json['mayor'],
      population: json['population'] ?? json['population_count'],
      performanceMonth: json['performance_month'],
      performanceYear: json['performance_year'],
      monthlyPerformance: monthlyPerformance,
      emergencyPhone: json['emergency_phone'] ?? json['contact_phone'],
      demoProjectImageUrl: json['demo_project_image_url'],
      demoEventImageUrl: json['demo_event_image_url'],
      projects: projects,
      events: events,
      stats: stats,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'city_id': cityId,
      'name': name,
      'description': description,
      'logo_url': logoUrl,
      'website_url': websiteUrl,
      'mayor': mayor,
      'mayor_photo': mayorPhoto,
      'contact_phone': contactPhone,
      'contact_email': contactEmail,
      'address': address,
      'population_count': populationCount,
      'total_posts': totalPosts,
      'total_solved_issues': totalSolvedIssues,
      'average_response_time': averageResponseTime,
      'founded_year': foundedYear,
      'area': area,
      'photos': photos,
      'social_accounts': socialAccounts,
      'services': services,
      'achievements': achievements,
      'important_places': importantPlaces,
      'total_complaints': totalComplaints,
      'solved_complaints': solvedComplaints,
      'response_duration': responseDuration,
      'total_in_progress_issues': totalInProgressIssues,
      'total_waiting_issues': totalWaitingIssues,
      'total_rejected_issues': totalRejectedIssues,
      'satisfaction_rate': satisfactionRate,
      'problem_solving_rate': problemSolvingRate,
      'response_rate': responseRate,
      'solution_rate': solutionRate,
      'twitter_account': twitterAccount,
      'instagram_account': instagramAccount,
      'facebook_account': facebookAccount,
      'youtube_account': youtubeAccount,
      // Eklenen alanlar
      'political_party': politicalParty,
      'political_party_logo_url': politicalPartyLogoUrl,
      'info': info,
      'website': website,
      'active_complaints': activeComplaints,
      'complaint_count': complaintCount,
      'district_count': districtCount,
      // City Profile Screen için gerekli alanlar
      'award_text': awardText,
      'award_month': awardMonth,
      'award_score': awardScore,
      'demo_cover_image_url': demoCoverImageUrl,
      'demo_image_url': demoImageUrl,
      'demo_mayor_image_url': demoMayorImageUrl,
      'demo_mayor_name': demoMayorName,
      'population': population,
      'performance_month': performanceMonth,
      'performance_year': performanceYear,
      'monthly_performance': monthlyPerformance,
      'emergency_phone': emergencyPhone,
      'demo_project_image_url': demoProjectImageUrl,
      'demo_event_image_url': demoEventImageUrl,
      'projects': projects,
      'events': events,
      'stats': stats,
    };
  }

  String get formattedSolutionRate {
    if (solutionRate == null) return '0%';
    
    // Eğer değer 0-1 arasındaysa, yüzde olarak hesapla
    double rate = (solutionRate! <= 1.0) ? solutionRate! * 100 : solutionRate!;
    return '${rate.toStringAsFixed(1)}%';
  }

  String get formattedSatisfactionRate {
    if (satisfactionRate == null) return '0%';
    
    // Eğer değer 0-1 arasındaysa, yüzde olarak hesapla
    double rate = (satisfactionRate! <= 1.0) ? satisfactionRate! * 100 : satisfactionRate!;
    return '${rate.toStringAsFixed(1)}%';
  }

  // Çözülen sorun sayısını ve çözülme oranını formatlı olarak döndür
  String get formattedSolvedIssues {
    final solved = solvedComplaints ?? totalSolvedIssues ?? 0;
    final total = totalComplaints ?? totalPosts ?? 0;
    
    if (total == 0) return '0/0 (0%)';
    
    final rate = (solved / total) * 100;
    return '$solved/$total (${rate.toStringAsFixed(1)}%)';
  }

  // Bu method, kullanıcı arayüzünde çözüm oranını renk kodlarıyla göstermek için kullanılır
  String getSolutionRateColor() {
    if (solutionRate == null) return 'low';
    
    // 0-1 arasında bir değer mi kontrol et
    double rate = (solutionRate! <= 1.0) ? solutionRate! : solutionRate! / 100;
    
    if (rate >= 0.7) return 'high';
    if (rate >= 0.4) return 'medium';
    return 'low';
  }
  
  // Bu metod, solution_rate'in null olma durumunu kontrol eder ve güvenli bir şekilde değeri döndürür
  double getSolutionRateValue() {
    if (solutionRate == null) return 0.0;
    
    // 0-1 arasında bir değer mi kontrol et
    return (solutionRate! <= 1.0) ? solutionRate! : solutionRate! / 100;
  }

  // Şehir profil sayfası için kısa formatlı açıklama döndürür
  String get shortDescription {
    if (description == null || description!.isEmpty) {
      return '$name şehir profilinde henüz açıklama bulunmamaktadır.';
    }
    
    if (description!.length <= 150) {
      return description!;
    }
    
    return '${description!.substring(0, 147)}...';
  }
}