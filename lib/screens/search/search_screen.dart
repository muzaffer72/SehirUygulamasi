import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sikayet_var/models/category.dart';
import 'package:sikayet_var/models/post.dart';
import 'package:sikayet_var/services/api_service.dart';
import 'package:sikayet_var/widgets/post_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  
  List<Post> _searchResults = [];
  List<Category> _categories = [];
  
  bool _isLoading = false;
  bool _hasSearched = false;
  
  @override
  void initState() {
    super.initState();
    _loadCategories();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  Future<void> _loadCategories() async {
    try {
      final categories = await _apiService.getCategories();
      setState(() {
        _categories = categories;
      });
    } catch (e) {
      // Handle error if needed
    }
  }
  
  Future<void> _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    
    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });
    
    try {
      // In a real app, this would call an API with search parameters
      // For now, let's simulate a search by filtering all posts
      final allPosts = await _apiService.getPosts();
      
      final results = allPosts.where((post) {
        return post.title.toLowerCase().contains(query.toLowerCase()) ||
            post.content.toLowerCase().contains(query.toLowerCase());
      }).toList();
      
      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Arama yapılırken bir hata oluştu: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _searchByCategory(Category category) async {
    setState(() {
      _isLoading = true;
      _hasSearched = true;
      _searchController.text = 'Kategori: ${category.name}';
    });
    
    try {
      final posts = await _apiService.getPosts(categoryId: category.id);
      
      setState(() {
        _searchResults = posts;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Arama yapılırken bir hata oluştu: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // Sekme kontrolcüsü
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ara'),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Şikayet veya öneri ara...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _hasSearched = false;
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _performSearch(),
            ),
          ),
          
          // Sekmeler (Kategoriler/Şehirler)
          if (!_hasSearched)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildTabButton(
                title: 'Kategoriler',
                index: 0,
                icon: Icons.category,
                fullWidth: true,
              ),
            ),
          
          // İçerik alanı
          if (!_hasSearched)
            Expanded(
              child: _buildCategoriesTab(),
            ),
          
          // Search results
          if (_hasSearched)
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _searchResults.isEmpty
                      ? _buildEmptyResults()
                      : ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final post = _searchResults[index];
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
                                // Refresh search results
                                _performSearch();
                              },
                              onHighlight: () async {
                                await _apiService.highlightPost(post.id);
                                // Refresh search results
                                _performSearch();
                              },
                            );
                          },
                        ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Sonuç bulunamadı',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Farklı anahtar kelimeler deneyebilir veya\nkategorilerden arama yapabilirsiniz',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () {
              setState(() {
                _hasSearched = false;
                _searchController.clear();
              });
            },
            child: const Text('Kategorilere Dön'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCategoryCard(Category category) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _searchByCategory(category),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getCategoryIcon(category.iconName),
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                category.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSearchChip(String label) {
    return ActionChip(
      label: Text(label),
      onPressed: () {
        _searchController.text = label;
        _performSearch();
      },
      backgroundColor: Colors.grey[200],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
  
  IconData _getCategoryIcon(String? iconName) {
    switch (iconName) {
      case 'build':
        return Icons.build;
      case 'nature':
        return Icons.nature;
      case 'directions_bus':
        return Icons.directions_bus;
      case 'cleaning_services':
        return Icons.cleaning_services;
      default:
        return Icons.category;
    }
  }
  
  // Tab butonları oluşturma
  Widget _buildTabButton({
    required String title,
    required int index,
    required IconData icon,
    bool fullWidth = false,
  }) {
    final isSelected = _selectedTabIndex == index;
    
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected 
            ? Theme.of(context).colorScheme.primary 
            : Colors.grey.shade200,
        foregroundColor: isSelected 
            ? Colors.white 
            : Colors.grey.shade700,
        elevation: isSelected ? 2 : 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(title),
        ],
      ),
    );
  }
  
  // Kategoriler sekmesi
  Widget _buildCategoriesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kategoriler',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Categories grid
          _categories.isEmpty
              ? const Center(child: Text('Kategoriler yükleniyor...'))
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    return _buildCategoryCard(category);
                  },
                ),
          
          const SizedBox(height: 32),
          
          // Popular searches
          const Text(
            'Popüler Aramalar',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSearchChip('Sokak Lambaları'),
              _buildSearchChip('Çöp Toplama'),
              _buildSearchChip('Yol Çalışması'),
              _buildSearchChip('Park ve Bahçeler'),
              _buildSearchChip('Gürültü Kirliliği'),
              _buildSearchChip('Toplu Taşıma'),
              _buildSearchChip('Su Kesintisi'),
              _buildSearchChip('İnternet Altyapısı'),
            ],
          ),
        ],
      ),
    );
  }
}