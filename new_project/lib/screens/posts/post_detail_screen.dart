import 'package:flutter/material.dart';
import 'package:belediye_iletisim_merkezi/models/post.dart';
import 'package:belediye_iletisim_merkezi/models/comment.dart';
import 'package:belediye_iletisim_merkezi/services/api_service.dart';
import 'package:belediye_iletisim_merkezi/widgets/app_shimmer.dart';
import 'package:belediye_iletisim_merkezi/widgets/post_card.dart';
import 'package:belediye_iletisim_merkezi/widgets/comment_card.dart';

class PostDetailScreen extends StatefulWidget {
  final String id;
  
  const PostDetailScreen({
    Key? key,
    required this.id,
  }) : super(key: key);

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _commentController = TextEditingController();
  bool _isLoading = true;
  bool _isLoadingComments = true;
  bool _isSendingComment = false;
  Post? _post;
  List<Comment> _comments = [];
  
  @override
  void initState() {
    super.initState();
    _loadPost();
    _loadComments();
  }
  
  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
  
  Future<void> _loadPost() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final post = await _apiService.getPostById(widget.id);
      setState(() {
        _post = post;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gönderi yüklenirken bir hata oluştu: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  Future<void> _loadComments() async {
    setState(() {
      _isLoadingComments = true;
    });
    
    try {
      final comments = await _apiService.getCommentsByPostId(widget.id);
      setState(() {
        _comments = comments;
        _isLoadingComments = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Yorumlar yüklenirken bir hata oluştu: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        setState(() {
          _isLoadingComments = false;
        });
      }
    }
  }
  
  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty) return;
    
    setState(() {
      _isSendingComment = true;
    });
    
    try {
      final comment = await _apiService.addComment(
        postId: widget.id,
        content: _commentController.text.trim(),
      );
      
      setState(() {
        _comments.insert(0, comment);
        _isSendingComment = false;
      });
      
      _commentController.clear();
      
      if (_post != null) {
        setState(() {
          _post = _post!.copyWith(
            commentCount: _post!.commentCount + 1,
          );
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Yorum gönderilirken bir hata oluştu: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        setState(() {
          _isSendingComment = false;
        });
      }
    }
  }
  
  Future<void> _submitSatisfactionRating(int rating) async {
    try {
      bool success = await _apiService.submitSatisfaction(
        postId: widget.id, 
        rating: rating
      );
      
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Memnuniyet dereceniz gönderilemedi. Lütfen daha sonra tekrar deneyin.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      
      if (_post != null) {
        setState(() {
          _post = _post!.copyWith(
            satisfactionRating: rating,
          );
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Memnuniyet dereceniz kaydedildi, teşekkürler!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Memnuniyet derecesi gönderilirken bir hata oluştu: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLoading ? 'Gönderi Detayı' : _post?.title ?? 'Gönderi Detayı'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Paylaşma işlemi
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : _post == null
                    ? _buildErrorState()
                    : _buildPostDetails(),
          ),
          _buildCommentBox(),
        ],
      ),
    );
  }
  
  Widget _buildLoadingState() {
    return const Center(
      child: AppShimmer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
            ),
            SizedBox(height: 16),
            SizedBox(height: 20, width: 150),
            SizedBox(height: 8),
            SizedBox(height: 16, width: 250),
            SizedBox(height: 24),
            SizedBox(height: 200, width: double.infinity),
          ],
        ),
      ),
    );
  }
  
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          const Text(
            'Gönderi yüklenemedi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Lütfen internet bağlantınızı kontrol edin ve tekrar deneyin.',
            style: TextStyle(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadPost,
            icon: const Icon(Icons.refresh),
            label: const Text('Tekrar Dene'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPostDetails() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Gönderi kartı
          PostCard(
            post: _post!,
            isDetailView: true,
            onTap: () {}, // Zaten detay görünümündeyiz, tıklama gereksiz
            onLike: () async {
              try {
                await _apiService.likePost(_post!.id);
                setState(() {
                  _post = _post!.copyWith(
                    likes: _post!.likes + 1,
                  );
                });
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Beğeni gönderilirken bir hata oluştu: $e'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              }
            },
            onComment: () {
              // Yorum giriş alanına odaklan
              FocusScope.of(context).requestFocus(FocusNode());
            },
            onHighlight: () {
              // Öne çıkarma işlemi
            },
            onShare: () {
              // Paylaşım işlemi
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Paylaşım özelliği yakında eklenecek')),
              );
            },
          ),
          
          // Çözüm memnuniyeti (sadece çözülen gönderiler için)
          if (_post!.status == PostStatus.solved && _post!.satisfactionRating == 0)
            _buildSatisfactionRatingWidget(),
          
          const Divider(),
          
          // Yorumlar başlığı
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Yorumlar (${_post!.commentCount})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_isLoadingComments)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
              ],
            ),
          ),
          
          // Yorumlar listesi
          _isLoadingComments
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: AppShimmer(
                    child: Column(
                      children: [
                        SizedBox(height: 60, width: double.infinity),
                        SizedBox(height: 8),
                        SizedBox(height: 60, width: double.infinity),
                        SizedBox(height: 8),
                        SizedBox(height: 60, width: double.infinity),
                      ],
                    ),
                  ),
                )
              : _comments.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: Text('Henüz yorum yapılmamış. İlk yorumu siz yapın!'),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _comments.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final comment = _comments[index];
                        return CommentCard(comment: comment);
                      },
                    ),
        ],
      ),
    );
  }
  
  Widget _buildSatisfactionRatingWidget() {
    return Card(
      margin: const EdgeInsets.all(16),
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bu çözümden memnun kaldınız mı?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Çözüm kalitesini değerlendirmek için puanınızı seçin',
              style: TextStyle(
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                5,
                (index) => InkWell(
                  onTap: () => _submitSatisfactionRating(index + 1),
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.blue.shade200,
                      ),
                    ),
                    child: Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCommentBox() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
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
                hintText: 'Yorum yaz...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(24)),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _submitComment(),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _isSendingComment ? null : _submitComment,
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(12),
            ),
            child: _isSendingComment
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}