import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belediye_iletisim_merkezi/models/survey.dart';
import 'package:belediye_iletisim_merkezi/providers/auth_provider.dart';
import 'package:belediye_iletisim_merkezi/services/api_service.dart';
import 'package:belediye_iletisim_merkezi/widgets/survey_card.dart';
import 'package:belediye_iletisim_merkezi/widgets/app_shimmer.dart';
import 'package:carousel_slider/carousel_slider.dart';

class SurveysScreen extends ConsumerStatefulWidget {
  const SurveysScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SurveysScreen> createState() => _SurveysScreenState();
}

class _SurveysScreenState extends ConsumerState<SurveysScreen> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  final CarouselController _carouselController = CarouselController();
  
  TabController? _tabController;
  
  bool _isLoading = true;
  List<Survey> _citySurveys = [];
  List<Survey> _districtSurveys = [];
  int _activeCitySurveyIndex = 0;
  int _activeDistrictSurveyIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSurveys();
  }
  
  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }
  
  Future<void> _loadSurveys() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final authState = ref.read(authProvider);
      String? cityId;
      String? districtId;
      
      if (authState.user != null) {
        cityId = authState.user!.cityId;
        districtId = authState.user!.districtId;
      }
      
      // Şehir anketlerini yükle
      if (cityId != null) {
        final surveys = await _apiService.getCitySurveys(cityId);
        setState(() {
          _citySurveys = surveys;
        });
      }
      
      // İlçe anketlerini yükle
      if (districtId != null) {
        final surveys = await _apiService.getDistrictSurveys(districtId);
        setState(() {
          _districtSurveys = surveys;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Anketler yüklenirken bir hata oluştu: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final String? cityName = authState.user?.cityName;
    final String? districtName = authState.user?.districtName;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('ŞikayetVar', style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
        )),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.pushNamed(context, '/notifications');
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Şehrindeki Gönderiler'),
            Tab(text: 'İlçendeki Gönderiler'),
          ],
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Şehir tab görünümü
          _buildCityTab(cityName),
          // İlçe tab görünümü
          _buildDistrictTab(districtName),
        ],
      ),
    );
  }
  
  Widget _buildCityTab(String? cityName) {
    return RefreshIndicator(
      onRefresh: _loadSurveys,
      child: ListView(
        children: [
          // Anket başlık bölümü
          if (cityName != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'İlçe Anketleri',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          
          // Mevcut şehir anketleri
          _isLoading
              ? _buildLoadingSkeleton()
              : _buildCitySurveyCarousel(),
          
          // Şehir gönderileri başlık bölümü
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Şehir Gönderileri',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    // TODO: Filtre/Sıralama sayfasına yönlendir
                  },
                  icon: const Icon(Icons.filter_list),
                  label: const Text('Filtrele'),
                ),
              ],
            ),
          ),
          
          // Burada şehir gönderileri listesi eklenecek
          // (PostCard widget'ları)
          
          // Yüklü içerik olduğunu belirtmek için yer tutucu
          const SizedBox(height: 500),
        ],
      ),
    );
  }
  
  Widget _buildDistrictTab(String? districtName) {
    return RefreshIndicator(
      onRefresh: _loadSurveys,
      child: ListView(
        children: [
          // Anket başlık bölümü
          if (districtName != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'İlçe Anketleri',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          
          // Mevcut ilçe anketleri
          _isLoading
              ? _buildLoadingSkeleton()
              : _buildDistrictSurveyCarousel(),
          
          // İlçe gönderileri başlık bölümü
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'İlçe Gönderileri',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    // TODO: Filtre/Sıralama sayfasına yönlendir
                  },
                  icon: const Icon(Icons.filter_list),
                  label: const Text('Filtrele'),
                ),
              ],
            ),
          ),
          
          // Burada ilçe gönderileri listesi eklenecek
          // (PostCard widget'ları)
          
          // Yüklü içerik olduğunu belirtmek için yer tutucu
          const SizedBox(height: 500),
        ],
      ),
    );
  }
  
  Widget _buildCitySurveyCarousel() {
    if (_citySurveys.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            'Şehrinize ait anket bulunamadı',
            style: TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }
    
    return Column(
      children: [
        // Anket karusel gösterimi
        CarouselSlider(
          carouselController: _carouselController,
          options: CarouselOptions(
            height: 340,
            viewportFraction: 0.92,
            enlargeCenterPage: true,
            enableInfiniteScroll: _citySurveys.length > 1,
            onPageChanged: (index, reason) {
              setState(() {
                _activeCitySurveyIndex = index;
              });
            },
          ),
          items: _citySurveys.map((survey) {
            return SurveyCard(
              survey: survey,
              onVote: _loadSurveys,
            );
          }).toList(),
        ),
        
        // Karusel indikatörü
        if (_citySurveys.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _citySurveys.asMap().entries.map((entry) {
                final int index = entry.key;
                final bool isActive = _activeCitySurveyIndex == index;
                
                return Container(
                  width: isActive ? 24.0 : 8.0,
                  height: 8.0,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 4.0,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4.0),
                    color: isActive
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.withOpacity(0.3),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
  
  Widget _buildDistrictSurveyCarousel() {
    if (_districtSurveys.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            'İlçenize ait anket bulunamadı',
            style: TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }
    
    return Column(
      children: [
        // Anket karusel gösterimi
        CarouselSlider(
          options: CarouselOptions(
            height: 340,
            viewportFraction: 0.92,
            enlargeCenterPage: true,
            enableInfiniteScroll: _districtSurveys.length > 1,
            onPageChanged: (index, reason) {
              setState(() {
                _activeDistrictSurveyIndex = index;
              });
            },
          ),
          items: _districtSurveys.map((survey) {
            return SurveyCard(
              survey: survey,
              onVote: _loadSurveys,
            );
          }).toList(),
        ),
        
        // Karusel indikatörü
        if (_districtSurveys.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _districtSurveys.asMap().entries.map((entry) {
                final int index = entry.key;
                final bool isActive = _activeDistrictSurveyIndex == index;
                
                return Container(
                  width: isActive ? 24.0 : 8.0,
                  height: 8.0,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 4.0,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4.0),
                    color: isActive
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.withOpacity(0.3),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
  
  Widget _buildLoadingSkeleton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: AppShimmer(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: const SizedBox(
            width: double.infinity,
            height: 320,
          ),
        ),
      ),
    );
  }
}