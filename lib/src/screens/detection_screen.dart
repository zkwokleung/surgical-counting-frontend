import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:surgical_counting/src/constants/instruments.dart';
import 'package:surgical_counting/src/services/utils.dart';
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

  // Server status
  bool isServerOn = false;

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
                          : const Icon(Icons.camera_alt),
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
                  // Information
                  Expanded(
                    flex: 8,
                    child: DashCard(
                      title: AppLocalizations.of(context)!.information,
                      backgroundColor: Colors.grey[600],
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(12.0),
                        child: Table(
                          border: TableBorder.all(),
                          columnWidths: const <int, TableColumnWidth>{
                            // Name
                            0: FlexColumnWidth(0.2),
                            // Order
                            1: FlexColumnWidth(0.75),
                            // Quantity
                            2: FlexColumnWidth(0.05),
                          },
                          children: <TableRow>[
                            TableRow(
                              children: <Widget>[
                                Text(AppLocalizations.of(context)!.object),
                                Text(AppLocalizations.of(context)!.count),
                              ],
                            ),
                            for (final object in surgical_instruments.entries)
                              TableRow(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        8.0, 2.0, 8.0, 2.0),
                                    child: Text(object.value['name']),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        8.0, 2.0, 8.0, 2.0),
                                    child: Text(object.value.toString()),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Server Status
                  Expanded(
                    flex: 2,
                    child: DashCard(
                      title: AppLocalizations.of(context)!.serverStatus,
                      backgroundColor: Colors.grey[600],
                      floatingActionButton: FloatingActionButton(
                        onPressed: checkServerStatus,
                        child: const Icon(Icons.refresh),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text('${AppLocalizations.of(context)!.status}: '),
                          Text(
                            isServerOn
                                ? AppLocalizations.of(context)!.serverStatusOk
                                : AppLocalizations.of(context)!
                                    .serverStatusUnavailable,
                            style: TextStyle(
                                color: isServerOn
                                    ? Colors.green
                                    : Colors.red[900]),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Control Panel
                  Expanded(
                    flex: 2,
                    child: DashCard(
                      title: AppLocalizations.of(context)!.controlPanel,
                      backgroundColor: Colors.grey[600],
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
