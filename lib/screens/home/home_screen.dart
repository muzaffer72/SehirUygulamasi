import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sikayet_var/models/post.dart';
import 'package:sikayet_var/providers/auth_provider.dart';
import 'package:sikayet_var/providers/post_provider.dart';
import 'package:sikayet_var/screens/home/profile_screen.dart';
import 'package:sikayet_var/screens/posts/create_post_screen.dart';
import 'package:sikayet_var/screens/posts/post_detail_screen.dart';
import 'package:sikayet_var/widgets/filter_bar.dart';
import 'package:sikayet_var/widgets/post_card.dart';
import 'package:sikayet_var/widgets/survey_slider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  List<Post> _searchResults = [];
  bool _isSearching = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
  }
  
  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }
  
  void _handleTabChange() {
    // Clear search when changing tabs
    if (_searchController.text.isNotEmpty) {
      setState(() {
        _searchController.clear();
        _searchResults = [];
        _isSearching = false;
      });
    }
  }
  
  void _searchPosts(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }
    
    final posts = ref.read(postsProvider);
    final results = posts.where((post) {
      final titleMatches = post.title.toLowerCase().contains(query.toLowerCase());
      final contentMatches = post.content.toLowerCase().contains(query.toLowerCase());
      return titleMatches || contentMatches;
    }).toList();
    
    setState(() {
      _searchResults = results;
      _isSearching = true;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final posts = ref.watch(postsProvider);
    final isLoading = ref.watch(postsLoadingProvider);
    final filter = ref.watch(postFilterProvider);
    
    // Create different post lists based on type
    final complaintPosts = posts.where((post) => post.type == PostType.problem).toList();
    final suggestionPosts = posts.where((post) => post.type == PostType.general).toList();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('ŞikayetVar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: _PostSearchDelegate(
                  posts: posts,
                  onTap: (post) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PostDetailScreen(post: post),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.home),
              text: 'Ana Sayfa',
            ),
            Tab(
              icon: Icon(Icons.warning_rounded),
              text: 'Şikayetler',
            ),
            Tab(
              icon: Icon(Icons.lightbulb_outline),
              text: 'Öneriler',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // All posts tab
          _buildPostsTab(context, posts, isLoading, filter, showSurveys: true),
          
          // Complaints tab
          _buildPostsTab(context, complaintPosts, isLoading, filter),
          
          // Suggestions tab
          _buildPostsTab(context, suggestionPosts, isLoading, filter),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const CreatePostScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildPostsTab(BuildContext context, List<Post> posts, bool isLoading, Map<String, dynamic> filter, {bool showSurveys = false}) {
    // Display "isFiltered" message if filters are applied
    final bool hasFilters = filter['isFiltered'] == true;
    
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(postsProvider.notifier).loadPosts();
      },
      child: Column(
        children: [
          // Survey slider (optional)
          if (showSurveys) const SurveySlider(),
          
          // Filter bar
          FilterBar(
            onFilter: (cityId, districtId, categoryId) {
              ref.read(postsProvider.notifier).filterPosts(
                cityId: cityId,
                districtId: districtId,
                categoryId: categoryId,
              );
            },
            onClear: () {
              ref.read(postsProvider.notifier).clearFilters();
            },
          ),
          
          // Filter indicator
          if (hasFilters)
            Container(
              color: Colors.blue.shade50,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.filter_list, size: 18),
                  const SizedBox(width: 8),
                  const Text('Filtreler uygulandı'),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      ref.read(postsProvider.notifier).clearFilters();
                    },
                    child: const Text('Temizle'),
                  ),
                ],
              ),
            ),
          
          // Post list
          Expanded(
            child: _isSearching
                ? _buildPostList(_searchResults, isLoading)
                : _buildPostList(posts, isLoading),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPostList(List<Post> posts, bool isLoading) {
    if (isLoading && posts.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (posts.isEmpty) {
      return const Center(
        child: Text('Gönderi bulunamadı'),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80), // Space for FAB
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return PostCard(
          post: post,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PostDetailScreen(post: post),
              ),
            );
          },
          onLike: () {
            ref.read(postsProvider.notifier).likePost(post.id);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Gönderi beğenildi')),
            );
          },
          onHighlight: () {
            ref.read(postsProvider.notifier).highlightPost(post.id);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Gönderi öne çıkarıldı')),
            );
          },
        );
      },
    );
  }
}

// Search delegate for posts
class _PostSearchDelegate extends SearchDelegate<Post?> {
  final List<Post> posts;
  final Function(Post) onTap;
  
  _PostSearchDelegate({required this.posts, required this.onTap});
  
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }
  
  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }
  
  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }
  
  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }
  
  Widget _buildSearchResults(BuildContext context) {
    if (query.isEmpty) {
      return const Center(
        child: Text('Arama yapmak için yazın'),
      );
    }
    
    final searchQuery = query.toLowerCase();
    final results = posts.where((post) {
      final titleMatches = post.title.toLowerCase().contains(searchQuery);
      final contentMatches = post.content.toLowerCase().contains(searchQuery);
      return titleMatches || contentMatches;
    }).toList();
    
    if (results.isEmpty) {
      return const Center(
        child: Text('Sonuç bulunamadı'),
      );
    }
    
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final post = results[index];
        return ListTile(
          leading: Icon(
            post.type == PostType.problem
                ? Icons.warning_rounded
                : Icons.lightbulb_outline,
          ),
          title: Text(post.title),
          subtitle: Text(
            post.content,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () {
            close(context, post);
            onTap(post);
          },
        );
      },
    );
  }
}