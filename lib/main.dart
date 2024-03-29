import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';

void main() async {
  // * Initialize plugins
  WidgetsFlutterBinding.ensureInitialized();

  // * Camera
  final cameras = await availableCameras();

  // * Settings
  final settingsController = SettingsController(SettingsService());
  await settingsController.loadSettings();

  runApp(App(settingsController: settingsController, camera: cameras.first));
}
