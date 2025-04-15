import 'package:flutter/material.dart';
import 'package:belediye_iletisim_merkezi/models/post.dart';
import 'package:belediye_iletisim_merkezi/models/user.dart';
import 'package:belediye_iletisim_merkezi/models/category.dart';
import 'package:belediye_iletisim_merkezi/services/api_service.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cached_network_image/cached_network_image.dart';

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
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(color: Color(0xFFEEEEEE), width: 0.5),
      ),
      child: InkWell(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.all(0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Twitter tarzı header
              _buildTwitterHeader(),
              
              // Post içeriği
              Padding(
                padding: const EdgeInsets.fromLTRB(72, 0, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Post başlığı
                    Text(
                      widget.post.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    
                    // Post içeriği
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
                    
                    // "Daha fazla göster" butonu
                    if (!widget.showFullContent && !_isExpanded && widget.post.content.length > 100)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              _isExpanded = true;
                            });
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            minimumSize: Size.zero,
                          ),
                          child: Text(
                            'Daha fazla göster',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                    
                    // Post görselleri
                    if (widget.post.imageUrls != null && widget.post.imageUrls!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: _buildTwitterImageGrid(widget.post.imageUrls!),
                      ),
                    
                    // Durum göstergesi (Şikayet durumu)
                    if (widget.post.type == PostType.problem && widget.post.status != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: GestureDetector(
                          onTap: () {
                            // Filtreleme özelliği
                            Navigator.pushNamed(
                              context,
                              '/filtered_posts',
                              arguments: {
                                'filterType': 'status',
                                'statusValue': widget.post.status,
                                'statusText': _getStatusText(widget.post.status!),
                              },
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(widget.post.status!).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _getStatusColor(widget.post.status!).withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getStatusIcon(widget.post.status!),
                                  color: _getStatusColor(widget.post.status!),
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _getStatusText(widget.post.status!),
                                  style: TextStyle(
                                    color: _getStatusColor(widget.post.status!),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              
              // Twitter tarzı aksiyon butonları
              Padding(
                padding: const EdgeInsets.fromLTRB(72, 0, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Yorum butonu
                    _buildTwitterActionButton(
                      icon: Icons.chat_bubble_outline,
                      activeIcon: Icons.chat_bubble,
                      count: widget.post.commentCount,
                      color: Colors.blue,
                      onTap: widget.onTap,
                    ),
                    
                    // Retweet butonu
                    _buildTwitterActionButton(
                      icon: Icons.repeat,
                      activeIcon: Icons.repeat,
                      count: widget.post.highlightCount,
                      color: Colors.green,
                      onTap: widget.onHighlight,
                    ),
                    
                    // Like butonu
                    _buildTwitterActionButton(
                      icon: Icons.favorite_border,
                      activeIcon: Icons.favorite,
                      count: widget.post.likeCount,
                      color: Colors.red,
                      onTap: widget.onLike,
                    ),
                    
                    // Paylaş butonu
                    _buildTwitterActionButton(
                      icon: Icons.share,
                      activeIcon: Icons.share,
                      count: 0,
                      color: Colors.blue,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Paylaşım özelliği yakında eklenecek')),
                        );
                      },
                      showCount: false,
                    ),
                  ],
                ),
              ),
            ],
          ),
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
          GestureDetector(
            onTap: () {
              // Post tipine göre filtreleme ekranına git
              Navigator.pushNamed(
                context,
                '/filtered_posts',
                arguments: {
                  'filterType': 'type',
                  'typeValue': widget.post.type,
                  'typeText': widget.post.type == PostType.problem ? 'Şikayet' : 'Öneri',
                },
              );
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: widget.post.type == PostType.problem
                    ? Colors.red.withOpacity(0.1)
                    : Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.post.type == PostType.problem
                      ? Colors.red.withOpacity(0.3)
                      : Colors.green.withOpacity(0.3),
                  width: 1,
                ),
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
                          
                          return GestureDetector(
                            onTap: () {
                              // Şehir profil sayfasına yönlendirme
                              Navigator.pushNamed(
                                context,
                                '/city_profile',
                                arguments: int.parse(city.id),
                              );
                            },
                            child: Text(
                              locationText,
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.primary,
                                decoration: TextDecoration.underline,
                              ),
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
            FutureBuilder<Category?>(
              future: _apiService.getCategoryById(widget.post.categoryId!),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox.shrink();
                }
                
                final category = snapshot.data!;
                
                return GestureDetector(
                  onTap: () {
                    // Kategori filtresi için
                    Navigator.pushNamed(
                      context,
                      '/filtered_posts',
                      arguments: {
                        'filterType': 'category',
                        'categoryId': category.id,
                        'categoryName': category.name,
                      },
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey[400]!,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      category.name,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.primary,
                      ),
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