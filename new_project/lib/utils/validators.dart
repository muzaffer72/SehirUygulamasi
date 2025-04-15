import 'package:sikayet_var/utils/constants.dart';

// Validate email
String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'E-posta adresi gereklidir';
  }
  
  // Basic email validation pattern
  final emailPattern = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  
  if (!emailPattern.hasMatch(value)) {
    return 'Geçerli bir e-posta adresi giriniz';
  }
  
  return null;
}

// Validate password
String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Şifre gereklidir';
  }
  
  if (value.length < Constants.passwordMinLength) {
    return 'Şifre en az ${Constants.passwordMinLength} karakter olmalıdır';
  }
  
  return null;
}

// Validate confirm password
String? validateConfirmPassword(String? value, String password) {
  if (value == null || value.isEmpty) {
    return 'Şifre tekrarı gereklidir';
  }
  
  if (value != password) {
    return 'Şifreler eşleşmiyor';
  }
  
  return null;
}

// Validate name
String? validateName(String? value) {
  if (value == null || value.isEmpty) {
    return 'Ad Soyad gereklidir';
  }
  
  if (value.length < Constants.nameMinLength) {
    return 'Ad Soyad en az ${Constants.nameMinLength} karakter olmalıdır';
  }
  
  if (value.length > Constants.nameMaxLength) {
    return 'Ad Soyad en fazla ${Constants.nameMaxLength} karakter olmalıdır';
  }
  
  return null;
}

// Validate post title
String? validatePostTitle(String? value) {
  if (value == null || value.isEmpty) {
    return 'Başlık gereklidir';
  }
  
  if (value.length < Constants.titleMinLength) {
    return 'Başlık en az ${Constants.titleMinLength} karakter olmalıdır';
  }
  
  if (value.length > Constants.titleMaxLength) {
    return 'Başlık en fazla ${Constants.titleMaxLength} karakter olmalıdır';
  }
  
  return null;
}

// Validate post content
String? validatePostContent(String? value) {
  if (value == null || value.isEmpty) {
    return 'İçerik gereklidir';
  }
  
  if (value.length < Constants.contentMinLength) {
    return 'İçerik en az ${Constants.contentMinLength} karakter olmalıdır';
  }
  
  if (value.length > Constants.contentMaxLength) {
    return 'İçerik en fazla ${Constants.contentMaxLength} karakter olmalıdır';
  }
  
  return null;
}

// Validate comment
String? validateComment(String? value) {
  if (value == null || value.isEmpty) {
    return 'Yorum gereklidir';
  }
  
  if (value.length > Constants.maxCommentLength) {
    return 'Yorum en fazla ${Constants.maxCommentLength} karakter olmalıdır';
  }
  
  return null;
}

// Validate phone number (optional)
String? validatePhoneOptional(String? value) {
  if (value == null || value.isEmpty) {
    return null; // Phone is optional
  }
  
  // Turkish phone number pattern (10 digits, starting with 5)
  final phonePattern = RegExp(r'^0?5[0-9]{9}$');
  
  if (!phonePattern.hasMatch(value.replaceAll(RegExp(r'\s+'), ''))) {
    return 'Geçerli bir telefon numarası giriniz';
  }
  
  return null;
}

// Validate required fields
String? validateRequired(String? value, String fieldName) {
  if (value == null || value.isEmpty) {
    return '$fieldName alanı gereklidir';
  }
  
  return null;
}