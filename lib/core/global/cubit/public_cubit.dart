import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';
import 'package:injectable/injectable.dart';
import 'public_cubit_state.dart';
import '../../services/local_keys_service.dart';

@lazySingleton
class GlobalCubit extends Cubit<ChangeState> {
  final GetStorage _box;
  final LocalKeysService _localKey;
  ThemeMode _currentTheme = ThemeMode.light;
  Locale _currentLanguage = Locale('en', 'US');

  GlobalCubit(this._box, this._localKey) : super(ChangeState());

  void changeTheme() async {
    switch (_currentTheme) {
      case ThemeMode.light:
        _currentTheme = ThemeMode.dark;
        break;
      case ThemeMode.dark:
        _currentTheme = ThemeMode.light;
        break;
      default:
        _currentTheme = ThemeMode.light;
    }

    await _box.write(_localKey.theme, _currentTheme.index);
    await _box.save();
    emit(state.copyWith(locale: _currentLanguage, themeMode: _currentTheme));
  }

  void changeLanguage({required BuildContext context}) async {
    if (context.locale == Locale('en', 'US')) {
      _currentLanguage = Locale('ar', 'AR');
    } else {
      _currentLanguage = Locale('en', 'US');
    }
    await context.setLocale(_currentLanguage);
    await _box.write(_localKey.language, _currentLanguage.toString());
    await _box.save();
    // context.savedLocale;
    emit(state.copyWith(locale: _currentLanguage, themeMode: _currentTheme));
  }

  void load({required BuildContext context}) async {
    if (_box.hasData(_localKey.language)) {
      final languageCode = _box.read(_localKey.language) as String;
      switch (languageCode) {
        case 'en_US':
          _currentLanguage = Locale('ar', 'AR');
          break;
        case 'ar_AR':
          _currentLanguage = Locale('en', 'US');
          break;
      }
    } else {
      _currentLanguage = Locale('en', 'US');
      await context.setLocale(_currentLanguage);
      await _box.write(_localKey.language, _currentLanguage.languageCode);
    }
    if (_box.hasData(_localKey.theme)) {
      final themeIndex = _box.read(_localKey.theme) as int;
      _currentTheme = ThemeMode.values[themeIndex];
    } else {
      _currentTheme = ThemeMode.values[1];
      await _box.write(_localKey.theme, 1);
    }

    await _box.save();
    emit(state.copyWith(locale: _currentLanguage, themeMode: _currentTheme));
  }
}

