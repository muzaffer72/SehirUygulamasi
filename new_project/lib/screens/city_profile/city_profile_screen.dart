import 'package:flutter/material.dart';
import 'package:belediye_iletisim_merkezi/models/city_profile.dart';
import 'package:belediye_iletisim_merkezi/services/api_service.dart';
import 'package:belediye_iletisim_merkezi/widgets/app_shimmer.dart';

class CityProfileScreen extends StatefulWidget {
  final int cityId;

  const CityProfileScreen({
    Key? key, 
    required this.cityId,
  }) : super(key: key);

  @override
  State<CityProfileScreen> createState() => _CityProfileScreenState();
}

class _CityProfileScreenState extends State<CityProfileScreen> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  late TabController _tabController;
  bool _isLoading = true;
  CityProfile? _cityProfile;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCityProfile();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadCityProfile() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final cityProfile = await _apiService.getCityProfileById(widget.cityId.toString());
      setState(() {
        _cityProfile = cityProfile;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Şehir profili yüklenirken bir hata oluştu: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLoading ? 'Şehir Profili' : _cityProfile?.name ?? 'Şehir Profili'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Genel Bilgiler'),
            Tab(text: 'İstatistikler'),
            Tab(text: 'Yönetim'),
          ],
        ),
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _cityProfile == null
              ? _buildErrorState()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildGeneralInfoTab(),
                    _buildStatisticsTab(),
                    _buildManagementTab(),
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
              radius: 50,
            ),
            SizedBox(height: 16),
            SizedBox(height: 24, width: 150),
            SizedBox(height: 8),
            SizedBox(height: 16, width: 250),
            SizedBox(height: 32),
            SizedBox(height: 100, width: double.infinity),
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
            'Şehir bilgileri yüklenemedi',
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
            onPressed: _loadCityProfile,
            icon: const Icon(Icons.refresh),
            label: const Text('Tekrar Dene'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildGeneralInfoTab() {
    final city = _cityProfile!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık ve resim
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: city.imageUrl != null
                    ? NetworkImage(city.imageUrl!)
                    : null,
                backgroundColor: Colors.grey[200],
                child: city.imageUrl == null
                    ? Text(
                        city.name.substring(0, 1),
                        style: const TextStyle(fontSize: 30),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      city.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Nüfus: ${city.population.toString()}',
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Yönetim: ${city.governmentType}',
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Hakkında
          const Text(
            'Hakkında',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            city.description ?? 'Bu şehir hakkında bilgi bulunmuyor.',
            style: TextStyle(
              color: Colors.grey[800],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // İlçeler
          const Text(
            'İlçeler',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (city.districts.isEmpty)
            Text(
              'Bu şehir için ilçe bilgisi bulunmuyor.',
              style: TextStyle(
                color: Colors.grey[800],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: city.districts.length,
              itemBuilder: (context, index) {
                final district = city.districts[index];
                return ListTile(
                  title: Text(district.name),
                  subtitle: Text('Nüfus: ${district.population}'),
                  leading: const Icon(Icons.location_city),
                  onTap: () {
                    // İlçe detayı
                  },
                );
              },
            ),
        ],
      ),
    );
  }
  
  Widget _buildStatisticsTab() {
    final city = _cityProfile!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Problem çözme oranı
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Problem Çözme Oranı',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: SizedBox(
                      height: 200,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            '${city.problemSolvingRate.toStringAsFixed(1)}%',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Şikayet istatistikleri
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Şikayetler',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildStatRow('Toplam Şikayetler', city.complaintCount.toString()),
                  _buildStatRow('Çözülen Şikayetler', city.solvedComplaintCount.toString()),
                  _buildStatRow('Bekleyen Şikayetler', city.pendingComplaintCount.toString()),
                  _buildStatRow('Reddedilen Şikayetler', city.rejectedComplaintCount.toString()),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Kategori bazlı şikayetler
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kategorilere Göre Şikayetler',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: city.categories.length,
                      itemBuilder: (context, index) {
                        final category = city.categories[index];
                        return Container(
                          width: 100,
                          margin: const EdgeInsets.only(right: 8),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 120,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Text(
                                      '${category.complaintCount}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                category.name,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 12,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildManagementTab() {
    final city = _cityProfile!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Belediye Başkanı
          if (city.mayor != null)
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Belediye Başkanı',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: city.mayor!.imageUrl != null
                              ? NetworkImage(city.mayor!.imageUrl!)
                              : null,
                          backgroundColor: Colors.grey[200],
                          child: city.mayor!.imageUrl == null
                              ? Text(
                                  city.mayor!.name.substring(0, 1),
                                  style: const TextStyle(fontSize: 24),
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                city.mayor!.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Parti: ${city.mayor!.party ?? "Bağımsız"}',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Görev Süresi: ${city.mayor!.termStart} - ${city.mayor!.termEnd ?? "Devam Ediyor"}',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    if (city.mayor!.bio != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        city.mayor!.bio!,
                        style: TextStyle(
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          
          const SizedBox(height: 16),
          
          // İletişim Bilgileri
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'İletişim Bilgileri',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildContactRow(Icons.phone, 'Telefon', city.phone ?? 'Bilgi Yok'),
                  _buildContactRow(Icons.email, 'E-posta', city.email ?? 'Bilgi Yok'),
                  _buildContactRow(Icons.location_on, 'Adres', city.address ?? 'Bilgi Yok'),
                  _buildContactRow(Icons.language, 'Website', city.website ?? 'Bilgi Yok'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildContactRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}