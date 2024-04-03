import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:surgical_counting/src/screens/detection_screen.dart';
import 'package:surgical_counting/src/screens/full_screen_camera_screen.dart';

import 'settings/settings_controller.dart';

class App extends StatelessWidget {
  const App({
    super.key,
    required this.settingsController,
    required this.camera,
  });

  final SettingsController settingsController;
  final CameraDescription camera;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settingsController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          restorationScopeId: 'app',
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''),
          ],
          onGenerateTitle: (BuildContext context) =>
              AppLocalizations.of(context)!.appTitle,
          theme: ThemeData(),
          darkTheme: ThemeData.dark(),
          themeMode: settingsController.themeMode,
          onGenerateRoute: (RouteSettings routeSettings) {
            return MaterialPageRoute<void>(
              settings: routeSettings,
              builder: (BuildContext context) {
                switch (routeSettings.name) {
                  case FullScreenCameraScreen.routeName:
                    return FullScreenCameraScreen(camera: camera);
                  case DetectionScreen.routeName:
                  default:
                    return DetectionScreen(camera: camera);
                }
              },
            );
          },
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
