import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/app_shimmer.dart';

class Survey {
  final String id;
  final String title;
  final String description;
  final String cityName;
  final String districtName;
  final DateTime endDate;
  final int responseCount;
  final bool isActive;
  
  const Survey({
    required this.id,
    required this.title,
    required this.description,
    required this.cityName,
    required this.districtName,
    required this.endDate,
    required this.responseCount,
    required this.isActive,
  });
}

// Örnek anketler
final _sampleSurveys = [
  Survey(
    id: '1',
    title: 'Şehrimizin Park Alanları Hakkında',
    description: 'Şehrimizdeki park alanlarının yeterliliği ve bakımı hakkında görüşlerinizi bildirin.',
    cityName: 'İstanbul',
    districtName: 'Kadıköy',
    endDate: DateTime.now().add(const Duration(days: 5)),
    responseCount: 234,
    isActive: true,
  ),
  Survey(
    id: '2',
    title: 'Toplu Taşıma Kullanım Alışkanlıkları',
    description: 'Şehrimizde toplu taşıma kullanım alışkanlıklarını ve iyileştirme önerilerinizi öğrenmek istiyoruz.',
    cityName: 'İstanbul',
    districtName: 'Tüm İlçeler',
    endDate: DateTime.now().add(const Duration(days: 10)),
    responseCount: 512,
    isActive: true,
  ),
  Survey(
    id: '3',
    title: 'Çöp Toplama Saatleri',
    description: 'Mahallelerde çöp toplama saatleri hakkında görüşlerinizi bildirin.',
    cityName: 'Ankara',
    districtName: 'Çankaya',
    endDate: DateTime.now().add(const Duration(days: 3)),
    responseCount: 189,
    isActive: true,
  ),
  Survey(
    id: '4',
    title: 'Sokak Hayvanları Çalışmaları',
    description: 'Sokak hayvanları için yapılan çalışmalar hakkında görüşlerinizi öğrenmek istiyoruz.',
    cityName: 'İzmir',
    districtName: 'Karşıyaka',
    endDate: DateTime.now().add(const Duration(days: 7)),
    responseCount: 321,
    isActive: true,
  ),
  Survey(
    id: '5',
    title: 'Yol ve Kaldırım Kalitesi',
    description: 'Şehrimizdeki yolların ve kaldırımların kalitesi hakkında görüşlerinizi bildirin.',
    cityName: 'Bursa',
    districtName: 'Nilüfer',
    endDate: DateTime.now().add(const Duration(days: 12)),
    responseCount: 176,
    isActive: true,
  ),
  Survey(
    id: '6',
    title: 'Şehir İçi Otopark İhtiyacı',
    description: 'Şehir merkezlerindeki otopark ihtiyacı ve çözüm önerileri hakkında görüşlerinizi paylaşın.',
    cityName: 'Antalya',
    districtName: 'Muratpaşa',
    endDate: DateTime.now().subtract(const Duration(days: 2)),
    responseCount: 412,
    isActive: false,
  ),
  Survey(
    id: '7',
    title: 'Yeşil Alan Kullanımı',
    description: 'Şehrimizdeki yeşil alanların kullanımı ve iyileştirme önerileri hakkında görüşlerinizi bildirin.',
    cityName: 'Adana',
    districtName: 'Seyhan',
    endDate: DateTime.now().subtract(const Duration(days: 5)),
    responseCount: 143,
    isActive: false,
  ),
];

// Survey provider
final surveysProvider = FutureProvider<List<Survey>>((ref) async {
  // Gerçek bir API'den veri çekilecek, şimdilik örnek veri dönüyoruz
  await Future.delayed(const Duration(seconds: 1)); // Simüle edilmiş network gecikmesi
  return _sampleSurveys;
});

// Aktif filtre değeri için provider
final activeSurveyFilterProvider = StateProvider<bool>((ref) => true);

