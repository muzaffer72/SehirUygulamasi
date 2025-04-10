import 'package:flutter/material.dart';

class BestMunicipalityBanner extends StatelessWidget {
  final String cityName;
  final String month;
  final double score;
  final Function()? onTap;
  
  const BestMunicipalityBanner({
    Key? key,
    required this.cityName,
    required this.month,
    required this.score,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.amber.shade600,
              Colors.amber.shade400,
              Colors.amber.shade300,
            ],
          ),
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withOpacity(0.3),
              blurRadius: 8.0,
              spreadRadius: 1.0,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Altın kupa ikonu
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.emoji_events,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(width: 16.0),
            // Belediye bilgileri
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AYIN BELEDİYESİ',
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    cityName,
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    '$month Ayı Performans Puanı: ${score.toStringAsFixed(1)}/100',
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            // Ok ikonu
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 16.0,
            ),
          ],
        ),
      ),
    );
  }
}