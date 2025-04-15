import 'package:flutter/material.dart';
import 'package:sikayet_var/models/post.dart';
import 'package:sikayet_var/services/api_service.dart';
import 'package:sikayet_var/utils/ui_helpers.dart';

class SatisfactionRatingWidget extends StatefulWidget {
  final Post post;
  final Function(int)? onRated;
  final bool compact;

  const SatisfactionRatingWidget({
    Key? key,
    required this.post,
    this.onRated,
    this.compact = false,
  }) : super(key: key);

  @override
  State<SatisfactionRatingWidget> createState() => _SatisfactionRatingWidgetState();
}

class _SatisfactionRatingWidgetState extends State<SatisfactionRatingWidget> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  bool _isRated = false;
  int _rating = 0;

  @override
  void initState() {
    super.initState();
    _rating = widget.post.satisfactionRating ?? 0;
    _isRated = _rating > 0;
  }

  Future<void> _submitRating(int rating) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _apiService.submitSatisfactionRating(
        int.parse(widget.post.id),
        rating,
      );

      if (success) {
        setState(() {
          _rating = rating;
          _isRated = true;
        });
        
        if (widget.onRated != null) {
          widget.onRated!(rating);
        }
        
        UIHelpers.showSnackBar(
          context,
          'Değerlendirmeniz için teşekkürler!',
          type: SnackbarType.success,
        );
      } else {
        UIHelpers.showSnackBar(
          context,
          'Puanlama yapılırken bir hata oluştu',
          type: SnackbarType.error,
        );
      }
    } catch (e) {
      UIHelpers.showSnackBar(
        context,
        'Puanlama yapılırken bir hata oluştu: $e',
        type: SnackbarType.error,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildReadOnlyStars(int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: index < rating ? Colors.amber : Colors.grey,
          size: widget.compact ? 16 : 24,
        );
      }),
    );
  }

  Widget _buildInteractiveStars() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        return IconButton(
          onPressed: _isLoading ? null : () => _submitRating(starValue),
          icon: Icon(
            _rating >= starValue ? Icons.star : Icons.star_border,
            color: _rating >= starValue ? Colors.amber : Colors.grey,
            size: widget.compact ? 18 : 28,
          ),
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(
            minWidth: widget.compact ? 26 : 40,
            minHeight: widget.compact ? 26 : 40,
          ),
          splashRadius: widget.compact ? 16 : 24,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.post.isSolved) {
      return const SizedBox.shrink();
    }

    // Compact mod: sadece puanları göster
    if (widget.compact && _isRated) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildReadOnlyStars(_rating),
          const SizedBox(width: 4),
          Text(
            '($_rating/5)',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      );
    }

    // Normal mod: başlık ve içerik
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isRated 
                  ? 'Memnuniyet Değerlendirmesi' 
                  : 'Bu şikayetin çözümünden memnun kaldınız mı?',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Column(
                children: [
                  _isRated || !widget.post.canRateSatisfaction
                      ? _buildReadOnlyStars(_rating)
                      : _buildInteractiveStars(),
                  if (_isRated)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        _getRatingText(_rating),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                ],
              ),
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'Hiç memnun kalmadınız';
      case 2:
        return 'Memnun kalmadınız';
      case 3:
        return 'Kararsız kaldınız';
      case 4:
        return 'Memnun kaldınız';
      case 5:
        return 'Çok memnun kaldınız';
      default:
        return '';
    }
  }
}