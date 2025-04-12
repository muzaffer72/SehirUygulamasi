// Bu dosya, native platformlar için compatibility sağlar
// Web olmayan Flutter platformları için kullanılır

import 'package:vector_math/vector_math.dart' as vector_math;
export 'package:vector_math/vector_math.dart' hide Colors; // Colors çakışmasını önle

/// Native platformlar için sabit kurulum ve boş bir fonksiyon
void initializeWebCompatibility() {
  // Native platformlarda yapılması gereken bir şey yok
}

/// Native platformlar için Matrix4 yardımcı sınıfı
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

/// Native platformlar için Vector3 yardımcı sınıfı
class IOVector3 {
  static vector_math.Vector3 create(double x, double y, double z) {
    return vector_math.Vector3(x, y, z);
  }
}