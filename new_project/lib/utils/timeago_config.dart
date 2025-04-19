import 'package:timeago/timeago.dart' as timeago;

/// Timeago kütüphanesini Türkçe dil desteği ile yapılandıran fonksiyon
void configureTimeAgo() {
  // Türkçe dilini kaydet
  timeago.setLocaleMessages('tr', TurkishMessages());
}

/// Türkçe zaman mesajları sınıfı
class TurkishMessages implements timeago.LookupMessages {
  @override
  String prefixAgo() => '';
  @override
  String prefixFromNow() => '';
  @override
  String suffixAgo() => 'önce';
  @override
  String suffixFromNow() => 'sonra';
  @override
  String lessThanOneMinute(int seconds) => 'az önce';
  @override
  String aboutAMinute(int minutes) => 'yaklaşık bir dakika';
  @override
  String minutes(int minutes) => '$minutes dakika';
  @override
  String aboutAnHour(int minutes) => 'yaklaşık bir saat';
  @override
  String hours(int hours) => '$hours saat';
  @override
  String aDay(int hours) => 'bir gün';
  @override
  String days(int days) => '$days gün';
  @override
  String aboutAMonth(int days) => 'yaklaşık bir ay';
  @override
  String months(int months) => '$months ay';
  @override
  String aboutAYear(int year) => 'yaklaşık bir yıl';
  @override
  String years(int years) => '$years yıl';
  @override
  String wordSeparator() => ' ';
}