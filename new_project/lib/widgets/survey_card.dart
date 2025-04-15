import 'package:flutter/material.dart';
import 'package:belediye_iletisim_merkezi/models/survey.dart';
import 'package:belediye_iletisim_merkezi/services/api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:belediye_iletisim_merkezi/providers/auth_provider.dart';

class SurveyCard extends ConsumerStatefulWidget {
  final Survey survey;
  final Function? onVote;
  final bool isDetailed;

  const SurveyCard({
    Key? key,
    required this.survey,
    this.onVote,
    this.isDetailed = false,
  }) : super(key: key);

  @override
  ConsumerState<SurveyCard> createState() => _SurveyCardState();
}

class _SurveyCardState extends ConsumerState<SurveyCard> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String? _selectedOptionId;

  @override
  void initState() {
    super.initState();
    // Kullanıcı daha önce ankete katıldıysa seçeneği seçili olarak göster
    if (widget.survey.hasUserVoted) {
      _loadUserVote();
    }
  }

  // Kullanıcının önceden verdiği oyu yükle
  Future<void> _loadUserVote() async {
    final authState = ref.read(authProvider);
    if (authState.user == null) return;

    try {
      final userVote = await _apiService.getUserSurveyVote(
        widget.survey.id,
        authState.user!.id,
      );

      if (userVote != null && userVote['option_id'] != null) {
        setState(() {
          _selectedOptionId = userVote['option_id'].toString();
        });
      }
    } catch (e) {
      // Hata durumunda sessizce devam et
    }
  }

  // Ankete oy ver
  Future<void> _vote() async {
    if (_selectedOptionId == null) return;
    
    final authState = ref.read(authProvider);
    if (authState.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Oy vermek için giriş yapmanız gerekiyor'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _apiService.voteSurvey(
        surveyId: widget.survey.id,
        optionId: _selectedOptionId!,
        userId: authState.user!.id,
      );
      
      // Callback fonksiyonu varsa çağır
      if (widget.onVote != null) {
        widget.onVote!();
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Oyunuz başarıyla kaydedildi'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Oy verirken bir hata oluştu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Başlık Alanı
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.survey.title,
                    style: TextStyle(
                      fontSize: widget.isDetailed ? 22 : 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                // Resmi anket ise rozet göster
                if (widget.survey.isOfficial)
                  Tooltip(
                    message: 'Resmi Anket',
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.verified,
                            color: Colors.white,
                            size: 16,
                          ),
                          if (widget.isDetailed) ...[
                            const SizedBox(width: 4),
                            const Text(
                              'Resmi',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            
            // Açıklama alanı (detaylı görünümde göster)
            if (widget.isDetailed && widget.survey.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                widget.survey.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Katılım oranı çubuğu
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Katılım: ${widget.survey.formattedParticipationRate}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Stack(
                  children: [
                    // Arka plan çubuğu
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    // Dolu çubuk
                    FractionallySizedBox(
                      widthFactor: widget.survey.participationRate / 100,
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: _getParticipationColor(widget.survey.participationRate),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    widget.survey.formattedParticipation,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Anket seçenekleri
            ...widget.survey.options.map((option) {
              final isSelected = _selectedOptionId == option.id;
              final hasVoted = widget.survey.hasUserVoted;
              final double percentage = option.percentage ?? 0;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: hasVoted || _isLoading
                      ? null
                      : () {
                          setState(() {
                            _selectedOptionId = option.id;
                          });
                        },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected 
                            ? colorScheme.primary 
                            : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // Radyo butonu
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected 
                                        ? colorScheme.primary 
                                        : Colors.grey[400]!,
                                    width: 2,
                                  ),
                                ),
                                child: isSelected
                                    ? Center(
                                        child: Container(
                                          width: 10,
                                          height: 10,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: colorScheme.primary,
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              // Seçenek metni
                              Expanded(
                                child: Text(
                                  option.text,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: isSelected 
                                        ? FontWeight.bold 
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                              // Yüzde gösterimi (kullanıcı oy verdiyse)
                              if (hasVoted)
                                Text(
                                  '${percentage.toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected 
                                        ? colorScheme.primary 
                                        : Colors.grey[600],
                                  ),
                                ),
                            ],
                          ),
                          // İlerleme çubuğu (kullanıcı oy verdiyse)
                          if (hasVoted) ...[
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: percentage / 100,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isSelected 
                                    ? colorScheme.primary 
                                    : Colors.grey[400]!,
                              ),
                              minHeight: 6,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
            
            // Oy verme butonu
            if (!widget.survey.hasUserVoted) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading || _selectedOptionId == null
                    ? null
                    : _vote,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Oyumu Gönder',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  // Katılım oranına göre renk belirle
  Color _getParticipationColor(double rate) {
    if (rate < 10) {
      return Colors.red;
    } else if (rate < 30) {
      return Colors.orange;
    } else if (rate < 50) {
      return Colors.amber;
    } else if (rate < 70) {
      return Colors.lightGreen;
    } else {
      return Colors.green;
    }
  }
}