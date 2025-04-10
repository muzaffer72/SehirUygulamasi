import 'package:flutter/material.dart';

class CityPriorityChart extends StatelessWidget {
  final Map<String, double> priorityData;
  final double height;
  final double width;
  final bool showLabels;
  
  const CityPriorityChart({
    Key? key,
    required this.priorityData,
    this.height = 150.0,
    this.width = double.infinity,
    this.showLabels = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5.0,
            spreadRadius: 1.0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Şehir Öncelik Dağılımı',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
          const SizedBox(height: 12.0),
          Expanded(
            child: _buildPriorityChart(context),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityChart(BuildContext context) {
    final List<MapEntry<String, double>> sortedEntries = priorityData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final Map<String, Color> categoryColors = {
      'Altyapı': Colors.blue,
      'Temizlik': Colors.green,
      'Yeşil Alan': Colors.lightGreen,
      'Ulaşım': Colors.orange,
      'Diğer': Colors.purple,
      // Varsayılan renkler
      'default1': Colors.red,
      'default2': Colors.amber,
      'default3': Colors.indigo,
      'default4': Colors.cyan,
      'default5': Colors.teal,
    };

    return Column(
      children: [
        Expanded(
          child: Row(
            children: sortedEntries.map((entry) {
              final color = categoryColors[entry.key] ?? 
                categoryColors['default${sortedEntries.indexOf(entry) % 5 + 1}'] ??
                Colors.grey;
              
              return Expanded(
                flex: (entry.value * 100).toInt(),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2.0),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        if (showLabels) const SizedBox(height: 8.0),
        if (showLabels)
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: sortedEntries.map((entry) {
              final color = categoryColors[entry.key] ?? 
                categoryColors['default${sortedEntries.indexOf(entry) % 5 + 1}'] ??
                Colors.grey;
              
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12.0,
                    height: 12.0,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4.0),
                  Text(
                    '${entry.key}: %${entry.value.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
      ],
    );
  }
}