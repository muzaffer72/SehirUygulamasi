import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';

class MonthlyPerformanceCard extends StatelessWidget {
  final Map<String, double> monthlyPerformance;
  final double width;
  
  const MonthlyPerformanceCard({
    Key? key,
    required this.monthlyPerformance,
    this.width = double.infinity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Son iki ayın değerlerini hesapla
    final List<String> months = monthlyPerformance.keys.toList();
    months.sort(); // Kronolojik olarak sıralama yap
    
    final String currentMonth = months.isNotEmpty ? months.last : '';
    final String previousMonth = months.length > 1 ? months[months.length - 2] : '';
    
    final double currentRate = monthlyPerformance[currentMonth] ?? 0.0;
    final double previousRate = monthlyPerformance[previousMonth] ?? 0.0;
    
    // Değişim oranını hesapla
    final double change = previousRate > 0 ? (currentRate - previousRate) / previousRate * 100 : 0.0;
    
    // Kart rengini belirle (performans artışı/düşüşü)
    final Color cardColor = change >= 0 ? Colors.green.shade50 : Colors.red.shade50;
    final Color changeColor = change >= 0 ? Colors.green : Colors.red;
    final IconData changeIcon = change >= 0 ? Icons.arrow_upward : Icons.arrow_downward;
    
    return Container(
      width: width,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: cardColor,
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
          Text(
            '$currentMonth Ayı Belediye Karnesi',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12.0),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sorun Çözme Oranı',
                      style: TextStyle(
                        fontSize: 13.0,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      '%${currentRate.toStringAsFixed(1)}',
                      style: const TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              if (previousMonth.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: changeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        changeIcon,
                        size: 16.0,
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
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12.0),
          if (previousMonth.isNotEmpty)
            Text(
              '$previousMonth ayına göre ${change >= 0 ? 'artış' : 'düşüş'} gösterdi.',
              style: TextStyle(
                fontSize: 12.0,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          // Performans göstergesi (çubuk)
          const SizedBox(height: 8.0),
          ClipRRect(
            borderRadius: BorderRadius.circular(2.0),
            child: LinearProgressIndicator(
              value: currentRate / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(changeColor),
              minHeight: 6.0,
            ),
          ),
        ],
      ),
    );
  }
}