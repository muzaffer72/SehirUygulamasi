import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sikayet_var/models/category.dart';
import 'package:sikayet_var/models/city.dart';
import 'package:sikayet_var/models/district.dart';
import 'package:sikayet_var/models/post.dart';
import 'package:sikayet_var/providers/auth_provider.dart';
import 'package:sikayet_var/services/api_service.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostCard extends ConsumerWidget {
  final Post post;
  final VoidCallback onTap;
  final VoidCallback onLike;
  final VoidCallback onHighlight;
  
  const PostCard({
    Key? key,
    required this.post,
    required this.onTap,
    required this.onLike,
    required this.onHighlight,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final isOwner = currentUser?.id == post.userId;
    final apiService = ApiService();
    
    // Set up timeago in Turkish
    timeago.setLocaleMessages('tr', timeago.TrMessages());
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Type and status indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: post.type == PostType.problem 
                          ? Colors.red.shade100 
                          : Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          post.type == PostType.problem
                              ? Icons.warning_rounded
                              : Icons.lightbulb_outline,
                          size: 16,
                          color: post.type == PostType.problem
                              ? Colors.red.shade700
                              : Colors.blue.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          post.type == PostType.problem ? 'Şikayet' : 'Öneri',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: post.type == PostType.problem
                                ? Colors.red.shade700
                                : Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  if (post.type == PostType.problem && post.status != null)
                    Container(
                      margin: const EdgeInsets.only(left: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: post.status == PostStatus.solved
                            ? Colors.green.shade100
                            : Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        post.status == PostStatus.solved
                            ? 'Çözüldü'
                            : 'Beklemede',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: post.status == PostStatus.solved
                              ? Colors.green.shade700
                              : Colors.orange.shade700,
                        ),
                      ),
                    ),
                    
                  const Spacer(),
                  
                  // Time ago
                  Text(
                    timeago.format(post.createdAt, locale: 'tr'),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                post.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            // Content (preview)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                post.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            
            // Image preview if available
            if (post.imageUrls.isNotEmpty)
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: post.imageUrls.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.only(
                        left: index == 0 ? 12 : 4,
                        right: index == post.imageUrls.length - 1 ? 12 : 4,
                      ),
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(post.imageUrls[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
            
            // Location and category
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: FutureBuilder(
                future: Future.wait([
                  apiService.getCityById(post.cityId),
                  apiService.getDistrictById(post.districtId),
                  apiService.getCategories().then((categories) => 
                    categories.firstWhere((c) => c.id == post.categoryId, 
                      orElse: () => Category(
                        id: post.categoryId,
                        name: 'Bilinmeyen',
                        description: '',
                      )
                    )
                  ),
                ]),
                builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text('Yükleniyor...');
                  }
                  
                  String cityName = 'Bilinmeyen İl';
                  String districtName = 'Bilinmeyen İlçe';
                  String categoryName = 'Bilinmeyen Kategori';
                  
                  if (snapshot.hasData) {
                    final city = snapshot.data![0] as City;
                    final district = snapshot.data![1] as District;
                    final category = snapshot.data![2] as Category;
                    
                    cityName = city.name;
                    districtName = district.name;
                    categoryName = category.name;
                  }
                  
                  return Wrap(
                    spacing: 8,
                    children: [
                      Chip(
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                        avatar: const Icon(Icons.location_on, size: 16),
                        label: Text('$districtName, $cityName'),
                        visualDensity: VisualDensity.compact,
                      ),
                      Chip(
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                        avatar: const Icon(Icons.category, size: 16),
                        label: Text(categoryName),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  );
                },
              ),
            ),
            
            // Divider
            const Divider(height: 1),
            
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Like button
                TextButton.icon(
                  onPressed: onLike,
                  icon: const Icon(Icons.thumb_up_outlined, size: 18),
                  label: Text('${post.likeCount}'),
                ),
                
                // Comment button
                TextButton.icon(
                  onPressed: onTap, // Go to detail screen to see comments
                  icon: const Icon(Icons.comment_outlined, size: 18),
                  label: Text('${post.commentCount}'),
                ),
                
                // Highlight button
                TextButton.icon(
                  onPressed: onHighlight,
                  icon: const Icon(Icons.star_outline, size: 18),
                  label: Text('${post.highlightCount}'),
                ),
                
                // Share button
                IconButton(
                  onPressed: () {
                    // TODO: Implement share functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Paylaşım özelliği yakında eklenecek'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.share_outlined, size: 18),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}