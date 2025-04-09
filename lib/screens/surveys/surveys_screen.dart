import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sikayet_var/models/category.dart';
import 'package:sikayet_var/models/city.dart';
import 'package:sikayet_var/models/district.dart';
import 'package:sikayet_var/models/survey.dart';
import 'package:sikayet_var/providers/survey_provider.dart';
import 'package:sikayet_var/providers/auth_provider.dart';
import 'package:sikayet_var/services/api_service.dart';
import 'package:sikayet_var/providers/user_provider.dart';

class SurveysScreen extends ConsumerStatefulWidget {
  const SurveysScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SurveysScreen> createState() => _SurveysScreenState();
}

class _SurveysScreenState extends ConsumerState<SurveysScreen> {
  final ApiService _apiService = ApiService();
  
  @override
  Widget build(BuildContext context) {
    // Kullanıcının konumuna göre filtrelenmiş anketleri kullan
    final surveysAsync = ref.watch(filteredSurveysProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anketler'),
        actions: [
          // Filtreleme bilgisi
          Consumer(
            builder: (context, ref, child) {
              final userAsync = ref.watch(currentUserProvider);
              if (userAsync is AsyncData && userAsync.value != null) {
                final user = userAsync.value!;
                return IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Filtreleme Bilgisi'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Anketler konum bilginize göre filtreleniyor:'),
                            const SizedBox(height: 12),
                            if (user.cityId != null) FutureBuilder<City>(
                              future: _apiService.getCityById(user.cityId!),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Text('Şehir: ${snapshot.data!.name}');
                                }
                                return const Text('Şehir: Yükleniyor...');
                              },
                            ),
                            if (user.districtId != null) FutureBuilder<District>(
                              future: _apiService.getDistrictById(user.districtId!),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Text('İlçe: ${snapshot.data!.name}');
                                }
                                return const Text('İlçe: Yükleniyor...');
                              },
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Tamam'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: surveysAsync.when(
        data: (surveys) {
          if (surveys.isEmpty) {
            return _buildEmptyState();
          }
          
          return RefreshIndicator(
            onRefresh: () async {
              ref.refresh(filteredSurveysProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: surveys.length,
              itemBuilder: (context, index) {
                final survey = surveys[index];
                return _buildSurveyCard(survey);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  'Anketler yüklenirken bir hata oluştu',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    ref.refresh(filteredSurveysProvider);
                  },
                  child: const Text('Tekrar Dene'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.how_to_vote_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Henüz aktif anket bulunmuyor',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Yakında yeni anketler eklenecek',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              ref.refresh(filteredSurveysProvider);
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Yenile'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSurveyCard(Survey survey) {
    // Calculate remaining days
    final now = DateTime.now();
    final remainingDays = survey.endDate.difference(now).inDays;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/survey_detail',
            arguments: survey,
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Survey image (if available)
            if (survey.imageUrl != null)
              Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  image: DecorationImage(
                    image: NetworkImage(survey.imageUrl!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and status indicator
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          survey.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: survey.isActive
                              ? remainingDays > 3
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.orange.withOpacity(0.1)
                              : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              survey.isActive
                                  ? remainingDays > 3
                                      ? Icons.check_circle
                                      : Icons.access_time
                                  : Icons.cancel,
                              size: 14,
                              color: survey.isActive
                                  ? remainingDays > 3
                                      ? Colors.green
                                      : Colors.orange
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              survey.isActive
                                  ? remainingDays > 0
                                      ? '$remainingDays gün kaldı'
                                      : 'Son gün'
                                  : 'Sona erdi',
                              style: TextStyle(
                                fontSize: 12,
                                color: survey.isActive
                                    ? remainingDays > 3
                                        ? Colors.green
                                        : Colors.orange
                                    : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Description
                  Text(
                    survey.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  
                  // Survey stats and location
                  Row(
                    children: [
                      // Total votes
                      Row(
                        children: [
                          Icon(
                            Icons.how_to_vote,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${survey.totalVotes} oy',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      
                      // Location (if available)
                      if (survey.cityId != null)
                        FutureBuilder<City>(
                          future: _apiService.getCityById(survey.cityId!),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const SizedBox.shrink();
                            }
                            
                            final city = snapshot.data!;
                            
                            return Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  city.name,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      
                      const Spacer(),
                      
                      // Category (if available)
                      if (survey.categoryId != null)
                        FutureBuilder<Category>(
                          future: _apiService.getCategoryById(survey.categoryId!),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const SizedBox.shrink();
                            }
                            
                            final category = snapshot.data!;
                            
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                category.name,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[800],
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                  
                  // Progress bar showing distribution of votes
                  if (survey.totalVotes > 0) ...[
                    const SizedBox(height: 16),
                    _buildSurveyProgressBar(survey),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSurveyProgressBar(Survey survey) {
    // Get top options by vote count (max 3)
    final sortedOptions = List<SurveyOption>.from(survey.options)
      ..sort((a, b) => b.voteCount.compareTo(a.voteCount));
    
    final topOptions = sortedOptions.take(3).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sonuçlar',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        for (var option in topOptions)
          Container(
            margin: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                // Progress bar
                Expanded(
                  child: Stack(
                    children: [
                      // Background
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      // Progress
                      Container(
                        height: 8,
                        width: MediaQuery.of(context).size.width * 
                            (option.voteCount / survey.totalVotes) * 0.5, // Adjusting for padding
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Percentage
                Text(
                  '${(option.voteCount / survey.totalVotes * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}