import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sikayet_var/models/category.dart';
import 'package:sikayet_var/models/city.dart';
import 'package:sikayet_var/models/district.dart';
import 'package:sikayet_var/models/post.dart';
import 'package:sikayet_var/utils/constants.dart';

class ApiService {
  final String baseUrl = Constants.apiBaseUrl;
  final http.Client _client = http.Client();
  
  // Get cities
  Future<List<City>> getCities() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/cities'),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(Constants.networkTimeout);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        return data.map((json) => City.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load cities');
      }
    } catch (e) {
      // For development/demo purposes
      if (e is SocketException || e is HttpException || e is TimeoutException) {
        await Future.delayed(const Duration(seconds: 1));
        return getMockCities();
      }
      throw Exception('Failed to load cities: $e');
    }
  }
  
  // Get city by ID
  Future<City> getCityById(String cityId) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/cities/$cityId'),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(Constants.networkTimeout);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        return City.fromJson(data);
      } else {
        throw Exception('Failed to load city');
      }
    } catch (e) {
      // For development/demo purposes
      if (e is SocketException || e is HttpException || e is TimeoutException) {
        await Future.delayed(const Duration(seconds: 1));
        final cities = getMockCities();
        final city = cities.firstWhere((city) => city.id == cityId, 
          orElse: () => cities.first);
        return city;
      }
      throw Exception('Failed to load city: $e');
    }
  }
  
  // Get districts
  Future<List<District>> getDistricts() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/districts'),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(Constants.networkTimeout);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        return data.map((json) => District.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load districts');
      }
    } catch (e) {
      // For development/demo purposes
      if (e is SocketException || e is HttpException || e is TimeoutException) {
        await Future.delayed(const Duration(seconds: 1));
        return getMockDistricts();
      }
      throw Exception('Failed to load districts: $e');
    }
  }
  
  // Get districts by city ID
  Future<List<District>> getDistrictsByCityId(String cityId) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/cities/$cityId/districts'),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(Constants.networkTimeout);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        return data.map((json) => District.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load districts');
      }
    } catch (e) {
      // For development/demo purposes
      if (e is SocketException || e is HttpException || e is TimeoutException) {
        await Future.delayed(const Duration(seconds: 1));
        return getMockDistricts().where((district) => district.cityId == cityId).toList();
      }
      throw Exception('Failed to load districts: $e');
    }
  }
  
  // Get district by ID
  Future<District> getDistrictById(String districtId) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/districts/$districtId'),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(Constants.networkTimeout);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        return District.fromJson(data);
      } else {
        throw Exception('Failed to load district');
      }
    } catch (e) {
      // For development/demo purposes
      if (e is SocketException || e is HttpException || e is TimeoutException) {
        await Future.delayed(const Duration(seconds: 1));
        final districts = getMockDistricts();
        final district = districts.firstWhere((district) => district.id == districtId, 
          orElse: () => districts.first);
        return district;
      }
      throw Exception('Failed to load district: $e');
    }
  }
  
  // Get categories
  Future<List<Category>> getCategories() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/categories'),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(Constants.networkTimeout);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        return data.map((json) => Category.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      // For development/demo purposes
      if (e is SocketException || e is HttpException || e is TimeoutException) {
        await Future.delayed(const Duration(seconds: 1));
        return getMockCategories();
      }
      throw Exception('Failed to load categories: $e');
    }
  }
  
  // Mock cities for development/demo
  List<City> getMockCities() {
    return [
      City(
        id: 'city_1',
        name: 'İstanbul',
        logoUrl: 'https://via.placeholder.com/150?text=İstanbul',
        districtCount: 39,
        population: 15840900,
        mayor: 'Ekrem İmamoğlu',
        politicalParty: 'CHP',
        politicalPartyLogoUrl: 'https://via.placeholder.com/50?text=CHP',
      ),
      City(
        id: 'city_2',
        name: 'Ankara',
        logoUrl: 'https://via.placeholder.com/150?text=Ankara',
        districtCount: 25,
        population: 5747325,
        mayor: 'Mansur Yavaş',
        politicalParty: 'CHP',
        politicalPartyLogoUrl: 'https://via.placeholder.com/50?text=CHP',
      ),
      City(
        id: 'city_3',
        name: 'İzmir',
        logoUrl: 'https://via.placeholder.com/150?text=İzmir',
        districtCount: 30,
        population: 4394694,
        mayor: 'Tunç Soyer',
        politicalParty: 'CHP',
        politicalPartyLogoUrl: 'https://via.placeholder.com/50?text=CHP',
      ),
      City(
        id: 'city_4',
        name: 'Bursa',
        logoUrl: 'https://via.placeholder.com/150?text=Bursa',
        districtCount: 17,
        population: 3101833,
        mayor: 'Alinur Aktaş',
        politicalParty: 'AKP',
        politicalPartyLogoUrl: 'https://via.placeholder.com/50?text=AKP',
      ),
      City(
        id: 'city_5',
        name: 'Antalya',
        logoUrl: 'https://via.placeholder.com/150?text=Antalya',
        districtCount: 19,
        population: 2548308,
        mayor: 'Muhittin Böcek',
        politicalParty: 'CHP',
        politicalPartyLogoUrl: 'https://via.placeholder.com/50?text=CHP',
      ),
    ];
  }
  
  // Mock districts for development/demo
  List<District> getMockDistricts() {
    return [
      // İstanbul
      District(
        id: 'district_1',
        name: 'Kadıköy',
        cityId: 'city_1',
        logoUrl: 'https://via.placeholder.com/150?text=Kadıköy',
        population: 458638,
        mayor: 'Şerdil Dara Odabaşı',
        politicalParty: 'CHP',
        politicalPartyLogoUrl: 'https://via.placeholder.com/50?text=CHP',
      ),
      District(
        id: 'district_2',
        name: 'Beşiktaş',
        cityId: 'city_1',
        logoUrl: 'https://via.placeholder.com/150?text=Beşiktaş',
        population: 181074,
        mayor: 'Rıza Akpolat',
        politicalParty: 'CHP',
        politicalPartyLogoUrl: 'https://via.placeholder.com/50?text=CHP',
      ),
      District(
        id: 'district_3',
        name: 'Beyoğlu',
        cityId: 'city_1',
        logoUrl: 'https://via.placeholder.com/150?text=Beyoğlu',
        population: 224876,
        mayor: 'Haydar Ali Yıldız',
        politicalParty: 'AKP',
        politicalPartyLogoUrl: 'https://via.placeholder.com/50?text=AKP',
      ),
      District(
        id: 'district_4',
        name: 'Üsküdar',
        cityId: 'city_1',
        logoUrl: 'https://via.placeholder.com/150?text=Üsküdar',
        population: 526271,
        mayor: 'Hilmi Türkmen',
        politicalParty: 'AKP',
        politicalPartyLogoUrl: 'https://via.placeholder.com/50?text=AKP',
      ),
      // Ankara
      District(
        id: 'district_5',
        name: 'Çankaya',
        cityId: 'city_2',
        logoUrl: 'https://via.placeholder.com/150?text=Çankaya',
        population: 920890,
        mayor: 'Alper Taşdelen',
        politicalParty: 'CHP',
        politicalPartyLogoUrl: 'https://via.placeholder.com/50?text=CHP',
      ),
      District(
        id: 'district_6',
        name: 'Keçiören',
        cityId: 'city_2',
        logoUrl: 'https://via.placeholder.com/150?text=Keçiören',
        population: 909787,
        mayor: 'Turgut Altınok',
        politicalParty: 'AKP',
        politicalPartyLogoUrl: 'https://via.placeholder.com/50?text=AKP',
      ),
      District(
        id: 'district_7',
        name: 'Yenimahalle',
        cityId: 'city_2',
        logoUrl: 'https://via.placeholder.com/150?text=Yenimahalle',
        population: 663580,
        mayor: 'Fethi Yaşar',
        politicalParty: 'CHP',
        politicalPartyLogoUrl: 'https://via.placeholder.com/50?text=CHP',
      ),
      // İzmir
      District(
        id: 'district_8',
        name: 'Karşıyaka',
        cityId: 'city_3',
        logoUrl: 'https://via.placeholder.com/150?text=Karşıyaka',
        population: 344140,
        mayor: 'Cemil Tugay',
        politicalParty: 'CHP',
        politicalPartyLogoUrl: 'https://via.placeholder.com/50?text=CHP',
      ),
      District(
        id: 'district_9',
        name: 'Konak',
        cityId: 'city_3',
        logoUrl: 'https://via.placeholder.com/150?text=Konak',
        population: 356563,
        mayor: 'Abdül Batur',
        politicalParty: 'CHP',
        politicalPartyLogoUrl: 'https://via.placeholder.com/50?text=CHP',
      ),
      District(
        id: 'district_10',
        name: 'Bornova',
        cityId: 'city_3',
        logoUrl: 'https://via.placeholder.com/150?text=Bornova',
        population: 446232,
        mayor: 'Mustafa İduğ',
        politicalParty: 'CHP',
        politicalPartyLogoUrl: 'https://via.placeholder.com/50?text=CHP',
      ),
    ];
  }
  
  // Mock categories for development/demo
  List<Category> getMockCategories() {
    return [
      Category(
        id: 'category_1',
        name: 'Altyapı',
        description: 'Yol, su, elektrik, doğalgaz vb. altyapı sorunları',
        iconName: 'construction',
        subCategories: [
          SubCategory(
            id: 'subcategory_1',
            name: 'Yol Çalışmaları',
            categoryId: 'category_1',
            description: 'Asfalt, kaldırım, yol çalışmaları',
            iconName: 'road',
          ),
          SubCategory(
            id: 'subcategory_2',
            name: 'Su ve Kanalizasyon',
            categoryId: 'category_1',
            description: 'Su kesintileri, kanalizasyon sorunları',
            iconName: 'water',
          ),
        ],
      ),
      Category(
        id: 'category_2',
        name: 'Temizlik',
        description: 'Çöp toplama, sokak temizliği vb. temizlik hizmetleri',
        iconName: 'cleaning_services',
        subCategories: [
          SubCategory(
            id: 'subcategory_3',
            name: 'Çöp Toplama',
            categoryId: 'category_2',
            description: 'Çöp konteynerleri, çöp toplama hizmetleri',
            iconName: 'delete',
          ),
          SubCategory(
            id: 'subcategory_4',
            name: 'Sokak Temizliği',
            categoryId: 'category_2',
            description: 'Cadde ve sokakların temizliği',
            iconName: 'clear',
          ),
        ],
      ),
      Category(
        id: 'category_3',
        name: 'Yeşil Alan',
        description: 'Park, bahçe, ağaçlandırma vb. yeşil alan hizmetleri',
        iconName: 'park',
        subCategories: [
          SubCategory(
            id: 'subcategory_5',
            name: 'Park ve Bahçeler',
            categoryId: 'category_3',
            description: 'Park ve bahçe düzenlemeleri, bakımı',
            iconName: 'grass',
          ),
          SubCategory(
            id: 'subcategory_6',
            name: 'Ağaçlandırma',
            categoryId: 'category_3',
            description: 'Ağaçlandırma çalışmaları',
            iconName: 'eco',
          ),
        ],
      ),
      Category(
        id: 'category_4',
        name: 'Trafik',
        description: 'Trafik ışıkları, yol işaretleri, trafik düzenlemeleri',
        iconName: 'traffic',
        subCategories: [
          SubCategory(
            id: 'subcategory_7',
            name: 'Trafik Işıkları',
            categoryId: 'category_4',
            description: 'Trafik ışıklarının bakımı, arızaları',
            iconName: 'traffic_light',
          ),
          SubCategory(
            id: 'subcategory_8',
            name: 'Yol İşaretleri',
            categoryId: 'category_4',
            description: 'Trafik işaretleri, yol çizgileri',
            iconName: 'signpost',
          ),
        ],
      ),
      Category(
        id: 'category_5',
        name: 'Sosyal Hizmetler',
        description: 'Sosyal yardım, eğitim, kültürel etkinlikler',
        iconName: 'people',
        subCategories: [
          SubCategory(
            id: 'subcategory_9',
            name: 'Sosyal Yardım',
            categoryId: 'category_5',
            description: 'İhtiyaç sahiplerine yönelik yardımlar',
            iconName: 'volunteer_activism',
          ),
          SubCategory(
            id: 'subcategory_10',
            name: 'Kültürel Etkinlikler',
            categoryId: 'category_5',
            description: 'Konser, festival, sergi vb. etkinlikler',
            iconName: 'theater_comedy',
          ),
        ],
      ),
    ];
  }
}