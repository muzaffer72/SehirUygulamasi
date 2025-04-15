// Arama önerileri için model sınıfı
class SearchSuggestion {
  final int id;
  final String text;

  SearchSuggestion({
    required this.id,
    required this.text,
  });

  factory SearchSuggestion.fromJson(Map<String, dynamic> json) {
    return SearchSuggestion(
      id: json['id'] as int,
      text: json['text'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
    };
  }

  @override
  String toString() {
    return text;
  }
}