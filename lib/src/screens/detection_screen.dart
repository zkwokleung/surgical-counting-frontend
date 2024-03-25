import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:surgical_counting/src/constants/instruments.dart';
import 'package:surgical_counting/src/models/instruments.dart';
import 'package:surgical_counting/src/services/predict.dart';
import 'package:surgical_counting/src/services/utils.dart';
import 'package:surgical_counting/src/widgets/camera.dart';
import 'package:surgical_counting/src/widgets/dash_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:surgical_counting/src/widgets/detection_information_pannel.dart';
import 'package:surgical_counting/src/widgets/detection_server_status.dart';

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

  // Server status
  bool isServerOn = false;

  // Instrument status
  late Map<String, dynamic> instrumentsStatus = {};

  void resetInstrumentsStatus() {
    instrumentsStatus = Map.from(surgicalInstruments
        .map((key, value) => MapEntry(key, InstrumentStatus())));
  }

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

  void checkServerStatus() async {
    try {
      final status = await getServerStatus();
      setState(() {
        isServerOn = status;
      });
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  void predict() async {
    try {
      resetInstrumentsStatus();

      final XFile file = await captureImage();

      final response = await postPrediction(file);
      setState(() {
        imageFile = response.image;
        info = response.objects.toString();
      });

      // Update instruments status
      for (int i = 0; i < response.objects.length; i++) {
        final instrument = surgicalInstruments[response.objects[i].item2];
        if (instrument != null) {
          instrumentsStatus[response.objects[i].item2]!.qty += 1;
          instrumentsStatus[response.objects[i].item2]!.order = i;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  @override
  void initState() {
    super.initState();

    // Variables
    resetInstrumentsStatus();

    // System Chrome
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

    // Camera initialization
    _cameraController = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );

    _initializeCameraControllerFuture = _cameraController.initialize();

    // Lock camera orientation
    // If it is not running on chrome
    if (!kIsWeb) {
      _cameraController
          .lockCaptureOrientation(DeviceOrientation.landscapeRight);
    }
  }

  @override
  void dispose() {
    // System Chrome
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

    // Camera
    _cameraController.dispose();

    super.dispose();
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
              flex: 5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Camera
                  Expanded(
                    child: DashCard(
                      title: AppLocalizations.of(context)!.camera,
                      backgroundColor: Colors.grey[600],
                      floatingActionButton: FloatingActionButton(
                        onPressed: toggleCamera,
                        child: const Icon(Icons.camera_alt),
                      ),
                      child: isCameraOn
                          ? Camera(camera: widget.camera)
                          : Container(
                              width: MediaQuery.of(context).size.width / 2.8,
                              height: double.infinity,
                              color: Colors.black,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    AppLocalizations.of(context)!.camOffMsg,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),

                  // Result
                  Expanded(
                    child: DashCard(
                      title: AppLocalizations.of(context)!.detection,
                      backgroundColor: Colors.grey[600],
                      child: imageFile != null
                          ? (kIsWeb)
                              ? Image.network(imageFile!.path)
                              : Image.file(
                                  File(imageFile!.path),
                                )
                          : Container(
                              color: Colors.black,
                              width: MediaQuery.of(context).size.width / 2.8,
                              height: double.infinity,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  const Icon(
                                    Icons.image_not_supported,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    AppLocalizations.of(context)!.noPreviewMsg,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),

            // Right Panel
            Expanded(
              flex: 5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  // Information
                  Expanded(
                    flex: 8,
                    child: DetectionInformationPannel(
                      instrumentsStatus: instrumentsStatus,
                    ),
                  ),

                  // Server Status
                  const Expanded(flex: 2, child: DetectionServerStatus()),

                  // Control Panel
                  Expanded(
                    flex: 2,
                    child: DashCard(
                      title: AppLocalizations.of(context)!.controlPanel,
                      backgroundColor: Colors.grey[600],
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  imageFile = null;
                                  resetInstrumentsStatus();
                                });
                              },
                              child: Text(AppLocalizations.of(context)!.clear),
                            ),
                          ),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: predict,
                              child:
                                  Text(AppLocalizations.of(context)!.capture),
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
