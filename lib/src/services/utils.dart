import 'package:http/http.dart' as http;
import 'package:surgical_counting/src/constants/backend.dart';
import 'package:surgical_counting/src/settings/settings_controller.dart';

Future<bool> getServerStatus(SettingsController settings) async {
  final response =
      await http.get(Uri.parse(settings.apiUrl + serverStatusRoute));
  return response.statusCode == 200;
}
