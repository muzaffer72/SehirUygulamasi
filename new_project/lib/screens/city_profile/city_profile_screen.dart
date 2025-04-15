import 'package:belediye_iletisim_merkezi/models/city_profile.dart';
import 'package:belediye_iletisim_merkezi/models/post.dart';
import 'package:belediye_iletisim_merkezi/models/survey.dart';
import 'package:belediye_iletisim_merkezi/services/api_service.dart';
import 'package:belediye_iletisim_merkezi/widgets/custom_app_bar.dart';
import 'package:belediye_iletisim_merkezi/widgets/loading_indicator.dart';
import 'package:belediye_iletisim_merkezi/widgets/error_view.dart';
import 'package:belediye_iletisim_merkezi/widgets/post_card.dart';
import 'package:belediye_iletisim_merkezi/widgets/survey_card.dart';
import 'package:belediye_iletisim_merkezi/utils/constants.dart';
import 'package:belediye_iletisim_merkezi/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class CityProfileScreen extends StatefulWidget {
  final String cityId;

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
  CityProfile? _cityProfile;
  List<Post> _posts = [];
  List<Survey> _surveys = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCityProfile();
  }

  Future<void> _loadCityProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Şehir profil bilgilerini yükle
      final cityProfile = await _apiService.getCityProfileById(widget.cityId);
      setState(() {
        _cityProfile = cityProfile;
      });

      // Şehir gönderilerini yükle
      final posts = await _apiService.getPosts(
        cityId: widget.cityId,
        limit: 10,
      );
      
      // Şehir anketlerini yükle
      final surveys = await _apiService.getCitySurveys(widget.cityId);

      setState(() {
        _posts = posts;
        _surveys = surveys;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: CustomAppBar(
        title: _cityProfile?.name ?? 'Şehir Profili',
        showBackButton: true,
      ),
      body: _isLoading
          ? const LoadingIndicator()
          : _error != null
              ? ErrorView(
                  error: _error!,
                  onRetry: _loadCityProfile,
                )
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_cityProfile == null) {
      return const Center(
        child: Text('Şehir profili bulunamadı.'),
      );
    }

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverToBoxAdapter(
          child: _buildHeader(),
        ),
        SliverAppBar(
          pinned: true,
          elevation: 0,
          automaticallyImplyLeading: false,
          backgroundColor: AppTheme.background,
          toolbarHeight: 0,
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Genel Bilgiler'),
              Tab(text: 'İçerikler'),
              Tab(text: 'Anketler'),
            ],
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: AppTheme.grey,
            indicatorColor: AppTheme.primaryColor,
            indicatorWeight: 3,
          ),
        ),
      ],
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDetailsTab(),
          _buildPostsTab(),
          _buildSurveysTab(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Kapak fotoğrafı
        _cityProfile!.bannerUrl != null
            ? SizedBox(
                height: 200,
                width: double.infinity,
                child: CachedNetworkImage(
                  imageUrl: _cityProfile!.bannerUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppTheme.lightGrey,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppTheme.lightGrey,
                    child: const Icon(Icons.image, size: 48, color: AppTheme.grey),
                  ),
                ),
              )
            : Container(
                height: 150,
                width: double.infinity,
                color: AppTheme.primaryColor.withOpacity(0.1),
                child: Center(
                  child: Text(
                    _cityProfile!.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
        
        // Şehir logo ve ismi
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Logo
              _cityProfile!.logoUrl != null
                  ? Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: _cityProfile!.logoUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          errorWidget: (context, url, error) => const Icon(
                            Icons.location_city,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    )
                  : Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.location_city,
                        color: AppTheme.primaryColor,
                        size: 30,
                      ),
                    ),
              const SizedBox(width: 16),
              
              // Şehir Adı ve İstatistikler
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _cityProfile!.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _cityProfile!.population != null
                          ? 'Nüfus: ${_cityProfile!.population}'
                          : 'Türkiye',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // İstatistik kartları
        _buildStatisticsRow(),
        
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildStatisticsRow() {
    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          _buildStatCard(
            icon: Icons.thumb_up,
            value: _cityProfile!.formattedSatisfactionRate,
            label: 'Memnuniyet',
            color: Colors.green,
          ),
          _buildStatCard(
            icon: Icons.access_time,
            value: _cityProfile!.formattedResponseTime,
            label: 'Yanıt Süresi',
            color: Colors.orange,
          ),
          _buildStatCard(
            icon: Icons.task_alt,
            value: _cityProfile!.formattedProblemSolvingRate,
            label: 'Çözüm Oranı',
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_cityProfile!.description != null && _cityProfile!.description!.isNotEmpty) ...[
            const Text(
              'Şehir Hakkında',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _cityProfile!.description!,
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
          ],
          
          // Belediye Başkanı Bilgisi
          if (_cityProfile!.mayor != null) ...[
            const Text(
              'Belediye Başkanı',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_cityProfile!.mayorPhoto != null)
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: _cityProfile!.mayorPhoto!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[200],
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _cityProfile!.mayor!,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Belediye Başkanı',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
          
          // İletişim Bilgileri
          const Text(
            'İletişim Bilgileri',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          _buildContactInfo(
            icon: Icons.public,
            label: 'Website',
            value: _cityProfile!.website,
            onTap: _cityProfile!.website != null
                ? () => _launchUrl(_cityProfile!.website!)
                : null,
          ),
          _buildContactInfo(
            icon: Icons.phone,
            label: 'Telefon',
            value: _cityProfile!.phone,
            onTap: _cityProfile!.phone != null
                ? () => _launchUrl('tel:${_cityProfile!.phone}')
                : null,
          ),
          _buildContactInfo(
            icon: Icons.email,
            label: 'E-posta',
            value: _cityProfile!.email,
            onTap: _cityProfile!.email != null
                ? () => _launchUrl('mailto:${_cityProfile!.email}')
                : null,
          ),
          _buildContactInfo(
            icon: Icons.location_on,
            label: 'Adres',
            value: _cityProfile!.address,
          ),
          
          // Şehir Bilgileri
          if (_cityProfile!.population != null ||
              _cityProfile!.area != null ||
              _cityProfile!.established != null) ...[
            const SizedBox(height: 20),
            const Text(
              'Şehir Bilgileri',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 12),
            if (_cityProfile!.population != null)
              _buildInfoRow('Nüfus', _cityProfile!.population!),
            if (_cityProfile!.area != null)
              _buildInfoRow('Yüzölçümü', '${_cityProfile!.area} km²'),
            if (_cityProfile!.populationDensity != null)
              _buildInfoRow('Nüfus Yoğunluğu', _cityProfile!.populationDensity!),
            if (_cityProfile!.established != null)
              _buildInfoRow('Kuruluş', _cityProfile!.established!),
          ],
          
          const SizedBox(height: 20),
          _buildStatsSection(),
        ],
      ),
    );
  }

  Widget _buildContactInfo({
    required IconData icon,
    required String label,
    String? value,
    VoidCallback? onTap,
  }) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 20,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      color: onTap != null ? AppTheme.primaryColor : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'İstatistikler',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 12),
        // İstatistikleri gösteren kartlar
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          children: [
            _buildStatisticsCard(
              icon: Icons.error_outline,
              title: 'Toplam Şikayet',
              value: _cityProfile!.totalComplaints.toString(),
              color: Colors.orange,
            ),
            _buildStatisticsCard(
              icon: Icons.check_circle_outline,
              title: 'Çözülen Şikayet',
              value: _cityProfile!.solvedComplaints.toString(),
              color: Colors.green,
            ),
            _buildStatisticsCard(
              icon: Icons.lightbulb_outline,
              title: 'Öneriler',
              value: _cityProfile!.totalSuggestions.toString(),
              color: Colors.blue,
            ),
            _buildStatisticsCard(
              icon: Icons.pending_actions,
              title: 'Aktif Şikayet',
              value: _cityProfile!.activeComplaints.toString(),
              color: Colors.red,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatisticsCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostsTab() {
    if (_posts.isEmpty) {
      return const Center(
        child: Text('Bu şehir için henüz içerik bulunmamaktadır.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        return PostCard(post: _posts[index]);
      },
    );
  }

  Widget _buildSurveysTab() {
    if (_surveys.isEmpty) {
      return const Center(
        child: Text('Bu şehir için henüz anket bulunmamaktadır.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _surveys.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: SurveyCard(survey: _surveys[index]),
        );
      },
    );
  }

  Future<void> _launchUrl(String url) async {
    if (!(url.startsWith('http://') || url.startsWith('https://') || 
        url.startsWith('tel:') || url.startsWith('mailto:'))) {
      if (url.startsWith('www.')) {
        url = 'https://$url';
      } else if (!(url.startsWith('tel:') || url.startsWith('mailto:'))) {
        url = 'https://$url';
      }
    }
    
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bağlantı açılamadı')),
      );
    }
  }
}