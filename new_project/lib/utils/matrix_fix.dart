// Flutter web için vector_math düzeltmesi
// Bu modül Matrix4 ve Vector3 sınıflarını flutter_web kullanımı için yeniden ihraç eder

// Re-export the types used in this app
import 'package:vector_math/vector_math.dart' as vector_math;

export 'package:vector_math/vector_math.dart' show Matrix4, Vector3, Vector4, Quad, Matrix3;

// Global uyumluluk sınıfları
class Matrix4Fix {
  static vector_math.Matrix4 zero() => vector_math.Matrix4.zero();
  static vector_math.Matrix4 identity() => vector_math.Matrix4.identity();
  static vector_math.Matrix4 diagonal3Values(double x, double y, double z) => 
    vector_math.Matrix4.diagonal3Values(x, y, z);
  static vector_math.Matrix4 translationValues(double x, double y, double z) => 
    vector_math.Matrix4.translation(vector_math.Vector3(x, y, z));
}

// Helper kısaltmalar
typedef Matrix4 = vector_math.Matrix4;
typedef Vector3 = vector_math.Vector3;