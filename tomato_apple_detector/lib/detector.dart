import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Detector extends StatefulWidget {
  const Detector({super.key});

  @override
  State<Detector> createState() => _DetectorState();
}

class _DetectorState extends State<Detector> {
  late File _img;
  bool isSetImg = false;

  Future<void> selectImg() async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (img!.path != null) {
      setState(() {
        isSetImg = true;
        _img = File(img.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tomato/Apple Detector"),
      ),
      body: Column(children: [
        (isSetImg) ? Image.file(_img) : Container(),
        ElevatedButton(
            onPressed: selectImg, child: const Text("Select an Image"))
      ]),
    );
  }
}
