import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../models/political_party.dart';
import '../../services/party_service.dart';

class PartyPerformanceScroll extends StatefulWidget {
  final double height;
  final bool autoScroll;
  final Duration scrollDuration;
  final double itemWidth;
  final double spacing;

  const PartyPerformanceScroll({
    Key? key,
    this.height = 100,
    this.autoScroll = true,
    this.scrollDuration = const Duration(seconds: 30), // Tam devir süresi
    this.itemWidth = 110,
    this.spacing = 15,
  }) : super(key: key);

  @override
  _PartyPerformanceScrollState createState() => _PartyPerformanceScrollState();
}

class _PartyPerformanceScrollState extends State<PartyPerformanceScroll> {
  final PartyService _partyService = PartyService();
  List<PoliticalParty> _parties = [];
  bool _isLoading = true;
  Timer? _scrollTimer;
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    _loadParties();
    
    // Otomatik kaydırma için Timer
    if (widget.autoScroll) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startAutoScroll();
      });
    }
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  // Parti listesini yükle
  Future<void> _loadParties() async {
    try {
      final parties = await _partyService.getParties();
      setState(() {
        _parties = parties;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Partiler yüklenirken hata oluştu: $e');
    }
  }

  // Otomatik kaydırma işlevini başlat
  void _startAutoScroll() {
    // İlk önce tüm scroll width'ini hesapla
    final totalWidth = (_parties.length * (widget.itemWidth + widget.spacing)) + 100;
    
    if (totalWidth > MediaQuery.of(context).size.width) {
      _scrollTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
        if (_scrollController.hasClients) {
          // Scroll position kontrolü
          if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent) {
            // Sona geldiğinde başa dön
            _scrollController.jumpTo(0);
          } else {
            // Düzgün kaydırma
            _scrollController.animateTo(
              _scrollController.position.pixels + 1,
              duration: const Duration(milliseconds: 50),
              curve: Curves.linear,
            );
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SizedBox(
        height: widget.height,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_parties.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: const Center(
          child: Text('Parti verileri bulunamadı'),
        ),
      );
    }

    return Container(
      height: widget.height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 3,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: widget.autoScroll ? const NeverScrollableScrollPhysics() : const BouncingScrollPhysics(),
        itemCount: _parties.length,
        itemBuilder: (context, index) {
          final party = _parties[index];
          // HEX renk kodunu Color nesnesine dönüştür
          Color partyColor = _hexToColor(party.color);
          
          return Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 16 : widget.spacing / 2,
              right: index == _parties.length - 1 ? 16 : widget.spacing / 2,
            ),
            child: _buildPartyPerformanceItem(party, partyColor),
          );
        },
      ),
    );
  }

  Widget _buildPartyPerformanceItem(PoliticalParty party, Color partyColor) {
    return Container(
      width: widget.itemWidth,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: partyColor.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Parti logosu
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: party.logoUrl.endsWith('.svg')
                ? SvgPicture.asset(
                    party.logoUrl,
                    width: 48,
                    height: 48,
                  )
                : Image.network(
                    party.logoUrl,
                    width: 48,
                    height: 48,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 48,
                        height: 48,
                        color: partyColor.withOpacity(0.2),
                        child: Center(
                          child: Text(
                            party.shortName,
                            style: TextStyle(
                              color: partyColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
            ),
          ),
          
          const SizedBox(height: 4),
          
          // Parti kısa adı
          Text(
            party.shortName,
            style: TextStyle(
              color: partyColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          
          const SizedBox(height: 2),
          
          // Çözüm oranı
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: partyColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '%${party.problemSolvingRate.toStringAsFixed(1)}',
              style: TextStyle(
                color: partyColor,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // HEX renk kodunu Color nesnesine dönüştür
  Color _hexToColor(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF' + hexColor;
    }
    return Color(int.parse(hexColor, radix: 16));
  }
}