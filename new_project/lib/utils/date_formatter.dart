import 'package:intl/intl.dart';

class DateFormatter {
  /// Tarihi göreli formatta döner (örn: "2 saat önce", "3 gün önce")
  static String formatRelative(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inSeconds < 60) {
      return 'Az önce';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} dakika önce';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} saat önce';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün önce';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks hafta önce';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ay önce';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years yıl önce';
    }
  }
  
  /// Çözüm bekleme süresi için özel format (örn: "12 gündür çözüm bekliyor")
  static String formatWaitingForSolution(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays < 1) {
      return 'Bugün paylaşıldı';
    } else {
      return '${difference.inDays} gündür çözüm bekliyor';
    }
  }
  
  /// Kısa tarih formatı: 01.01.2023
  static String formatShortDate(DateTime dateTime) {
    return DateFormat('dd.MM.yyyy').format(dateTime);
  }
  
  /// Tam tarih formatı: 01 Ocak 2023, 14:30
  static String formatFullDate(DateTime dateTime) {
    final monthNames = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];
    
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = monthNames[dateTime.month - 1];
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    
    return '$day $month $year, $hour:$minute';
  }
  
  /// Haftanın günü ve tarih: Pazartesi, 01 Ocak
  static String formatDayAndDate(DateTime dateTime) {
    final dayNames = [
      'Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 
      'Cuma', 'Cumartesi', 'Pazar'
    ];
    
    final monthNames = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];
    
    // Türkçe'de hafta Pazartesi'den başlar, Dart'ta Pazartesi 1'dir
    final day = dayNames[(dateTime.weekday - 1) % 7];
    final monthDay = dateTime.day.toString().padLeft(2, '0');
    final month = monthNames[dateTime.month - 1];
    
    return '$day, $monthDay $month';
  }
  
  /// Tarih aralığı formatı: 01 - 15 Ocak 2023
  static String formatDateRange(DateTime startDate, DateTime endDate) {
    final monthNames = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];
    
    final startDay = startDate.day.toString().padLeft(2, '0');
    final endDay = endDate.day.toString().padLeft(2, '0');
    
    // Aynı ay ve yıl içindeyse
    if (startDate.month == endDate.month && startDate.year == endDate.year) {
      final month = monthNames[startDate.month - 1];
      final year = startDate.year;
      return '$startDay - $endDay $month $year';
    } 
    // Aynı yıl içinde ama farklı aylardaysa
    else if (startDate.year == endDate.year) {
      final startMonth = monthNames[startDate.month - 1];
      final endMonth = monthNames[endDate.month - 1];
      final year = startDate.year;
      return '$startDay $startMonth - $endDay $endMonth $year';
    } 
    // Farklı yıllardaysa
    else {
      final startMonth = monthNames[startDate.month - 1];
      final endMonth = monthNames[endDate.month - 1];
      final startYear = startDate.year;
      final endYear = endDate.year;
      return '$startDay $startMonth $startYear - $endDay $endMonth $endYear';
    }
  }
}