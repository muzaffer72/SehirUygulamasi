import 'package:flutter/material.dart';
import '../../models/city_profile.dart';
import '../../widgets/best_municipality_banner.dart';
import '../../widgets/city_priority_chart.dart';
import '../../widgets/monthly_performance_card.dart';
import '../../widgets/city_stats_chart.dart';
import '../../utils/ticker_fix.dart';
import '../../models/city_service.dart';
import '../../models/city_project.dart';
import '../../models/city_event.dart';
import '../../models/city_stat.dart';

class CityProfileScreen extends StatefulWidget {
  final CityProfile cityProfile;

  const CityProfileScreen({Key? key, required this.cityProfile}) : super(key: key);

  @override
  State<CityProfileScreen> createState() => _CityProfileScreenState();
}

class _CityProfileScreenState extends State<CityProfileScreen> with SafeSingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  bool _hasAward = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _hasAward = widget.cityProfile.awardText != null && widget.cityProfile.awardText!.isNotEmpty;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200.0,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  widget.cityProfile.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black54,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      widget.cityProfile.demoCoverImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Theme.of(context).primaryColor.withOpacity(0.5),
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 50,
                              color: Colors.white54,
                            ),
                          ),
                        );
                      },
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black54,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Şehir bilgileri
            SliverToBoxAdapter(
              child: _buildCityInfoSection(),
            ),
            // Tab Bar
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: Theme.of(context).primaryColor,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Theme.of(context).primaryColor,
                  tabs: const [
                    Tab(icon: Icon(Icons.home), text: 'Genel'),
                    Tab(icon: Icon(Icons.business), text: 'Hizmetler'),
                    Tab(icon: Icon(Icons.construction), text: 'Projeler'),
                    Tab(icon: Icon(Icons.event), text: 'Etkinlikler'),
                    Tab(icon: Icon(Icons.bar_chart), text: 'İstatistikler'),
                  ],
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildGeneralTab(),
            _buildServicesTab(),
            _buildProjectsTab(),
            _buildEventsTab(),
            _buildStatsTab(),
          ],
        ),
      ),
    );
  }

  // Şehir bilgileri bölümü
  Widget _buildCityInfoSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  widget.cityProfile.demoImageUrl,
                  width: 110,
                  height: 110,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 110,
                    height: 110,
                    color: Colors.grey.withOpacity(0.3),
                    child: const Icon(
                      Icons.image_not_supported,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Belediye Başkanı',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 15,
                                    backgroundImage: NetworkImage(widget.cityProfile.demoMayorImageUrl),
                                    onBackgroundImageError: (exception, stackTrace) => {},
                                    backgroundColor: Colors.grey.withOpacity(0.3),
                                    child: const Icon(
                                      Icons.person,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      widget.cityProfile.demoMayorName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _infoChip(
                          Icons.people,
                          '${widget.cityProfile.population}',
                          'Nüfus',
                        ),
                        _infoChip(
                          Icons.location_city,
                          '${widget.cityProfile.districtCount}',
                          'İlçe',
                        ),
                        _infoChip(
                          Icons.thumb_up,
                          '%${widget.cityProfile.solutionRate.toStringAsFixed(1)}',
                          'Çözüm',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_hasAward)
            BestMunicipalityBanner(
              cityName: widget.cityProfile.name,
              awardMonth: widget.cityProfile.awardMonth ?? 'Nisan',
              awardScore: widget.cityProfile.awardScore != null
                  ? widget.cityProfile.awardScore!.toInt()
                  : 95,
              awardText: widget.cityProfile.awardText ??
                  'Vatandaş memnuniyeti ve şikayet çözüm süreleri temel alınarak seçilmiştir.',
            ),
        ],
      ),
    );
  }

  // Bilgi çipi
  Widget _infoChip(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // Genel sekmesi
  Widget _buildGeneralTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Şehir Açıklaması
          if (widget.cityProfile.description != null &&
              widget.cityProfile.description!.isNotEmpty)
            Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Şehir Hakkında',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.cityProfile.description!,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),

          // Aylık Performans Kartı
          if (widget.cityProfile.monthlyPerformance != null)
            MonthlyPerformanceCard(
              performanceMonth: widget.cityProfile.performanceMonth ?? 'Nisan',
              performanceYear: widget.cityProfile.performanceYear ?? '2025',
              monthlyPerformance: widget.cityProfile.monthlyPerformance!,
              width: double.infinity,
            ),
          const SizedBox(height: 16),

          // Belediye Öncelikleri
          _buildPrioritiesTab(),
          
          const SizedBox(height: 16),
          
          // İletişim Bilgileri
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.contact_phone, color: Colors.green, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'İletişim Bilgileri',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  if (widget.cityProfile.contactPhone != null)
                    _contactItem(
                      Icons.phone,
                      'Telefon',
                      widget.cityProfile.contactPhone!,
                    ),
                  if (widget.cityProfile.emergencyPhone != null)
                    _contactItem(
                      Icons.emergency,
                      'Acil Durum',
                      widget.cityProfile.emergencyPhone!,
                    ),
                  if (widget.cityProfile.contactEmail != null)
                    _contactItem(
                      Icons.email,
                      'E-posta',
                      widget.cityProfile.contactEmail!,
                    ),
                  if (widget.cityProfile.website != null)
                    _contactItem(
                      Icons.language,
                      'Web Sitesi',
                      widget.cityProfile.website!,
                    ),
                  // Örnek iletişim bilgileri (gerçek veriler yoksa)
                  if (widget.cityProfile.contactPhone == null &&
                      widget.cityProfile.contactEmail == null &&
                      widget.cityProfile.website == null)
                    Column(
                      children: [
                        _contactItem(
                          Icons.phone,
                          'Telefon',
                          '0212 123 45 67',
                        ),
                        _contactItem(
                          Icons.emergency,
                          'Acil Durum',
                          '153',
                        ),
                        _contactItem(
                          Icons.email,
                          'E-posta',
                          'info@${widget.cityProfile.name.toLowerCase().replaceAll(' ', '')}.bel.tr',
                        ),
                        _contactItem(
                          Icons.language,
                          'Web Sitesi',
                          'www.${widget.cityProfile.name.toLowerCase().replaceAll(' ', '')}.bel.tr',
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // İletişim öğesi
  Widget _contactItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Hizmetler sekmesi
  Widget _buildServicesTab() {
    final services = widget.cityProfile.services ?? [];
    
    // Demo hizmetler oluştur (gerçek hizmetler yoksa)
    if (services.isEmpty) {
      // Demo hizmet listesi
      final demoServices = [
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
        CityService(
          id: 5,
          name: 'Sosyal Destek Hizmetleri',
          description: 'İhtiyaç sahiplerine gıda, kıyafet ve eğitim yardımları',
          type: 'active',
          category: 'sosyal hizmetler',
        ),
      ];
      
      return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: demoServices.length,
        itemBuilder: (context, index) {
          final service = demoServices[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: Icon(
                _getCategoryIcon(service.category ?? ''),
                color: Theme.of(context).primaryColor,
                size: 30,
              ),
              title: Text(service.name),
              subtitle: Text(service.description ?? ''),
              trailing: service.type == 'active'
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : const Icon(Icons.cancel, color: Colors.red),
            ),
          );
        },
      );
    }
    
    // Gerçek hizmetleri kullan
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            leading: Icon(
              _getCategoryIcon(service.category ?? ''),
              color: Theme.of(context).primaryColor,
              size: 30,
            ),
            title: Text(service.name),
            subtitle: Text(service.description ?? ''),
            trailing: service.type == 'active'
                ? const Icon(Icons.check_circle, color: Colors.green)
                : const Icon(Icons.cancel, color: Colors.red),
          ),
        );
      },
    );
  }

  // Projeler sekmesi
  Widget _buildProjectsTab() {
    final projects = widget.cityProfile.projects ?? [];
    
    // Demo projeler oluştur (gerçek projeler yoksa)
    if (projects.isEmpty) {
      // Demo proje listesi
      final demoProjects = [
        CityProject(
          id: 1,
          cityId: widget.cityProfile.id,
          name: 'Şehir Merkezi Yenileme Projesi',
          description: 'Şehir merkezindeki tarihi binaların restore edilmesi ve çevre düzenlemelerinin yapılması',
          status: 'inProgress',
          startDate: '15 Mart 2025',
          endDate: '20 Aralık 2025',
          budget: 32500000,
          likes: 214,
          dislikes: 15,
        ),
        CityProject(
          id: 2,
          cityId: widget.cityProfile.id,
          name: 'Akıllı Sokak Aydınlatma Sistemi',
          description: 'Enerji tasarruflu, hareket sensörlü sokak lambaları kurulumu',
          status: 'completed',
          startDate: '5 Ocak 2025',
          endDate: '10 Mart 2025',
          budget: 5750000,
          likes: 352,
          dislikes: 8,
        ),
        CityProject(
          id: 3,
          cityId: widget.cityProfile.id,
          name: 'Yeni Kültür Merkezi İnşaatı',
          description: 'Şehir kütüphanesi, sanat galerisi ve 500 kişilik konferans salonundan oluşan kültür merkezi',
          status: 'planned',
          startDate: '10 Haziran 2025',
          endDate: '15 Eylül 2026',
          budget: 58250000,
          likes: 189,
          dislikes: 45,
        ),
        CityProject(
          id: 4,
          cityId: widget.cityProfile.id,
          name: 'Şehir Parkı Genişletme Projesi',
          description: 'Mevcut şehir parkına yeni spor alanları, çocuk oyun alanları ve piknik alanlarının eklenmesi',
          status: 'inProgress',
          startDate: '20 Şubat 2025',
          endDate: '15 Haziran 2025',
          budget: 12800000,
          likes: 278,
          dislikes: 12,
        ),
      ];
      
      return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: demoProjects.length,
        itemBuilder: (context, index) {
          final project = demoProjects[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  widget.cityProfile.demoProjectImageUrl,
                  width: double.infinity,
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: double.infinity,
                    height: 150,
                    color: Colors.grey.withOpacity(0.2),
                    child: const Icon(
                      Icons.image_not_supported,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              project.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(project.status),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              project.statusDisplay,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (project.description != null)
                        Text(
                          project.description!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            'Başlangıç: ${project.startDate ?? 'Belirtilmemiş'}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Icon(Icons.flag, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            'Bitiş: ${project.endDate ?? 'Belirtilmemiş'}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      if (project.budget != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            children: [
                              const Icon(Icons.attach_money, size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                'Bütçe: ${project.budget?.toStringAsFixed(0)} TL',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
    
    // Gerçek projeleri kullan
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                project.imageUrl ?? widget.cityProfile.demoProjectImageUrl,
                width: double.infinity,
                height: 150,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: double.infinity,
                  height: 150,
                  color: Colors.grey.withOpacity(0.2),
                  child: const Icon(
                    Icons.image_not_supported,
                    size: 50,
                    color: Colors.grey,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            project.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(project.status),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            project.statusDisplay,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (project.description != null)
                      Text(
                        project.description!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          'Başlangıç: ${project.startDate ?? 'Belirtilmemiş'}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Icon(Icons.flag, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          'Bitiş: ${project.endDate ?? 'Belirtilmemiş'}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    if (project.budget != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            const Icon(Icons.attach_money, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              'Bütçe: ${project.budget?.toStringAsFixed(0)} TL',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Etkinlikler sekmesi
  Widget _buildEventsTab() {
    final events = widget.cityProfile.events ?? [];
    
    // Demo etkinlikler oluştur (gerçek etkinlikler yoksa)
    if (events.isEmpty) {
      // Demo etkinlik listesi
      final now = DateTime.now();
      final demoEvents = [
        CityEvent(
          id: 1,
          cityId: widget.cityProfile.id,
          name: 'Şehir Kültür Festivali',
          description: 'Şehrimizin kültürel değerlerini tanıtan ve yerel sanatçıların performanslarını içeren festival',
          eventDate: DateTime(now.year, now.month + 2, 15),
          date: '15-20 Haziran 2025',
          location: 'Şehir Meydanı',
          isActive: true,
        ),
        CityEvent(
          id: 2,
          cityId: widget.cityProfile.id,
          name: 'Engelsiz Yaşam Şenliği',
          description: 'Engelli vatandaşlarımız için farkındalık oluşturmak amacıyla düzenlenen etkinlikler',
          eventDate: DateTime(now.year, 12, 3),
          date: '3 Aralık 2025',
          location: 'Kültür Merkezi',
          isActive: true,
        ),
        CityEvent(
          id: 3,
          cityId: widget.cityProfile.id,
          name: 'Çocuk Bilim Şenliği',
          description: 'Çocuklara bilimi sevdirmek amacıyla düzenlenen atölye ve deneyler',
          eventDate: DateTime(now.year, 4, 23),
          date: '23 Nisan 2025',
          location: 'Bilim Merkezi',
          isActive: true,
        ),
        CityEvent(
          id: 4,
          cityId: widget.cityProfile.id,
          name: 'Şehir Kitap Günleri',
          description: 'Yerel ve ulusal yazarların katılımıyla düzenlenen kitap fuarı ve imza günleri',
          eventDate: DateTime(now.year, 9, 8),
          date: '8-15 Eylül 2025',
          location: 'Kültür Parkı',
          isActive: true,
        ),
      ];
      
      return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: demoEvents.length,
        itemBuilder: (context, index) {
          final event = demoEvents[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  widget.cityProfile.demoEventImageUrl,
                  width: double.infinity,
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: double.infinity,
                    height: 150,
                    color: Colors.grey.withOpacity(0.2),
                    child: const Icon(
                      Icons.image_not_supported,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (event.description != null)
                        Text(
                          event.description!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            'Tarih: ${event.date ?? 'Belirtilmemiş'}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      if (event.location != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on, size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                'Yer: ${event.location}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
    
    // Gerçek etkinlikleri kullan
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                event.imageUrl ?? widget.cityProfile.demoEventImageUrl,
                width: double.infinity,
                height: 150,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: double.infinity,
                  height: 150,
                  color: Colors.grey.withOpacity(0.2),
                  child: const Icon(
                    Icons.image_not_supported,
                    size: 50,
                    color: Colors.grey,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (event.description != null)
                      Text(
                        event.description!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          'Tarih: ${event.date ?? 'Belirtilmemiş'}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    if (event.location != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              'Yer: ${event.location}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // İstatistikler sekmesi
  Widget _buildStatsTab() {
    final stats = widget.cityProfile.stats;
    
    // Demo istatistikler oluştur
    if (stats == null || stats.isEmpty) {
      // Demo istatistik listesi
      final demoStats = [
        // Demografi istatistikleri
        CityStat(
          id: 1,
          cityId: widget.cityProfile.id,
          name: 'Kadın Nüfus Oranı',
          title: 'Kadın Nüfus Oranı',
          value: '%51.2',
          type: 'demografi',
        ),
        CityStat(
          id: 2,
          cityId: widget.cityProfile.id,
          name: 'Erkek Nüfus Oranı',
          title: 'Erkek Nüfus Oranı',
          value: '%48.8',
          type: 'demografi',
        ),
        CityStat(
          id: 3,
          cityId: widget.cityProfile.id,
          name: 'Yaş Ortalaması',
          title: 'Yaş Ortalaması',
          value: '32.4',
          type: 'demografi',
        ),
        CityStat(
          id: 4,
          cityId: widget.cityProfile.id,
          name: 'Nüfus Artış Hızı',
          title: 'Nüfus Artış Hızı',
          value: '%1.8',
          type: 'demografi',
        ),
        
        // Eğitim istatistikleri
        CityStat(
          id: 5,
          cityId: widget.cityProfile.id,
          name: 'Okur-Yazarlık',
          title: 'Okur-Yazarlık',
          value: '%98.5',
          type: 'egitim',
        ),
        CityStat(
          id: 6,
          cityId: widget.cityProfile.id,
          name: 'Yüksekokul Mezunu',
          title: 'Yüksekokul Mezunu',
          value: '%32.7',
          type: 'egitim',
        ),
        CityStat(
          id: 7,
          cityId: widget.cityProfile.id,
          name: 'Lise Mezunu',
          title: 'Lise Mezunu',
          value: '%45.3',
          type: 'egitim',
        ),
        CityStat(
          id: 8,
          cityId: widget.cityProfile.id,
          name: 'İlkokul Mezunu',
          title: 'İlkokul Mezunu',
          value: '%22.0',
          type: 'egitim',
        ),
        
        // Ekonomi istatistikleri
        CityStat(
          id: 9,
          cityId: widget.cityProfile.id,
          name: 'İşsizlik Oranı',
          title: 'İşsizlik Oranı',
          value: '%6.8',
          type: 'ekonomi',
        ),
        CityStat(
          id: 10,
          cityId: widget.cityProfile.id,
          name: 'Kişi Başı Milli Gelir',
          title: 'Kişi Başı Milli Gelir',
          value: '22345 TL',
          type: 'ekonomi',
        ),
        CityStat(
          id: 11,
          cityId: widget.cityProfile.id,
          name: 'Yıllık Ekonomik Büyüme',
          title: 'Yıllık Ekonomik Büyüme',
          value: '%4.2',
          type: 'ekonomi',
        ),
        CityStat(
          id: 12,
          cityId: widget.cityProfile.id,
          name: 'Turizm Geliri',
          title: 'Turizm Geliri',
          value: '18500000 TL',
          type: 'ekonomi',
        ),
        
        // Altyapı istatistikleri
        CityStat(
          id: 13,
          cityId: widget.cityProfile.id,
          name: 'Temiz Su Erişimi',
          title: 'Temiz Su Erişimi',
          value: '%98.2',
          type: 'altyapi',
        ),
        CityStat(
          id: 14,
          cityId: widget.cityProfile.id,
          name: 'Kanalizasyon Altyapısı',
          title: 'Kanalizasyon Altyapısı',
          value: '%97.5',
          type: 'altyapi',
        ),
        CityStat(
          id: 15,
          cityId: widget.cityProfile.id,
          name: 'Yol Ağı',
          title: 'Yol Ağı',
          value: '1250 km',
          type: 'altyapi',
        ),
        CityStat(
          id: 16,
          cityId: widget.cityProfile.id,
          name: 'İnternet Erişimi',
          title: 'İnternet Erişimi',
          value: '%93.8',
          type: 'altyapi',
        ),
      ];
      
      // İstatistikleri kategorilere göre grupla
      final demografiStats = demoStats.where((stat) => stat.type == 'demografi').toList();
      final ekonomiStats = demoStats.where((stat) => stat.type == 'ekonomi').toList();
      final egitimStats = demoStats.where((stat) => stat.type == 'egitim').toList();
      final altyapiStats = demoStats.where((stat) => stat.type == 'altyapi').toList();
      
      // Eğitim istatistiklerini grafik için hazırla
      final Map<String, double> egitimData = {};
      for (var stat in egitimStats) {
        if (stat.value != null) {
          double? value = double.tryParse(stat.value!.replaceAll(',', '.').replaceAll('%', ''));
          if (value != null) {
            egitimData[stat.name] = value;
          }
        }
      }
      
      // Altyapı istatistiklerini grafik için hazırla
      final Map<String, double> altyapiData = {};
      for (var stat in altyapiStats) {
        if (stat.value != null) {
          double? value = double.tryParse(stat.value!.replaceAll(',', '.').replaceAll('%', ''));
          if (value != null) {
            altyapiData[stat.name] = value;
          }
        }
      }
      
      // Ekonomi istatistiklerini grafik için hazırla
      final Map<String, double> ekonomiData = {};
      for (var stat in ekonomiStats) {
        if (stat.value != null) {
          double? value = double.tryParse(stat.value!.replaceAll(',', '.').replaceAll('%', '').replaceAll('TL', '').trim());
          if (value != null) {
            ekonomiData[stat.name] = value;
          }
        }
      }
      
      // Çözüm istatistikleri
      final Map<String, double> cozumVerileri = {
        'Çözülen': widget.cityProfile.totalSolvedIssues.toDouble(),
        'Bekleyen': (widget.cityProfile.totalPosts - widget.cityProfile.totalSolvedIssues).toDouble(),
      };
      
      return ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Belediye Performans Göstergeleri
          if (cozumVerileri.isNotEmpty)
            CityStatsChart(
              data: cozumVerileri,
              title: 'Belediye Şikayet Çözüm Durumu',
              description: 'Belediyeye iletilen şikayetlerin çözüm durumu',
              gradientColors: [Colors.orange, Colors.deepOrange],
            ),
          const SizedBox(height: 24),
          
          // Eğitim İstatistik Grafiği
          if (egitimData.isNotEmpty)
            RadarCityStatsChart(
              data: egitimData,
              title: 'Eğitim Durumu',
              description: 'Şehrin eğitim alanındaki göstergeleri',
              fillColor: const Color(0x402196F3),
              borderColor: Colors.blue,
            ),
          const SizedBox(height: 24),
          
          // Ekonomi İstatistik Grafiği
          if (ekonomiData.isNotEmpty)
            CityStatsChart(
              data: ekonomiData,
              title: 'Ekonomik Göstergeler',
              description: 'Şehrin ekonomik performans göstergeleri',
              gradientColors: [Colors.green.shade300, Colors.green.shade700],
            ),
          const SizedBox(height: 24),
          const Text(
            'Genel İstatistikler',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Nüfus Bilgileri
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Demografi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildStatItem(
                    'Toplam Nüfus',
                    '${widget.cityProfile.population} kişi',
                    Icons.people,
                  ),
                  ...demografiStats.map((stat) => 
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: _buildStatItem(
                        stat.name,
                        stat.value ?? 'Belirtilmemiş',
                        _getIconForStatType(stat.type),
                      ),
                    )
                  ).toList(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Ekonomi Bilgileri
          if (ekonomiStats.isNotEmpty)
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ekonomi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...ekonomiStats.map((stat) => 
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: _buildStatItem(
                          stat.name,
                          stat.value ?? 'Belirtilmemiş',
                          _getIconForStatType(stat.type),
                        ),
                      )
                    ).toList(),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          
          // Eğitim Bilgileri
          if (egitimStats.isNotEmpty)
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Eğitim',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...egitimStats.map((stat) => 
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: _buildStatItem(
                          stat.name,
                          stat.value ?? 'Belirtilmemiş',
                          _getIconForStatType(stat.type),
                        ),
                      )
                    ).toList(),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          
          // Altyapı Bilgileri
          if (altyapiStats.isNotEmpty)
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Altyapı ve Ulaşım',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...altyapiStats.map((stat) => 
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: _buildStatItem(
                          stat.name,
                          stat.value ?? 'Belirtilmemiş',
                          _getIconForStatType(stat.type),
                        ),
                      )
                    ).toList(),
                  ],
                ),
              ),
            ),
        ],
      );
    }
    
    // Gerçek istatistikleri kullan
    // İstatistikleri kategorilere göre grupla
    final demografiStats = stats.where((stat) => stat.type == 'demografi').toList();
    final ekonomiStats = stats.where((stat) => stat.type == 'ekonomi').toList();
    final egitimStats = stats.where((stat) => stat.type == 'egitim').toList();
    final altyapiStats = stats.where((stat) => stat.type == 'altyapi').toList();
    
    // Eğitim istatistiklerini grafik için hazırla
    final Map<String, double> egitimData = {};
    for (var stat in egitimStats) {
      if (stat.value != null) {
        double? value = double.tryParse(stat.value!.replaceAll(',', '.').replaceAll('%', ''));
        if (value != null) {
          egitimData[stat.name] = value;
        }
      }
    }
    
    // Altyapı istatistiklerini grafik için hazırla
    final Map<String, double> altyapiData = {};
    for (var stat in altyapiStats) {
      if (stat.value != null) {
        double? value = double.tryParse(stat.value!.replaceAll(',', '.').replaceAll('%', ''));
        if (value != null) {
          altyapiData[stat.name] = value;
        }
      }
    }
    
    // Ekonomi istatistiklerini grafik için hazırla
    final Map<String, double> ekonomiData = {};
    for (var stat in ekonomiStats) {
      if (stat.value != null) {
        double? value = double.tryParse(stat.value!.replaceAll(',', '.').replaceAll('%', '').replaceAll('TL', '').trim());
        if (value != null) {
          ekonomiData[stat.name] = value;
        }
      }
    }
    
    // Çözüm istatistikleri
    final Map<String, double> cozumVerileri = {
      'Çözülen': widget.cityProfile.totalSolvedIssues.toDouble(),
      'Bekleyen': (widget.cityProfile.totalPosts - widget.cityProfile.totalSolvedIssues).toDouble(),
    };
    
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Belediye Performans Göstergeleri
        if (cozumVerileri.isNotEmpty)
          CityStatsChart(
            data: cozumVerileri,
            title: 'Belediye Şikayet Çözüm Durumu',
            description: 'Belediyeye iletilen şikayetlerin çözüm durumu',
            gradientColors: [Colors.orange, Colors.deepOrange],
          ),
        const SizedBox(height: 24),
        
        // Eğitim İstatistik Grafiği
        if (egitimData.isNotEmpty)
          RadarCityStatsChart(
            data: egitimData,
            title: 'Eğitim Durumu',
            description: 'Şehrin eğitim alanındaki göstergeleri',
            fillColor: const Color(0x402196F3),
            borderColor: Colors.blue,
          ),
        const SizedBox(height: 24),
        
        // Ekonomi İstatistik Grafiği
        if (ekonomiData.isNotEmpty)
          CityStatsChart(
            data: ekonomiData,
            title: 'Ekonomik Göstergeler',
            description: 'Şehrin ekonomik performans göstergeleri',
            gradientColors: [Colors.green.shade300, Colors.green.shade700],
          ),
        const SizedBox(height: 24),
        const Text(
          'Genel İstatistikler',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Nüfus Bilgileri
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Demografi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildStatItem(
                  'Toplam Nüfus',
                  '${widget.cityProfile.population} kişi',
                  Icons.people,
                ),
                ...demografiStats.map((stat) => 
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: _buildStatItem(
                      stat.name,
                      stat.value ?? 'Belirtilmemiş',
                      _getIconForStatType(stat.type),
                    ),
                  )
                ).toList(),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Ekonomi Bilgileri
        if (ekonomiStats.isNotEmpty)
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ekonomi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...ekonomiStats.map((stat) => 
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: _buildStatItem(
                        stat.name,
                        stat.value ?? 'Belirtilmemiş',
                        _getIconForStatType(stat.type),
                      ),
                    )
                  ).toList(),
                ],
              ),
            ),
          ),
        const SizedBox(height: 16),
        
        // Eğitim Bilgileri
        if (egitimStats.isNotEmpty)
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Eğitim',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...egitimStats.map((stat) => 
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: _buildStatItem(
                        stat.name,
                        stat.value ?? 'Belirtilmemiş',
                        _getIconForStatType(stat.type),
                      ),
                    )
                  ).toList(),
                ],
              ),
            ),
          ),
        const SizedBox(height: 16),
        
        // Altyapı Bilgileri
        if (altyapiStats.isNotEmpty)
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Altyapı ve Ulaşım',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...altyapiStats.map((stat) => 
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: _buildStatItem(
                        stat.name,
                        stat.value ?? 'Belirtilmemiş',
                        _getIconForStatType(stat.type),
                      ),
                    )
                  ).toList(),
                ],
              ),
            ),
          ),
      ],
    );
  }
  
  // İstatistik tipi için ikon döndürür
  IconData _getIconForStatType(String type) {
    switch (type.toLowerCase()) {
      case 'demografi':
      case 'nufus':
        return Icons.people;
      case 'egitim':
        return Icons.school;
      case 'ekonomi':
        return Icons.attach_money;
      case 'altyapi':
        return Icons.build;
      case 'ulasim':
        return Icons.directions_bus;
      case 'yesilalan':
      case 'cevre':
        return Icons.park;
      case 'su':
        return Icons.water_drop;
      default:
        return Icons.info;
    }
  }

  // Öncelikler sekmesi
  Widget _buildPrioritiesTab() {
    final priorityData = widget.cityProfile.priorityData;
    
    // Demo öncelik verileri oluştur
    if (priorityData == null || priorityData.isEmpty) {
      // Demo öncelik verileri
      final demoPriorityData = {
        'Altyapı Yatırımları': 25.0,
        'Ulaşım ve Trafik': 20.0,
        'Sosyal Hizmetler': 18.0,
        'Çevre ve Yeşil Alanlar': 15.0,
        'Kültür ve Sanat': 12.0,
        'Eğitim Destekleri': 10.0,
      };
      
      return ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Belediye Öncelikleri',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Aşağıdaki grafikte belediyenin öncelik verdiği alanlar ve bunlara ayrılan bütçe oranları gösterilmektedir.',
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 24),
          
          CityPriorityChart(priorityData: demoPriorityData),
        ],
      );
    }
    
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text(
          'Belediye Öncelikleri',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Aşağıdaki grafikte belediyenin öncelik verdiği alanlar ve bunlara ayrılan bütçe oranları gösterilmektedir.',
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
        const SizedBox(height: 24),
        
        CityPriorityChart(priorityData: priorityData),
      ],
    );
  }

  // İstatistik öğesi oluşturur
  Widget _buildStatItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 3,
            spreadRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon, 
              size: 20, 
              color: Theme.of(context).primaryColor
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: Colors.grey.shade400,
          ),
        ],
      ),
    );
  }

  // Proje durumuna göre renk döndürür
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'tamamlandı':
        return Colors.green;
      case 'inProgress':
      case 'devam ediyor':
        return Colors.blue;
      case 'planned':
      case 'planlama':
        return Colors.orange;
      case 'cancelled':
      case 'ertelendi':
      case 'iptal':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Kategori için icon döndürür
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'altyapı':
        return Icons.build;
      case 'temizlik':
        return Icons.cleaning_services;
      case 'ulaşım':
      case 'ulasim':
        return Icons.directions_bus;
      case 'park ve bahçeler':
      case 'parklar':
        return Icons.nature;
      case 'sosyal hizmetler':
        return Icons.people;
      case 'kültür':
      case 'kultur':
        return Icons.theater_comedy;
      case 'güvenlik':
      case 'guvenlik':
        return Icons.security;
      case 'eğitim':
      case 'egitim':
        return Icons.school;
      case 'sağlık':
      case 'saglik':
        return Icons.local_hospital;
      default:
        return Icons.category;
    }
  }

  // Performans değerine göre renk döndürür
  Color _getPerformanceColor(double performance) {
    if (performance >= 80) {
      return Colors.green;
    } else if (performance >= 60) {
      return Colors.lightGreen;
    } else if (performance >= 40) {
      return Colors.amber;
    } else if (performance >= 20) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}

// TabBar için delegate
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}