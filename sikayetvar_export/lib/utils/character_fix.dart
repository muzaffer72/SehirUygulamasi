// Flutter's Characters sınıfının bir mock implementasyonu
// Bu dosya, Characters sınıfı ile ilgili derleme hatalarını çözmek için oluşturulmuştur

class Characters {
  final String _text;
  
  Characters(this._text);
  
  String characterAt(int index) {
    if (index >= 0 && index < _text.length) {
      return _text[index];
    }
    return '';
  }
  
  int get length => _text.length;
  
  @override
  String toString() => _text;
}

extension CharactersExtension on String {
  Characters get characters => Characters(this);
}