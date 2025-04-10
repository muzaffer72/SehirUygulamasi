import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sikayet_var/models/city_profile.dart';
import 'package:sikayet_var/models/post.dart';
import 'package:sikayet_var/models/survey.dart';
import 'package:sikayet_var/providers/city_profile_provider.dart';
import 'package:sikayet_var/providers/current_user_provider.dart';
import 'package:sikayet_var/providers/api_service_provider.dart';
import 'package:sikayet_var/screens/posts/post_detail_screen.dart';
import 'package:sikayet_var/screens/surveys/survey_detail_screen.dart';
import 'package:sikayet_var/widgets/post_card.dart';
import 'package:sikayet_var/widgets/survey_slider.dart';

class CityProfileScreen extends ConsumerStatefulWidget {
  final int cityId;
  final String cityName;
  
  const CityProfileScreen({
    Key? key,
    required this.cityId,
    required this.cityName,
  }) : super(key: key);

  @override
  ConsumerState<CityProfileScreen> createState() => _CityProfileScreenState();
}

class _CityProfileScreenState extends ConsumerState<CityProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cityProfileAsync = ref.watch(cityProfileProvider(widget.cityId));
    
    return Scaffold(
      body: cityProfileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Şehir profili yüklenirken hata oluştu: $error'),
        ),
        data: (cityProfile) {
          return _buildCityProfile(context, cityProfile);
        },
      ),
    );
  }
  
  Widget _buildCityProfile(BuildContext context, CityProfile cityProfile) {
    return CustomScrollView(
      slivers: [
        // Üst kısım - Şehir Kapak Fotoğrafı ve Bilgileri
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              cityProfile.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    offset: Offset(1, 1),
                    blurRadius: 3,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
            background: cityProfile.coverImageUrl != null 
              ? Image.network(
                  cityProfile.coverImageUrl!,
                  fit: BoxFit.cover,
                )
              : Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Theme.of(context).colorScheme.primary.withOpacity(0.7),
                        Theme.of(context).colorScheme.primary,
                      ],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      cityProfile.name,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ),
                ),
          ),
        ),
        
        // Şehir Bilgileri Özeti
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Şehir açıklaması
                if (cityProfile.description != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      cityProfile.description!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                
                // İstatistikler ve özet bilgiler
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatCard(
                      context, 
                      'İlçe Sayısı', 
                      '${cityProfile.districtCount}',
                      Icons.location_city,
                    ),
                    _buildStatCard(
                      context, 
                      'Nüfus', 
                      '${cityProfile.population}',
                      Icons.people,
                    ),
                    _buildStatCard(
                      context, 
                      'Çözüm Oranı', 
                      '%${cityProfile.solutionRate.toStringAsFixed(1)}',
                      Icons.check_circle_outline,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        // Tab Bar
        SliverPersistentHeader(
          delegate: _SliverAppBarDelegate(
            TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Colors.grey,
              isScrollable: true,
              tabs: const [
                Tab(text: 'Şikayetler'),
                Tab(text: 'Projeler'),
                Tab(text: 'Etkinlikler'),
                Tab(text: 'Hizmetler'),
                Tab(text: 'Hakkında'),
              ],
            ),
          ),
          pinned: true,
        ),
        
        // Tab İçerikleri
        SliverFillRemaining(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Şehirdeki Şikayetler (Gönderiler)
              _buildPostsTab(cityProfile),
              
              // Şehirdeki Projeler
              _buildProjectsTab(cityProfile),
              
              // Şehirdeki Etkinlikler
              _buildEventsTab(cityProfile),
              
              // Şehirdeki Hizmetler
              _buildServicesTab(cityProfile),
              
              // Şehir Hakkında Bilgiler
              _buildAboutTab(cityProfile),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPostsTab(CityProfile cityProfile) {
    final recentPosts = cityProfile.recentPosts;
    
    if (recentPosts == null || recentPosts.isEmpty) {
      return const Center(
        child: Text('Bu şehirde henüz paylaşım bulunmuyor.'),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: recentPosts.length,
      itemBuilder: (context, index) {
        final post = recentPosts[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: PostCard(
            post: post,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PostDetailScreen(post: post),
                ),
              );
            },
            onLike: () async {
              // Beğeni fonksiyonu
              await ref.read(apiServiceProvider).likePost(post.id);
            },
            onHighlight: () async {
              // Öne çıkarma fonksiyonu
              await ref.read(apiServiceProvider).highlightPost(post.id);
            },
          ),
        );
      },
    );
  }
  
  Widget _buildSurveysTab(CityProfile cityProfile) {
    final activeSurveys = cityProfile.activeSurveyList;
    
    if (activeSurveys == null || activeSurveys.isEmpty) {
      return const Center(
        child: Text('Bu şehirde aktif anket bulunmuyor.'),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: activeSurveys.length,
      itemBuilder: (context, index) {
        final survey = activeSurveys[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SurveyDetailScreen(survey: survey),
              ),
            );
          },
          child: Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    survey.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    survey.description,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Katılım: ${survey.totalVotes} oy',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'Bitiş: ${survey.getRemainingTimeText()}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildProjectsTab(CityProfile cityProfile) {
    final projects = cityProfile.projects;
    
    if (projects == null || projects.isEmpty) {
      return const Center(
        child: Text('Bu şehirde henüz proje bilgisi bulunmuyor.'),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (project.imageUrl != null)
                Image.network(
                  project.imageUrl!,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (project.description != null)
                      Text(
                        project.description!,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Başlangıç: ${project.startDate ?? "Belirtilmemiş"}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    if (project.endDate != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.flag,
                              size: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Bitiş: ${project.endDate}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (project.status != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(project.status!),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            project.status!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildEventsTab(CityProfile cityProfile) {
    final events = cityProfile.events;
    
    if (events == null || events.isEmpty) {
      return const Center(
        child: Text('Bu şehirde henüz etkinlik bilgisi bulunmuyor.'),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Tarih bilgisi
                          if (event.date != null) ...[
                            Text(
                              event.date!.split(' ')[0], // Gün
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            Text(
                              _getShortMonth(event.date!), // Ay
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (event.location != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 14,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      event.location!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (event.description != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      event.description!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildServicesTab(CityProfile cityProfile) {
    final services = cityProfile.services;
    
    if (services == null || services.isEmpty) {
      return const Center(
        child: Text('Bu şehirde henüz hizmet bilgisi bulunmuyor.'),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  _getServiceIcon(service.category),
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (service.description != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            service.description!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      if (service.contactInfo != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              Icon(
                                Icons.phone,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                service.contactInfo!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (service.workingHours != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                service.workingHours!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  // Hizmet kategorisine göre ikon döndürür
  IconData _getServiceIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'sağlık':
        return Icons.local_hospital;
      case 'eğitim':
        return Icons.school;
      case 'ulaşım':
        return Icons.directions_bus;
      case 'güvenlik':
        return Icons.security;
      case 'çevre':
        return Icons.eco;
      case 'sosyal':
        return Icons.people;
      case 'kültür':
        return Icons.theater_comedy;
      case 'spor':
        return Icons.sports_soccer;
      default:
        return Icons.miscellaneous_services;
    }
  }
  
  // Proje durumuna göre renk döndürür
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'tamamlandı':
        return Colors.green;
      case 'devam ediyor':
        return Colors.blue;
      case 'planlanıyor':
        return Colors.orange;
      case 'iptal edildi':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  
  // Tarihten kısa ay adı çıkarır
  String _getShortMonth(String date) {
    try {
      final parts = date.split(' ');
      if (parts.length > 1) {
        final monthNumber = int.tryParse(parts[1]);
        if (monthNumber != null && monthNumber >= 1 && monthNumber <= 12) {
          const months = ['Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'];
          return months[monthNumber - 1];
        }
      }
      return '';
    } catch (e) {
      return '';
    }
  }
  
  Widget _buildAboutTab(CityProfile cityProfile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Belediye Başkanı Bilgileri
          if (cityProfile.mayorName != null) ...[
            const Text(
              'Belediye Başkanı',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    if (cityProfile.mayorImageUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(40),
                        child: Image.network(
                          cityProfile.mayorImageUrl!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cityProfile.mayorName!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (cityProfile.mayorParty != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                if (cityProfile.mayorPartyLogo != null)
                                  Image.network(
                                    cityProfile.mayorPartyLogo!,
                                    width: 20,
                                    height: 20,
                                  )
                                else
                                  Icon(
                                    Icons.group,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                const SizedBox(width: 4),
                                Text(
                                  cityProfile.mayorParty!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (cityProfile.mayorSatisfactionRate != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  'Memnuniyet Oranı: ',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  '%${cityProfile.mayorSatisfactionRate}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _getSatisfactionColor(cityProfile.mayorSatisfactionRate!),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
          
          // İletişim Bilgileri
          const Text(
            'İletişim Bilgileri',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          if (cityProfile.contactPhone != null)
            _buildContactRow(Icons.phone, 'Telefon', cityProfile.contactPhone!),
          
          if (cityProfile.emergencyPhone != null)
            _buildContactRow(Icons.emergency, 'Acil Durum', cityProfile.emergencyPhone!),
          
          if (cityProfile.contactEmail != null)
            _buildContactRow(Icons.email, 'E-posta', cityProfile.contactEmail!),
          
          if (cityProfile.website != null)
            _buildContactRow(Icons.language, 'Web Sitesi', cityProfile.website!),
          
          const SizedBox(height: 24),
          
          // Genel Bilgiler
          const Text(
            'Genel Bilgiler',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          // Nüfus
          _buildInfoRow('Nüfus', '${cityProfile.population}'),
          
          // Koordinatlar
          _buildInfoRow('Enlem', '${cityProfile.latitude.toStringAsFixed(6)}'),
          _buildInfoRow('Boylam', '${cityProfile.longitude.toStringAsFixed(6)}'),
          
          // İstatistikler
          const SizedBox(height: 24),
          const Text(
            'İstatistikler',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          // Şehir İstatistikleri
          if (cityProfile.stats != null && cityProfile.stats!.isNotEmpty) ...[
            for (var stat in cityProfile.stats!)
              _buildInfoRow(stat.name, stat.value),
            const SizedBox(height: 16),
          ],
          
          // Standart İstatistikler
          _buildInfoRow('Toplam Paylaşım', '${cityProfile.totalPosts}'),
          _buildInfoRow('Çözülen Sorunlar', '${cityProfile.totalSolvedIssues}'),
          _buildInfoRow('Aktif Anketler', '${cityProfile.activeSurveys}'),
          _buildInfoRow('Aktif Kullanıcılar', '${cityProfile.activeUsers}'),
          _buildInfoRow('Çözüm Oranı', '%${cityProfile.solutionRate.toStringAsFixed(1)}'),
          _buildInfoRow('İlçe Sayısı', '${cityProfile.districtCount}'),
        ],
      ),
    );
  }
  
  Widget _buildContactRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // Memnuniyet oranına göre renk döndürür
  Color _getSatisfactionColor(int rate) {
    if (rate >= 70) {
      return Colors.green;
    } else if (rate >= 40) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// TabBar için delegate
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}