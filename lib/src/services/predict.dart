import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:surgical_counting/src/constants/backend.dart';
import 'package:surgical_counting/src/models/responses.dart';

Future<PredictResponse> postPrediction(XFile image) async {
  PredictRequestBody requestBody = PredictRequestBody(image);

  final response = await http.post(
    Uri.parse(predict),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(await requestBody.toJson()),
  );

  print(response.body);

  if (response.statusCode == 200) {
    return PredictResponse.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to post prediction');
  }
}
