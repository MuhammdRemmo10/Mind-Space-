import 'package:flutter/widgets.dart';

import 'generated/app_localizations.dart';

extension AppLocalizationExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
