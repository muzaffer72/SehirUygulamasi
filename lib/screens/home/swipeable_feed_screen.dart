import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sikayet_var/screens/home/city_feed_screen.dart';
import 'package:sikayet_var/screens/home/district_feed_screen.dart';

class SwipeableFeedScreen extends ConsumerStatefulWidget {
  const SwipeableFeedScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SwipeableFeedScreen> createState() => _SwipeableFeedScreenState();
}

class _SwipeableFeedScreenState extends ConsumerState<SwipeableFeedScreen> with SingleTickerProviderStateMixin {
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
          tabs: const [
            Tab(
              icon: Icon(Icons.location_city),
              text: 'Şehir',
            ),
            Tab(
              icon: Icon(Icons.location_on),
              text: 'İlçe',
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