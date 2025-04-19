import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sikayet_var/models/district.dart';
import 'package:sikayet_var/providers/city_provider.dart';
import 'package:sikayet_var/providers/post_provider.dart';
import 'package:sikayet_var/widgets/post_card.dart';
import 'package:sikayet_var/screens/posts/post_detail_screen.dart';

class DistrictProfileScreen extends ConsumerWidget {
  final String districtId;

  const DistrictProfileScreen({
    Key? key,
    required this.districtId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final districtProfileAsync = ref.watch(districtProfileProvider(districtId));
    final postsAsync = ref.watch(postsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('İlçe Profili'),
      ),
      body: districtProfileAsync.when(
        data: (district) => _buildDistrictProfile(context, ref, district, postsAsync),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Profil yüklenirken hata: $error'),
        ),
      ),
    );
  }

  Widget _buildDistrictProfile(
    BuildContext context,
    WidgetRef ref,
    District district,
    AsyncValue<List<Post>> postsAsync,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.refresh(districtProfileProvider(districtId));
        ref.read(postsProvider.notifier).filterPosts(districtId: districtId);
      },
      child: CustomScrollView(
        slivers: [
          // District header
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // District logo
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: district.logoUrl != null
                        ? NetworkImage(district.logoUrl!)
                        : null,
                    child: district.logoUrl == null
                        ? const Icon(Icons.location_on, size: 50)
                        : null,
                  ),
                  const SizedBox(height: 16),
                  
                  // District name
                  Text(
                    district.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  // City name
                  FutureBuilder<City>(
                    future: ref.read(apiServiceProvider).getCityProfile(district.cityId),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Text(
                          snapshot.data!.name,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  
                  // Political party if available
                  if (district.politicalParty != null && district.politicalParty!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (district.politicalPartyLogoUrl != null)
                            Image.network(
                              district.politicalPartyLogoUrl!,
                              width: 20,
                              height: 20,
                              errorBuilder: (context, error, stackTrace) {
                                return const SizedBox(width: 20, height: 20);
                              },
                            ),
                          const SizedBox(width: 4),
                          Text(
                            district.politicalParty!,
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // District info
                  if (district.info != null && district.info!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        district.info!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  
                  // Contact info
                  if (district.contactPhone != null || district.contactEmail != null || district.websiteUrl != null)
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
                            if (district.contactPhone != null)
                              Row(
                                children: [
                                  const Icon(Icons.phone, size: 16),
                                  const SizedBox(width: 8),
                                  Text(district.contactPhone!),
                                ],
                              ),
                            if (district.contactEmail != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Row(
                                  children: [
                                    const Icon(Icons.email, size: 16),
                                    const SizedBox(width: 8),
                                    Text(district.contactEmail!),
                                  ],
                                ),
                              ),
                            if (district.websiteUrl != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Row(
                                  children: [
                                    const Icon(Icons.link, size: 16),
                                    const SizedBox(width: 8),
                                    Text(district.websiteUrl!),
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
                          value: district.solutionRate,
                          minHeight: 10,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            district.solutionRate > 0.7 ? Colors.green : 
                            district.solutionRate > 0.4 ? Colors.orange : Colors.red,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(district.solutionRate * 100).toStringAsFixed(1)}% - ${district.solvedIssuesCount} / ${district.totalIssuesCount} çözüldü',
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
                        'İlçe Gönderileri',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Filter posts by district
                          ref.read(postsProvider.notifier).filterPosts(districtId: districtId);
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
          
          // District posts
          postsAsync.when(
            data: (posts) {
              // Filter posts by district
              final districtPosts = posts.where((post) => post.districtId == districtId).toList();
              
              if (districtPosts.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: Text('Bu ilçeye ait henüz gönderi yok'),
                  ),
                );
              }
              
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final post = districtPosts[index];
                    return PostCard(
                      post: post,
                      onTap: () {
                        ref.read(selectedPostProvider.notifier).state = post;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PostDetailScreen(id: post.id),
                          ),
                        );
                      },
                      onLike: () {
                        ref.read(postsProvider.notifier).likePost(post.id);
                      },
                      onHighlight: () {
                        ref.read(postsProvider.notifier).highlightPost(post.id);
                      },
                    );
                  },
                  childCount: districtPosts.length,
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
