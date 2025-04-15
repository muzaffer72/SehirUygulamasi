// Flutter web derleme sorununu çözmek için List extension'ı
extension FlattenExtension<T> on List<List<T>> {
  // 'flattened' extension metodu - yuvalanmış listeler için düzleştirme işlemi yapar
  List<T> get flattened {
    final List<T> result = [];
    for (final list in this) {
      result.addAll(list);
    }
    return result;
  }
}