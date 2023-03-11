import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:tflite/tflite.dart';

class CamDetection extends StatefulWidget {
  const CamDetection({super.key});

  @override
  State<CamDetection> createState() => _CamDetectionState();
}

class _CamDetectionState extends State<CamDetection> {
  var detectedOutput = [];
  late List<CameraDescription> _cameras;
  late CameraController controller;
  late Future<void> futureController;

  @override
  void initState() {
    super.initState();
    futureController = initCamera();
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  Future<void> initCamera() async {
    _cameras = await availableCameras();
    controller = CameraController(_cameras[0], ResolutionPreset.max);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            // Handle access errors here.
            break;
          default:
            // Handle other errors here.
            break;
        }
      }
    });
  }

  loadModel() async {
    await Tflite.loadModel(
        model: 'assets/model_unquant.tflite', labels: 'assets/labels.txt');
  }

  void predictImage(File img) async {
    var output = await Tflite.runModelOnImage(
        path: img.path,
        numResults: 2,
        threshold: 0.5,
        imageMean: 127.5,
        imageStd: 127.5);
    setState(() {
      detectedOutput = output!;
    });
    // print("Result are: ${detectedOutput}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Detect using Camera")),
        body: Column(
          children: [
            Expanded(
                flex: 9,
                child: FutureBuilder(
                  future: futureController,
                  builder: (context, snapshot) =>
                      (snapshot.connectionState == ConnectionState.done)
                          ? SizedBox(
                              width: double.infinity,
                              child: AspectRatio(
                                  aspectRatio: 4,
                                  child: CameraPreview(controller)))
                          : const Center(child: CircularProgressIndicator()),
                )),
            Expanded(
                flex: 1,
                child: Container(
                    color: Colors.redAccent,
                    width: double.infinity,
                    height: double.infinity,
                    child: const Center(
                        child: Text(
                      "This is the output",
                      style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w500,
                          color: Colors.white),
                    ))))
          ],
        ));
  }
}
