import 'package:flutter/material.dart';

/// UI preferences are separate from authentication and business data.
class StorePreferences extends ChangeNotifier {
  Locale locale = const Locale('en');
  void toggleLanguage() {
    locale = Locale(locale.languageCode == 'en' ? 'ar' : 'en');
    notifyListeners();
  }
}
