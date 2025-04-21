import 'package:flutter/material.dart';
import 'package:belediye_iletisim_merkezi/models/post.dart';
import 'package:belediye_iletisim_merkezi/models/user.dart';
import 'package:belediye_iletisim_merkezi/models/category.dart';
import 'package:belediye_iletisim_merkezi/services/api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belediye_iletisim_merkezi/providers/api_service_provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cached_network_image/cached_network_image.dart';

class PostCard extends ConsumerStatefulWidget {
  final Post post;
  final VoidCallback onTap;
  final VoidCallback onLike;
  final VoidCallback onHighlight;
  final bool showFullContent;
  final bool isDetailView;
  final VoidCallback? onComment;
  final VoidCallback? onShare;

  const PostCard({
    Key? key,
    required this.post,
    required this.onTap,
    required this.onLike,
    required this.onHighlight,
    this.showFullContent = false,
    this.isDetailView = false,
    this.onComment,
    this.onShare,
  }) : super(key: key);

  @override
  ConsumerState<PostCard> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<PostCard> {
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
                      onTap: widget.onShare ?? () {
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
                    : FutureBuilder<User?>(
                        future: ref.read(apiServiceProvider).getUserById(int.parse(widget.post.userId)),
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
                    
                    // Location - Önce doğrudan Post nesnesindeki konum bilgilerini kontrol et
                    if (widget.post.hasLocationInfo) ...[
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
                      
                      // Post üzerindeki şehir/ilçe adı bilgisini kullan
                      if (widget.post.cityName != null) 
                        GestureDetector(
                          onTap: () {
                            // Şehir profil sayfasına yönlendirme
                            Navigator.pushNamed(
                              context,
                              '/city_profile',
                              arguments: widget.post.cityId,
                            );
                          },
                          child: Text(
                            widget.post.districtName != null 
                                ? '${widget.post.districtName}, ${widget.post.cityName}' 
                                : widget.post.cityName!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        )
                      // Yalnızca cityId varsa, API'den bilgileri çek
                      else if (widget.post.cityId != null)
                        FutureBuilder<List<dynamic>>(
                          future: Future.wait([
                            ref.read(apiServiceProvider).getCityById(widget.post.cityId!),
                            if (widget.post.districtId != null) 
                              ref.read(apiServiceProvider).getDistrictById(widget.post.districtId!) 
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
                            
                            if (snapshot.data == null || snapshot.data!.isEmpty || snapshot.data![0] == null) {
                              return Text(
                                'Bilinmeyen Konum',
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
                                  arguments: city.id,
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
          
          // Category - doğrudan Posttan veya API'den kategori bilgisi göster
          if (widget.post.categoryName != null) // Önce doğrudan Post nesnesindeki kategori adını kullan
            GestureDetector(
              onTap: () {
                // Kategori filtresi için
                Navigator.pushNamed(
                  context,
                  '/filtered_posts',
                  arguments: {
                    'filterType': 'category',
                    'categoryId': widget.post.categoryId,
                    'categoryName': widget.post.categoryName,
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
                  widget.post.categoryName!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            )
          // Eğer Post nesnesinde categoryName yoksa ama categoryId varsa
          else if (widget.post.categoryId != null)
            FutureBuilder<Category?>(
              future: ref.read(apiServiceProvider).getCategoryById(widget.post.categoryId!),
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
  
  // Twitter tarzı header
  Widget _buildTwitterHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar (veya şikayet tipi ikonu)
          GestureDetector(
            onTap: () {
              if (!widget.post.isAnonymous) {
                // Kullanıcı profiline git
                Navigator.pushNamed(
                  context,
                  '/profile',
                  arguments: widget.post.userId,
                );
              }
            },
            child: Container(
              width: 48,
              height: 48,
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
              child: widget.post.isAnonymous
                ? Center(
                    child: Icon(
                      widget.post.type == PostType.problem
                          ? Icons.warning_rounded
                          : Icons.lightbulb_outline,
                      color: widget.post.type == PostType.problem
                          ? Colors.red
                          : Colors.green,
                      size: 24,
                    ),
                  )
                : FutureBuilder<User?>(
                    future: ref.read(apiServiceProvider).getUserById(int.parse(widget.post.userId)),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data!.profileImageUrl != null) {
                        return ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: snapshot.data!.profileImageUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Center(
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
                            errorWidget: (context, url, error) => Center(
                              child: Icon(
                                Icons.person,
                                color: Theme.of(context).primaryColor,
                                size: 24,
                              ),
                            ),
                          ),
                        );
                      } else {
                        return Center(
                          child: Icon(
                            widget.post.type == PostType.problem
                                ? Icons.warning_rounded
                                : Icons.lightbulb_outline,
                            color: widget.post.type == PostType.problem
                                ? Colors.red
                                : Colors.green,
                            size: 24,
                          ),
                        );
                      }
                    },
                  ),
            ),
          ),
          const SizedBox(width: 8),
          
          // Kullanıcı bilgileri
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kullanıcı adı ve kontrol ikonu
                Row(
                  children: [
                    widget.post.isAnonymous
                        ? const Text(
                            'Anonim',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          )
                        : widget.post.username != null
                            // Post nesnesindeki username bilgisini kullan
                            ? GestureDetector(
                                onTap: () {
                                  // Kullanıcı profiline git
                                  Navigator.pushNamed(
                                    context,
                                    '/profile',
                                    arguments: widget.post.userId,
                                  );
                                },
                                child: Text(
                                  widget.post.username!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              )
                            // Yoksa API'den kullanıcı bilgisini çek
                            : FutureBuilder<User?>(
                                future: ref.read(apiServiceProvider).getUserById(int.parse(widget.post.userId)),
                                builder: (context, snapshot) {
                                  // Yükleme durumu, hata durumu veya veri yoksa
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const Text(
                                      'Yükleniyor...',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: Colors.grey,
                                      ),
                                    );
                                  }
                                  
                                  if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                                    return const Text(
                                      'Bilinmeyen Kullanıcı',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: Colors.grey,
                                      ),
                                    );
                                  }
                                  
                                  // Güvenli erişim için null kontrolü
                                  final userName = snapshot.data!.name ?? 'İsimsiz Kullanıcı';
                                  
                                  return GestureDetector(
                                    onTap: () {
                                      // Kullanıcı profiline git
                                      Navigator.pushNamed(
                                        context,
                                        '/profile',
                                        arguments: widget.post.userId,
                                      );
                                    },
                                    child: Text(
                                      userName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  );
                                },
                              ),
                    
                    if (!widget.post.isAnonymous)
                      const Icon(
                        Icons.verified,
                        color: Colors.blue,
                        size: 14,
                      ),
                    
                    Text(
                      ' · ',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 15,
                      ),
                    ),
                    
                    // Zaman
                    Text(
                      timeago.format(widget.post.createdAt, locale: 'tr'),
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                
                // Konum bilgisi - önce doğrudan Post nesnesindeki konum bilgilerini kontrol et
                if (widget.post.hasLocationInfo) 
                  // Post üzerindeki konum bilgisini göster
                  widget.post.cityName != null 
                  ? Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 12,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 2),
                        GestureDetector(
                          onTap: () {
                            // Şehir profil sayfasına git
                            Navigator.pushNamed(
                              context,
                              '/city_profile',
                              arguments: widget.post.cityId,
                            );
                          },
                          child: Text(
                            widget.post.districtName != null
                                ? '${widget.post.districtName}, ${widget.post.cityName}'
                                : widget.post.cityName!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    )
                  // Eğer API'den konum bilgisi almak gerekiyorsa
                  : FutureBuilder<List<dynamic>>(
                      future: Future.wait([
                        ref.read(apiServiceProvider).getCityById(int.parse(widget.post.cityId!)),
                        if (widget.post.districtId != null) 
                          ref.read(apiServiceProvider).getDistrictById(int.parse(widget.post.districtId!)) 
                        else 
                          Future.value(null),
                      ]),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty || snapshot.data![0] == null) {
                          return Text(
                            'Konum bilgisi alınamadı',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          );
                        }
                        
                        final city = snapshot.data![0];
                        final district = snapshot.data!.length > 1 ? snapshot.data![1] : null;
                        
                        if (city == null) {
                          return Text(
                            'Şehir bilgisi bulunamadı',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          );
                        }
                        
                        final cityName = city.name ?? 'Bilinmeyen Şehir';
                        final districtName = district?.name;
                        
                        final locationText = (districtName != null && districtName.isNotEmpty)
                            ? '$districtName, $cityName' 
                            : cityName;
                        
                        return Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 12,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 2),
                            GestureDetector(
                              onTap: () {
                                // Şehir profil sayfasına git
                                Navigator.pushNamed(
                                  context,
                                  '/city_profile',
                                  arguments: city.id,
                                );
                              },
                              child: Text(
                                locationText,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                
                // Kategori - Önce posttan kategori adı bilgisini kontrol et
                if (widget.post.categoryName != null)
                  // Post üzerindeki kategori adını göster
                  GestureDetector(
                    onTap: () {
                      // Kategori filtresi için
                      Navigator.pushNamed(
                        context,
                        '/filtered_posts',
                        arguments: {
                          'filterType': 'category',
                          'categoryId': widget.post.categoryId,
                          'categoryName': widget.post.categoryName,
                        },
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.post.categoryName!,
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  )
                // Kategori bilgisi yoksa API'den çek
                else if (widget.post.categoryId != null)
                  FutureBuilder<Category?>(
                    future: ref.read(apiServiceProvider).getCategoryById(int.parse(widget.post.categoryId!)),
                    builder: (context, snapshot) {
                      // Yükleme, hata veya veri yoksa
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox.shrink();
                      }
                      
                      if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                        return const SizedBox.shrink();
                      }
                      
                      final category = snapshot.data!;
                      // Kategori adı yoksa gösterme
                      if (category.name == null || category.name.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      
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
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            category.name,
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
          
          // Seçenekler menüsü
          IconButton(
            icon: const Icon(Icons.more_vert, size: 16),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              // Daha fazla seçenek
              showModalBottomSheet(
                context: context,
                builder: (context) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.report),
                      title: const Text('Bildir'),
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Bildirim alma özelliği yakında eklenecek')),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.bookmark_border),
                      title: const Text('Kaydet'),
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Kaydetme özelliği yakında eklenecek')),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
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
  
  // Twitter tarzı resim grid'i
  Widget _buildTwitterImageGrid(List<String> imageUrls) {
    if (imageUrls.isEmpty) return const SizedBox.shrink();
    
    // Twitter tarzı fotoğraf gösterimi (1-4 arası)
    if (imageUrls.length == 1) {
      // Tek fotoğraf
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: CachedNetworkImage(
          imageUrl: imageUrls[0],
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey[300],
            height: 200,
            width: double.infinity,
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[300],
            height: 200,
            width: double.infinity,
            child: const Center(
              child: Icon(Icons.error, color: Colors.red),
            ),
          ),
        ),
      );
    } else if (imageUrls.length == 2) {
      // İki fotoğraf yan yana
      return Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: CachedNetworkImage(
                imageUrl: imageUrls[0],
                height: 200,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  height: 200,
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  height: 200,
                  child: const Center(
                    child: Icon(Icons.error, color: Colors.red),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 2),
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              child: CachedNetworkImage(
                imageUrl: imageUrls[1],
                height: 200,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  height: 200,
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  height: 200,
                  child: const Center(
                    child: Icon(Icons.error, color: Colors.red),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    } else if (imageUrls.length == 3) {
      // Bir büyük, iki küçük
      return Row(
        children: [
          Expanded(
            flex: 1,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: CachedNetworkImage(
                imageUrl: imageUrls[0],
                height: 200,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  height: 200,
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  height: 200,
                  child: const Center(
                    child: Icon(Icons.error, color: Colors.red),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 2),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: imageUrls[1],
                    height: 99,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                      height: 99,
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      height: 99,
                      child: const Center(
                        child: Icon(Icons.error, color: Colors.red),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(16),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: imageUrls[2],
                    height: 99,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                      height: 99,
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      height: 99,
                      child: const Center(
                        child: Icon(Icons.error, color: Colors.red),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      // Dört fotoğraf (2x2 grid)
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: imageUrls[0],
                    height: 120,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                      height: 120,
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      height: 120,
                      child: const Center(
                        child: Icon(Icons.error, color: Colors.red),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 2),
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: imageUrls[1],
                    height: 120,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                      height: 120,
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      height: 120,
                      child: const Center(
                        child: Icon(Icons.error, color: Colors.red),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: imageUrls[2],
                    height: 120,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                      height: 120,
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      height: 120,
                      child: const Center(
                        child: Icon(Icons.error, color: Colors.red),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 2),
              Expanded(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomRight: Radius.circular(16),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: imageUrls[3],
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[300],
                          height: 120,
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[300],
                          height: 120,
                          child: const Center(
                            child: Icon(Icons.error, color: Colors.red),
                          ),
                        ),
                      ),
                    ),
                    
                    // "More" göstergesi
                    if (imageUrls.length > 4)
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomRight: Radius.circular(16),
                          ),
                          child: Container(
                            color: Colors.black.withOpacity(0.5),
                            child: Center(
                              child: Text(
                                '+${imageUrls.length - 4}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      );
    }
  }
  
  // Twitter tarzı aksiyon butonu
  Widget _buildTwitterActionButton({
    required IconData icon,
    required IconData activeIcon,
    required int count,
    required Color color,
    required VoidCallback onTap,
    bool showCount = true,
  }) {
    final isActive = count > 0;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              size: 16,
              color: isActive ? color : Colors.grey[600],
            ),
            if (showCount) ...[
              const SizedBox(width: 4),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 14,
                  color: isActive ? color : Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}