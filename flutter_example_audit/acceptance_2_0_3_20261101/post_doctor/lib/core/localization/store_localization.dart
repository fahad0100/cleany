import 'package:flutter/widgets.dart';

import '../errors/failure.dart';
import 'generated/app_localizations.dart';
export 'generated/app_localizations.dart';

extension StoreLocalization on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
  String failureText(Failure failure) => switch (failure) {
    NetworkFailure() => l10n.networkError,
    UnauthorizedFailure() => l10n.invalidCredentials,
    ValidationFailure() => l10n.invalidData,
    ServerFailure() => l10n.serverError,
    _ => l10n.genericError,
  };
}
