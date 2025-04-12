import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sikayet_var/models/comment.dart';
import 'package:sikayet_var/models/post.dart';
import 'package:sikayet_var/models/user.dart';
import 'package:sikayet_var/providers/auth_provider.dart';
import 'package:sikayet_var/providers/current_user_provider.dart';
import 'package:sikayet_var/services/api_service.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:sikayet_var/providers/user_provider.dart';
import 'package:sikayet_var/providers/api_service_provider.dart';

class PostDetailScreen extends ConsumerStatefulWidget {
  final Post post;
  
  const PostDetailScreen({
    Key? key,
    required this.post,
  }) : super(key: key);

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _commentController = TextEditingController();
  
  bool _isLoadingComments = false;
  bool _isSubmittingComment = false;
  bool _isAnonymousComment = false;
  
  List<Comment> _comments = [];
  
  @override
  void initState() {
    super.initState();
    _loadComments();
  }
  
  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
  
  Future<void> _loadComments() async {
    setState(() {
      _isLoadingComments = true;
    });
    
    try {
      final comments = await _apiService.getCommentsByPostId(widget.post.id);
      
      setState(() {
        _comments = comments;
      });
    } catch (e) {
      _showErrorSnackBar('Yorumlar yüklenirken bir hata oluştu: $e');
    } finally {
      setState(() {
        _isLoadingComments = false;
      });
    }
  }
  
