import 'package:flutter/material.dart';
import 'package:sikayet_var/models/post.dart';
import 'package:sikayet_var/models/survey.dart';

class CityService {
  final int id;
  final String name;
  final String? description;
  final String? iconUrl;
  final String type;
  final String? url;
  final String? category;
  final String? contactInfo;
  final String? workingHours;
  
  CityService({
    required this.id,
    required this.name,
    this.description,
    this.iconUrl,
    required this.type,
    this.url,
    this.category,
    this.contactInfo,
    this.workingHours,
  });
  
  factory CityService.fromJson(Map<String, dynamic> json) {
    return CityService(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      iconUrl: json['iconUrl'],
      type: json['type'],
      url: json['url'],
      category: json['category'],
      contactInfo: json['contactInfo'],
      workingHours: json['workingHours'],
    );
  }
}

class CityProject {
  final int id;
  final int cityId;
  final String name;
  final String? description;
  final String? imageUrl;
  final DateTime? startDateDt;
  final DateTime? endDateDt;
  final String? startDate; // String formatında tarih
  final String? endDate; // String formatında tarih
  final String status; // planned, inProgress, completed
  final int likes;
  final int dislikes;
  final double? budget; // Proje bütçesi
  
  CityProject({
    required this.id,
    required this.cityId,
    required this.name,
    this.description,
    this.imageUrl,
    this.startDateDt,
    this.endDateDt,
    this.startDate,
    this.endDate,
    required this.status,
    required this.likes,
    required this.dislikes,
    this.budget,
  });
  
  factory CityProject.fromJson(Map<String, dynamic> json) {
    DateTime? startDateDt, endDateDt;
    String? startDateStr, endDateStr;
    
    // Tarih dönüşümleri
    if (json['startDate'] != null) {
      try {
        startDateDt = DateTime.parse(json['startDate']);
        startDateStr = '${startDateDt.day}/${startDateDt.month}/${startDateDt.year}';
      } catch (e) {
        startDateStr = json['startDate'];
      }
    }
    
    if (json['endDate'] != null) {
      try {
        endDateDt = DateTime.parse(json['endDate']);
        endDateStr = '${endDateDt.day}/${endDateDt.month}/${endDateDt.year}';
      } catch (e) {
        endDateStr = json['endDate'];
      }
    }
    
    double? budget;
    if (json['budget'] != null) {
      budget = json['budget'] is int ? json['budget'].toDouble() : json['budget'];
    }
    
    return CityProject(
      id: json['id'],
      cityId: json['cityId'],
      name: json['name'] ?? json['title'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      startDateDt: startDateDt,
      endDateDt: endDateDt,
      startDate: startDateStr,
      endDate: endDateStr,
      status: json['status'],
      likes: json['likes'] ?? 0,
      dislikes: json['dislikes'] ?? 0,
      budget: budget,
    );
  }
  
  // Projenin durumunu görsel olarak göstermek için
  String get statusDisplay {
    switch (status) {
      case 'planned':
        return 'Planlandı';
      case 'inProgress':
        return 'Devam Ediyor';
      case 'completed':
        return 'Tamamlandı';
      default:
        return 'Belirsiz';
    }
  }
  
  // Kalan gün hesaplama
  int? get remainingDays {
    if (status != 'inProgress' || endDateDt == null) return null;
    return endDateDt!.difference(DateTime.now()).inDays;
  }
}

class CityEvent {
  final int id;
  final int cityId;
  final String name;
  final String? description;
  final String? imageUrl;
  final String? location;
  final DateTime eventDate;
  final bool isActive;
  final String? date; // Formatlanmış tarih
  
  CityEvent({
    required this.id,
    required this.cityId,
    required this.name,
    this.description,
    this.imageUrl,
    this.location,
    required this.eventDate,
    required this.isActive,
    this.date,
  });
  
  factory CityEvent.fromJson(Map<String, dynamic> json) {
    String? dateStr;
    if (json['eventDate'] != null) {
      final date = DateTime.parse(json['eventDate']);
      dateStr = "${date.day} ${date.month} ${date.year}";
    }
    
    return CityEvent(
      id: json['id'],
      cityId: json['cityId'],
      name: json['title'] ?? json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      location: json['location'],
      eventDate: json['eventDate'] != null ? DateTime.parse(json['eventDate']) : DateTime.now(),
      isActive: json['isActive'] ?? true,
      date: dateStr,
    );
  }
}

class CityStat {
  final int id;
  final int cityId;
  final String type; // economy, tourism, education, environment
  final String? iconUrl;
  final String title;
  final String? description;
  final String? value;
  final String name; // İstatistik adı (gösterim için)
  
