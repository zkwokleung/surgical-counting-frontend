import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:surgical_counting/src/constants/backend.dart';
import 'package:surgical_counting/src/settings/settings_controller.dart';

// Fetch png images
Future<void> getInstrumentImageSingle(
    SettingsController settings, String instrumentName) async {
  final response = await http.get(
      Uri.parse(settings.apiUrl + instrumentImageSingleRoute + instrumentName));
  if (response.statusCode == 200) {
    if (kDebugMode) {
      print("fuck${response.body}");
    }
  } else {
    throw Exception('Failed to get instrument image');
  }
}
