import 'package:flutter/material.dart';
import 'package:sikayet_var/models/post.dart';
import 'package:sikayet_var/providers/auth_provider.dart';
import 'package:sikayet_var/services/api_service.dart';
import 'package:provider/provider.dart';

class SatisfactionRatingWidget extends StatefulWidget {
  final Post post;
  final double? initialRating;
  final Function(int)? onRated;
  final bool isEnabled;

  const SatisfactionRatingWidget({
    Key? key,
    required this.post,
    this.initialRating,
    this.onRated,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  State<SatisfactionRatingWidget> createState() => _SatisfactionRatingWidgetState();
}

class _SatisfactionRatingWidgetState extends State<SatisfactionRatingWidget> {
  late double _rating;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating ?? 0;
  }

  // Yeni memnuniyet derecelendirmesini sunucuya gönderir
  Future<void> _submitRating(int rating) async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      if (authProvider.currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Derecelendirme göndermek için giriş yapmalısınız')),
        );
        return;
      }
      
      final bool success = await apiService.submitSatisfactionRating(
        widget.post.id,
        rating
      );
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Değerlendirmeniz için teşekkürler!')),
        );
        
        if (widget.onRated != null) {
          widget.onRated!(rating);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Değerlendirme gönderilemedi. Lütfen tekrar deneyin.')),
        );
      }
    } catch (e) {
      print('Satisfaction rating error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bir hata oluştu. Lütfen tekrar deneyin.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Memnuniyet Puanı',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Memnun değilim', style: TextStyle(fontSize: 12)),
            Text('Çok memnunum', style: TextStyle(fontSize: 12)),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Row(
            children: [
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Theme.of(context).primaryColor,
                    inactiveTrackColor: Colors.grey.shade300,
                    thumbColor: Theme.of(context).colorScheme.secondary,
                    overlayColor: Theme.of(context).primaryColor.withOpacity(0.2),
                    trackHeight: 4.0,
                  ),
                  child: Slider(
                    value: _rating,
                    min: 0,
                    max: 5,
                    divisions: 10,
                    label: _rating.toString(),
                    onChanged: widget.isEnabled
                        ? (newRating) {
                            setState(() {
                              _rating = newRating;
                            });
                            _submitRating(newRating.toInt());
                          }
                        : null,
                  ),
                ),
              ),
              Container(
                width: 40,
                alignment: Alignment.center,
                child: Text(
                  _rating.toStringAsFixed(1),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}