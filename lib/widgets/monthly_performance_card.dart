import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class MonthlyPerformanceCard extends StatelessWidget {
  final Map<String, double> monthlyPerformance;
  final double width;
  final String? performanceMonth;
  final String? performanceYear;
  
  const MonthlyPerformanceCard({
    Key? key,
    required this.monthlyPerformance,
    this.width = double.infinity,
    this.performanceMonth,
    this.performanceYear,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Son üç ayın değerlerini hesapla
    final List<String> months = monthlyPerformance.keys.toList();
    months.sort(); // Kronolojik olarak sıralama yap
    
    final String currentMonth = performanceMonth ?? (months.isNotEmpty ? months.last : '');
    final String previousMonth = months.length > 1 ? months[months.length - 2] : '';
    
    final double currentRate = monthlyPerformance[currentMonth] ?? 0.0;
    final double previousRate = monthlyPerformance[previousMonth] ?? 0.0;
    
    // Değişim oranını hesapla
    final double change = previousRate > 0 ? (currentRate - previousRate) / previousRate * 100 : 0.0;
    
    // Kart rengini belirle (performans artışı/düşüşü)
    final Color cardColor = change >= 0 ? Colors.green.shade50 : Colors.red.shade50;
    final Color changeColor = change >= 0 ? Colors.green.shade600 : Colors.red.shade600;
    final IconData changeIcon = change >= 0 ? Icons.arrow_upward : Icons.arrow_downward;

    // Performans derecelendirmesi
    String performanceRating;
    Color ratingColor;
    if (currentRate >= 80) {
      performanceRating = "Çok İyi";
      ratingColor = Colors.green.shade800;
    } else if (currentRate >= 60) {
      performanceRating = "İyi";
      ratingColor = Colors.green.shade600;
    } else if (currentRate >= 40) {
      performanceRating = "Orta";
      ratingColor = Colors.orange;
    } else if (currentRate >= 20) {
      performanceRating = "Geliştirilmeli";
      ratingColor = Colors.deepOrange;
    } else {
      performanceRating = "Yetersiz";
      ratingColor = Colors.red;
    }
    
    return Container(
      width: width,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8.0,
            spreadRadius: 1.0,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: changeColor.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$currentMonth ${performanceYear ?? ''} Belediye Karnesi',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                  color: Colors.grey[800],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ratingColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: ratingColor.withOpacity(0.3)),
                ),
                child: Text(
                  performanceRating,
                  style: TextStyle(
                    color: ratingColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          
          // Performans grafik çizgisi
          SizedBox(
            height: 150,
            child: _buildChart(months),
          ),
          
          const SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Çözüm Başarı Oranı',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Row(
                      children: [
                        Text(
                          '%${currentRate.toStringAsFixed(1)}',
                          style: const TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        if (previousMonth.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                            decoration: BoxDecoration(
                              color: changeColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  changeIcon,
                                  size: 14.0,
                                  color: changeColor,
                                ),
                                const SizedBox(width: 4.0),
                                Text(
                                  change.abs() < 0.1 
                                    ? 'Değişim yok' 
                                    : '%${change.abs().toStringAsFixed(1)}',
                                  style: TextStyle(
                                    color: changeColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
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
              _buildGaugeIndicator(currentRate),
            ],
          ),
          const SizedBox(height: 12.0),
          if (previousMonth.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: changeColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: changeColor.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(
                    change >= 0 ? Icons.trending_up : Icons.trending_down,
                    color: changeColor,
                    size: 16,
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      '$previousMonth ayına göre ${change.abs().toStringAsFixed(1)}% ${change >= 0 ? 'artış' : 'düşüş'} gösterdi.',
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
  
  // Çizgi grafiği oluştur
  Widget _buildChart(List<String> months) {
    // Son 3 ayı göster
    final displayMonths = months.length > 3 ? months.sublist(months.length - 3) : months;
    final spots = <FlSpot>[];
    
    for (int i = 0; i < displayMonths.length; i++) {
      final month = displayMonths[i];
      final value = monthlyPerformance[month] ?? 0;
      spots.add(FlSpot(i.toDouble(), value));
    }
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 20,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.2),
              strokeWidth: 1,
              dashArray: [5, 5],
            );
          },
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < displayMonths.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      displayMonths[value.toInt()],
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  );
                }
                return const SizedBox();
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 20,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    '%${value.toInt()}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 10),
                  ),
                );
              },
              reservedSize: 30,
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: displayMonths.length.toDouble() - 1,
        minY: 0,
        maxY: 100,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.blueGrey.shade700,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((LineBarSpot spot) {
                final month = displayMonths[spot.x.toInt()];
                return LineTooltipItem(
                  '$month: %${spot.y.toStringAsFixed(1)}',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            gradient: LinearGradient(
              colors: [Colors.blue.shade300, Colors.blue.shade700],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.white,
                  strokeWidth: 2,
                  strokeColor: Colors.blue.shade700,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  Colors.blue.shade200.withOpacity(0.3),
                  Colors.blue.shade300.withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Yarım daire gösterge widget'ı
  Widget _buildGaugeIndicator(double value) {
    // Değere göre renk belirleme
    Color gaugeColor;
    if (value >= 80) {
      gaugeColor = Colors.green;
    } else if (value >= 60) {
      gaugeColor = Colors.lightGreen;
    } else if (value >= 40) {
      gaugeColor = Colors.amber;
    } else if (value >= 20) {
      gaugeColor = Colors.orange;
    } else {
      gaugeColor = Colors.red;
    }
    
    return SizedBox(
      width: 70,
      height: 70,
      child: Stack(
        children: [
          Center(
            child: SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                value: value / 100,
                strokeWidth: 8,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(gaugeColor),
              ),
            ),
          ),
          Center(
            child: Text(
              '%${value.toInt()}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}