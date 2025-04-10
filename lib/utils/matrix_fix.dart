import 'package:vector_math/vector_math_64.dart' hide Colors;

// Genel Flutter Matrix4 sorunlarını gidermek için oluşturulan yardımcı sınıf
class Matrix4Fix {
  // Matrix4 sınıfı için eksik metodlar veya yardımcı fonksiyonlar
  static Matrix4 zero() => Matrix4.zero();
  static Matrix4 identity() => Matrix4.identity();
  static Matrix4 diagonal3Values(double x, double y, double z) => Matrix4.diagonal3Values(x, y, z);
  static Matrix4 translationValues(double x, double y, double z) => Matrix4.translationValues(x, y, z);
}