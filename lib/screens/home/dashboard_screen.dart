import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:sikayet_var/models/post.dart';
import 'package:sikayet_var/providers/auth_provider.dart';
import 'package:sikayet_var/providers/current_user_provider.dart';
import 'package:sikayet_var/providers/user_provider.dart';
import 'package:sikayet_var/services/api_service.dart';
import 'package:sikayet_var/widgets/post_card.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> with SingleTickerProviderStateMixin {
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<TabController>('_tabController', _tabController));
  }
  
  @override
  void activate() {
    super.activate();
  }
  late TabController _tabController;
  final ApiService _apiService = ApiService();
  
  // Lists for different tabs
  List<Post> _myPosts = [];
  List<Post> _inProgress = [];
  List<Post> _solved = [];
  
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadData() async {
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Get user's posts
      final posts = await _apiService.getPosts(
        userId: currentUser.id,
        type: PostType.problem,
      );
      
      // Filter by status
      setState(() {
        _myPosts = posts;
        _inProgress = posts.where((post) => 
          post.status == PostStatus.inProgress || 
          post.status == PostStatus.awaitingSolution
        ).toList();
        _solved = posts.where((post) => 
          post.status == PostStatus.solved
        ).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veriler yüklenirken bir hata oluştu: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panelim'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Tümü'),
            Tab(text: 'İşlemde'),
            Tab(text: 'Çözülenler'),
          ],
        ),
      ),
      body: currentUser.when(
        data: (user) {
          if (user == null) {
            return const Center(
              child: Text('Panelimi görebilmek için giriş yapmalısınız.'),
            );
          }
          
          if (_isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          return TabBarView(
            controller: _tabController,
            children: [
              _buildPostList(_myPosts, 'Henüz şikayetiniz bulunmuyor'),
              _buildPostList(_inProgress, 'İşlemde olan şikayetiniz bulunmuyor'),
              _buildPostList(_solved, 'Çözülmüş şikayetiniz bulunmuyor'),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text('Bir hata oluştu: $error'),
        ),
      ),
    );
  }
  
  Widget _buildPostList(List<Post> posts, String emptyMessage) {
    if (posts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inbox,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                emptyMessage,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return PostCard(
            post: post,
            onTap: () {
              Navigator.pushNamed(
                context,
                '/post_detail',
                arguments: post,
              );
            },
            onLike: () async {
              await _apiService.likePost(post.id);
              _loadData(); // Refresh data
            },
            onHighlight: () async {
              await _apiService.highlightPost(post.id);
              _loadData(); // Refresh data
            },
          );
        },
      ),
    );
  }
}