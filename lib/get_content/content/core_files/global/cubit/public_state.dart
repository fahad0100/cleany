String createGlobalStateFile() {
  return '''
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class ChangeState extends Equatable {
  final ThemeMode themeMode;
  final Locale locale;

  const ChangeState({
    this.themeMode = ThemeMode.light,
    this.locale = const Locale('en', 'US'),
  });

  ChangeState copyWith({ThemeMode? themeMode, Locale? locale}) {
    return ChangeState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
    );
  }

  @override
  List<Object?> get props => [themeMode, locale];
}

''';
}
