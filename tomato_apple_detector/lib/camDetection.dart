import 'dart:io';

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
    return Container();
  }
}
