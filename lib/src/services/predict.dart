import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:surgical_counting/src/constants/backend.dart';
import 'package:surgical_counting/src/models/responses.dart';
import 'package:surgical_counting/src/settings/settings_controller.dart';

Future<PredictResponse> postPrediction(
    SettingsController settings, XFile image) async {
  PredictRequestBody requestBody = PredictRequestBody(image);

  final response = await http.post(
    Uri.parse(settings.apiUrl + predictRoute),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(await requestBody.toJson()),
  );

  if (response.statusCode == 200) {
    return PredictResponse.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to post prediction');
  }
}
