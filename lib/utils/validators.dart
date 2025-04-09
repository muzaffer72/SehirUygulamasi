// Validates an email address
String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'E-posta adresi gereklidir';
  }
  
  final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  if (!emailRegex.hasMatch(value)) {
    return 'Geçerli bir e-posta adresi giriniz';
  }
  
  return null;
}

// Validates a password
String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Şifre gereklidir';
  }
  
  if (value.length < 6) {
    return 'Şifre en az 6 karakter olmalıdır';
  }
  
  return null;
}

// Validates a name
String? validateName(String? value) {
  if (value == null || value.isEmpty) {
    return 'Ad gereklidir';
  }
  
  if (value.length < 2) {
    return 'Ad en az 2 karakter olmalıdır';
  }
  
  return null;
}

// Validates a phone number
String? validatePhone(String? value) {
  if (value == null || value.isEmpty) {
    return null; // Phone number is optional
  }
  
  final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
  if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'\s+'), ''))) {
    return 'Geçerli bir telefon numarası giriniz';
  }
  
  return null;
}

// Validates a post title
String? validatePostTitle(String? value) {
  if (value == null || value.isEmpty) {
    return 'Başlık gereklidir';
  }
  
  if (value.length < 5) {
    return 'Başlık en az 5 karakter olmalıdır';
  }
  
  if (value.length > 100) {
    return 'Başlık en fazla 100 karakter olmalıdır';
  }
  
  return null;
}

// Validates a post content
String? validatePostContent(String? value) {
  if (value == null || value.isEmpty) {
    return 'İçerik gereklidir';
  }
  
  if (value.length < 20) {
    return 'İçerik en az 20 karakter olmalıdır';
  }
  
  if (value.length > 1000) {
    return 'İçerik en fazla 1000 karakter olmalıdır';
  }
  
  return null;
}

// Validates a comment
String? validateComment(String? value) {
  if (value == null || value.isEmpty) {
    return 'Yorum gereklidir';
  }
  
  if (value.length < 2) {
    return 'Yorum en az 2 karakter olmalıdır';
  }
  
  if (value.length > 500) {
    return 'Yorum en fazla 500 karakter olmalıdır';
  }
  
  return null;
}

// A general purpose validator that checks if a value is required
String? validateRequired(value, String fieldName) {
  if (value == null || (value is String && value.isEmpty)) {
    return '$fieldName gereklidir';
  }
  
  return null;
}