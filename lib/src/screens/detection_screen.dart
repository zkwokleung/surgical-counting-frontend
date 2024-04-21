import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:surgical_counting/src/constants/design.dart';
import 'package:surgical_counting/src/constants/instruments.dart';
import 'package:surgical_counting/src/models/instruments.dart';
import 'package:surgical_counting/src/screens/full_screen_camera_screen.dart';
import 'package:surgical_counting/src/services/predict.dart';
import 'package:surgical_counting/src/services/utils.dart';
import 'package:surgical_counting/src/settings/settings_controller.dart';
import 'package:surgical_counting/src/widgets/camera.dart';
import 'package:surgical_counting/src/widgets/dash_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:surgical_counting/src/widgets/detection_information_pannel.dart';
import 'package:surgical_counting/src/widgets/detection_server_status.dart';

class DetectionScreen extends StatefulWidget {
  const DetectionScreen({
    super.key,
    required this.settingsController,
    required this.camera,
  });

  final SettingsController settingsController;

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
  // XFile? resultImageFile;
  Uint8List? resultImageBytes;

  // Info
  String info = '';

  // Server status
  bool isPredicting = false;

  // Instrument status
  late Map<String, dynamic> instrumentsStatus = {};

  void resetInstrumentsStatus() {
    instrumentsStatus = Map.from(defaultInstrumentsData
        .map((key, value) => MapEntry(key, InstrumentStatus())));
  }

  void toggleCamera() async {
    setState(() {
      isCameraOn = !isCameraOn;
    });
  }

  void openFullScreenCamera() {
    // Restart the camera
    if (isCameraOn) {
      toggleCamera();
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenCameraScreen(
          camera: widget.camera,
          onTakePictureComplete: onTakePictureComplete,
        ),
      ),
    );
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

  void predict(XFile image) async {
    isPredicting = true;
    try {
      resetInstrumentsStatus();

      final response = await postPrediction(widget.settingsController, image);

      setState(() {
        // resultImageFile = response.image;
        resultImageBytes = response.bytes;
        info = response.objects.toString();
      });

      // Update instruments status
      for (int i = 0; i < response.objects.length; i++) {
        final instrument = defaultInstrumentsData[response.objects[i].item2];
        if (instrument != null) {
          instrumentsStatus[response.objects[i].item2]!.qty += 1;
          instrumentsStatus[response.objects[i].item2]!.order = i;
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.predictionFailed),
          ),
        );
      }
    }
    isPredicting = false;
  }

  void onTakePictureComplete(XFile? file) {
    Navigator.pop(context);

    if (file == null) return;
    // Run detection
    predict(file);
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
      ResolutionPreset.max,
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
      body: Container(
        color: dashboardBackgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
                        backgroundColor: dashboardCardBackgroundColor,
                        floatingActionButton: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            FloatingActionButton(
                              onPressed: toggleCamera,
                              // On/off button icon
                              child: isCameraOn
                                  ? const Icon(Icons.videocam)
                                  : const Icon(Icons.videocam_off),
                            ),
                            const SizedBox(
                              width: dashboardSpaceBetweenFloatingButton,
                            ),
                            FloatingActionButton(
                              onPressed: openFullScreenCamera,
                              child: const Icon(Icons.zoom_out_map),
                            ),
                          ],
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
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(
                      width: dashboardSpaceBetweenCard,
                      height: dashboardSpaceBetweenCard,
                    ),

                    // Result
                    Expanded(
                      child: DashCard(
                        title: AppLocalizations.of(context)!.detection,
                        backgroundColor: dashboardCardBackgroundColor,
                        floatingActionButton: FloatingActionButton(
                          onPressed: () {
                            // Display the image in fullscreen with a return button
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Scaffold(
                                  body: Center(
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: Image.memory(
                                        resultImageBytes!,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          child: const Icon(Icons.zoom_out_map),
                        ),
                        child: isPredicting
                            ? const Center(
                                child: CircularProgressIndicator(),
                              )
                            : (resultImageBytes != null)
                                ? Image.memory(
                                    resultImageBytes!,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    color: Colors.black,
                                    width:
                                        MediaQuery.of(context).size.width / 2.8,
                                    height: double.infinity,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        const Icon(
                                          Icons.image_not_supported,
                                          color: Colors.white,
                                        ),
                                        Text(
                                          AppLocalizations.of(context)!
                                              .noPreviewMsg,
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                width: dashboardSpaceBetweenCard,
                height: dashboardSpaceBetweenCard,
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
                        settingsController: widget.settingsController,
                        instrumentsStatus: instrumentsStatus,
                      ),
                    ),

                    const SizedBox(
                      width: dashboardSpaceBetweenCard,
                      height: dashboardSpaceBetweenCard,
                    ),

                    // Server Status
                    Expanded(
                      flex: 2,
                      child: DetectionServerStatus(
                          settingsController: widget.settingsController),
                    ),

                    const SizedBox(
                      width: dashboardSpaceBetweenCard,
                      height: dashboardSpaceBetweenCard,
                    ),

                    // Control Panel
                    Expanded(
                      flex: 2,
                      child: DashCard(
                        title: AppLocalizations.of(context)!.controlPanel,
                        backgroundColor: dashboardCardBackgroundColor,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            // Clear Button
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                onPressed: resultImageBytes == null
                                    ? null
                                    : () {
                                        setState(() {
                                          resultImageBytes = null;
                                          resetInstrumentsStatus();
                                        });
                                      },
                                child:
                                    Text(AppLocalizations.of(context)!.clear),
                              ),
                            ),

                            // Predict Button
                            Expanded(
                              child: ElevatedButton(
                                onPressed: isCameraOn
                                    ? () => {
                                          captureImage()
                                              .then((value) => predict(value))
                                        }
                                    : null,
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
      ),
    );
  }
}
