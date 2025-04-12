import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sikayet_var/utils/matrix_fix.dart';
import 'package:sikayet_var/utils/ticker_fix.dart';
import 'package:sikayet_var/screens/home/city_feed_screen.dart';
import 'package:sikayet_var/screens/home/district_feed_screen.dart';

class SwipeableFeedScreen extends ConsumerStatefulWidget {
  const SwipeableFeedScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SwipeableFeedScreen> createState() => _SwipeableFeedScreenState();
}

class _SwipeableFeedScreenState extends ConsumerState<SwipeableFeedScreen> with SafeSingleTickerProviderStateMixin {
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<TabController>('_tabController', _tabController));
  }
  
  @override
  void activate() {
    super.activate();
  }
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ŞikayetVar'),
        bottom: TabBar(
          controller: _tabController,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          indicatorWeight: 2.0,
          indicatorColor: Theme.of(context).colorScheme.primary,
          tabs: const [
            Tab(
              text: 'Şehrindeki Gönderiler',
            ),
            Tab(
              text: 'İlçendeki Gönderiler',
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bildirimler yakında eklenecek')),
              );
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          // Şehir gönderileri
          CityFeedScreen(),
          
          // İlçe gönderileri
          DistrictFeedScreen(),
        ],
      ),
    );
  }
}