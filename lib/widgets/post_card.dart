import 'package:flutter/material.dart';
import 'package:sikayet_var/models/post.dart';
import 'package:sikayet_var/services/api_service.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostCard extends StatefulWidget {
  final Post post;
  final VoidCallback onTap;
  final VoidCallback onLike;
  final VoidCallback onHighlight;
  final bool showFullContent;

  const PostCard({
    Key? key,
    required this.post,
    required this.onTap,
    required this.onLike,
    required this.onHighlight,
    this.showFullContent = false,
  }) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final ApiService _apiService = ApiService();
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with user info and post metadata
            _buildHeader(),
            
            // Post content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Post title
                  Text(
                    widget.post.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Post content
                  GestureDetector(
                    onTap: () {
                      if (!widget.showFullContent) {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      }
                    },
                    child: Text(
                      widget.post.content,
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                      maxLines: _getMaxLines(),
                      overflow: _getTextOverflow(),
                    ),
                  ),
                  
                  // "See more" button if content is truncated
                  if (!widget.showFullContent && !_isExpanded && widget.post.content.length > 100)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            _isExpanded = true;
                          });
                        },
                        child: const Text('Daha Fazla Göster'),
                      ),
                    ),
                ],
              ),
            ),
            
            // Post images (if any)
            if (widget.post.imageUrls.isNotEmpty)
              SizedBox(
                height: 180,
                child: PageView.builder(
                  itemCount: widget.post.imageUrls.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(widget.post.imageUrls[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
            
            // Status indicator for problem posts
            if (widget.post.type == PostType.problem && widget.post.status != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                decoration: BoxDecoration(
                  color: _getStatusColor(widget.post.status!).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getStatusIcon(widget.post.status!),
                      color: _getStatusColor(widget.post.status!),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getStatusText(widget.post.status!),
                      style: TextStyle(
                        color: _getStatusColor(widget.post.status!),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            
            // Actions bar
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Like button
                  _buildActionButton(
                    icon: Icons.thumb_up_outlined,
                    activeIcon: Icons.thumb_up,
                    label: widget.post.likeCount.toString(),
                    isActive: widget.post.likeCount > 0,
                    onPressed: widget.onLike,
                  ),
                  
                  // Comment button
                  _buildActionButton(
                    icon: Icons.comment_outlined,
                    activeIcon: Icons.comment,
                    label: widget.post.commentCount.toString(),
                    isActive: widget.post.commentCount > 0,
                    onPressed: widget.onTap,
                  ),
                  
                  // Highlight button
                  _buildActionButton(
                    icon: Icons.star_outline,
                    activeIcon: Icons.star,
                    label: widget.post.highlightCount.toString(),
                    isActive: widget.post.highlightCount > 0,
                    onPressed: widget.onHighlight,
                  ),
                  
                  // Share button
                  _buildActionButton(
                    icon: Icons.share_outlined,
                    activeIcon: Icons.share,
                    label: 'Paylaş',
                    isActive: false,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Paylaşım özelliği yakında eklenecek')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Post type icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: widget.post.type == PostType.problem
                  ? Colors.red.withOpacity(0.1)
                  : Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              widget.post.type == PostType.problem
                  ? Icons.warning_rounded
                  : Icons.lightbulb_outline,
              color: widget.post.type == PostType.problem
                  ? Colors.red
                  : Colors.green,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          
          // Author info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Author name
                widget.post.isAnonymous
                    ? const Text(
                        'Anonim',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : FutureBuilder<User>(
                        future: _apiService.getUserById(widget.post.userId),
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
                
                // Location and time
                Row(
                  children: [
                    // Time ago
                    Text(
                      timeago.format(widget.post.createdAt, locale: 'tr'),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    
                    // Location
                    if (widget.post.cityId != null) ...[
                      Text(
                        ' • ',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const Icon(
                        Icons.location_on,
                        size: 12,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 2),
                      FutureBuilder<List<dynamic>>(
                        future: Future.wait([
                          _apiService.getCityById(widget.post.cityId!),
                          if (widget.post.districtId != null) 
                            _apiService.getDistrictById(widget.post.districtId!) 
                          else 
                            Future.value(null),
                        ]),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Text(
                              'Yükleniyor...',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            );
                          }
                          
                          final city = snapshot.data![0];
                          final district = snapshot.data!.length > 1 ? snapshot.data![1] : null;
                          
                          final locationText = district != null 
                              ? '${district.name}, ${city.name}' 
                              : city.name;
                          
                          return Text(
                            locationText,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          
          // Category
          if (widget.post.categoryId != null)
            FutureBuilder<Category>(
              future: _apiService.getCategoryById(widget.post.categoryId!),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox.shrink();
                }
                
                final category = snapshot.data!;
                
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    category.name,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[800],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
  
  Widget _buildActionButton({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isActive,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              size: 18,
              color: isActive ? Theme.of(context).colorScheme.primary : Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isActive ? Theme.of(context).colorScheme.primary : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  int? _getMaxLines() {
    if (widget.showFullContent || _isExpanded) {
      return null;
    }
    return 3;
  }
  
  TextOverflow _getTextOverflow() {
    if (widget.showFullContent || _isExpanded) {
      return TextOverflow.visible;
    }
    return TextOverflow.ellipsis;
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
}