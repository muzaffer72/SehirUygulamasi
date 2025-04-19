import 'package:flutter/material.dart';

/// Ana sayfada gösterilen anket slider'ı
class SurveySlider extends StatefulWidget {
  const SurveySlider({Key? key}) : super(key: key);

  @override
  State<SurveySlider> createState() => _SurveySliderState();
}

class _SurveySliderState extends State<SurveySlider> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  final List<Map<String, dynamic>> _surveys = [
    {
      'title': 'Şehir Parkları',
      'description': 'Şehrimizdeki park alanlarının yeterliliği ve bakımı',
      'color': Colors.green[100]!,
      'icon': Icons.park_outlined,
      'iconColor': Colors.green[700]!,
    },
    {
      'title': 'Toplu Taşıma',
      'description': 'Şehirdeki toplu taşıma hizmetlerinin kalitesi',
      'color': Colors.blue[100]!,
      'icon': Icons.directions_bus_outlined,
      'iconColor': Colors.blue[700]!,
    },
    {
      'title': 'Sokak Hayvanları',
      'description': 'Sokak hayvanları için yapılan çalışmalar',
      'color': Colors.orange[100]!,
      'icon': Icons.pets_outlined,
      'iconColor': Colors.orange[700]!,
    },
  ];
  
  @override
  void initState() {
    super.initState();
    // Otomatik slider özelliği
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      _startAutoSlide();
    });
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  void _startAutoSlide() {
    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;
      
      if (_currentPage < _surveys.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
      
      _startAutoSlide();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _surveys.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                final survey = _surveys[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  decoration: BoxDecoration(
                    color: survey['color'],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    children: [
                      // İkon arkaplanı
                      Positioned(
                        right: -40,
                        bottom: -40,
                        child: Icon(
                          survey['icon'],
                          size: 150,
                          color: survey['iconColor'].withOpacity(0.2),
                        ),
                      ),
                      
                      // İçerik
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  survey['icon'],
                                  color: survey['iconColor'],
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  survey['title'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              survey['description'],
                              style: const TextStyle(fontSize: 14),
                            ),
                            const Spacer(),
                            ElevatedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${survey['title']} anketine katılıyorsunuz'),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: survey['iconColor'],
                              ),
                              child: const Text('Ankete Katıl'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _surveys.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                height: 8,
                width: _currentPage == index ? 24 : 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}