// Flutter web uyumluluğu için gerekli import ve export sınıfları
// Flutter web'in Matrix4 ve Vector3 sınıflarıyla ilgili sorunlarını çözmek için

import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:vector_math/vector_math.dart' as vector_math;

// Vector Math'den önemli sınıfları seçerek export edelim, Colors sınıfını export etmeyelim
export 'package:vector_math/vector_math.dart' 
    hide Colors; // Flutter'ın kendi Colors sınıfıyla çakışmaması için

/// Web uyumluluğuna yönelik initizeleme
void initializeWebCompatibility() {
  // Sadece debug modunda mesaj göster
  if (kDebugMode) {
    print('Flutter Web uyumluluğu için vector_math kütüphanesi kullanılıyor');
  }
}

/// Web uyumluluğu için Ticker nesneleri oluşturmak amacıyla yardımcı fonksiyon
/// Bu kısım, doğrudan vector_math kütüphanesini kullanmak için gerekli
class WebCompatMatrix4 {
  static vector_math.Matrix4 identity() {
    return vector_math.Matrix4.identity();
  }
  
  static vector_math.Matrix4 translation(vector_math.Vector3 translation) {
    return vector_math.Matrix4.translation(translation);
  }
  
  static vector_math.Matrix4 translationValues(double x, double y, double z) {
    return vector_math.Matrix4.translation(vector_math.Vector3(x, y, z));
  }
}

/// İhtiyaç duyulan Vector3 ve Matrix4 fonksiyonlarını sağlar
class WebCompatVector3 {
  static vector_math.Vector3 create(double x, double y, double z) {
    return vector_math.Vector3(x, y, z);
  }
}

/// IO platformu için gerekli sınıflar
/// Bu kısım aslında kullanılmayan ama karşılığı olması gereken bir kısım
class IOMatrix4 {
  static vector_math.Matrix4 identity() {
    return vector_math.Matrix4.identity();
  }
  
  static vector_math.Matrix4 translation(vector_math.Vector3 translation) {
    return vector_math.Matrix4.translation(translation);
  }
  
  static vector_math.Matrix4 translationValues(double x, double y, double z) {
    return vector_math.Matrix4.translation(vector_math.Vector3(x, y, z));
  }
}

/// IO platformu için Vector3 karşılığı
class IOVector3 {
  static vector_math.Vector3 create(double x, double y, double z) {
    return vector_math.Vector3(x, y, z);
  }
}