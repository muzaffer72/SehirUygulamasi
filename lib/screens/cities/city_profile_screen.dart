import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sikayet_var/models/city_profile.dart';
import 'package:sikayet_var/models/post.dart';
import 'package:sikayet_var/models/survey.dart';
import 'package:sikayet_var/providers/city_profile_provider.dart';
import 'package:sikayet_var/providers/current_user_provider.dart';
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
    _tabController = TabController(length: 3, vsync: this);
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
            background: cityProfile.headerImageUrl != null 
              ? Image.network(
                  cityProfile.headerImageUrl!,
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
              tabs: const [
                Tab(text: 'Gönderiler'),
                Tab(text: 'Anketler'),
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
              // Şehirdeki Gönderiler
              _buildPostsTab(cityProfile),
              
              // Şehirdeki Anketler
              _buildSurveysTab(cityProfile),
              
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
                  builder: (context) => PostDetailScreen(postId: post.id),
                ),
              );
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
  
  Widget _buildAboutTab(CityProfile cityProfile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          
          // Toplam Paylaşım Sayısı
          _buildInfoRow('Toplam Paylaşım', '${cityProfile.totalPosts}'),
          
          // Çözülen Sorun Sayısı
          _buildInfoRow('Çözülen Sorunlar', '${cityProfile.totalSolvedIssues}'),
          
          // Aktif Anket Sayısı
          _buildInfoRow('Aktif Anketler', '${cityProfile.activeSurveys}'),
          
          // Aktif Kullanıcı Sayısı
          _buildInfoRow('Aktif Kullanıcılar', '${cityProfile.activeUsers}'),
          
          // Çözüm Oranı
          _buildInfoRow('Çözüm Oranı', '%${cityProfile.solutionRate.toStringAsFixed(1)}'),
          
          // İlçe Sayısı
          _buildInfoRow('İlçe Sayısı', '${cityProfile.districtCount}'),
        ],
      ),
    );
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