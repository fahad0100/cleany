String stringExtensionsFile() {
  return '''
// string_extensions.dart
extension StringExtensions on String {
  // Validation
  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}\$').hasMatch(this);
  }

  bool get isValidPhone {
    return RegExp(r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*\$').hasMatch(this);
  }

  // Formatting
  String capitalize() {
    if (isEmpty) return this;
    return '\${this[0].toUpperCase()}\${substring(1)}';
  }

  String get removeWhitespace => replaceAll(' ', '');
  
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '\${substring(0, maxLength)}...';
  }

  // Parsing
  int? get toInt => int.tryParse(this);
  double? get toDouble => double.tryParse(this);
}
''';
}
