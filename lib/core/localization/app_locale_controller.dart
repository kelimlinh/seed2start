import 'package:flutter/material.dart';

import 'app_localizations.dart';

class AppLocaleController extends ChangeNotifier {
  AppLocaleController._();

  static final AppLocaleController instance = AppLocaleController._();

  Locale _locale = const Locale('vi');

  Locale get locale => _locale;

  bool supports(String languageCode) => AppLocalizations.supportedLocales.any(
        (locale) => locale.languageCode == languageCode,
      );

  void setLocaleCode(String languageCode) {
    if (!supports(languageCode) || _locale.languageCode == languageCode) {
      return;
    }

    _locale = Locale(languageCode);
    notifyListeners();
  }

  void resetToDefault() => setLocaleCode('vi');
}
