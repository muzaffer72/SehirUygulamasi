import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sikayet_var/models/category.dart';
import 'package:sikayet_var/models/city.dart';
import 'package:sikayet_var/models/district.dart';
import 'package:sikayet_var/models/post.dart';
import 'package:sikayet_var/providers/auth_provider.dart';
import 'package:sikayet_var/providers/post_provider.dart';
import 'package:sikayet_var/services/api_service.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostDetailScreen extends ConsumerWidget {
  final Post post;
  
  const PostDetailScreen({Key? key, required this.post}) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final isOwner = currentUser?.id == post.userId;
    final apiService = ApiService();
    
    // Set up timeago in Turkish
    timeago.setLocaleMessages('tr', timeago.TrMessages());
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gönderi Detayı'),
        actions: [
          if (isOwner && post.type == PostType.problem)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'mark_solved') {
                  _markAsSolved(context, ref);
                } else if (value == 'mark_unsolved') {
                  _markAsUnsolved(context, ref);
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'mark_solved',
                  enabled: post.status != PostStatus.solved,
                  child: const Text('Çözüldü olarak işaretle'),
                ),
                PopupMenuItem<String>(
                  value: 'mark_unsolved',
                  enabled: post.status == PostStatus.solved,
                  child: const Text('Çözülmedi olarak işaretle'),
                ),
              ],
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type and status indicator
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
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
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                post.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                post.content,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            
            // Images
            if (post.imageUrls.isNotEmpty)
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: post.imageUrls.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.only(
                        left: index == 0 ? 16 : 8,
                        right: index == post.imageUrls.length - 1 ? 16 : 0,
                      ),
                      width: 200,
                      height: 200,
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
            
            const SizedBox(height: 16),
            
            // Location and category
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Konum',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('$districtName, $cityName'),
                      const SizedBox(height: 12),
                      const Text(
                        'Kategori',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(categoryName),
                    ],
                  );
                },
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStat(context, post.likeCount, 'Beğeni'),
                  _buildStat(context, post.commentCount, 'Yorum'),
                  _buildStat(context, post.highlightCount, 'Öne Çıkarma'),
                ],
              ),
            ),
            
            const Divider(height: 32),
            
            // Comments section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text(
                    'Yorumlar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${post.commentCount}',
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Comment input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Yorum yazın...',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (value) {
                        if (value.isNotEmpty) {
                          // TODO: Implement comment functionality
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Yorum özelliği yakında eklenecek'),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      // TODO: Implement comment functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Yorum özelliği yakında eklenecek'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Sample comments (placeholder)
            _buildCommentPlaceholder(context),
            _buildCommentPlaceholder(context),
            _buildCommentPlaceholder(context),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.thumb_up_outlined),
              onPressed: () {
                ref.read(postsProvider.notifier).likePost(post.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Gönderi beğenildi')),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.star_outline),
              onPressed: () {
                ref.read(postsProvider.notifier).highlightPost(post.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Gönderi öne çıkarıldı')),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.share_outlined),
              onPressed: () {
                // TODO: Implement share functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Paylaşım özelliği yakında eklenecek'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStat(BuildContext context, int count, String label) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
  
  Widget _buildCommentPlaceholder(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 16,
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Kullanıcı Adı',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '2 saat önce',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Bu yorumlar henüz yüklenmedi. Yorum özelliği yakında eklenecek.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  void _markAsSolved(BuildContext context, WidgetRef ref) {
    ref.read(postsProvider.notifier).updatePostStatus(post.id, PostStatus.solved);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Şikayet çözüldü olarak işaretlendi')),
    );
  }
  
  void _markAsUnsolved(BuildContext context, WidgetRef ref) {
    ref.read(postsProvider.notifier).updatePostStatus(post.id, PostStatus.awaitingSolution);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Şikayet beklemede olarak işaretlendi')),
    );
  }
}