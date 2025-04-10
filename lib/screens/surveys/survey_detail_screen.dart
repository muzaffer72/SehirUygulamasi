import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sikayet_var/models/survey.dart';
import 'package:sikayet_var/providers/auth_provider.dart';
import 'package:sikayet_var/providers/current_user_provider.dart';
import 'package:sikayet_var/services/api_service.dart';
import 'package:sikayet_var/providers/user_provider.dart';
import 'package:sikayet_var/providers/api_service_provider.dart';

class SurveyDetailScreen extends ConsumerStatefulWidget {
  final Survey survey;
  
  const SurveyDetailScreen({
    Key? key,
    required this.survey,
  }) : super(key: key);

  @override
  ConsumerState<SurveyDetailScreen> createState() => _SurveyDetailScreenState();
}

class _SurveyDetailScreenState extends ConsumerState<SurveyDetailScreen> {
  final ApiService _apiService = ApiService();
  
  String? _selectedOptionId;
  bool _hasVoted = false;
  bool _isSubmitting = false;
  
  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider).value;
    final bool isLoggedIn = currentUser != null;
    
    // Calculate remaining days
    final now = DateTime.now();
    final remainingDays = widget.survey.endDate.difference(now).inDays;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anket Detayı'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Survey title
            Text(
              widget.survey.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            // Survey metadata
            Row(
              children: [
                Icon(
                  Icons.how_to_vote,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${widget.survey.totalVotes} oy',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.timelapse,
                  size: 16,
                  color: remainingDays > 5 ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 4),
                Text(
                  remainingDays > 0
                      ? '$remainingDays gün kaldı'
                      : 'Anket sona erdi',
                  style: TextStyle(
                    color: remainingDays > 5 ? Colors.green : Colors.orange,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Survey image
            if (widget.survey.imageUrl != null)
              Container(
                height: 200,
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(widget.survey.imageUrl!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            
            // Survey description
            Text(
              widget.survey.description,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            
            // Survey options
            const Text(
              'Seçenekler',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            if (_hasVoted || !isLoggedIn || !widget.survey.isActive)
              // Results view
              Column(
                children: widget.survey.options.map((option) {
                  final percent = option.getPercentage(widget.survey.totalVotes);
                  final isSelected = option.id == _selectedOptionId;
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                option.text,
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                            Text(
                              '${percent.toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Stack(
                          children: [
                            // Background
                            Container(
                              height: 12,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            // Progress
                            Container(
                              height: 12,
                              width: MediaQuery.of(context).size.width * (percent / 100) * 0.8, // Consider padding
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.primary.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${option.voteCount} oy',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              )
            else
              // Voting view
              Column(
                children: widget.survey.options.map((option) {
                  final isSelected = option.id == _selectedOptionId;
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: RadioListTile<String>(
                      title: Text(option.text),
                      value: option.id,
                      groupValue: _selectedOptionId,
                      onChanged: (String? value) {
                        setState(() {
                          _selectedOptionId = value;
                        });
                      },
                      activeColor: Theme.of(context).colorScheme.primary,
                      selected: isSelected,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey[300]!,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            
            const SizedBox(height: 16),
            
            if (!isLoggedIn)
              // Login prompt
              Center(
                child: Column(
                  children: [
                    const Text(
                      'Oy vermek için giriş yapın',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate back - user needs to log in
                        Navigator.pop(context);
                      },
                      child: const Text('Giriş Yap'),
                    ),
                  ],
                ),
              )
            else if (_hasVoted)
              // Already voted message
              const Center(
                child: Text(
                  'Bu ankette oy kullandınız',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            else if (!widget.survey.isActive)
              // Survey ended message
              const Center(
                child: Text(
                  'Bu anket sona erdi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              )
            else
              // Vote button
              Center(
                child: SizedBox(
                  width: 200,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _selectedOptionId == null || _isSubmitting
                        ? null
                        : _submitVote,
                    child: _isSubmitting
                        ? const CircularProgressIndicator()
                        : const Text(
                            'Oy Ver',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
              ),
            
            const SizedBox(height: 24),
            
            // Survey location
            if (widget.survey.cityId != null)
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FutureBuilder(
                          future: Future.wait([
                            _apiService.getCityById(widget.survey.cityId!),
                            if (widget.survey.districtId != null)
                              _apiService.getDistrictById(widget.survey.districtId!)
                            else
                              Future.value(null),
                          ]),
                          builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                            if (!snapshot.hasData) {
                              return const Text('Konum yükleniyor...');
                            }
                            
                            final city = snapshot.data![0];
                            final district = snapshot.data!.length > 1 && snapshot.data![1] != null
                                ? snapshot.data![1]
                                : null;
                            
                            final locationText = district != null
                                ? '${district.name}, ${city.name}'
                                : city.name;
                            
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Konum',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(locationText),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            // Survey category
            if (widget.survey.categoryId != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.category),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FutureBuilder(
                          future: _apiService.getCategoryById(widget.survey.categoryId!),
                          builder: (context, AsyncSnapshot<dynamic> snapshot) {
                            if (!snapshot.hasData) {
                              return const Text('Kategori yükleniyor...');
                            }
                            
                            final category = snapshot.data!;
                            
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Kategori',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(category.name),
                              ],
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
      ),
    );
  }
  
  Future<void> _submitVote() async {
    if (_selectedOptionId == null) {
      return;
    }
    
    setState(() {
      _isSubmitting = true;
    });
    
    try {
      await _apiService.voteOnSurvey(
        widget.survey.id,
        _selectedOptionId!,
      );
      
      setState(() {
        _hasVoted = true;
        _isSubmitting = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Oyunuz başarıyla kaydedildi'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Oy verilirken bir hata oluştu: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}