import 'dart:convert';

import 'package:camera/camera.dart';

import 'generic.dart';

class PredictRequestBody {
  final XFile image;

  PredictRequestBody(this.image);

  Future<Map<String, String>> toJson() async {
    // Encode with base64
    final bytes = await image.readAsBytes();
    final base64Image = base64Encode(bytes);
    return <String, String>{
      'image': base64Image,
    };
  }
}

class PredictResponse {
  final XFile image;
  final List<Tuple2<int, String>> objects;

  PredictResponse(this.image, this.objects);

  factory PredictResponse.fromJson(Map<String, dynamic> json) {
    final objects = <Tuple2<int, String>>[];
    for (final object in json['objects']) {
      objects.add(Tuple2(object[0], object[1]));
    }

    // Decode base64
    final bytes = base64Decode(json['image']);
    final image = XFile.fromData(bytes);

    return PredictResponse(image, objects);
  }
}
