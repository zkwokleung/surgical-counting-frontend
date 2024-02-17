import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/card/gf_card.dart';
import 'package:getwidget/getwidget.dart';
import 'package:surgical_counting/src/widgets/camera.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
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
                      child: Card(
                    clipBehavior: Clip.hardEdge,
                    child: Scaffold(
                        // appBar: AppBar(
                        //   title: const Text("Camera View"),
                        // ),
                        backgroundColor: Colors.blue[200],
                        body: Center(child: Camera(camera: widget.camera))),
                  )),
                  // Expanded(child: Camera(camera: widget.camera)),
                  Expanded(
                    child: Card(
                      clipBehavior: Clip.hardEdge,
                      child: Scaffold(
                          // appBar: AppBar(
                          //   title: const Text("Result"),
                          // ),
                          backgroundColor: Colors.green[200],
                          body:
                              const Center(child: CircularProgressIndicator())),
                    ),
                  ),
                ],
              )),

          // Right Panel
          Expanded(
              flex: 4,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Expanded(
                      child: Card(
                        clipBehavior: Clip.hardEdge,
                        child: Scaffold(
                            // appBar: AppBar(
                            //   title: const Text("Info"),
                            // ),
                            backgroundColor: Colors.red[200],
                            body: const Center(
                                child: CircularProgressIndicator())),
                      ),
                    ),
                    Expanded(
                      child: Card(
                        clipBehavior: Clip.hardEdge,
                        child: Scaffold(
                            // appBar: AppBar(
                            //   title: const Text("??"),
                            // ),
                            backgroundColor: Colors.amber[200],
                            body: const Center(
                                child: CircularProgressIndicator())),
                      ),
                    ),
                  ])),
        ],
      ),
    );
  }
}
