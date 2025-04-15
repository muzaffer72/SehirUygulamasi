import 'package:flutter/material.dart';

class SatisfactionRatingWidget extends StatefulWidget {
  final int postId;
  final double? initialRating;
  final Function(double) onRatingChanged;
  final bool isEnabled;

  const SatisfactionRatingWidget({
    Key? key,
    required this.postId,
    this.initialRating,
    required this.onRatingChanged,
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
                            widget.onRatingChanged(newRating);
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