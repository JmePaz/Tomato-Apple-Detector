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
  var isDetected = false;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  void initialize() async {
    futureController = initCamera();
  }

  Future<void> initCamera() async {
    _cameras = await availableCameras();
    controller = CameraController(_cameras[0], ResolutionPreset.medium,
        enableAudio: false);
    await controller.initialize().then((_) {
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

    await loadModel();
    controller.startImageStream((CameraImage image) {
      if (isDetected) return;
      setState(() => {isDetected = true});
      try {
        // await doSomethingWith(image)
        predictImage(image);
      } catch (e) {
        // await handleExepction(e)
      } finally {
        setState(() => {isDetected = false});
      }
    });
  }

  loadModel() async {
    await Tflite.loadModel(
        model: 'assets/model_unquant.tflite', labels: 'assets/labels.txt');
  }

  void predictImage(CameraImage img) async {
    var recognitions = await Tflite.runModelOnFrame(
        bytesList: img.planes.map((plane) {
          return plane.bytes;
        }).toList(), // required
        imageHeight: img.height,
        imageWidth: img.width,
        imageMean: 127.5, // defaults to 127.5
        imageStd: 127.5, // defaults to 127.5
        rotation: 90, // defaults to 90, Android only
        numResults: 2, // defaults to 5
        threshold: 0.1, // defaults to 0.1
        asynch: true // defaults to true
        );
    setState(() {
      detectedOutput = recognitions!;
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
                    child: Center(
                        child: Text(
                      (detectedOutput.isNotEmpty)
                          ? "${detectedOutput[0]["label"].split(" ")[1]}: ${detectedOutput[0]["confidence"].toStringAsFixed(2)}"
                          : "Capture an object",
                      style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w500,
                          color: Colors.white),
                    ))))
          ],
        ));
  }
}
