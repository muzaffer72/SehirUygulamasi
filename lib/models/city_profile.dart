import 'package:sikayet_var/models/post.dart';
import 'package:sikayet_var/models/survey.dart';

class CityProfile {
  final int id;
  final String name;
  final String? description;
  final String? imageUrl;
  final String? headerImageUrl;
  final int population;
  final double latitude;
  final double longitude;
  final int totalPosts;
  final int totalSolvedIssues;
  final int activeSurveys;
  final List<Post>? recentPosts;
  final List<Survey>? activeSurveyList;
  
  // İstatistikler
  final Map<String, int>? statistics;
  
  CityProfile({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.headerImageUrl,
    required this.population,
    required this.latitude,
    required this.longitude,
    required this.totalPosts,
    required this.totalSolvedIssues,
    required this.activeSurveys,
    this.recentPosts,
    this.activeSurveyList,
    this.statistics,
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
    
    return CityProfile(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      headerImageUrl: json['headerImageUrl'],
      population: json['population'] ?? 0,
      latitude: json['latitude'] ?? 0.0,
      longitude: json['longitude'] ?? 0.0,
      totalPosts: json['totalPosts'] ?? 0,
      totalSolvedIssues: json['totalSolvedIssues'] ?? 0,
      activeSurveys: json['activeSurveysCount'] ?? 0,
      recentPosts: recentPosts,
      activeSurveyList: activeSurveyList,
      statistics: statistics,
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