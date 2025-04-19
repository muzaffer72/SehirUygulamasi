import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/city_profile.dart';
import '../../providers/city_profile_provider.dart';
import '../../providers/post_provider.dart' as post_provider;
import '../../widgets/post_card.dart';
import '../posts/post_detail_screen.dart';
import '../../models/post.dart';

// Helper extension
extension NullableDoubleHelpers on double? {
  double getOr(double defaultValue) => this ?? defaultValue;
}

class CityProfileScreen extends ConsumerWidget {
  // Helper methods for solution rate calculation
  double _calculateSolutionRateValue(CityProfile city) {
    if (city.solutionRate == null) return 0.0;
    return (city.solutionRate is double) ? city.solutionRate!.getOr(0.0) : city.solutionRate!.getOr(0.0) / 100;
  }
  
  Color _getSolutionRateColor(CityProfile city) {
    if (city.solutionRate == null) return Colors.grey;
    
    final rate = _calculateSolutionRateValue(city);
    if (rate > 0.7) return Colors.green;
    if (rate > 0.4) return Colors.orange;
    return Colors.red;
  }
  
  String _formatSolutionRate(CityProfile city) {
    if (city.solutionRate == null) return "0.0";
    
    final rate = city.solutionRate is double 
        ? city.solutionRate!.getOr(0.0) * 100 
        : city.solutionRate!.getOr(0.0);
    return rate.toStringAsFixed(1);
  }
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('cityId', cityId));
  }
  final String cityId;
  final String? cityName; // Opsiyonel parametre olarak şehir ismi

  const CityProfileScreen({
    Key? key,
    required this.cityId,
    this.cityName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cityProfileAsync = ref.watch(cityProfileProvider(cityId));
    final posts = ref.watch(post_provider.postsProvider);
    // Convert to AsyncValue for compatibility
    final postsAsync = AsyncValue.data(posts);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Şehir Profili'),
      ),
      body: cityProfileAsync.when(
        data: (city) => _buildCityProfile(context, ref, city ?? CityProfile(id: "0", cityId: "0", name: "Bulunamadı"), postsAsync),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Profil yüklenirken hata: $error'),
        ),
      ),
    );
  }

  Widget _buildCityProfile(
    BuildContext context,
    WidgetRef ref,
    CityProfile city,
    AsyncValue<List<Post>> postsAsync,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.refresh(cityProfileProvider(cityId));
        ref.read(post_provider.postsProvider.notifier).filterPosts(cityId: cityId);
      },
      child: CustomScrollView(
        slivers: [
          // City header
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // City logo
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: city.logoUrl != null
                        ? NetworkImage(city.logoUrl!)
                        : null,
                    child: city.logoUrl == null
                        ? const Icon(Icons.location_city, size: 50)
                        : null,
                  ),
                  const SizedBox(height: 16),
                  
                  // City name
                  Text(
                    city.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  // Political party if available
                  if (city.politicalParty != null && city.politicalParty!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (city.politicalPartyLogoUrl != null)
                            Image.network(
                              city.politicalPartyLogoUrl!,
                              width: 20,
                              height: 20,
                              errorBuilder: (context, error, stackTrace) {
                                return const SizedBox(width: 20, height: 20);
                              },
                            ),
                          const SizedBox(width: 4),
                          Text(
                            city.politicalParty!,
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // City info
                  if (city.info != null && city.info!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        city.info!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  
                  // Contact info
                  if (city.contactPhone != null || city.contactEmail != null || city.website != null)
                    Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'İletişim Bilgileri',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (city.contactPhone != null)
                              Row(
                                children: [
                                  const Icon(Icons.phone, size: 16),
                                  const SizedBox(width: 8),
                                  Text(city.contactPhone!),
                                ],
                              ),
                            if (city.contactEmail != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Row(
                                  children: [
                                    const Icon(Icons.email, size: 16),
                                    const SizedBox(width: 8),
                                    Text(city.contactEmail!),
                                  ],
                                ),
                              ),
                            if (city.website != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Row(
                                  children: [
                                    const Icon(Icons.link, size: 16),
                                    const SizedBox(width: 8),
                                    Text(city.website!),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  
                  // Solution rate
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      children: [
                        const Text(
                          'Çözüm Oranı',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: _calculateSolutionRateValue(city),
                          minHeight: 10,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getSolutionRateColor(city),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_formatSolutionRate(city)}% - ${city.solvedComplaints ?? city.totalSolvedIssues ?? 0} / ${city.totalComplaints ?? city.totalPosts ?? 0} çözüldü',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Posts header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Şehir Gönderileri',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Filter posts by city
                          ref.read(post_provider.postsProvider.notifier).filterPosts(cityId: cityId);
                        },
                        child: const Text('Hepsini Göster'),
                      ),
                    ],
                  ),
                  const Divider(),
                ],
              ),
            ),
          ),
          
          // City posts
          postsAsync.when(
            data: (posts) {
              // Filter posts by city
              final cityPosts = posts.where((post) => post.cityId == cityId).toList();
              
              if (cityPosts.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: Text('Bu şehre ait henüz gönderi yok'),
                  ),
                );
              }
              
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final post = cityPosts[index];
                    return PostCard(
                      post: post,
                      onTap: () {
                        ref.read(post_provider.selectedPostProvider.notifier).state = post;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PostDetailScreen(id: post.id),
                          ),
                        );
                      },
                      onLike: () {
                        ref.read(post_provider.postsProvider.notifier).likePost(post.id);
                      },
                      onHighlight: () {
                        // Öne çıkarma işlevi
                      },
                      onComment: () {
                        // Yorum yapma işlevi
                        ref.read(post_provider.selectedPostProvider.notifier).state = post;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PostDetailScreen(id: post.id),
                          ),
                        );
                      },
                    );
                  },
                  childCount: cityPosts.length,
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stackTrace) => SliverFillRemaining(
              child: Center(
                child: Text('Gönderiler yüklenirken hata: $error'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}