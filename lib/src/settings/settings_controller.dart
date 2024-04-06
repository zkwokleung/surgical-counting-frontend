import 'package:flutter/material.dart';

import 'settings_service.dart';

class SettingsController with ChangeNotifier {
  SettingsController(this._settingsService);

  final SettingsService _settingsService;

  late ThemeMode _themeMode;
  ThemeMode get themeMode => _themeMode;

  late String _language;
  String get language => _language;

  late String _apiUrl;
  String get apiUrl => _apiUrl;

  Future<void> loadSettings() async {
    _themeMode = await _settingsService.themeMode();
    _language = await _settingsService.language();
    _apiUrl = await _settingsService.apiUrl();

    notifyListeners();
  }

  Future<void> updateThemeMode(ThemeMode? newThemeMode) async {
    if (newThemeMode == null) return;

    if (newThemeMode == _themeMode) return;

    _themeMode = newThemeMode;

    notifyListeners();

    await _settingsService.updateThemeMode(newThemeMode);
  }

  Future<void> updateLanguage(String newLanguage) async {
    if (newLanguage == _language) return;

    _language = newLanguage;

    notifyListeners();

    await _settingsService.updateLanguage(newLanguage);
  }

  Future<void> updateApiUrl(String newApiUrl) async {
    if (newApiUrl == _apiUrl) return;

    _apiUrl = newApiUrl;

    notifyListeners();

    await _settingsService.updateApiUrl(newApiUrl);
  }
}
