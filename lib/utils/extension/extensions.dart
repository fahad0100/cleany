extension StringExtension on String {
  String toCapitalized() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }

  String toCapitalizeSecondWord() {
    if (!contains('_')) return this;

    final parts = split('_');
    if (parts.length < 2) return this;

    final first = parts.first;

    final rest = parts
        .skip(1)
        .map((word) {
          if (word.isEmpty) return '';
          return word[0].toUpperCase() + word.substring(1);
        })
        .join('');

    return first + rest;
  }

  String toLowerFirst() {
    if (isEmpty) return this;
    return this[0].toLowerCase() + substring(1);
  }
}
