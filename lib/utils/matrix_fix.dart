// vector_math sorunlarından kaçınmak için kendi Matrix4 sınıfımızı implementasyonu

// Temel Matrix4 sınıfı
class Matrix4 {
  // 4x4 matris temsili için iç veri
  final List<double> _storage = List.filled(16, 0.0);
  
  // İçerik oluşturucular
  Matrix4.zero();
  
  Matrix4.identity() {
    _storage[0] = 1.0;
    _storage[5] = 1.0;
    _storage[10] = 1.0;
    _storage[15] = 1.0;
  }
  
  Matrix4.diagonal3Values(double x, double y, double z) {
    _storage[0] = x;
    _storage[5] = y;
    _storage[10] = z;
    _storage[15] = 1.0;
  }
  
  Matrix4.translationValues(double x, double y, double z) {
    _storage[0] = 1.0;
    _storage[5] = 1.0;
    _storage[10] = 1.0;
    _storage[15] = 1.0;
    _storage[12] = x;
    _storage[13] = y;
    _storage[14] = z;
  }
  
  // Setter ve getter metodları
  double operator [](int index) => _storage[index];
  void operator []=(int index, double value) => _storage[index] = value;
}

// Vector3 sınıfı için basit implementasyon
class Vector3 {
  double x, y, z;
  
  Vector3(this.x, this.y, this.z);
  Vector3.zero() : x = 0.0, y = 0.0, z = 0.0;
}

// Quad sınıfı için basit implementasyon
class Quad {
  final List<Vector3> points = List.filled(4, Vector3.zero());
  
  Quad();
}

// Matrix4 yardımcı fonksiyonları
class Matrix4Fix {
  static Matrix4 zero() => Matrix4.zero();
  static Matrix4 identity() => Matrix4.identity();
  static Matrix4 diagonal3Values(double x, double y, double z) => Matrix4.diagonal3Values(x, y, z);
  static Matrix4 translationValues(double x, double y, double z) => Matrix4.translationValues(x, y, z);
}