class SurveysScreen extends ConsumerWidget {
  const SurveysScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surveysAsync = ref.watch(surveysProvider);
    final showOnlyActive = ref.watch(activeSurveyFilterProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anketler'),
        elevation: 0.5,
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog(context, ref, showOnlyActive);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtre göstergesi
          if (showOnlyActive)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: Row(
                children: [
                  const Icon(Icons.filter_alt, size: 16),
                  const SizedBox(width: 8),
                  const Text('Sadece aktif anketler gösteriliyor'),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => ref.read(activeSurveyFilterProvider.notifier).state = false,
                    child: const Icon(Icons.close, size: 16),
                  ),
                ],
              ),
            ),
          
          // Anket listesi
          Expanded(
            child: surveysAsync.when(
              data: (surveys) {
                // Filtre uygula
                final filteredSurveys = showOnlyActive
                    ? surveys.where((s) => s.isActive).toList()
                    : surveys;
                
                if (filteredSurveys.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.poll_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Henüz anket bulunmuyor',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: filteredSurveys.length,
                  itemBuilder: (context, index) {
                    final survey = filteredSurveys[index];
                    return _buildSurveyCard(context, survey);
                  },
                );
              },
              loading: () => _buildLoadingShimmer(),
              error: (error, stack) => _buildErrorWidget(context, error),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSurveyCard(BuildContext context, Survey survey) {
    final daysLeft = survey.isActive
        ? survey.endDate.difference(DateTime.now()).inDays
        : 0;
    
    final bool isEnding = daysLeft <= 3 && daysLeft > 0;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: survey.isActive
              ? isEnding
                  ? Colors.amber.withOpacity(0.5)
                  : Colors.green.withOpacity(0.3)
              : Colors.grey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Anket üst bölümü
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: survey.isActive
                  ? isEnding
                      ? Colors.amber.withOpacity(0.1)
                      : Colors.green.withOpacity(0.05)
                  : Colors.grey.withOpacity(0.05),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: survey.isActive
                        ? isEnding
                            ? Colors.amber.withOpacity(0.2)
                            : Colors.green.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.poll_outlined,
                    color: survey.isActive
                        ? isEnding
                            ? Colors.amber[700]
                            : Colors.green[700]
                        : Colors.grey[700],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        survey.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${survey.cityName} - ${survey.districtName}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Anket açıklaması
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              survey.description,
              style: const TextStyle(fontSize: 15),
            ),
          ),
          
          // Anket bilgileri
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Katılım sayısı
                Row(
                  children: [
                    const Icon(Icons.people_outline, size: 16),
                    const SizedBox(width: 4),
                    Text('${survey.responseCount} katılımcı'),
                  ],
                ),
                
                // Kalan süre
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: survey.isActive
                        ? isEnding
                            ? Colors.amber.withOpacity(0.2)
                            : Colors.green.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    survey.isActive
                        ? isEnding
                            ? daysLeft == 0
                                ? 'Bugün bitiyor'
                                : '$daysLeft gün kaldı'
                            : '${daysLeft} gün kaldı'
                        : 'Sona erdi',
                    style: TextStyle(
                      color: survey.isActive
                          ? isEnding
                              ? Colors.amber[700]
                              : Colors.green[700]
                          : Colors.grey[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Katıl butonu
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: survey.isActive
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${survey.title} anketine katılıyorsunuz')),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: survey.isActive
                      ? isEnding
                          ? Colors.amber[600]
                          : Theme.of(context).colorScheme.primary
                      : Colors.grey,
                  disabledForegroundColor: Colors.white54,
                  disabledBackgroundColor: Colors.grey,
                ),
                child: Text(survey.isActive ? 'Ankete Katıl' : 'Anket Sona Erdi'),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showFilterDialog(BuildContext context, WidgetRef ref, bool currentValue) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Anket Filtresi'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CheckboxListTile(
                    title: const Text('Sadece aktif anketleri göster'),
                    value: currentValue,
                    onChanged: (value) {
                      setState(() {
                        currentValue = value!;
                      });
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(activeSurveyFilterProvider.notifier).state = currentValue;
                Navigator.pop(context);
              },
              child: const Text('Uygula'),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildLoadingShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: AppShimmer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 80,
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const CircleAvatar(radius: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 16,
                              width: 150,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 12,
                              width: 100,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 14, width: double.infinity),
                      SizedBox(height: 8),
                      SizedBox(height: 14, width: double.infinity),
                      SizedBox(height: 8),
                      SizedBox(height: 14, width: 200),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 12,
                        width: 80,
                        color: Colors.white,
                      ),
                      Container(
                        height: 24,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: Container(
                    height: 40,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildErrorWidget(BuildContext context, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          const Text(
            'Anketler yüklenirken bir hata oluştu',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error.toString(),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          Consumer(
            builder: (context, ref, child) {
              return ElevatedButton(
                onPressed: () {
                  // Veriyi yeniden yükleme (Riverpod yöntemi)
                  ref.refresh(surveysProvider);
                },
                child: const Text('Tekrar Dene'),
              );
            },
          ),
        ],
      ),
    );
  }
}