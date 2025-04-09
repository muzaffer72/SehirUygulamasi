import 'package:flutter/material.dart';
import 'package:sikayet_var/models/survey.dart';
import 'package:sikayet_var/screens/surveys/survey_detail_screen.dart';
import 'package:sikayet_var/services/api_service.dart';

class SurveySlider extends StatefulWidget {
  const SurveySlider({Key? key}) : super(key: key);

  @override
  State<SurveySlider> createState() => _SurveySliderState();
}

class _SurveySliderState extends State<SurveySlider> {
  final ApiService _apiService = ApiService();
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _apiService.getActiveSurveys(),
      builder: (context, AsyncSnapshot<List<Survey>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingIndicator();
        }
        
        if (snapshot.hasError) {
          return _buildErrorWidget();
        }
        
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink(); // No surveys available
        }
        
        final surveys = snapshot.data!;
        
        return Column(
          children: [
            // Survey header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Anketler',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${_currentPage + 1}/${surveys.length}',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            // Survey carousel
            SizedBox(
              height: 180,
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
            
            // Dot indicators
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(surveys.length, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: _currentPage == index ? 24 : 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildSurveyCard(Survey survey) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SurveyDetailScreen(survey: survey),
            ),
          );
        },
        child: Stack(
          children: [
            // Survey background image
            if (survey.imageUrl != null)
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(survey.imageUrl!),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.3),
                      BlendMode.darken,
                    ),
                  ),
                ),
              ),
            
            // Survey content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Survey title
                  Text(
                    survey.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: survey.imageUrl != null ? Colors.white : theme.colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  
                  // Survey description
                  Text(
                    survey.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: survey.imageUrl != null 
                        ? Colors.white.withOpacity(0.8) 
                        : theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  
                  // Survey participation info
                  Row(
                    children: [
                      const Icon(
                        Icons.how_to_vote,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${survey.totalVotes} oy',
                        style: TextStyle(
                          fontSize: 14,
                          color: survey.imageUrl != null 
                            ? Colors.white 
                            : theme.colorScheme.onSurface,
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => SurveyDetailScreen(survey: survey),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Katıl'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLoadingIndicator() {
    return Container(
      height: 180,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
  
  Widget _buildErrorWidget() {
    return Container(
      height: 180,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.grey, size: 40),
            const SizedBox(height: 8),
            Text(
              'Anketler yüklenirken bir hata oluştu',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}