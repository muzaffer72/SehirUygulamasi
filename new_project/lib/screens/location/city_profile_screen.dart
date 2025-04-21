import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/city_profile.dart';
import '../../models/city_service.dart';
import '../../models/city_project.dart';
import '../../providers/city_profile_provider.dart';
import '../../providers/post_provider.dart' as post_provider;
import '../../widgets/post_card.dart';
import '../posts/post_detail_screen.dart';
import '../../models/post.dart';

// Helper extension
extension NullableDoubleHelpers on double? {
  double getOr(double defaultValue) => this ?? defaultValue;
}

class CityProfileScreen extends ConsumerWidget {
  // Helper methods for solution rate calculation
  double _calculateSolutionRateValue(CityProfile city) {
    if (city.solutionRate == null) return 0.0;
    return (city.solutionRate is double) ? city.solutionRate!.getOr(0.0) : city.solutionRate!.getOr(0.0) / 100;
  }
  
  Color _getSolutionRateColor(CityProfile city) {
    if (city.solutionRate == null) return Colors.grey;
    
    final rate = _calculateSolutionRateValue(city);
    if (rate > 0.7) return Colors.green;
    if (rate > 0.4) return Colors.orange;
    return Colors.red;
  }
  
  String _formatSolutionRate(CityProfile city) {
    if (city.solutionRate == null) return "0.0";
    
    final rate = city.solutionRate is double 
        ? city.solutionRate!.getOr(0.0) * 100 
        : city.solutionRate!.getOr(0.0);
    return rate.toStringAsFixed(1);
  }
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('cityId', cityId));
  }
  final String cityId;
  final String? cityName; // Opsiyonel parametre olarak şehir ismi
  
  // Şehir Hizmetleri bölümünü oluşturan widget
  Widget _buildServicesSection(CityProfile city) {
    List<CityService> services = [];
    
    // Api'den gelen hizmetleri işle veya mock veri oluştur
    if (city.projects != null && city.projects!.isNotEmpty) {
      // API'den gelen verileri CityService nesnelerine dönüştür
      for (var serviceData in city.projects!) {
        services.add(CityService(
          id: serviceData['id'] is int ? serviceData['id'] : int.tryParse(serviceData['id'].toString()) ?? 0,
          name: serviceData['name'] ?? 'Hizmet',
          description: serviceData['description'],
          type: serviceData['type'],
          category: serviceData['category'],
          iconUrl: serviceData['icon_url'],
        ));
      }
    } else {
      // Eğer veri yoksa örnek hizmetler oluştur
      services = [
        CityService(
          id: 1,
          name: 'Su ve Kanalizasyon Hizmetleri',
          description: 'Şehrin temiz su dağıtımı ve kanalizasyon sistemi bakım hizmetleri',
          type: 'active',
          category: 'altyapı',
        ),
        CityService(
          id: 2,
          name: 'Çöp Toplama ve Temizlik',
          description: 'Düzenli çöp toplama ve cadde temizleme hizmetleri',
          type: 'active',
          category: 'temizlik',
        ),
        CityService(
          id: 3,
          name: 'Toplu Taşıma',
          description: 'Şehir içi otobüs ve minibüs hatları',
          type: 'active',
          category: 'ulaşım',
        ),
        CityService(
          id: 4,
          name: 'Park ve Bahçe Bakımı',
          description: 'Şehirdeki park, bahçe ve yeşil alanların bakımı',
          type: 'active',
          category: 'park ve bahçeler',
        ),
      ];
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.business_center,
                        color: Colors.blue,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Belediye Hizmetleri',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () {
                    // Tüm hizmetleri göster (ileride eklenecek)
                  },
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  label: const Text('Tümünü Gör'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    backgroundColor: Colors.grey[100],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Divider(),
            ),
            // Hizmet kartları
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: services.length > 3 ? 3 : services.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _buildServiceCard(services[index]),
            ),
            if (services.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Center(
                  child: TextButton.icon(
                    onPressed: () {
                      // Daha fazla göster
                    },
                    icon: const Icon(Icons.add, size: 16),
                    label: Text('${services.length - 3} hizmet daha'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      backgroundColor: Colors.grey[100],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
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
  
  // Şehir projeleri bölümünü oluşturan widget
  Widget _buildProjectsSection(CityProfile city) {
    List<CityProject> projects = [];
    
    // Api'den gelen projeleri işle veya mock veri oluştur
    if (city.projects != null && city.projects!.isNotEmpty) {
      // API'den gelen verileri CityProject nesnelerine dönüştür
      for (var projectData in city.projects!) {
        projects.add(CityProject(
          id: projectData['id'] is int ? projectData['id'] : int.tryParse(projectData['id'].toString()) ?? 0,
          name: projectData['name'] ?? 'Proje',
          description: projectData['description'],
          status: projectData['status'],
          budget: projectData['budget'] is double ? projectData['budget'] : 
                  double.tryParse(projectData['budget'].toString()),
          startDate: projectData['start_date'] ?? projectData['startDate'],
          endDate: projectData['end_date'] ?? projectData['endDate'],
          imageUrl: projectData['image_url'] ?? projectData['imageUrl'],
          location: projectData['location'],
          completionRate: projectData['completion_rate'] is double ? projectData['completion_rate'] : 
                          double.tryParse(projectData['completion_rate'].toString()),
          projectManager: projectData['project_manager'] ?? projectData['projectManager'],
        ));
      }
    } else {
      // Eğer veri yoksa örnek projeler oluştur
      projects = [
        CityProject(
          id: 1,
          name: 'Şehir Merkezi Yenileme Projesi',
          description: 'Şehir merkezindeki tarihi binaların restore edilmesi ve çevre düzenlemelerinin yapılması',
          status: 'inProgress',
          budget: 32500000,
          startDate: '15 Mart 2025',
          endDate: '20 Aralık 2025',
          completionRate: 0.35,
        ),
        CityProject(
          id: 2,
          name: 'Akıllı Şehir Uygulamaları',
          description: 'Şehir genelinde akıllı aydınlatma, akıllı ulaşım ve akıllı atık yönetimi sistemlerinin kurulması',
          status: 'planned',
          budget: 45000000,
          startDate: '10 Eylül 2025',
          endDate: '30 Haziran 2026',
          completionRate: 0.0,
        ),
        CityProject(
          id: 3,
          name: 'Yeni Kültür Merkezi',
          description: 'Modern mimari ile tasarlanmış, konser salonu, tiyatro sahnesi ve sergi alanları içeren çok amaçlı kültür merkezi',
          status: 'completed',
          budget: 25000000,
          startDate: '5 Ocak 2024',
          endDate: '20 Şubat 2025',
          completionRate: 1.0,
        ),
      ];
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.engineering,
                        color: Colors.green,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Belediye Projeleri',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () {
                    // Tüm projeleri göster (ileride eklenecek)
                  },
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  label: const Text('Tümünü Gör'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    backgroundColor: Colors.grey[100],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Divider(),
            ),
            // Proje kartları
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: projects.length > 2 ? 2 : projects.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) => _buildProjectCard(projects[index]),
            ),
            if (projects.length > 2)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Center(
                  child: TextButton.icon(
                    onPressed: () {
                      // Daha fazla göster
                    },
                    icon: const Icon(Icons.add, size: 16),
                    label: Text('${projects.length - 2} proje daha'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      backgroundColor: Colors.grey[100],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
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

  const CityProfileScreen({
    Key? key,
    required this.cityId,
    this.cityName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cityProfileAsync = ref.watch(cityProfileProvider(cityId));
    final posts = ref.watch(post_provider.postsProvider);
    // Convert to AsyncValue for compatibility
    final postsAsync = AsyncValue.data(posts);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Şehir Profili'),
      ),
      body: cityProfileAsync.when(
        data: (city) => _buildCityProfile(context, ref, city ?? CityProfile(id: "0", cityId: "0", name: "Bulunamadı"), postsAsync),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Profil yüklenirken hata: $error'),
        ),
      ),
    );
  }

  Widget _buildCityProfile(
    BuildContext context,
    WidgetRef ref,
    CityProfile city,
    AsyncValue<List<Post>> postsAsync,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.refresh(cityProfileProvider(cityId));
        ref.read(post_provider.postsProvider.notifier).filterPosts(cityId: cityId);
      },
      child: CustomScrollView(
        slivers: [
          // City header
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // City logo
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: city.logoUrl != null
                        ? NetworkImage(city.logoUrl!)
                        : null,
                    child: city.logoUrl == null
                        ? const Icon(Icons.location_city, size: 50)
                        : null,
                  ),
                  const SizedBox(height: 16),
                  
                  // City name
                  Text(
                    city.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  // Political party if available
                  if (city.politicalParty != null && city.politicalParty!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (city.politicalPartyLogoUrl != null)
                            Image.network(
                              city.politicalPartyLogoUrl!,
                              width: 20,
                              height: 20,
                              errorBuilder: (context, error, stackTrace) {
                                return const SizedBox(width: 20, height: 20);
                              },
                            ),
                          const SizedBox(width: 4),
                          Text(
                            city.politicalParty!,
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // City info
                  if (city.info != null && city.info!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        city.info!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  
                  // Contact info
                  if (city.contactPhone != null || city.contactEmail != null || city.website != null)
                    Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'İletişim Bilgileri',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (city.contactPhone != null)
                              Row(
                                children: [
                                  const Icon(Icons.phone, size: 16),
                                  const SizedBox(width: 8),
                                  Text(city.contactPhone!),
                                ],
                              ),
                            if (city.contactEmail != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Row(
                                  children: [
                                    const Icon(Icons.email, size: 16),
                                    const SizedBox(width: 8),
                                    Text(city.contactEmail!),
                                  ],
                                ),
                              ),
                            if (city.website != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Row(
                                  children: [
                                    const Icon(Icons.link, size: 16),
                                    const SizedBox(width: 8),
                                    Text(city.website!),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  
                  // Solution rate
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      children: [
                        const Text(
                          'Çözüm Oranı',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: _calculateSolutionRateValue(city),
                          minHeight: 10,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getSolutionRateColor(city),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_formatSolutionRate(city)}% - ${city.solvedComplaints ?? city.totalSolvedIssues ?? 0} / ${city.totalComplaints ?? city.totalPosts ?? 0} çözüldü',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Posts header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Şehir Gönderileri',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Filter posts by city
                          ref.read(post_provider.postsProvider.notifier).filterPosts(cityId: cityId);
                        },
                        child: const Text('Hepsini Göster'),
                      ),
                    ],
                  ),
                  const Divider(),
                ],
              ),
            ),
          ),
          
          // Şehir Hizmetleri
          SliverToBoxAdapter(
            child: _buildServicesSection(city),
          ),
          
          // Şehir Projeleri
          SliverToBoxAdapter(
            child: _buildProjectsSection(city),
          ),
          
          // City posts
          postsAsync.when(
            data: (posts) {
              // Filter posts by city
              final cityPosts = posts.where((post) => post.cityId == cityId).toList();
              
              if (cityPosts.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: Text('Bu şehre ait henüz gönderi yok'),
                  ),
                );
              }
              
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final post = cityPosts[index];
                    return PostCard(
                      post: post,
                      onTap: () {
                        ref.read(post_provider.selectedPostProvider.notifier).state = post;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PostDetailScreen(id: post.id),
                          ),
                        );
                      },
                      onLike: () {
                        ref.read(post_provider.postsProvider.notifier).likePost(post.id);
                      },
                      onHighlight: () {
                        // Öne çıkarma işlevi
                      },
                      onComment: () {
                        // Yorum yapma işlevi
                        ref.read(post_provider.selectedPostProvider.notifier).state = post;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PostDetailScreen(id: post.id),
                          ),
                        );
                      },
                    );
                  },
                  childCount: cityPosts.length,
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stackTrace) => SliverFillRemaining(
              child: Center(
                child: Text('Gönderiler yüklenirken hata: $error'),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Hizmet kartı widget
  Widget _buildServiceCard(CityService service) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // Hizmet detayına git (ileride eklenecek)
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: (service.type?.toLowerCase() == 'active' ? Colors.blue : Colors.grey).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          _getServiceIcon(service.category ?? ''),
                          color: service.type?.toLowerCase() == 'active' ? Colors.blue : Colors.grey,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              service.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (service.category != null)
                              Row(
                                children: [
                                  Icon(
                                    Icons.folder_outlined,
                                    size: 14,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatCategory(service.category!),
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      if (service.type != null)
                        _buildServiceStatusChip(service.type!),
                    ],
                  ),
                  if (service.description != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0, left: 2),
                      child: Text(
                        service.description!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.3,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          // Detaya git
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          foregroundColor: Colors.blue,
                          visualDensity: VisualDensity.compact,
                        ),
                        child: const Text('Detaylar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Proje kartı widget
  Widget _buildProjectCard(CityProject project) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // Proje detayına git (ileride eklenecek)
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Proje görseli mock
                Stack(
                  children: [
                    Container(
                      height: 160,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: _getProjectColor(project.status ?? '').withOpacity(0.1),
                        image: project.imageUrl != null 
                          ? DecorationImage(
                              image: NetworkImage(project.imageUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                      ),
                      child: project.imageUrl == null ? Center(
                        child: Icon(
                          Icons.engineering,
                          size: 50,
                          color: _getProjectColor(project.status ?? '').withOpacity(0.3),
                        ),
                      ) : null,
                    ),
                    // Bütçe badge
                    if (project.budget != null)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.attach_money, size: 16, color: Colors.green),
                              const SizedBox(width: 2),
                              Text(
                                _formatCurrency(project.budget!),
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    // Durum badge
                    if (project.status != null)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: _buildProjectStatusChip(project.status!),
                      ),
                  ],
                ),
                
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Proje adı
                      Text(
                        project.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      // Proje açıklaması
                      if (project.description != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            project.description!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      
                      const SizedBox(height: 16),
                      
                      // Başlangıç ve bitiş tarihleri
                      if (project.startDate != null || project.endDate != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                              const SizedBox(width: 6),
                              Text(
                                '${project.startDate ?? 'N/A'} - ${project.endDate ?? 'Devam ediyor'}',
                                style: TextStyle(color: Colors.grey[700], fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      
                      const SizedBox(height: 16),
                      
                      // Tamamlanma oranı
                      if (project.completionRate != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Proje Durumu',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _getCompletionColor(project.completionRate!).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '%${(project.completionRate! * 100).toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: _getCompletionColor(project.completionRate!),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: project.completionRate!,
                                minHeight: 10,
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _getCompletionColor(project.completionRate!),
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                      const SizedBox(height: 16),
                      
                      // Detaylar butonu
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Detaylara git
                          },
                          icon: const Icon(Icons.visibility, size: 16),
                          label: const Text('Detayları Görüntüle'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _getProjectColor(project.status ?? ''),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Hizmet tipi için chip widget
  Widget _buildServiceStatusChip(String type) {
    Color color;
    String text;
    
    switch (type.toLowerCase()) {
      case 'active':
        color = Colors.green;
        text = 'Aktif';
        break;
      case 'passive':
        color = Colors.red;
        text = 'Pasif';
        break;
      case 'planned':
        color = Colors.orange;
        text = 'Planlanan';
        break;
      default:
        color = Colors.blue;
        text = type;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Proje durumu için chip widget
  Widget _buildProjectStatusChip(String status) {
    Color color;
    String text;
    IconData icon;
    
    switch (status.toLowerCase()) {
      case 'completed':
      case 'tamamlandı':
        color = Colors.green;
        text = 'Tamamlandı';
        icon = Icons.check_circle;
        break;
      case 'inprogress':
      case 'in_progress':
      case 'in-progress':
      case 'devam ediyor':
        color = Colors.blue;
        text = 'Devam Ediyor';
        icon = Icons.autorenew;
        break;
      case 'planned':
      case 'planning':
      case 'planlanan':
        color = Colors.orange;
        text = 'Planlanan';
        icon = Icons.calendar_today;
        break;
      case 'cancelled':
      case 'iptal':
        color = Colors.red;
        text = 'İptal Edildi';
        icon = Icons.cancel;
        break;
      default:
        color = Colors.grey;
        text = status;
        icon = Icons.info;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Hizmet kategorisine göre ikon seçimi
  IconData _getServiceIcon(String category) {
    switch (category.toLowerCase()) {
      case 'altyapı':
        return Icons.build;
      case 'temizlik':
        return Icons.cleaning_services;
      case 'ulaşım':
        return Icons.directions_bus;
      case 'park ve bahçeler':
        return Icons.park;
      case 'eğitim':
        return Icons.school;
      case 'sağlık':
        return Icons.local_hospital;
      case 'kültür':
        return Icons.theater_comedy;
      case 'sosyal':
        return Icons.people;
      default:
        return Icons.miscellaneous_services;
    }
  }

  // Kategori adını formatlı gösterme
  String _formatCategory(String category) {
    // İlk harfleri büyük yap
    return category.split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  // Para birimini formatlı gösterme
  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)} Milyon ₺';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)} Bin ₺';
    } else {
      return '$amount ₺';
    }
  }

  // Tamamlanma oranına göre renk seçimi
  Color _getCompletionColor(double rate) {
    if (rate >= 0.75) return Colors.green;
    if (rate >= 0.5) return Colors.lightGreen;
    if (rate >= 0.25) return Colors.orange;
    return Colors.red;
  }
  
  // Proje durumuna göre renk seçimi
  Color _getProjectColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'tamamlandı':
        return Colors.green;
      case 'inprogress':
      case 'in_progress':
      case 'in-progress':
      case 'devam ediyor':
        return Colors.blue;
      case 'planned':
      case 'planning':
      case 'planlanan':
        return Colors.orange;
      case 'cancelled':
      case 'iptal':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}