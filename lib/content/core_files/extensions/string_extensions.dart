String stringExtensionsFile() {
  return '''
extension StringExtensions on String {
  // ------------------------------------------------------------
  // VALIDATION
  // ------------------------------------------------------------

  bool get isValidEmail {
    return RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}\$').hasMatch(this);
  }

  /// Phone number validation
  bool get isValidPhone {
    return RegExp(r'^[+]*[(]?[0-9]{1,4}[)]?[-\s./0-9]*\$').hasMatch(this);
  }

  /// Validate if string contains only numbers
  bool get isNumeric => RegExp(r'^\d+\$').hasMatch(this);

  /// Validate if string contains only letters
  bool get isAlphabetic => RegExp(r'^[A-Za-z]+\$').hasMatch(this);

  /// Validate if string is strong password
  /// at least 8 chars, 1 letter, 1 number
  bool get isStrongPassword {
    return RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}\$').hasMatch(this);
  }

  // ------------------------------------------------------------
  // FORMATTING
  // ------------------------------------------------------------

  /// Capitalize first letter
  String capitalize() {
    if (trim().isEmpty) return this;
    return '\${this[0].toUpperCase()}\${substring(1)}';
  }

  /// Capitalize all words
  String get capitalizeWords {
    return split(' ')
        .map(
          (word) => word.isEmpty
              ? word
              : '\${word[0].toUpperCase()}\${word.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  /// Remove all whitespace
  String get removeWhitespace => replaceAll(RegExp(r'\s+'), '');

  /// Trim and reduce multiple spaces → single space
  String get normalizeSpaces => trim().replaceAll(RegExp(r'\s+'), ' ');

  /// Limit string to max length
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '\${substring(0, maxLength)}...';
  }

  /// Convert to snake_case
  String get toSnakeCase {
    return replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => '_\${match.group(0)!.toLowerCase()}',
    ).replaceFirst('_', '');
  }

  /// Convert to camelCase
  String get toCamelCase {
    final words = split(RegExp(r'[_\s-]+'));
    return words.first.toLowerCase() +
        words.skip(1).map((w) => w.capitalize()).join('');
  }

  // ------------------------------------------------------------
  // PARSING
  // ------------------------------------------------------------

  int? get toInt => int.tryParse(this);

  double? get toDouble => double.tryParse(this);

  bool? get toBool {
    final lower = toLowerCase();
    if (lower == 'true') return true;
    if (lower == 'false') return false;
    return null;
  }

  /// Convert to DateTime safely
  DateTime? get toDateTime => DateTime.tryParse(this);

  // ------------------------------------------------------------
  // CHECKERS
  // ------------------------------------------------------------

  bool get isNullOrEmpty => trim().isEmpty;

  bool get isNotNullOrEmpty => trim().isNotEmpty;

  /// Check if string contains any digit
  bool get containsNumber => RegExp(r'\d').hasMatch(this);

  /// Check if string contains emojis
  bool get containsEmoji => RegExp(
    r'[\u{1F600}-\u{1F64F}]|' // Emoticons
    r'[\u{1F300}-\u{1F5FF}]|' // Symbols & Pictographs
    r'[\u{1F680}-\u{1F6FF}]|' // Transport & Map
    r'[\u{1F1E0}-\u{1F1FF}]', // Flags
  ).hasMatch(this);

  /// Convert from "YYYY-MM-DD" → "DD/MM/YYYY"
  String get toDayMonthYear {
    try {
      final parts = split('-'); // [2025, 11, 25]
      if (parts.length != 3) return this;

      final year = parts[0];
      final month = parts[1];
      final day = parts[2];

      return "\$day/\$month/\$year";
    } catch (_) {
      return this;
    }
  }

  /// Convert from "DD/MM/YYYY" → "YYYY-MM-DD"
  String get toYearMonthDay {
    try {
      final parts = split('/'); // [25, 11, 2025]
      if (parts.length != 3) return this;

      final day = parts[0];
      final month = parts[1];
      final year = parts[2];

      return "\$year-\$month-\$day";
    } catch (_) {
      return this;
    }
  }
}

''';
}
