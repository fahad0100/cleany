extension StringExtension on String {
  String toCapitalized() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }

  String toCapitalizeSecondWord() {
    if (!contains('_')) return this;

    final parts = split('_');
    if (parts.length < 2) return this;

    final first = parts[0];
    final second = parts[1];

    // تحويل أول حرف من الكلمة الثانية إلى كبتل
    final formattedSecond = second.isNotEmpty
        ? second[0].toUpperCase() + second.substring(1)
        : '';

    return first + formattedSecond;
  }
}
