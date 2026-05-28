extension StringExtension on String {
  String toCamelCase() {
    if (isEmpty) return this;

    // تقسيم النص بناءً على الشرطة السفلية
    final words = this.split('_');

    // أخذ الكلمة الأولى وتحويلها لأحرف صغيرة
    String result = words.first.toLowerCase();

    // المرور على باقي الكلمات، تكبير أول حرف، وتصغير الباقي
    for (int i = 1; i < words.length; i++) {
      final word = words[i];
      if (word.isNotEmpty) {
        result += word[0].toUpperCase() + word.substring(1).toLowerCase();
      }
    }

    return result;
  }

  //----
  String toSnakeCase() {
    if (isEmpty) return this;

    String result = replaceAllMapped(RegExp(r'[A-Z]'), (Match match) {
      return '_${match.group(0)?.toLowerCase()}';
    });

    if (result.startsWith('_')) {
      result = result.substring(1);
    }

    return result;
  }
}
