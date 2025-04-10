import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sikayet_var/models/city_profile.dart';
import 'package:sikayet_var/screens/cities/city_profile_screen.dart';

/// Ayın Belediyesi Banner'ı
/// Anasayfada gösterilen, en iyi performansa sahip belediyeyi gösteren banner
class BestMunicipalityBanner extends ConsumerWidget {
  const BestMunicipalityBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Örnek veri (gerçek uygulamada API'den gelecek)
    final bestMunicipality = CityProfile(
      id: 34,
      name: "İstanbul",
      description: "Türkiye'nin en büyük şehri",
      imageUrl: "https://upload.wikimedia.org/wikipedia/commons/5/53/Istanbulview.jpg",
      coverImageUrl: "https://upload.wikimedia.org/wikipedia/commons/5/53/Istanbulview.jpg",
      population: 16000000,
      latitude: 41.0082,
      longitude: 28.9784,
      totalPosts: 14250,
      totalSolvedIssues: 12500,
      activeSurveys: 8,
      mayorName: "Ekrem İmamoğlu",
      mayorParty: "CHP",
      isBestOfMonth: true,
      awardMonth: "Nisan",
      awardScore: 92.5,
    );

    return GestureDetector(
      onTap: () {
        // Belediye profil sayfasına git
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CityProfileScreen(cityId: bestMunicipality.id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.8), 
              Theme.of(context).colorScheme.secondary.withOpacity(0.9)
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Üst kısım: Başlık ve Kupa İkonu
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.9),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.emoji_events, // Kupa ikonu
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "${bestMunicipality.awardMonth} Ayının Belediyesi",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            
            // Alt kısım: Belediye Bilgileri
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Belediye Logosu/Resmi
                  if (bestMunicipality.imageUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        bestMunicipality.imageUrl!,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 70,
                            height: 70,
                            color: Colors.grey[300],
                            child: const Icon(Icons.location_city, size: 36, color: Colors.white),
                          );
                        },
                      ),
                    )
                  else
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.location_city, size: 36, color: Colors.white),
                    ),
                  
                  const SizedBox(width: 16),
                  
                  // Belediye Bilgileri
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bestMunicipality.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        if (bestMunicipality.mayorName != null)
                          Text(
                            "Belediye Başkanı: ${bestMunicipality.mayorName}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        const SizedBox(height: 4),
                        Text(
                          "Performans Puanı: %${bestMunicipality.awardScore?.toStringAsFixed(1) ?? 'N/A'}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // İleri Ok İkonu
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 16,
                  ),
                ],
              ),
            ),
            
            // Bilgi Metni
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Text(
                'Bu belediye ${"vatandaş memnuniyeti, sorun çözme hızı ve şeffaflık"} kategorilerinde en yüksek puanı aldı.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}