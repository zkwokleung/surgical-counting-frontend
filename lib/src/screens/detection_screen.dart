import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:surgical_counting/src/constants/instruments.dart';
import 'package:surgical_counting/src/services/predict.dart';
import 'package:surgical_counting/src/services/utils.dart';
import 'package:surgical_counting/src/widgets/camera.dart';
import 'package:surgical_counting/src/widgets/dash_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

    // Variables
    instrumentsStatus = Map.from(surgicalInstruments
        .map((key, value) => MapEntry(key, {'order': -1, 'qty': 0})));

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
              flex: 5,
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
                            1: FlexColumnWidth(0.7),
                            // Quantity
                            2: FlexColumnWidth(0.1),
                          },
                          children: <TableRow>[
                            TableRow(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      4.0, 4.0, 2.0, 2.0),
                                  child: Text(
                                      AppLocalizations.of(context)!.object),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      4.0, 4.0, 2.0, 2.0),
                                  child:
                                      Text(AppLocalizations.of(context)!.order),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      2.0, 2.0, 2.0, 2.0),
                                  child: Center(
                                      child: Text(AppLocalizations.of(context)!
                                          .quantity)),
                                ),
                              ],
                            ),
                            for (final key in surgicalInstruments.keys)
                              TableRow(
                                children: <Widget>[
                                  // Name
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        8.0, 2.0, 8.0, 2.0),
                                    child:
                                        Text(surgicalInstruments[key]!['name']),
                                  ),

                                  // Order
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        8.0, 2.0, 8.0, 2.0),
                                    child: Text(
                                      style: TextStyle(
                                        color:
                                            instrumentsStatus[key]!['order'] ==
                                                    surgicalInstruments[key]![
                                                        'order']
                                                ? Colors.green
                                                : Colors.red[900],
                                      ),
                                      instrumentsStatus[key]!['order'] < 0
                                          ? 'DNE'
                                          : instrumentsStatus[key]!['order']
                                              .toString(),
                                    ),
                                  ),

                                  // Quantity
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        8.0, 2.0, 8.0, 2.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                            style: TextStyle(
                                              color: instrumentsStatus[key]![
                                                          'qty'] ==
                                                      surgicalInstruments[key]![
                                                          'qty']
                                                  ? Colors.green
                                                  : Colors.red[900],
                                            ),
                                            "${instrumentsStatus[key]!['qty']}"),
                                        Text(
                                            "/${surgicalInstruments[key]!['qty']}"),
                                      ],
                                    ),
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
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  imageFile = null;
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
