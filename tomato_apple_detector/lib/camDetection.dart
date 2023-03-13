import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';

class CamDetection extends StatefulWidget {
  CamDetection({super.key, required this.cameras});
  List<CameraDescription> cameras;
  @override
  State<CamDetection> createState() => _CamDetectionState();
}

class _CamDetectionState extends State<CamDetection> {
  var detectedOutput = [];
  late CameraController controller;
  late Future<void> futureController;
  var isDetected = false;
  var isCameraInitialize = false;

  @override
  void initState() {
    super.initState();
    initCamera();
    //initializeModel();
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  void initializeModel() async {
    await loadModel();
    controller.startImageStream((CameraImage image) {
      if (isDetected) return;
      isDetected = true;
      try {
        // await doSomethingWith(image)
        predictImage(image);
      } catch (e) {
        // await handleExepction(e)
      } finally {
        isDetected = false;
      }
    });
  }

  void initCamera() async {
    controller = CameraController(widget.cameras[0], ResolutionPreset.max,
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
      isDetected = true;
      try {
        // await doSomethingWith(image)
        predictImage(image);
      } catch (e) {
        // await handleExepction(e)
      } finally {}
    });
  }

  loadModel() async {
    await Tflite.loadModel(
        model: 'assets/model_unquant.tflite', labels: 'assets/labels.txt');
  }

  void predictImage(CameraImage img) async {
    var recognition = await Tflite.runModelOnFrame(
        bytesList: img.planes.map((plane) {
          return plane.bytes;
        }).toList(), // required
        imageHeight: img.height,
        imageWidth: img.width,
        imageMean: 127.5, // defaults to 127.5
        imageStd: 127.5, // defaults to 127.5
        rotation: 90, // defaults to 90, Android only
        numResults: 2, // defaults to 5
        threshold: 0.5,
        asynch: true // defaults to true
        );
    if (!mounted) return;
    setState(() {
      detectedOutput = recognition!;
      isDetected = false;
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
                child: SizedBox(
                    width: double.infinity,
                    child: AspectRatio(
                        aspectRatio: 4, child: CameraPreview(controller)))),
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
