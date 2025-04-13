import 'package:flutter/material.dart';
import 'package:sikayet_var/models/political_party.dart';
import 'package:sikayet_var/services/party_service.dart';

class PartyPerformanceScroll extends StatefulWidget {
  const PartyPerformanceScroll({Key? key}) : super(key: key);

  @override
  State<PartyPerformanceScroll> createState() => _PartyPerformanceScrollState();
}

class _PartyPerformanceScrollState extends State<PartyPerformanceScroll> {
  final PartyService _partyService = PartyService();
  bool _isLoading = true;
  String? _errorMessage;
  List<PoliticalParty> _parties = [];

  @override
  void initState() {
    super.initState();
    _loadParties();
  }

  Future<void> _loadParties() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final parties = await _partyService.getParties();
      
      // Başarı oranına göre sırala (büyükten küçüğe)
      parties.sort((a, b) => b.problemSolvingRate.compareTo(a.problemSolvingRate));
      
      setState(() {
        _parties = parties;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Parti verileri yüklenemedi: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadParties,
              child: const Text('Yeniden Dene'),
            ),
          ],
        ),
      );
    }

    if (_parties.isEmpty) {
      return const Center(
        child: Text('Parti performans verisi bulunamadı.'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Belediye Başarı Oranları',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            scrollDirection: Axis.horizontal,
            itemCount: _parties.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final party = _parties[index];
              return _buildPartyPerformanceCard(party);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPartyPerformanceCard(PoliticalParty party) {
    return GestureDetector(
      onTap: () {
        // Detay sayfasına yönlendirme yapılabilir
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${party.name} belediyelerinin başarı oranı: ${party.getFormattedRate()}'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  party.logoUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: party.getPartyColor(),
                      child: Center(
                        child: Text(
                          party.shortName.substring(0, 2),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              party.shortName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: party.getRateColor(),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                party.getFormattedRate(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}