  Future<void> _submitComment() async {
    final content = _commentController.text.trim();
    
    if (content.isEmpty) {
      return;
    }
    
    setState(() {
      _isSubmittingComment = true;
    });
    
    try {
      final comment = await _apiService.addComment(
        widget.post.id,
        content,
        isAnonymous: _isAnonymousComment,
      );
      
      setState(() {
        _comments = [comment, ..._comments];
        _commentController.clear();
        _isAnonymousComment = false;
      });
      
      FocusScope.of(context).unfocus();
    } catch (e) {
      _showErrorSnackBar('Yorum gönderilirken bir hata oluştu: $e');
    } finally {
      setState(() {
        _isSubmittingComment = false;
      });
    }
  }
  
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider).value;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gönderi Detayı'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Paylaşım özelliği yakında eklenecek')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Post content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Post type and status
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: widget.post.type == PostType.problem
                              ? Colors.red.withOpacity(0.1)
                              : Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              widget.post.type == PostType.problem
                                  ? Icons.warning_rounded
                                  : Icons.lightbulb_outline,
                              color: widget.post.type == PostType.problem
                                  ? Colors.red
                                  : Colors.green,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.post.type == PostType.problem
                                  ? 'Şikayet'
                                  : 'Öneri',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: widget.post.type == PostType.problem
                                    ? Colors.red
                                    : Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      
                      if (widget.post.status != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(widget.post.status!).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getStatusIcon(widget.post.status!),
                                color: _getStatusColor(widget.post.status!),
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _getStatusText(widget.post.status!),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: _getStatusColor(widget.post.status!),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Post title
                  Text(
                    widget.post.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Post author and location
                  Row(
                    children: [
                      // Author
                      FutureBuilder<User>(
                        future: _apiService.getUserById(widget.post.userId),
                        builder: (context, snapshot) {
                          final String authorName = widget.post.isAnonymous
                              ? 'Anonim'
                              : snapshot.hasData
                                  ? snapshot.data!.name
                                  : 'Yükleniyor...';
                          
                          return Text(
                            authorName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      
                      // Created time
                      Text(
                        timeago.format(widget.post.createdAt, locale: 'tr'),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                      
                      if (widget.post.cityId != null) ...[
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 2),
                        
                        // Location
                        FutureBuilder(
                          future: Future.wait([
                            _apiService.getCityById(widget.post.cityId!),
                            if (widget.post.districtId != null)
                              _apiService.getDistrictById(widget.post.districtId!)
                            else
                              Future.value(null),
                          ]),
                          builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                            if (!snapshot.hasData) {
                              return Text(
                                'Yükleniyor...',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              );
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
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Post content
                  Text(
                    widget.post.content,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Post images
                  if (widget.post.imageUrls != null && widget.post.imageUrls!.isNotEmpty) ...[
                    SizedBox(
                      height: 200,
                      child: PageView.builder(
                        itemCount: widget.post.imageUrls!.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              // TODO: Show full screen image
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: NetworkImage(widget.post.imageUrls![index]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Like button
                      _buildActionButton(
                        icon: Icons.thumb_up_outlined,
                        activeIcon: Icons.thumb_up,
                        label: '${widget.post.likeCount}',
                        isActive: widget.post.likeCount > 0,
                        onPressed: () async {
                          await _apiService.likePost(widget.post.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Gönderi beğenildi')),
                          );
                        },
                      ),
                      
                      // Comments count
                      _buildActionButton(
                        icon: Icons.comment_outlined,
                        activeIcon: Icons.comment,
                        label: '${widget.post.commentCount}',
                        isActive: widget.post.commentCount > 0,
                        onPressed: () {
                          // Scroll to comments
                        },
                      ),
                      
                      // Highlight button
                      _buildActionButton(
                        icon: Icons.star_outline,
                        activeIcon: Icons.star,
                        label: '${widget.post.highlightCount}',
                        isActive: widget.post.highlightCount > 0,
                        onPressed: () async {
                          await _apiService.highlightPost(widget.post.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Gönderi öne çıkarıldı')),
                          );
                        },
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
                  
                  const Divider(height: 32),
                  
                  // Comments section
                  const Text(
                    'Yorumlar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Comments
                  if (_isLoadingComments)
                    const Center(child: CircularProgressIndicator())
                  else if (_comments.isEmpty)
                    const Center(
                      child: Text(
                        'Henüz yorum yok. İlk yorumu sen yapabilirsin!',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _comments.length,
                      separatorBuilder: (context, index) => const Divider(height: 24),
                      itemBuilder: (context, index) {
                        final comment = _comments[index];
                        return _buildCommentWidget(comment);
                      },
                    ),
                ],
              ),
            ),
          ),
          
          // Comment input
          if (currentUser != null)
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Anonymous switch
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isAnonymousComment = !_isAnonymousComment;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        _isAnonymousComment
                            ? Icons.visibility_off
                            : Icons.visibility_off_outlined,
                        color: _isAnonymousComment
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey,
                      ),
                    ),
                  ),
                  
                  // Comment input
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                        hintText: 'Yorumunuzu yazın...',
                        border: InputBorder.none,
                      ),
                      minLines: 1,
                      maxLines: 5,
                      enabled: !_isSubmittingComment,
                    ),
                  ),
                  
                  // Send button
                  IconButton(
                    icon: _isSubmittingComment
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(),
                          )
                        : const Icon(Icons.send),
                    onPressed: _isSubmittingComment ? null : _submitComment,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildCommentWidget(Comment comment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Comment header
        Row(
          children: [
            // Author
            FutureBuilder<User>(
              future: _apiService.getUserById(comment.userId),
              builder: (context, snapshot) {
                final String authorName = comment.isAnonymous
                    ? 'Anonim'
                    : snapshot.hasData
                        ? snapshot.data!.name
                        : 'Yükleniyor...';
                
                return Text(
                  authorName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
            const SizedBox(width: 8),
            
            // Created time
            Text(
              timeago.format(comment.createdAt, locale: 'tr'),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        
        // Comment content
        Text(comment.content),
        const SizedBox(height: 8),
        
        // Comment actions
        Row(
          children: [
            // Like button
            InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Yorum beğenme özelliği yakında eklenecek')),
                );
              },
              child: Row(
                children: [
                  Icon(
                    comment.likeCount > 0
                        ? Icons.thumb_up
                        : Icons.thumb_up_outlined,
                    size: 16,
                    color: comment.likeCount > 0
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    comment.likeCount.toString(),
                    style: TextStyle(
                      fontSize: 12,
                      color: comment.likeCount > 0
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            
            // Reply button
            InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Yanıtlama özelliği yakında eklenecek')),
                );
              },
              child: Row(
                children: [
                  Icon(
                    Icons.reply,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Yanıtla',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        
        // Replies
        if (comment.replies != null && comment.replies!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            margin: const EdgeInsets.only(left: 16),
            padding: const EdgeInsets.only(left: 8),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: Colors.grey[300]!,
                  width: 2,
                ),
              ),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: comment.replies!.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final reply = comment.replies![index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Reply header
                    Row(
                      children: [
                        // Author
                        FutureBuilder<User>(
                          future: _apiService.getUserById(reply.userId),
                          builder: (context, snapshot) {
                            final String authorName = reply.isAnonymous
                                ? 'Anonim'
                                : snapshot.hasData
                                    ? snapshot.data!.name
                                    : 'Yükleniyor...';
                            
                            return Text(
                              authorName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        
                        // Created time
                        Text(
                          timeago.format(reply.createdAt, locale: 'tr'),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    
                    // Reply content
                    Text(
                      reply.content,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ],
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