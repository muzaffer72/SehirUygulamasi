import 'package:flutter/material.dart';
import 'package:sikayet_var/models/survey.dart';
import 'package:sikayet_var/screens/surveys/survey_detail_screen.dart';
import 'package:sikayet_var/services/api_service.dart';
import 'dart:async';

class SurveySlider extends StatefulWidget {
  // Yeni özellik: Anket türü (şehir/ilçe filtrelemesi için)
  final String? filterType;

  const SurveySlider({Key? key, this.filterType}) : super(key: key);

  @override
  State<SurveySlider> createState() => _SurveySliderState();
}

class _SurveySliderState extends State<SurveySlider> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  final PageController _pageController = PageController();
  late AnimationController _textAnimationController;
  late Timer _timer;
  int _currentPage = 0;
  int _textScrollIndex = 0;
  
  @override
  void initState() {
    super.initState();
    
    // Metin animasyonu için controller
    _textAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
    
    // Her 4 saniyede bir metin değişimi için timer
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      setState(() {
        _textScrollIndex++;
      });
    });
  }
  
  @override
  void dispose() {
    _timer.cancel();
    _textAnimationController.dispose();
    _pageController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180, // Daha küçük bir yükseklik
      child: FutureBuilder<List<Survey>>(
        future: widget.filterType == 'city' 
          ? _apiService.getActiveSurveysByType('city')
          : widget.filterType == 'district'
            ? _apiService.getActiveSurveysByType('district')
            : _apiService.getActiveSurveys(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Text('Hata: ${snapshot.error}'),
            );
          }
          
          final surveys = snapshot.data ?? [];
          
          if (surveys.isEmpty) {
            return const Center(
              child: Text('Aktif anket bulunmuyor'),
            );
          }
          
          return Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: surveys.length,
                  onPageChanged: (int page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  itemBuilder: (context, index) {
                    final survey = surveys[index];
                    return _buildSurveyCard(survey);
                  },
                ),
              ),
              
              // Page indicator
              if (surveys.length > 1)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      surveys.length,
                      (index) => _buildDotIndicator(index, surveys.length),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildSurveyCard(Survey survey) {
    // Kalan süre bilgisini model üzerinden al
    String remainingTime = survey.getRemainingTimeText();
    final bool isSurveyExpired = survey.endDate.isBefore(DateTime.now());
    
    // Katılım oranını modelden al
    final double participationRate = survey.getParticipationRate();
    
    // Katılım oranına göre arka plan rengini belirle
    Color startColor;
    Color endColor;
    
    if (isSurveyExpired) {
      // Sona ermiş anket - gri tonlar
      startColor = const Color(0xFF9E9E9E); 
      endColor = const Color(0xFF616161);
    } else if (participationRate < 0.3) {
      // Düşük katılım - kırmızı tonlar
      startColor = const Color(0xFFEF9A9A);
      endColor = const Color(0xFFC62828);
    } else if (participationRate < 0.7) {
      // Orta katılım - turuncu-sarı tonlar
      startColor = const Color(0xFFFFD54F);
      endColor = const Color(0xFFEF6C00);
    } else {
      // Yüksek katılım - yeşil tonlar
      startColor = const Color(0xFFA5D6A7);
      endColor = const Color(0xFF2E7D32);
    }
    
    // Animasyon için metinler - daha kısa ve özlü
    final List<String> animationTexts = [
      "%${(participationRate * 100).toStringAsFixed(1)} katılım oranı",
      "${survey.totalVotes}/${survey.totalUsers} kişi katıldı",
    ];
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SurveyDetailScreen(survey: survey),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.all(16),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          height: 100, // Daha da küçük yükseklik
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                startColor, // Katılım oranına göre belirlenen renkler
                endColor,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12), // Daha az padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Survey title ve süre bilgisi
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        survey.shortTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Saat ikonu veya sona erme ikonu
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSurveyExpired ? Icons.check_circle_outline : Icons.access_time_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                          if (!isSurveyExpired) ...[
                            const SizedBox(width: 4),
                            Text(
                              remainingTime,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Açıklamayı kaldırıyoruz, sadece katılım grafiği gösteriyoruz
                const SizedBox(height: 8),
                
                // Katılım oranı göstergesi
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Katılım: ${(participationRate * 100).toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '${survey.totalVotes}/${survey.totalUsers}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Stack(
                      children: [
                        // Zemin çubuk
                        Container(
                          height: 6,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        // Dolu kısım
                        FractionallySizedBox(
                          widthFactor: participationRate.clamp(0.0, 1.0), // 0-1 arasında olmasını sağla
                          child: Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                // "Ankete Katıl" butonu kaldırıldı, tüm kart tıklanabilir
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildDotIndicator(int index, int count) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? Theme.of(context).colorScheme.primary
            : Colors.grey.withOpacity(0.5),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}