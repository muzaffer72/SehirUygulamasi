enum UserLevel {
  newUser,     // 0-100 puan - Yeni Kullanıcı
  contributor, // 101-500 puan - Şehrini Seven
  active,      // 501-1000 puan - Şehir Sevdalısı
  expert,      // 1001-2000 puan - Şehir Aşığı
  master       // 2000+ puan - Şehir Uzmanı
}

// Kullanıcı rozetleri
enum UserBadge {
  mahalleBekçisi,    // Bir mahalledeki sorunları sürekli rapor edenler
  sorunAvcısı,       // Birçok farklı sorunu bulan ve bildirenler
  halkTemsilcisi,    // En çok oylanan ve desteklenen gönderilere sahip
  çözümÜreticisi,    // Sorunlar çözüldüğünde belediye tarafından atanır
  toplumdanBiri,     // Aktif yorum yapan ve topluluk etkileşimi yüksek
  çevreDostu,        // Çevre sorunları hakkında paylaşım yapanlar
  altyapıDenetçisi,  // Altyapı sorunları hakkında paylaşım yapanlar 
  ulaşımŞampiyonu    // Ulaşım sorunları hakkında paylaşım yapanlar
}

class User {
  final String id;
  final String name;
  final String email;
  final String? profileImageUrl;
  final String? bio;
  final String? cityId;
  final String? districtId;
  final bool isVerified;
  final int points;
  final int postCount;
  final int commentCount;
  final UserLevel level;
  final DateTime createdAt;
  final List<UserBadge> badges; // Kullanıcının rozetleri

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profileImageUrl,
    this.bio,
    this.cityId,
    this.districtId,
    required this.isVerified,
    this.points = 0,
    this.postCount = 0,
    this.commentCount = 0,
    this.level = UserLevel.newUser,
    required this.createdAt,
    this.badges = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Rozet verilerini işle
    List<UserBadge> badges = [];
    if (json['badges'] != null) {
      try {
        final badgesList = json['badges'] as List;
        for (var badge in badgesList) {
          if (badge is String) {
            switch (badge) {
              case 'mahalleBekçisi':
                badges.add(UserBadge.mahalleBekçisi);
                break;
              case 'sorunAvcısı':
                badges.add(UserBadge.sorunAvcısı);
                break;
              case 'halkTemsilcisi':
                badges.add(UserBadge.halkTemsilcisi);
                break;
              case 'çözümÜreticisi':
                badges.add(UserBadge.çözümÜreticisi);
                break;
              case 'toplumdanBiri':
                badges.add(UserBadge.toplumdanBiri);
                break;
              case 'çevreDostu':
                badges.add(UserBadge.çevreDostu);
                break;
              case 'altyapıDenetçisi':
                badges.add(UserBadge.altyapıDenetçisi);
                break;
              case 'ulaşımŞampiyonu':
                badges.add(UserBadge.ulaşımŞampiyonu);
                break;
            }
          }
        }
      } catch (e) {
        print('Rozetler çözümlenirken hata oluştu: $e');
      }
    }
    
    // Varsayılan rozet ekleme (örnek için)
    final points = json['points'] ?? 0;
    if (badges.isEmpty && points >= 500) {
      // 500+ puan ise en az bir rozet ver
      badges.add(UserBadge.toplumdanBiri);
      
      // 1000+ puan ise sorun avcısı rozeti ver
      if (points >= 1000) {
        badges.add(UserBadge.sorunAvcısı);
      }
      
      // 1500+ puan ise mahalle bekçisi rozeti ver
      if (points >= 1500) {
        badges.add(UserBadge.mahalleBekçisi);
      }
    }
    
