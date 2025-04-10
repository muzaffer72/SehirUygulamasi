// Matrix4 sorununu çözmek için geçici bir sınıf

import 'package:vector_math/vector_math.dart';

// Flutter içindeki Matrix4 tipiyle çakışmaları önlemek için
// kendi Matrix4 sınıfımızı burada tanımlıyoruz
class Matrix4Fix {
  // Matrix4'ün temel özelliklerini burada tanımlayabiliriz
  // veya gerektiğinde vector_math paketini kullanabiliriz
  
  static Matrix4Fix identity() {
    return Matrix4Fix();
  }
}

// Uygulama içinde gerektiğinde bu sınıfı kullanabiliriz