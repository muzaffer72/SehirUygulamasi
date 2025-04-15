import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/city_profile.dart';
import '../../providers/city_profile_provider.dart';
import '../location/city_profile_screen.dart' as location;

// Bu sınıf, eski ve yeni API arasında köprü görevi görür
class CityProfileScreen extends ConsumerWidget {
  final String cityId;

  const CityProfileScreen({
    Key? key,
    required this.cityId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Eski API ile uyumlu ekranı kullanıyoruz
    return location.CityProfileScreen(cityId: cityId);
  }
}