import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sikayet_var/models/post.dart';
import 'package:sikayet_var/providers/auth_provider.dart';
import 'package:sikayet_var/providers/post_provider.dart';
import 'package:sikayet_var/services/api_service.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostDetailScreen extends ConsumerStatefulWidget {
  final Post post;
  
  const PostDetailScreen({Key? key, required this.post}) : super(key: key);

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  final _commentController = TextEditingController();
  bool _isAddingComment = false;
  bool _showFullContent = false;
  
  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final apiService = ApiService();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gönderi Detayı'),
        actions: [
          if (currentUser != null && (currentUser.id == widget.post.userId || currentUser.isAdmin))
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'update_status') {
                  _showUpdateStatusDialog();
                } else if (value == 'delete') {
                  _showDeleteConfirmationDialog();
                }
              },
              itemBuilder: (context) => [
                if (widget.post.type == PostType.problem)
                  const PopupMenuItem(
                    value: 'update_status',
                    child: Text('Durum Güncelle'),
                  ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Sil'),
                ),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          // Post details
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Post header
                  _buildPostHeader(apiService),
                  
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
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Post content
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _showFullContent = !_showFullContent;
                            });
                          },
                          child: Text(
                            widget.post.content,
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                            maxLines: _showFullContent ? null : 5,
                            overflow: _showFullContent ? TextOverflow.visible : TextOverflow.ellipsis,
                          ),
                        ),
                        
                        if (widget.post.content.length > 200 && !_showFullContent)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  _showFullContent = true;
                                });
                              },
                              child: const Text('Daha Fazla Göster'),
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  // Post images
                  if (widget.post.imageUrls.isNotEmpty)
                    Container(
                      height: 200,
                      margin: const EdgeInsets.symmetric(vertical: 16),
                      child: PageView.builder(
                        itemCount: widget.post.imageUrls.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
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
                  
                  // Post status
                  if (widget.post.type == PostType.problem && widget.post.status != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      color: _getStatusColor(widget.post.status!).withOpacity(0.1),
                      child: Row(
                        children: [
                          Icon(
                            _getStatusIcon(widget.post.status!),
                            color: _getStatusColor(widget.post.status!),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _getStatusText(widget.post.status!),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _getStatusColor(widget.post.status!),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // Post actions
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // Like button
                        _buildActionButton(
                          icon: Icons.thumb_up,
                          label: widget.post.likeCount.toString(),
                          active: widget.post.likeCount > 0,
                          onPressed: () {
                            ref.read(postsProvider.notifier).likePost(widget.post.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Gönderi beğenildi')),
                            );
                          },
                        ),
                        
                        // Comment button
                        _buildActionButton(
                          icon: Icons.comment,
                          label: widget.post.commentCount.toString(),
                          active: widget.post.commentCount > 0,
                          onPressed: () {
                            // Scroll to comments
                          },
                        ),
                        
                        // Highlight button
                        _buildActionButton(
                          icon: Icons.highlight,
                          label: widget.post.highlightCount.toString(),
                          active: widget.post.highlightCount > 0,
                          onPressed: () {
                            ref.read(postsProvider.notifier).highlightPost(widget.post.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Gönderi öne çıkarıldı')),
                            );
                          },
                        ),
                        
                        // Share button
                        _buildActionButton(
                          icon: Icons.share,
                          label: 'Paylaş',
                          active: false,
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Paylaşım özelliği yakında eklenecek')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  const Divider(thickness: 1),
                  
                  // Comments section
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Yorumlar',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        FutureBuilder(
                          future: apiService.getCommentsByPostId(widget.post.id),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            
                            if (snapshot.hasError) {
                              return Center(
                                child: Text('Hata: ${snapshot.error}'),
                              );
                            }
                            
                            final comments = snapshot.data ?? [];
                            
                            if (comments.isEmpty) {
                              return const Center(
                                child: Text('Henüz yorum yapılmamış'),
                              );
                            }
                            
                            return ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: comments.length,
                              separatorBuilder: (context, index) => const Divider(),
                              itemBuilder: (context, index) {
                                final comment = comments[index];
                                
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                    child: const Icon(Icons.person),
                                  ),
                                  title: FutureBuilder(
                                    future: apiService.getUserById(comment.userId),
                                    builder: (context, snapshot) {
                                      final userName = snapshot.hasData
                                          ? snapshot.data!.name
                                          : 'Kullanıcı';
                                      
                                      return Row(
                                        children: [
                                          Text(
                                            userName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            timeago.format(comment.createdAt, locale: 'tr'),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(comment.content),
                                  ),
                                  trailing: comment.likeCount > 0
                                      ? Chip(
                                          label: Text(
                                            comment.likeCount.toString(),
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                          avatar: const Icon(
                                            Icons.thumb_up,
                                            size: 12,
                                          ),
                                          visualDensity: VisualDensity.compact,
                                        )
                                      : null,
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Add comment section
          if (currentUser != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                        hintText: 'Yorumunuzu yazın...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.newline,
                    ),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    onPressed: _isAddingComment ? null : _addComment,
                    icon: _isAddingComment
                        ? const CircularProgressIndicator()
                        : const Icon(Icons.send),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildPostHeader(ApiService apiService) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
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
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          
          // Post author and metadata
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Author
                widget.post.isAnonymous
                    ? const Text(
                        'Anonim',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      )
                    : FutureBuilder(
                        future: apiService.getUserById(widget.post.userId),
                        builder: (context, snapshot) {
                          final userName = snapshot.hasData
                              ? snapshot.data!.name
                              : 'Yükleniyor...';
                          
                          return Text(
                            userName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          );
                        },
                      ),
                const SizedBox(height: 4),
                
                // Time and location
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      timeago.format(widget.post.createdAt, locale: 'tr'),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    if (widget.post.cityId != null) ...[
                      const SizedBox(width: 16),
                      const Icon(Icons.location_on, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      FutureBuilder(
                        future: Future.wait([
                          apiService.getCityById(widget.post.cityId!),
                          if (widget.post.districtId != null)
                            apiService.getDistrictById(widget.post.districtId!)
                          else
                            Future.value(null),
                        ]),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Text('Konum yükleniyor...');
                          }
                          
                          final city = snapshot.data![0];
                          final district = snapshot.data!.length > 1
                              ? snapshot.data![1]
                              : null;
                          
                          final locationText = district != null
                              ? '${district.name}, ${city.name}'
                              : city.name;
                          
                          return Text(
                            locationText,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
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
        ],
      ),
    );
  }
  
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required bool active,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);
    final color = active ? theme.colorScheme.primary : Colors.grey;
    
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _addComment() async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yorum yapabilmek için giriş yapmalısınız')),
      );
      return;
    }
    
    final comment = _commentController.text.trim();
    if (comment.isEmpty) {
      return;
    }
    
    setState(() {
      _isAddingComment = true;
    });
    
    try {
      final apiService = ApiService();
      await apiService.addComment(widget.post.id, comment);
      
      if (mounted) {
        _commentController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Yorum başarıyla eklendi')),
        );
        
        // Refresh comments
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAddingComment = false;
        });
      }
    }
  }
  
  void _showUpdateStatusDialog() {
    final currentStatus = widget.post.status ?? PostStatus.awaitingSolution;
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Durum Güncelle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final status in PostStatus.values)
                RadioListTile<PostStatus>(
                  title: Text(_getStatusText(status)),
                  value: status,
                  groupValue: currentStatus,
                  onChanged: (value) {
                    Navigator.of(context).pop(value);
                  },
                ),
            ],
          ),
        );
      },
    ).then((newStatus) {
      if (newStatus != null && newStatus != currentStatus) {
        _updatePostStatus(newStatus);
      }
    });
  }
  
  Future<void> _updatePostStatus(PostStatus newStatus) async {
    try {
      await ref.read(postsProvider.notifier).updatePostStatus(widget.post.id, newStatus);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gönderi durumu güncellendi')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: ${e.toString()}')),
        );
      }
    }
  }
  
  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Gönderiyi Sil'),
          content: const Text('Bu gönderiyi silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Sil'),
            ),
          ],
        );
      },
    ).then((confirmed) {
      if (confirmed == true) {
        _deletePost();
      }
    });
  }
  
  Future<void> _deletePost() async {
    // TODO: Implement delete post functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gönderi silme özelliği yakında eklenecek')),
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