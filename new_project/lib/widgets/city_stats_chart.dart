import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class CityStatsChart extends StatelessWidget {
  final Map<String, double> data;
  final String title;
  final String description;
  final List<Color> gradientColors;
  
  const CityStatsChart({
    Key? key,
    required this.data,
    required this.title,
    this.description = '',
    this.gradientColors = const [Color(0xff23b6e6), Color(0xff02d39a)],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18, 
              ),
            ),
            if (description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ),
            const SizedBox(height: 20),
            SizedBox(
              height: 220,
              child: data.isEmpty
                ? Center(child: Text('Veri bulunamadı', style: TextStyle(color: Colors.grey.shade600)))
                : _buildChart(),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: _buildLegendItems(),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: _calculateMaxY(),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < data.keys.length) {
                  final String label = data.keys.elementAt(value.toInt());
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _shortenLabel(label),
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
              reservedSize: 40,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    value.toInt().toString(),
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 10,
                    ),
                  ),
                );
              },
              reservedSize: 30,
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
          show: false,
        ),
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.shade200,
              strokeWidth: 1,
              dashArray: [5, 5],
            );
          },
        ),
        barGroups: _generateBarGroups(),
      ),
    );
  }
  
  List<BarChartGroupData> _generateBarGroups() {
    final List<BarChartGroupData> groups = [];
    int i = 0;
    
    for (final entry in data.entries) {
      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: entry.value,
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
              width: data.length > 5 ? 12 : 20,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
          ],
        ),
      );
      i++;
    }
    
    return groups;
  }
  
  double _calculateMaxY() {
    if (data.isEmpty) return 100;
    final maxValue = data.values.reduce((a, b) => a > b ? a : b);
    return (maxValue * 1.2).ceilToDouble(); // %20 ekstra alan
  }
  
  String _shortenLabel(String label) {
    if (label.length <= 10) return label;
    return '${label.substring(0, 8)}...';
  }
  
  List<Widget> _buildLegendItems() {
    final items = <Widget>[];
    for (final entry in data.entries) {
      items.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                ),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '${entry.key}: ${entry.value.toStringAsFixed(1)}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }
    return items;
  }
}

class RadarCityStatsChart extends StatelessWidget {
  final Map<String, double> data;
  final String title;
  final String description;
  final Color fillColor;
  final Color borderColor;
  
  const RadarCityStatsChart({
    Key? key,
    required this.data,
    required this.title,
    this.description = '',
    this.fillColor = const Color(0x402196F3),
    this.borderColor = const Color(0xFF2196F3),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18, 
              ),
            ),
            if (description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ),
            const SizedBox(height: 20),
            SizedBox(
              height: 250,
              child: data.isEmpty
                ? Center(child: Text('Veri bulunamadı', style: TextStyle(color: Colors.grey.shade600)))
                : _buildRadarChart(),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: _buildLegendItems(),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRadarChart() {
    return RadarChart(
      RadarChartData(
        radarShape: RadarShape.polygon,
        dataSets: [
          RadarDataSet(
            fillColor: fillColor,
            borderColor: borderColor,
            borderWidth: 2,
            entryRadius: 5,
            dataEntries: _generateRadarEntries(),
          ),
        ],
        radarBorderData: const BorderSide(color: Colors.transparent),
        gridBorderData: BorderSide(color: Colors.grey.shade300, width: 1),
        tickBorderData: BorderSide(color: Colors.grey.shade300, width: 1),
        ticksTextStyle: TextStyle(color: Colors.grey.shade600, fontSize: 10),
        titleTextStyle: TextStyle(color: Colors.grey.shade700, fontSize: 12),
        getTitle: (index, angle) {
          if (index >= 0 && index < data.keys.length) {
            return RadarChartTitle(
              text: data.keys.elementAt(index),
              angle: angle,
            );
          }
          return const RadarChartTitle(text: '');
        },
        titlePositionPercentageOffset: 0.1,
      ),
      swapAnimationDuration: const Duration(milliseconds: 400),
    );
  }
  
  List<RadarEntry> _generateRadarEntries() {
    return data.entries.map((entry) => RadarEntry(value: entry.value)).toList();
  }
  
  List<Widget> _buildLegendItems() {
    final items = <Widget>[];
    for (final entry in data.entries) {
      items.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: borderColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '${entry.key}: ${entry.value.toStringAsFixed(1)}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }
    return items;
  }
}