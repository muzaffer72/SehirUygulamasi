import 'package:flutter/material.dart';
import 'package:belediye_iletisim_merkezi/models/political_party.dart';
import 'package:belediye_iletisim_merkezi/services/party_service.dart';

class PartyPerformanceScroll extends StatefulWidget {
  final double height;
  final bool autoScroll;
  final Duration scrollDuration;
  
  const PartyPerformanceScroll({
    super.key, 
    this.height = 120, 
    this.autoScroll = false,
    this.scrollDuration = const Duration(seconds: 20),
  });

  @override
  State<PartyPerformanceScroll> createState() => _PartyPerformanceScrollState();
}

class _PartyPerformanceScrollState extends State<PartyPerformanceScroll> {
  final PartyService _partyService = PartyService();
  bool _isLoading = true;
  String? _errorMessage;
  List<PoliticalParty> _parties = [];
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    _loadParties();
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  // Otomatik kaydırma için Timer
  void _setupAutoScroll() {
    if (!widget.autoScroll) return;
    
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      
      // Düzenli aralıklarla otomatik kaydırma
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startAutoScroll();
      });
    });
  }
  
  void _startAutoScroll() {
    if (!mounted || _scrollController.positions.isEmpty) return;
    
    final maxScrollExtent = _scrollController.position.maxScrollExtent;
    
    // Önce sağa doğru kaydır
    _scrollController.animateTo(
      maxScrollExtent,
      duration: widget.scrollDuration,
      curve: Curves.linear,
    ).then((_) {
      if (!mounted) return;
      
      // Sonra başa dön
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      ).then((_) {
        if (!mounted) return;
        
        // Tekrar başlat
        Future.delayed(const Duration(seconds: 1), () {
          _startAutoScroll();
        });
      });
    });
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
      
      // Verileri yükledikten sonra otomatik kaydırmayı başlat
      if (widget.autoScroll && parties.isNotEmpty) {
        _setupAutoScroll();
      }
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
        const SizedBox(height: 8),
        SizedBox(
          height: widget.height,
          child: ListView.separated(
            controller: _scrollController,
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