  CityStat({
    required this.id,
    required this.cityId,
    required this.type,
    this.iconUrl,
    required this.title,
    this.description,
    this.value,
    String? name,
  }) : name = name ?? title;
  
  factory CityStat.fromJson(Map<String, dynamic> json) {
    return CityStat(
      id: json['id'],
      cityId: json['cityId'],
      type: json['type'],
      iconUrl: json['iconUrl'],
      title: json['title'],
      description: json['description'],
      value: json['value'] is int ? json['value'].toString() : json['value'],
      name: json['name'] ?? json['title'],
    );
  }
}

class CityProfile {
  final int id;
  final String name;
  final String? description;
  final String? imageUrl;
  final String? coverImageUrl;
  final int population;
  final double latitude;
  final double longitude;
  final int totalPosts;
  final int totalSolvedIssues;
  final int activeSurveys;
  final List<Post>? recentPosts;
  final List<Survey>? activeSurveyList;
  
  // Şehir bilgileri
  final String? region;  // Şehrin bulunduğu bölge (Marmara, Ege vb.)
  
  // Belediye bilgileri
  final String? mayorName;
  final String? mayorImageUrl;
  final String? mayorParty;
  final String? mayorPartyLogo;
  final int? mayorSatisfactionRate;
  
  // İletişim bilgileri
  final String? contactEmail;
  final String? contactPhone;
  final String? emergencyPhone;
  final String? website;
  
  // Şehir hizmetleri, projeler, etkinlikler ve istatistikler
  final List<CityService>? services;
  final List<CityProject>? projects;
  final List<CityEvent>? events;
  final List<CityStat>? stats;
  
  // İstatistikler
  final Map<String, int>? statistics;
  
  // Çözüm/Şikayet sayıları
  final int? solvedCount;
  final int? complaintCount;
  
  // Belediye öncelik durumu
  final Map<String, double>? priorityData;
  
  // Aylık performans değerlendirmesi
  final Map<String, double>? monthlyPerformance;
  final String? performanceMonth;  // Performans ayı (örn: Nisan)
  final String? performanceYear;   // Performans yılı (örn: 2024)
  
  // Belediye ödülleri
  final bool isBestOfMonth; // Ayın en iyi belediyesi
  final String? awardMonth; // Hangi ay için ödül aldı
  final double? awardScore;  // Ödül puanı
  final String? awardText;  // Ödül açıklaması
  
  CityProfile({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.coverImageUrl,
    required this.population,
    required this.latitude,
    required this.longitude,
    required this.totalPosts,
    required this.totalSolvedIssues,
    required this.activeSurveys,
    this.recentPosts,
    this.activeSurveyList,
    this.region,
    this.mayorName,
    this.mayorImageUrl,
    this.mayorParty,
    this.mayorPartyLogo,
    this.mayorSatisfactionRate,
    this.contactEmail,
    this.contactPhone,
    this.emergencyPhone,
    this.website,
    this.services,
    this.projects,
    this.events,
    this.stats,
    this.statistics,
    this.solvedCount,
    this.complaintCount,
    this.priorityData,
    this.monthlyPerformance,
    this.performanceMonth,
    this.performanceYear,
    this.isBestOfMonth = false,
    this.awardMonth,
    this.awardScore,
    this.awardText,
  });
  
