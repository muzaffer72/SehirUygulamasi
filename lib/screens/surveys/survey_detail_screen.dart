import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sikayet_var/models/survey.dart';
import 'package:sikayet_var/providers/auth_provider.dart';
import 'package:sikayet_var/services/api_service.dart';

class SurveyDetailScreen extends ConsumerStatefulWidget {
  final Survey survey;
  
  const SurveyDetailScreen({Key? key, required this.survey}) : super(key: key);

  @override
  ConsumerState<SurveyDetailScreen> createState() => _SurveyDetailScreenState();
}

class _SurveyDetailScreenState extends ConsumerState<SurveyDetailScreen> {
  String? _selectedOptionId;
  bool _hasVoted = false;
  bool _isVoting = false;
  Survey? _updatedSurvey;
  
  @override
  void initState() {
    super.initState();
    _updatedSurvey = widget.survey;
    _checkUserVote();
  }
  
  Future<void> _checkUserVote() async {
    // TODO: Check if user has already voted on this survey
    setState(() {
      _hasVoted = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final survey = _updatedSurvey ?? widget.survey;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anket Detayı'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Survey header
            if (survey.imageUrl != null)
              Container(
                height: 200,
                width: double.infinity,
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
                child: Center(
                  child: Text(
                    survey.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(24),
                width: double.infinity,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                child: Text(
                  survey.title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            
            // Survey description
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    survey.description,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Toplam ${survey.totalVotes} oy kullanıldı',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  const Text(
                    'Seçenekler',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Options list
                  ...survey.options.map((option) => _buildSurveyOption(
                    option,
                    survey.totalVotes,
                    _hasVoted,
                  )),
                  
                  const SizedBox(height: 32),
                  
                  // Vote button
                  if (!_hasVoted && currentUser != null)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _selectedOptionId == null || _isVoting
                            ? null
                            : _submitVote,
                        child: _isVoting
                            ? const CircularProgressIndicator()
                            : const Text(
                                'Oy Ver',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    )
                  else if (!_hasVoted && currentUser == null)
                    const Center(
                      child: Text(
                        'Oy verebilmek için giriş yapmalısınız',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else
                    const Center(
                      child: Text(
                        'Bu ankete zaten oy verdiniz',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  
                  // Survey metadata
                  const SizedBox(height: 24),
                  _buildSurveyMeta(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSurveyOption(SurveyOption option, int totalVotes, bool showResults) {
    final percentValue = option.getPercentage(totalVotes);
    final percent = percentValue.toStringAsFixed(1);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Option selection
          if (!_hasVoted)
            RadioListTile<String>(
              title: Text(option.text),
              value: option.id,
              groupValue: _selectedOptionId,
              onChanged: (value) {
                setState(() {
                  _selectedOptionId = value;
                });
              },
            )
          else
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 8),
              child: Text(
                option.text,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          
          // Results bar
          if (_hasVoted)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Stack(
                    children: [
                      // Background bar
                      Container(
                        height: 24,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      
                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOut,
                          height: 24,
                          width: MediaQuery.of(context).size.width * (percentValue / 100) * 0.85,
                          color: _getOptionColor(percentValue),
                        ),
                      ),
                      
                      // Percentage text
                      Container(
                        height: 24,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$percent%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '${option.voteCount} oy',
                              style: TextStyle(
                                color: percentValue > 50 ? Colors.white : Colors.black87,
                                fontSize: 14,
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
      ),
    );
  }
  
  Widget _buildSurveyMeta() {
    final survey = _updatedSurvey ?? widget.survey;
    final apiService = ApiService();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Anket Bilgileri',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Divider(),
            _buildMetaRow(
              'Başlangıç Tarihi:',
              '${survey.startDate.day}/${survey.startDate.month}/${survey.startDate.year}',
            ),
            _buildMetaRow(
              'Bitiş Tarihi:',
              '${survey.endDate.day}/${survey.endDate.month}/${survey.endDate.year}',
            ),
            _buildMetaRow(
              'Durum:',
              survey.isActive ? 'Aktif' : 'Sona Erdi',
            ),
            if (survey.cityId != null)
              FutureBuilder(
                future: apiService.getCityById(survey.cityId!),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox.shrink();
                  }
                  
                  final city = snapshot.data!;
                  
                  return Column(
                    children: [
                      _buildMetaRow('Şehir:', city.name),
                      if (survey.districtId != null)
                        FutureBuilder(
                          future: apiService.getDistrictById(survey.districtId!),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const SizedBox.shrink();
                            }
                            
                            final district = snapshot.data!;
                            
                            return _buildMetaRow('İlçe:', district.name);
                          },
                        ),
                    ],
                  );
                },
              ),
            if (survey.categoryId != null)
              FutureBuilder(
                future: apiService.getCategoryById(survey.categoryId!),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox.shrink();
                  }
                  
                  final category = snapshot.data!;
                  
                  return _buildMetaRow('Kategori:', category.name);
                },
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMetaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(value),
        ],
      ),
    );
  }
  
  Color _getOptionColor(double percent) {
    if (percent >= 70) {
      return Colors.green;
    } else if (percent >= 40) {
      return Colors.amber;
    } else {
      return Colors.redAccent;
    }
  }
  
  Future<void> _submitVote() async {
    if (_selectedOptionId == null) return;
    
    setState(() {
      _isVoting = true;
    });
    
    try {
      final apiService = ApiService();
      await apiService.voteSurvey(widget.survey.id, _selectedOptionId!);
      
      // Refresh survey data
      final updatedSurvey = await apiService.getSurveyById(widget.survey.id);
      
      if (mounted) {
        setState(() {
          _hasVoted = true;
          _isVoting = false;
          _updatedSurvey = updatedSurvey;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Oy başarıyla kaydedildi')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isVoting = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: ${e.toString()}')),
        );
      }
    }
  }
}