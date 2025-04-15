/// Form doğrulama işlemleri için yardımcı sınıf
class Validators {
  /// E-posta doğrulama
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'E-posta adresi gereklidir';
    }
    
    // E-posta formatı kontrolü
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(value)) {
      return 'Geçerli bir e-posta adresi giriniz';
    }
    
    return null;
  }
  
  /// Şifre doğrulama
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre gereklidir';
    }
    
    if (value.length < 6) {
      return 'Şifre en az 6 karakter olmalıdır';
    }
    
    return null;
  }
  
  /// İsim doğrulama
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'İsim gereklidir';
    }
    
    if (value.length < 2) {
      return 'İsim en az 2 karakter olmalıdır';
    }
    
    return null;
  }
  
  /// Telefon numarası doğrulama
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Telefon zorunlu değil
    }
    
    // Telefon formatı kontrolü (Türkiye için)
    final phoneRegExp = RegExp(r'^\d{10,11}$');
    if (!phoneRegExp.hasMatch(value.replaceAll(RegExp(r'\D'), ''))) {
      return 'Geçerli bir telefon numarası giriniz';
    }
    
    return null;
  }
  
  /// Şehir doğrulama
  static String? validateCity(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şehir seçimi gereklidir';
    }
    
    return null;
  }
  
  /// Boş alan kontrolü
  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Bu alan'} gereklidir';
    }
    
    return null;
  }
  
  /// URL doğrulama
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null; // URL zorunlu değil
    }
    
    // URL formatı kontrolü
    try {
      final uri = Uri.parse(value);
      if (!uri.hasScheme || !uri.hasAuthority) {
        return 'Geçerli bir URL giriniz';
      }
    } catch (e) {
      return 'Geçerli bir URL giriniz';
    }
    
    return null;
  }
  
  /// Şifre eşleşme kontrolü
  static String? validatePasswordMatch(String? value, String? confirmValue) {
    if (value == null || confirmValue == null || value.isEmpty || confirmValue.isEmpty) {
      return 'Her iki şifre alanı da gereklidir';
    }
    
    if (value != confirmValue) {
      return 'Şifreler eşleşmiyor';
    }
    
    return null;
  }
}