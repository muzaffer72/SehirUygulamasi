import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tema modu için state provider
final themeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

/// Tema tercihi için provider
final darkModeProvider = Provider<bool>((ref) {
  final themeMode = ref.watch(themeProvider);
  return themeMode == ThemeMode.dark;
});

/// Tema servisi
class ThemeService {
  static const String _themeKey = 'theme_mode';
  
  /// Tema tercihini kaydet
  static Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    String value = 'system';
    
    if (mode == ThemeMode.light) {
      value = 'light';
    } else if (mode == ThemeMode.dark) {
      value = 'dark';
    }
    
    await prefs.setString(_themeKey, value);
  }
  
  /// Tema tercihini yükle
  static Future<ThemeMode> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_themeKey);
    
    if (value == 'light') {
      return ThemeMode.light;
    } else if (value == 'dark') {
      return ThemeMode.dark;
    }
    
    return ThemeMode.system;
  }
}