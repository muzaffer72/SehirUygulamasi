import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sikayet_var/models/survey.dart';
import 'package:sikayet_var/providers/survey_provider.dart';

class SurveySlider extends ConsumerStatefulWidget {
  final List<Survey> surveys;
  
  const SurveySlider({Key? key, required this.surveys}) : super(key: key);

  @override
  ConsumerState<SurveySlider> createState() => _SurveySliderState();
}

class _SurveySliderState extends ConsumerState<SurveySlider> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemCount: widget.surveys.length,
              itemBuilder: (context, index) {
                final survey = widget.surveys[index];
                return _buildSurveyCard(context, survey);
              },
            ),
          ),
          const SizedBox(height: 8),
          // Indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.surveys.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentIndex == index
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade300,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSurveyCard(BuildContext context, Survey survey) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              survey.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              survey.question,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: survey.options.map((option) => _buildOption(context, survey, option)).toList(),
              ),
            ),
            if (survey.result != null)
              _buildResultBadge(context, survey.result!),
          ],
        ),
      ),
    );
  }
  
  Widget _buildOption(BuildContext context, Survey survey, SurveyOption option) {
    return InkWell(
      onTap: () => _vote(survey.id, option.id),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Theme.of(context).primaryColor),
            ),
            child: Text(
              option.text,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text('${option.percentage.toStringAsFixed(1)}%'),
        ],
      ),
    );
  }
  
  Widget _buildResultBadge(BuildContext context, SurveyResult result) {
    Color color;
    IconData icon;
    
    switch (result.type) {
      case SurveyResultType.positive:
        color = Colors.green;
        icon = Icons.thumb_up;
        break;
      case SurveyResultType.negative:
        color = Colors.red;
        icon = Icons.thumb_down;
        break;
      case SurveyResultType.neutral:
        color = Colors.amber;
        icon = Icons.thumbs_up_down;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              result.message,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: result.isCritical ? FontWeight.bold : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
  
  void _vote(String surveyId, String optionId) async {
    try {
      final voteParams = VoteParams(surveyId: surveyId, optionId: optionId);
      await ref.read(voteSurveyProvider(voteParams).future);
      
      if (!mounted) return;
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Oyunuz başarıyla kaydedildi')),
      );
      
      // Refresh surveys
      ref.invalidate(surveysProvider);
    } catch (e) {
      if (!mounted) return;
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Oy verme işlemi başarısız: $e')),
      );
    }
  }
}