  factory CityProfile.fromJson(Map<String, dynamic> json) {
    List<Post>? recentPosts;
    if (json['recentPosts'] != null) {
      recentPosts = List<Post>.from(
        json['recentPosts'].map((x) => Post.fromJson(x)));
    }
    
    List<Survey>? activeSurveyList;
    if (json['activeSurveys'] != null) {
      activeSurveyList = List<Survey>.from(
        json['activeSurveys'].map((x) => Survey.fromJson(x)));
    }
    
    Map<String, int>? statistics;
    if (json['statistics'] != null) {
      statistics = Map<String, int>.from(json['statistics']);
    }
    
    List<CityService>? services;
    if (json['services'] != null) {
      services = List<CityService>.from(
        json['services'].map((x) => CityService.fromJson(x)));
    }
    
    List<CityProject>? projects;
    if (json['projects'] != null) {
      projects = List<CityProject>.from(
        json['projects'].map((x) => CityProject.fromJson(x)));
    }
    
    List<CityEvent>? events;
    if (json['events'] != null) {
      events = List<CityEvent>.from(
        json['events'].map((x) => CityEvent.fromJson(x)));
    }
    
    List<CityStat>? stats;
    if (json['stats'] != null) {
      stats = List<CityStat>.from(
        json['stats'].map((x) => CityStat.fromJson(x)));
    }
    
    Map<String, double>? priorityData;
    if (json['priorityData'] != null) {
      priorityData = Map<String, double>.from(json['priorityData']);
    } else {
      // Varsayılan örnek veri
      priorityData = {
        'Altyapı': 60.0,
        'Temizlik': 10.0,
        'Yeşil Alan': 15.0,
        'Ulaşım': 8.0,
        'Diğer': 7.0,
      };
    }
    
    Map<String, double>? monthlyPerformance;
    if (json['monthlyPerformance'] != null) {
      monthlyPerformance = Map<String, double>.from(json['monthlyPerformance']);
    } else {
      // Varsayılan örnek veri (son 3 ay)
      monthlyPerformance = {
        'Şubat': 75.0,
        'Mart': 82.0,
        'Nisan': 88.0,
      };
    }
    
    // Şehrin performans ayı ve yılını belirle
    String? performanceMonth;
    String? performanceYear;
    
    if (json['performanceMonth'] != null) {
      performanceMonth = json['performanceMonth'];
    } else {
      // Varsayılan olarak son ayı kullan
      final now = DateTime.now();
      final months = ['Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran', 
                      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'];
      performanceMonth = months[now.month - 1];
      performanceYear = now.year.toString();
    }
    
    if (json['performanceYear'] != null) {
      performanceYear = json['performanceYear'];
    }
    
    return CityProfile(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      coverImageUrl: json['coverImageUrl'] ?? json['headerImageUrl'],
      population: json['population'] ?? 0,
      latitude: json['latitude'] ?? 0.0,
      longitude: json['longitude'] ?? 0.0,
      totalPosts: json['totalPosts'] ?? 0,
      totalSolvedIssues: json['totalSolvedIssues'] ?? 0,
      activeSurveys: json['activeSurveysCount'] ?? 0,
      recentPosts: recentPosts,
      activeSurveyList: activeSurveyList,
      region: json['region'],
      mayorName: json['mayorName'],
      mayorImageUrl: json['mayorImageUrl'],
      mayorParty: json['mayorParty'],
      mayorPartyLogo: json['mayorPartyLogo'],
      mayorSatisfactionRate: json['mayorSatisfactionRate'],
      contactEmail: json['contactEmail'],
      contactPhone: json['contactPhone'],
      emergencyPhone: json['emergencyPhone'],
      website: json['website'],
      services: services,
      projects: projects,
      events: events,
      stats: stats,
      statistics: statistics,
      solvedCount: json['solvedCount'] ?? json['totalSolvedIssues'] ?? 0,
      complaintCount: json['complaintCount'] ?? json['totalPosts'] ?? 0,
      priorityData: priorityData,
      monthlyPerformance: monthlyPerformance,
      performanceMonth: performanceMonth,
      performanceYear: performanceYear,
      isBestOfMonth: json['is_best_of_month'] ?? json['isBestOfMonth'] ?? false,
      awardMonth: json['award_month'] ?? json['awardMonth'],
      awardScore: json['award_score'] != null ? json['award_score'].toDouble() : 
                  json['awardScore'] != null ? json['awardScore'].toDouble() : null,
      awardText: json['award_text'] ?? json['awardText']
    );
  }
  
  // Şehrin ilçe sayısını döndür
  int get districtCount => statistics?['districtCount'] ?? 0;
  
  // Şehirdeki aktif kullanıcı sayısını döndür
  int get activeUsers => statistics?['activeUsers'] ?? 0;
  
  // Çözüm oranını hesapla
  double get solutionRate {
    if (totalPosts == 0) return 0;
    return totalSolvedIssues / totalPosts * 100;
  }
}