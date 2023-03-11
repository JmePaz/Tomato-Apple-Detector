import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class Detector extends StatefulWidget {
  const Detector({super.key});

  @override
  State<Detector> createState() => _DetectorState();
}

class _DetectorState extends State<Detector> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tomato/Apple Detector"),
      ),
      body: Column(children: []),
    );
  }
}
