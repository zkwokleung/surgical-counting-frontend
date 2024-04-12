import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:surgical_counting/src/constants/design.dart';
import 'package:surgical_counting/src/widgets/camera.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FullScreenCameraScreen extends StatefulWidget {
  const FullScreenCameraScreen({
    super.key,
    required this.camera,
    this.onTakePictureComplete,
  });

  static const String routeName = '/full_screen_camera_screen';

  final CameraDescription camera;

  final Function? onTakePictureComplete;

  @override
  State<FullScreenCameraScreen> createState() => _FullScreenCameraScreenState();
}

class _FullScreenCameraScreenState extends State<FullScreenCameraScreen>
    with SingleTickerProviderStateMixin {
  // Cameras
  bool isCameraOn = true;
  late CameraController _cameraController;
  late Future<void> _initializeCameraControllerFuture;
  XFile? capturedImageFile;

  // Animation
  AnimationController? _controller;
  late Animation<double> _animatedCameraButtonPadding;
  late Animation<double> _animatedCameraOpacity;

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

  void onCaptureButtonPressed() async {
    try {
      if (isCameraOn) {
        _controller!.forward();
        capturedImageFile = await captureImage();
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return;
    }
  }

  void onTakePictureComplete() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (widget.onTakePictureComplete != null) {
      widget.onTakePictureComplete!(capturedImageFile);
    }
  }

  @override
  void initState() {
    super.initState();

    // Cameras
    _cameraController = CameraController(
      widget.camera,
      ResolutionPreset.max,
    );
    _initializeCameraControllerFuture = _cameraController.initialize();
    if (!kIsWeb) {
      _cameraController
          .lockCaptureOrientation(DeviceOrientation.landscapeRight);
    }

    // Animations
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 100),
    );
    _controller!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller!.reverse();
        onTakePictureComplete();
      }
    });

    _animatedCameraButtonPadding =
        Tween<double>(begin: 12.0, end: 20.0).animate(
      CurvedAnimation(
        parent: _controller!,
        curve: Curves.linear,
      ),
    );

    _animatedCameraOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller!,
        curve: Curves.linear,
      ),
    );
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: fullScreenCameraBackgroundColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 1,
              child: SizedBox(
                height: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => {Navigator.pop(context)},
                      child: const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),

            // Camera
            Expanded(
              flex: 7,
              child: isCameraOn
                  ? AnimatedBuilder(
                      animation: _controller!,
                      builder: (BuildContext context, Widget? child) {
                        return Opacity(
                          opacity: _animatedCameraOpacity.value,
                          child: child,
                        );
                      },
                      child: Camera(camera: widget.camera),
                    )
                  : Container(
                      width: MediaQuery.of(context).size.width / 1.5,
                      height: double.infinity,
                      color: Colors.black,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
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

            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 150,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: onCaptureButtonPressed,
                        child: RawMaterialButton(
                          hoverColor: Colors.black,
                          shape: const CircleBorder(
                            side: BorderSide(color: Colors.white, width: 4),
                          ),
                          elevation: 2,
                          hoverElevation: 4,
                          onPressed: null,
                          child: AnimatedBuilder(
                            animation: _controller!,
                            builder: (BuildContext context, Widget? child) {
                              return Padding(
                                padding: EdgeInsets.all(
                                    _animatedCameraButtonPadding.value),
                                child: child,
                              );
                            },
                            child: AnimatedContainer(
                              decoration: const BoxDecoration(
                                  shape: BoxShape.circle, color: Colors.white),
                              duration: const Duration(seconds: 1),
                              curve: Curves.bounceInOut,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