    return User(
      id: json['id'].toString(),
      name: json['name'],
      email: json['email'],
      profileImageUrl: json['profile_image_url'],
      bio: json['bio'],
      cityId: json['city_id']?.toString(),
      districtId: json['district_id']?.toString(),
      isVerified: json['is_verified'] ?? false,
      points: points,
      postCount: json['post_count'] ?? 0,
      commentCount: json['comment_count'] ?? 0,
      level: _getUserLevel(points),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      badges: badges,
    );
  }

  static UserLevel _getUserLevel(int points) {
    if (points >= 2000) return UserLevel.master;
    if (points >= 1001) return UserLevel.expert;
    if (points >= 501) return UserLevel.active;
    if (points >= 101) return UserLevel.contributor;
    return UserLevel.newUser;
  }

  Map<String, dynamic> toJson() {
    // Rozet adlarını string listesine çevir
    final badgeNames = badges.map((badge) => badge.toString().split('.').last).toList();
    
    return {
      'id': id,
      'name': name,
      'email': email,
      'profile_image_url': profileImageUrl,
      'bio': bio,
      'city_id': cityId,
      'district_id': districtId,
      'is_verified': isVerified,
      'points': points,
      'post_count': postCount,
      'comment_count': commentCount,
      'created_at': createdAt.toIso8601String(),
      'badges': badgeNames,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? profileImageUrl,
    String? bio,
    String? cityId,
    String? districtId,
    bool? isVerified,
    int? points,
    int? postCount,
    int? commentCount,
    UserLevel? level,
    DateTime? createdAt,
    List<UserBadge>? badges,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      bio: bio ?? this.bio,
      cityId: cityId ?? this.cityId,
      districtId: districtId ?? this.districtId,
      isVerified: isVerified ?? this.isVerified,
      points: points ?? this.points,
      postCount: postCount ?? this.postCount,
      commentCount: commentCount ?? this.commentCount,
      level: level ?? this.level,
      createdAt: createdAt ?? this.createdAt,
      badges: badges ?? this.badges,
    );
  }

  String getLevelName() {
    switch (level) {
      case UserLevel.newUser:
        return "Yeni Kullanıcı";
      case UserLevel.contributor:
        return "Şehrini Seven";
      case UserLevel.active:
        return "Şehir Sevdalısı";
      case UserLevel.expert:
        return "Şehir Aşığı";
      case UserLevel.master:
        return "Şehir Uzmanı";
    }
  }
  
  // Rozet bilgilerini döndürür
  Map<String, dynamic> getBadgeInfo(UserBadge badge) {
    switch (badge) {
      case UserBadge.mahalleBekçisi:
        return {
          'name': 'Mahalle Bekçisi',
          'description': 'Mahallesindeki sorunları sürekli takip eden ve raporlayan kullanıcı',
          'icon': 'visibility', // Gözetleme
          'color': 0xFF4CAF50, // Yeşil
        };
      case UserBadge.sorunAvcısı:
        return {
          'name': 'Sorun Avcısı',
          'description': 'Birçok farklı sorunu keşfedip bildiren kullanıcı',
          'icon': 'bug_report',  // Hata raporu
          'color': 0xFFF44336, // Kırmızı
        };
      case UserBadge.halkTemsilcisi:
        return {
          'name': 'Halk Temsilcisi',
          'description': 'Gönderileri en çok desteklenen ve oylanan kullanıcı',
          'icon': 'people',  // İnsanlar
          'color': 0xFF2196F3, // Mavi
        };
      case UserBadge.çözümÜreticisi:
        return {
          'name': 'Çözüm Üreticisi',
          'description': 'Bildirdiği sorunların çözüme kavuşma oranı yüksek olan kullanıcı',
          'icon': 'lightbulb', // Ampul
          'color': 0xFFFFEB3B, // Sarı
        };
      case UserBadge.toplumdanBiri:
        return {
          'name': 'Toplumdan Biri',
          'description': 'Aktif yorum yapan ve topluluk katılımı yüksek olan kullanıcı',
          'icon': 'forum', // Forum
          'color': 0xFF9C27B0, // Mor
        };
      case UserBadge.çevreDostu:
        return {
          'name': 'Çevre Dostu',
          'description': 'Çevre sorunları hakkında paylaşım yapan kullanıcı',
          'icon': 'eco', // Çevre
          'color': 0xFF8BC34A, // Açık yeşil
        };
      case UserBadge.altyapıDenetçisi:
        return {
          'name': 'Altyapı Denetçisi',
          'description': 'Altyapı sorunları hakkında paylaşım yapan kullanıcı',
          'icon': 'construction', // İnşaat
          'color': 0xFFFF9800, // Turuncu
        };
      case UserBadge.ulaşımŞampiyonu:
        return {
          'name': 'Ulaşım Şampiyonu',
          'description': 'Ulaşım sorunları hakkında paylaşım yapan kullanıcı',
          'icon': 'directions_bus', // Otobüs
          'color': 0xFF3F51B5, // Lacivert
        };
    }
  }
}