import 'package:cleany/utils/file_modifier.dart';

String createGlobalCubitFile() {
  final projectName = FileModifier.getProjectName();

  return '''
import 'package:easy_localization/easy_localization.dart';
import 'package:$projectName/core/constants/app_enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:$projectName/core/global/cubit/public_state.dart';
import 'package:$projectName/core/services/local_keys_service.dart';

@lazySingleton
class GlobalCubit extends Cubit<ChangeState> {
  final GetStorage _box;
  final LocalKeysService _localKey;

  GlobalCubit(this._box, this._localKey) : super(ChangeState());

  Future<void> changeLanguage({
    required BuildContext context,
    required LanguagesEnum lang,
  }) async {
    final newLocale = lang == LanguagesEnum.en ? Locale('en') : Locale('ar');
    await _box.write(_localKey.language, newLocale.languageCode);
    if (context.mounted) {
      await context.setLocale(newLocale);
    }

    if (context.mounted) {
      context.savedLocale;
    }
    await Future.delayed(Duration.zero);

    emit(ChangeImageLoadedState());
    WidgetsBinding.instance.performReassemble();
  }

  void load({required BuildContext context}) async {
    Locale currentLocale = Locale('en');

    if (_box.hasData(_localKey.language)) {
      final languageCode = _box.read(_localKey.language) as String;
      currentLocale = Locale(languageCode);
    }

    context.setLocale(currentLocale);
    context.savedLocale;
    await Future.delayed(Duration.zero);

    emit(ChangeImageLoadedState());
    WidgetsBinding.instance.performReassemble();
  }
}


''';
}
