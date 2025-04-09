import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sikayet_var/models/post.dart';
import 'package:sikayet_var/models/user.dart';
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
    final apiService = ApiService();
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post header
            _buildPostHeader(context, apiService, currentUser),
            
            // Post content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Post title
                  Text(
                    post.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Post content
                  Text(
                    post.content,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
            
            // Post images (if any)
            if (post.imageUrls.isNotEmpty)
              SizedBox(
                height: 200,
                child: _buildImageGallery(),
              ),
            
            // Post status
            if (post.type == PostType.problem && post.status != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: _getStatusColor(post.status!).withOpacity(0.1),
                child: Row(
                  children: [
                    Icon(
                      _getStatusIcon(post.status!),
                      size: 16,
                      color: _getStatusColor(post.status!),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getStatusText(post.status!),
                      style: TextStyle(
                        fontSize: 14,
                        color: _getStatusColor(post.status!),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            
            // Post metadata
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Category and time info
                  Expanded(
                    child: FutureBuilder(
                      future: apiService.getCategoryById(post.categoryId),
                      builder: (context, snapshot) {
                        final categoryName = snapshot.hasData
                            ? snapshot.data!.name
                            : 'Yükleniyor...';
                        
                        return Row(
                          children: [
                            const Icon(Icons.category, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              categoryName,
                              style: const TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.access_time, size: 16),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                timeago.format(post.createdAt, locale: 'tr'),
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  
                  // Post actions
                  Row(
                    children: [
                      // Like button
                      InkWell(
                        onTap: onLike,
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            children: [
                              Icon(
                                Icons.thumb_up,
                                size: 16,
                                color: post.likeCount > 0
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                post.likeCount.toString(),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: post.likeCount > 0
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Comment button
                      InkWell(
                        onTap: onTap, // Navigate to detail screen for comments
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            children: [
                              Icon(
                                Icons.comment,
                                size: 16,
                                color: post.commentCount > 0
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                post.commentCount.toString(),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: post.commentCount > 0
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Highlight button
                      InkWell(
                        onTap: onHighlight,
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            children: [
                              Icon(
                                Icons.highlight,
                                size: 16,
                                color: post.highlightCount > 0
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                post.highlightCount.toString(),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: post.highlightCount > 0
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPostHeader(BuildContext context, ApiService apiService, User? currentUser) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Post type icon and color
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: post.type == PostType.problem
                  ? Colors.red.withOpacity(0.1)
                  : Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              post.type == PostType.problem
                  ? Icons.warning_rounded
                  : Icons.lightbulb_outline,
              color: post.type == PostType.problem ? Colors.red : Colors.green,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          
          // Post author info
          Expanded(
            child: post.isAnonymous
                ? const Text(
                    'Anonim',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : FutureBuilder(
                    future: apiService.getUserById(post.userId),
                    builder: (context, snapshot) {
                      final userName = snapshot.hasData
                          ? snapshot.data!.name
                          : 'Yükleniyor...';
                      
                      return Text(
                        userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
          ),
          
          // Location info
          if (post.cityId != null)
            FutureBuilder(
              future: Future.wait([
                apiService.getCityById(post.cityId!),
                if (post.districtId != null)
                  apiService.getDistrictById(post.districtId!)
                else
                  Future.value(null),
              ]),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox.shrink();
                }
                
                final city = snapshot.data![0];
                final district = snapshot.data!.length > 1 ? snapshot.data![1] : null;
                
                final locationText = district != null
                    ? '${district.name}, ${city.name}'
                    : city.name;
                
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      locationText,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
  
  Widget _buildImageGallery() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: post.imageUrls.length,
      itemBuilder: (context, index) {
        return Container(
          width: 200,
          margin: const EdgeInsets.only(left: 16, right: 8, bottom: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: NetworkImage(post.imageUrls[index]),
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }
  
  String _getStatusText(PostStatus status) {
    switch (status) {
      case PostStatus.awaitingSolution:
        return 'Çözüm Bekliyor';
      case PostStatus.inProgress:
        return 'İşleme Alındı';
      case PostStatus.solved:
        return 'Çözüldü';
      case PostStatus.rejected:
        return 'Reddedildi';
    }
  }
  
  IconData _getStatusIcon(PostStatus status) {
    switch (status) {
      case PostStatus.awaitingSolution:
        return Icons.hourglass_empty;
      case PostStatus.inProgress:
        return Icons.pending_actions;
      case PostStatus.solved:
        return Icons.check_circle;
      case PostStatus.rejected:
        return Icons.cancel;
    }
  }
  
  Color _getStatusColor(PostStatus status) {
    switch (status) {
      case PostStatus.awaitingSolution:
        return Colors.orange;
      case PostStatus.inProgress:
        return Colors.blue;
      case PostStatus.solved:
        return Colors.green;
      case PostStatus.rejected:
        return Colors.red;
    }
  }
}