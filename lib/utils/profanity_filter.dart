class ProfanityFilter {
  // Yasaklı kelimeler listesi (admin panelden güncellenebilir)
  static List<String> _bannedWords = [
    // Türkçe yasaklı kelimeler - örnek
    "küfür",
    "hakaret",
    "sövmek",
    // Diğer dillerdeki yasaklı kelimeler eklenebilir
  ];

  // Kelime listesini güncelleme
  static void updateBannedWords(List<String> newWords) {
    _bannedWords = newWords;
  }

  // Kelime listesine yeni kelime ekleme
  static void addBannedWord(String word) {
    if (!_bannedWords.contains(word)) {
      _bannedWords.add(word);
    }
  }

  // Metinde yasaklı kelime kontrolü
  static bool containsProfanity(String text) {
    final lowerText = text.toLowerCase();
    
    // Basit kontrol - metinde yasaklı kelime var mı
    for (var word in _bannedWords) {
      if (lowerText.contains(word.toLowerCase())) {
        return true;
      }
    }
    
    return false;
  }

  // Yasaklı kelimeleri *** ile değiştirme
  static String censorText(String text) {
    String censoredText = text;
    
    for (var word in _bannedWords) {
      final replacement = '*' * word.length;
      final regex = RegExp(word, caseSensitive: false);
      censoredText = censoredText.replaceAll(regex, replacement);
    }
    
    return censoredText;
  }
}