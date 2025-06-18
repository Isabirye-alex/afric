import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:flutter/foundation.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    barcodeScanner = BarcodeScanner(formats: [BarcodeFormat.all]);
    requestCameraPermission().then((granted) {
      if (granted) {
        initCamera();
      } else {
        setState(() {
          errorMessage =
              'Camera permission denied. Please grant permission in settings.';
        });
      }
    });
  }

  Future<bool> requestCameraPermission() async {
    try {
      final response = await Permission.camera.request();
      if (response.isGranted) {
        return true;
      } else if (response.isPermanentlyDenied) {
        openAppSettings();
        return false;
      }
      return false;
    } catch (e) {
      debugPrint('Error requesting camera permission: $e');
      setState(() {
        errorMessage = 'Failed to request camera permission: $e';
      });
      return false;
    }
  }

  Future<void> initCamera() async {
    try {
      final camera = await availableCameras();
      if (!mounted) {
        return;
      }
      final backCamera = camera.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
      );
      cameraController = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await cameraController!.initialize();
      if (!mounted) {
        return;
      }

      await cameraController!.startImageStream(processCameraImage);
      setState(() {});
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Failed to initialize camera: $e';
        });
      }

      debugPrint('Camera initialization error: $e');
    }
  }

  Future<void> processCameraImage(CameraImage cameraImage) async {
    if (frameCount++ % frameSkip != 0) {
      return;
    }
    if (isDetecting || mounted) {
      return;
    }
    isDetecting = true;

    try {
      final WriteBuffer allBytes = WriteBuffer();
      for (final plane in cameraImage.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();
      debugPrint('Image bytes length: ${bytes.length}');

      if (frameCount == frameSkip) {
        await saveFrameForDebugging(
          bytes,
          cameraImage.width,
          cameraImage.height,
        );

        final Size imageSize = Size(
          cameraImage.width.toDouble(),
          cameraImage.height.toDouble(),
        );

        final bytesPerRow = cameraImage.planes.first.bytesPerRow;

        final sensorOrientation =
            cameraController!.description.sensorOrientation;
        final deviceOrientation =await NativeDeviceOrientationCommunicator()
            .orientation();
            
        InputImageRotation rotation = calculateRotation(
          sensorOrientation,
          deviceOrientation,
        );

        debugPrint(
          'Camera sensor orientation: $sensorOrientation, Device orientation: $deviceOrientation, Rotation: $rotation',
        );

        final inputImageFormat =
            cameraImage.format.group == ImageFormatGroup.yuv420
            ? InputImageFormat.nv21
            : InputImageFormat.bgra8888;

        final inputImageData = InputImageMetadata(
          size: imageSize,
          rotation: rotation,
          format: inputImageFormat,
          bytesPerRow: bytesPerRow,
        );

        final inputImage = InputImage.fromBytes(
          bytes: bytes,
          metadata: inputImageData,
        );

        final List<Barcode> barcodes = await barcodeScanner!.processImage(
          inputImage,
        );
        debugPrint('Detected ${barcodes.length} barcoes');
        if (barcodes.isNotEmpty && mounted) {
          final barcodeValue = barcodes.first.displayValue ?? 'No value';
          debugPrint(
            'Barcode Detected: $barcodeValue, Type ${barcodes.first.format}',
          );
        } else {
          debugPrint('No barcodes detected in this frame');
          setState(() {
            barcodeText =
                'No barcode detected. Center barcode in the green box';
          });
        }
      }
    } catch (e, stackTrace) {
      debugPrint('Error processing image: $e, StackTrace: $stackTrace');
      setState(() {
        barcodeText = 'Error: $e';
      });
    } finally {
      isDetecting = false;
    }
  }

  Future<void> saveFrameForDebugging(
    Uint8List bytes,
    int width,
    int height,
  ) async {
    try {
      final directory = await getTemporaryDirectory();
      final filePath =
          '${directory.path}/debug_frame_${DateTime.now().millisecondsSinceEpoch}.yuv';
      await File(filePath).writeAsBytes(bytes);
      debugPrint('Saved debug frame to: $filePath');
    } catch (e) {
      debugPrint('Error saving debug frame: $e');
    }
  }

  InputImageRotation calculateRotation(
    int sensorOrientation,
    NativeDeviceOrientation deviceOrientation,
  ) {
    int rotationDeg;

    switch (deviceOrientation) {
      case NativeDeviceOrientation.landscapeLeft:
        rotationDeg = 90;
        break;
      case NativeDeviceOrientation.landscapeRight:
        rotationDeg = 270;
        break;
      case NativeDeviceOrientation.portraitDown:
        rotationDeg = 180;
        break;
      case NativeDeviceOrientation.portraitUp:
      default:
        rotationDeg = 0;
    }

    final totalRotation = (sensorOrientation - rotationDeg + 360) % 360;
    switch (totalRotation) {
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      case 0:
      default:
        return InputImageRotation.rotation0deg;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.paused) {
      cameraController!.stopImageStream();
      debugPrint('Live Cam Feed stopped due to app pause');
    } else if (state == AppLifecycleState.resumed) {
      cameraController!.startImageStream(processCameraImage);
      debugPrint('Live cam feed resumed');
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    cameraController!.stopImageStream();
    cameraController!.dispose();
    barcodeScanner!.close();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
