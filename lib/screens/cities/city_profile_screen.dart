import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';
import '../../models/city_profile.dart';
import '../../widgets/best_municipality_banner.dart';
import '../../widgets/city_priority_chart.dart';
import '../../widgets/monthly_performance_card.dart';

class CityProfileScreen extends StatefulWidget {
  final CityProfile cityProfile;

  const CityProfileScreen({Key? key, required this.cityProfile}) : super(key: key);

  @override
  State<CityProfileScreen> createState() => _CityProfileScreenState();
}

class _CityProfileScreenState extends State<CityProfileScreen> with SingleTickerProviderStateMixin {
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
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            // App Bar
            SliverAppBar(
              expandedHeight: 200.0,
              floating: false,
              pinned: true,
              backgroundColor: Theme.of(context).primaryColor,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text(
                  widget.cityProfile.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: _buildHeaderBackground(),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () {
                    // Paylaşım fonksiyonelliği
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.star),
                  onPressed: () {
                    // Favorilere ekleme fonksiyonelliği
                  },
                ),
              ],
            ),
            // Bilgi Başlığı
            SliverToBoxAdapter(
              child: _buildInfoHeader(),
            ),
            // Ay'ın Belediyesi Banner'ı (varsa)
            if (_hasAward)
              SliverToBoxAdapter(
                child: BestMunicipalityBanner(
                  cityName: widget.cityProfile.name,
                  awardText: widget.cityProfile.awardText!,
                  awardMonth: widget.cityProfile.awardMonth ?? '',
                  awardScore: widget.cityProfile.awardScore != null ? widget.cityProfile.awardScore!.toInt() : null,
                ),
              ),
            // Tab Bar
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: Theme.of(context).primaryColor,
                  unselectedLabelColor: Colors.grey,
                  tabs: const [
                    Tab(icon: Icon(Icons.build), text: 'Hizmetler'),
                    Tab(icon: Icon(Icons.trending_up), text: 'Projeler'),
                    Tab(icon: Icon(Icons.event), text: 'Etkinlikler'),
                    Tab(icon: Icon(Icons.insert_chart), text: 'İstatistikler'),
                    Tab(icon: Icon(Icons.priority_high), text: 'Öncelikler'),
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
            _buildServicesTab(),
            _buildProjectsTab(),
            _buildEventsTab(),
            _buildStatsTab(),
            _buildPrioritiesTab(),
          ],
        ),
      ),
    );
  }

  // Header arkaplanını oluşturur
  Widget _buildHeaderBackground() {
    final background = widget.cityProfile.coverImageUrl != null
        ? Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                widget.cityProfile.coverImageUrl!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => 
                  Container(
                    height: 200,
                    color: Theme.of(context).primaryColor.withOpacity(0.05),
                  ),
              ),
              // Gradiant overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
            ],
          )
        : Container(
            color: Theme.of(context).primaryColor.withOpacity(0.05),
          );
    
    return Stack(
      children: [
        // Arka plan
        background,
        
        // İçerik
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Sol kısım: Parti logosu
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.cityProfile.mayorPartyLogo != null)
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Image.network(
                              widget.cityProfile.mayorPartyLogo!,
                              width: 60,
                              height: 60,
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                Icons.image_not_supported,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        const SizedBox(height: 8),
                        if (widget.cityProfile.mayorParty != null)
                          Text(
                            widget.cityProfile.mayorParty!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  // Orta kısım: Şehir logosu/arması
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.cityProfile.imageUrl != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              widget.cityProfile.imageUrl!,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey.withOpacity(0.3),
                                child: const Icon(
                                  Icons.location_city,
                                  size: 50,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  // Sağ kısım: Nüfus bilgisi
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.people,
                          color: Colors.white,
                          size: 30,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${widget.cityProfile.population.toString()} kişi',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Bilgi başlığını oluşturur
  Widget _buildInfoHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Belediye Başkanı Bilgisi
          if (widget.cityProfile.mayorName != null)
            Row(
              children: [
                const Icon(Icons.person, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                const Text(
                  'Belediye Başkanı:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  widget.cityProfile.mayorName!,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          
          const SizedBox(height: 8),
          
          // Bölge Bilgisi
          Row(
            children: [
              const Icon(Icons.location_on, size: 20, color: Colors.grey),
              const SizedBox(width: 8),
              const Text(
                'Bölge:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                widget.cityProfile.region ?? 'Belirtilmemiş',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Açıklama
          if (widget.cityProfile.description != null &&
              widget.cityProfile.description!.isNotEmpty)
            Text(
              widget.cityProfile.description!,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
              textAlign: TextAlign.justify,
            ),
          
          const SizedBox(height: 16),
          
          // Performans Kartı
          if (widget.cityProfile.monthlyPerformance != null)
            MonthlyPerformanceCard(
              performance: widget.cityProfile.monthlyPerformance!,
              month: widget.cityProfile.performanceMonth ?? 'Nisan',
              year: widget.cityProfile.performanceYear ?? '2024',
            ),
        ],
      ),
    );
  }

  // Hizmetler sekmesi
  Widget _buildServicesTab() {
    final services = widget.cityProfile.services ?? [];
    
    if (services.isEmpty) {
      return const Center(
        child: Text('Henüz hizmet bilgisi bulunmuyor.'),
      );
    }
    
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
            trailing: service.isAvailable
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
    
    if (projects.isEmpty) {
      return const Center(
        child: Text('Henüz proje bilgisi bulunmuyor.'),
      );
    }
    
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
              if (project.imageUrl != null)
                Image.network(
                  project.imageUrl!,
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
                            color: _getStatusColor(project.status ?? 'planlama'),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getStatusText(project.status ?? 'planlama'),
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
                              'Bütçe: ${project.budget} TL',
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
    
    if (events.isEmpty) {
      return const Center(
        child: Text('Henüz etkinlik bilgisi bulunmuyor.'),
      );
    }
    
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
              if (event.imageUrl != null)
                Image.network(
                  event.imageUrl!,
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
    
    if (stats == null || stats.isEmpty) {
      return const Center(
        child: Text('Henüz istatistik bilgisi bulunmuyor.'),
      );
    }
    
    // İstatistikleri kategorilere göre grupla
    final demografiStats = stats.where((stat) => stat.type == 'demografi').toList();
    final ekonomiStats = stats.where((stat) => stat.type == 'ekonomi').toList();
    final egitimStats = stats.where((stat) => stat.type == 'egitim').toList();
    final altyapiStats = stats.where((stat) => stat.type == 'altyapi').toList();
    
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Genel İstatistikler
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
    
    if (priorityData == null || priorityData.isEmpty) {
      return const Center(
        child: Text('Henüz öncelik bilgisi bulunmuyor.'),
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
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).primaryColor),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  // Proje durumuna göre renk döndürür
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'tamamlandı':
        return Colors.green;
      case 'devam ediyor':
        return Colors.blue;
      case 'planlama':
        return Colors.orange;
      case 'ertelendi':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Proje durumunu formatlar
  String _getStatusText(String status) {
    // Türkçe karakterler ve büyük/küçük harf düzeltmeleri
    switch (status.toLowerCase()) {
      case 'tamamlandi':
      case 'tamamlandı':
        return 'Tamamlandı';
      case 'devam ediyor':
      case 'devamediyor':
      case 'devam':
        return 'Devam Ediyor';
      case 'planlama':
      case 'plan':
        return 'Planlama';
      case 'ertelendi':
      case 'iptal':
        return 'Ertelendi';
      default:
        return status;
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