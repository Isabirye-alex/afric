import 'package:flutter/material.dart';
import 'dart:io';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:camera/camera.dart';

class BarcodePractice extends StatefulWidget {
  const BarcodePractice({super.key});

  @override
  State<BarcodePractice> createState() => _BarcodePracticeState();
}

class _BarcodePracticeState extends State<BarcodePractice>
    with WidgetsBindingObserver {
  late CameraController? cameraController;
  late BarcodeScanner? barcodeScanner;
    bool isDetecting = false;
  String barcodeText = 'Scan a barcode...';
  String? errorMessage;
  int frameCount = 0;
  static const int frameSkip = 5;
  bool isFlashOn = false;

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
