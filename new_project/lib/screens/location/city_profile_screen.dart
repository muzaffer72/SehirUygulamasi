import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/city_profile.dart';
import '../../providers/city_profile_provider.dart';
import '../../providers/post_provider.dart';
import '../../widgets/post_card.dart';
import '../posts/post_detail_screen.dart';
import '../../models/post.dart';

class CityProfileScreen extends ConsumerWidget {
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('cityId', cityId));
  }
  final String cityId;

  const CityProfileScreen({
    Key? key,
    required this.cityId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cityProfileAsync = ref.watch(cityProfileProvider(cityId));
    final postsAsync = ref.watch(postsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Şehir Profili'),
      ),
      body: cityProfileAsync.when(
        data: (city) => _buildCityProfile(context, ref, city, postsAsync),
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
        ref.read(postsProvider.notifier).filterPosts(cityId: cityId);
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
                          value: (city.solutionRate is double) ? city.solutionRate : city.solutionRate / 100,
                          minHeight: 10,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            (city.solutionRate is double ? city.solutionRate : city.solutionRate / 100) > 0.7 
                              ? Colors.green 
                              : (city.solutionRate is double ? city.solutionRate : city.solutionRate / 100) > 0.4 
                                ? Colors.orange 
                                : Colors.red,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(city.solutionRate is double ? city.solutionRate * 100 : city.solutionRate).toStringAsFixed(1)}% - ${city.solvedComplaints ?? city.totalSolvedIssues ?? 0} / ${city.totalComplaints ?? city.totalPosts ?? 0} çözüldü',
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
                          ref.read(postsProvider.notifier).filterPosts(cityId: cityId);
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
                        ref.read(selectedPostProvider.notifier).state = post;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PostDetailScreen(post: post),
                          ),
                        );
                      },
                      onLike: () {
                        ref.read(postsProvider.notifier).likePost(post.id);
                      },
                      onComment: () {
                        // Yorum yapma işlevi
                        ref.read(selectedPostProvider.notifier).state = post;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PostDetailScreen(post: post),
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