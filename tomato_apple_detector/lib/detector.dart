import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class Detector extends StatefulWidget {
  const Detector({super.key});

  @override
  State<Detector> createState() => _DetectorState();
}

class _DetectorState extends State<Detector> {
  late File _img;
  bool isSetImg = false;
  var detectedOutput = [];

  @override
  void initState() {
    super.initState();
    loadModel().then((value) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    Tflite.close();
  }

  Future<void> selectImg() async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (img?.path != null) {
      setState(() {
        isSetImg = true;
        _img = File(img!.path);
      });
      predictImage(_img);
    }
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
      appBar: AppBar(
        title: const Text("Detect by Image"),
      ),
      body: Column(children: [
        (isSetImg)
            ? Container(
                padding: const EdgeInsets.only(bottom: 20),
                child: Image.file(_img))
            : Container(),
        Container(
            width: double.infinity,
            decoration: const BoxDecoration(color: Colors.redAccent),
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Center(
                child: Text(
              (detectedOutput.isNotEmpty)
                  ? "${detectedOutput[0]["label"].split(" ")[1]}: ${detectedOutput[0]["confidence"].toStringAsFixed(2)}"
                  : "Select an Image First",
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white),
            ))),
        Container(
            margin: const EdgeInsets.only(top: 20),
            child: ElevatedButton(
                onPressed: selectImg,
                child: const Text(
                  "Select an Image",
                  style: TextStyle(fontSize: 20),
                )))
      ]),
    );
  }
}
