import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final _searchController = TextEditingController();
  bool _isSearching = false;
  List<String> _recentSearches = [
    'İstanbul',
    'Park sorunu',
    'Çöp toplama',
    'Trafik',
    'Yol çalışması'
  ];
  
  List<Map<String, dynamic>> _trendingTopics = [
    {'name': 'İstanbul', 'type': 'city', 'count': '523 gönderi'},
    {'name': 'Çöp toplama', 'type': 'topic', 'count': '342 gönderi'},
    {'name': 'Trafik', 'type': 'topic', 'count': '256 gönderi'},
    {'name': 'Ankara', 'type': 'city', 'count': '198 gönderi'},
    {'name': 'Yeşil alanlar', 'type': 'topic', 'count': '187 gönderi'},
    {'name': 'Yol çalışması', 'type': 'topic', 'count': '145 gönderi'},
    {'name': 'Sokak hayvanları', 'type': 'topic', 'count': '122 gönderi'},
    {'name': 'İzmir', 'type': 'city', 'count': '118 gönderi'},
    {'name': 'Çevre kirliliği', 'type': 'topic', 'count': '98 gönderi'},
    {'name': 'Toplu taşıma', 'type': 'topic', 'count': '87 gönderi'},
  ];
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Şehir, konu veya etiket ara...',
                  border: InputBorder.none,
                ),
                onSubmitted: _performSearch,
              )
            : const Text('Keşfet'),
        leading: _isSearching
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _isSearching = false;
                    _searchController.clear();
                  });
                },
              )
            : null,
        actions: [
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
            ),
          if (_isSearching && _searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
              },
            ),
        ],
      ),
      body: _isSearching && _searchController.text.isNotEmpty
          ? _buildSearchResults(_searchController.text)
          : _buildExploreContent(),
    );
  }
  
  void _performSearch(String query) {
    if (query.isEmpty) return;
    
    // Gerçek bir uygulamada burada API'den arama sonuçları alınır
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('"$query" için arama sonuçları yakında gösterilecek')),
    );
    
    // Arama sorgusunu son aramalar listesine ekle (duplicate'leri engelle)
    if (!_recentSearches.contains(query)) {
      setState(() {
        _recentSearches.insert(0, query);
        if (_recentSearches.length > 5) {
          _recentSearches = _recentSearches.take(5).toList();
        }
      });
    }
  }
  
  Widget _buildExploreContent() {
    return ListView(
      children: [
        if (_recentSearches.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Son Aramalar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _recentSearches.clear();
                    });
                  },
                  child: const Text('Temizle'),
                ),
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _recentSearches.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: const Icon(Icons.history),
                title: Text(_recentSearches[index]),
                onTap: () {
                  _searchController.text = _recentSearches[index];
                  _performSearch(_recentSearches[index]);
                },
                trailing: IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: () {
                    setState(() {
                      _recentSearches.removeAt(index);
                    });
                  },
                ),
              );
            },
          ),
          const Divider(),
        ],
        
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Gündem Konuları',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _trendingTopics.length,
          itemBuilder: (context, index) {
            final topic = _trendingTopics[index];
            return ListTile(
              leading: Icon(
                topic['type'] == 'city' ? Icons.location_city : Icons.tag,
                color: topic['type'] == 'city' 
                    ? Theme.of(context).colorScheme.primary 
                    : Theme.of(context).colorScheme.secondary,
              ),
              title: Text(topic['name']),
              subtitle: Text(topic['count']),
              trailing: IconButton(
                icon: const Icon(Icons.arrow_forward_ios, size: 16),
                onPressed: () {},
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${topic['name']} konusu yakında gösterilecek')),
                );
              },
            );
          },
        ),
      ],
    );
  }
  
  Widget _buildSearchResults(String query) {
    // Burada arama sonuçları gösterilecek
    // Şimdilik sadece bir placeholder gösterelim
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '"$query" için arama sonuçları',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bu özellik yakında kullanıma sunulacak',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}