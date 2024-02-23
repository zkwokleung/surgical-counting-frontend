import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:surgical_counting/src/widgets/camera.dart';
import 'package:surgical_counting/src/widgets/dash_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../services/predict.dart';

class DetectionScreen extends StatefulWidget {
  const DetectionScreen({
    super.key,
    required this.camera,
  });

  static const String routeName = '/detection';

  final CameraDescription camera;

  @override
  State<DetectionScreen> createState() => _DetectionScreenState();
}

class _DetectionScreenState extends State<DetectionScreen> {
  // Cameras
  bool isCameraOn = false;
  late CameraController _cameraController;
  late Future<void> _initializeCameraControllerFuture;

  // Image
  XFile? imageFile;

  // Info
  String info = '';

  void toggleCamera() async {
    setState(() {
      isCameraOn = !isCameraOn;
    });
  }

  Future<XFile> captureImage() async {
    try {
      await _initializeCameraControllerFuture;

      return await _cameraController.takePicture();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      throw Exception('Failed to capture image');
    }
  }

  void predict() async {
    try {
      final XFile file = await captureImage();

      final response = await postPrediction(file);
      setState(() {
        imageFile = response.image;
        info = response.objects.toString();
      });
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _cameraController = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );

    _initializeCameraControllerFuture = _cameraController.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Left Panel
            Expanded(
              flex: 6,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: DashCard(
                      title: AppLocalizations.of(context)!.camera,
                      backgroundColor: Colors.blue[800],
                      floatingActionButton: FloatingActionButton(
                        onPressed: toggleCamera,
                        child: const Icon(Icons.camera_alt),
                      ),
                      child: isCameraOn
                          ? Camera(camera: widget.camera)
                          : const Icon(Icons.camera_alt),
                    ),
                  ),
                  Expanded(
                    child: DashCard(
                      title: AppLocalizations.of(context)!.detection,
                      backgroundColor: Colors.green[800],
                      child: imageFile != null
                          ? (kIsWeb)
                              ? Image.network(imageFile!.path)
                              : Image.file(
                                  File(imageFile!.path),
                                )
                          : const Icon(Icons.image),
                    ),
                  ),
                ],
              ),
            ),

            // Right Panel
            Expanded(
              flex: 4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    flex: 8,
                    child: DashCard(
                      title: AppLocalizations.of(context)!.information,
                      backgroundColor: Colors.red[800],
                      child: info.isNotEmpty
                          ? Text(info)
                          : Text(
                              AppLocalizations.of(context)!.contentUnavailable,
                            ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: DashCard(
                      title: AppLocalizations.of(context)!.controlPanel,
                      backgroundColor: Colors.yellow[800],
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Expanded(
                            child: ElevatedButton(
                              onPressed: predict,
                              child:
                                  Text(AppLocalizations.of(context)!.capture),
                            ),
                          ),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  imageFile = null;
                                });
                              },
                              child: Text(AppLocalizations.of(context)!.clear),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
