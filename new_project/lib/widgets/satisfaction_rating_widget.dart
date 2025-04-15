import 'package:flutter/material.dart';

class SatisfactionRatingWidget extends StatefulWidget {
  final int? initialRating;
  final Function(int) onRatingChanged;
  final bool isReadOnly;

  const SatisfactionRatingWidget({
    Key? key,
    this.initialRating,
    required this.onRatingChanged,
    this.isReadOnly = false,
  }) : super(key: key);

  @override
  State<SatisfactionRatingWidget> createState() => _SatisfactionRatingWidgetState();
}

class _SatisfactionRatingWidgetState extends State<SatisfactionRatingWidget> {
  late int _currentRating;
  final int _maxRating = 5;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.initialRating ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Memnuniyet Derecesi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(_maxRating, (index) {
            final ratingValue = index + 1;
            return _buildRatingItem(ratingValue);
          }),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Hiç Memnun Değilim',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
              ),
            ),
            Text(
              'Çok Memnunum',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRatingItem(int rating) {
    final bool isSelected = rating <= _currentRating;
    final Color color = _getRatingColor(rating);
    
    return GestureDetector(
      onTap: widget.isReadOnly ? null : () {
        setState(() {
          _currentRating = rating;
        });
        widget.onRatingChanged(rating);
      },
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Icon(
          isSelected ? Icons.star : Icons.star_border,
          size: 32,
          color: isSelected ? color : Colors.grey[400],
        ),
      ),
    );
  }

  Color _getRatingColor(int rating) {
    // 1-2: Kırmızı, 3: Sarı, 4-5: Yeşil
    if (rating <= 2) {
      return Colors.red[400]!;
    } else if (rating == 3) {
      return Colors.amber[600]!;
    } else {
      return Colors.green[600]!;
    }
  }
}