import 'package:flutter/material.dart';
import 'package:surgical_counting/src/constants/backend.dart';
import 'package:surgical_counting/src/constants/instruments.dart';

class SettingsService {
  Future<ThemeMode> themeMode() async => ThemeMode.system;

  Future<String> language() async => 'en';

  Future<String> apiUrl() async => defaultApiUrl;

  Future<Map<String, Map<String, dynamic>>> instruments() async =>
      defaultInstrumentsData;

  Future<void> updateThemeMode(ThemeMode theme) async {}

  Future<void> updateLanguage(String language) async {}

  Future<void> updateApiUrl(String url) async {}

  Future<void> updateInstruments(
      Map<String, Map<String, dynamic>> instruments) async {}
}
