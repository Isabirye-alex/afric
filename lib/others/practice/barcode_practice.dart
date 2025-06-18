import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:native_device_orientation/native_device_orientation.dart';

class BarcodePractice extends StatefulWidget {
  const BarcodePractice({super.key});

  @override
  State<BarcodePractice> createState() => _BarcodePracticeState();
}

class _BarcodePracticeState extends State<BarcodePractice>
    with WidgetsBindingObserver {
  CameraController? cameraController;
  BarcodeScanner? barcodeScanner;
  late String? errorMessage = '';
  bool isDetecting = true;
  bool isFlashon = false;
  int frameCount = 0;
  int frameSkip = 5;

  @override
  void initState() {
    super.initState();
    barcodeScanner = BarcodeScanner(formats: [BarcodeFormat.all]);
    requestCameraPermission().then((granted) {
      if (granted) {
        initCamera();
      } else {
        setState(() {
          errorMessage =
              'Permission denied! Lexus camera permission in settings';
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
      debugPrint('Error: Could not grant camera access! $e');
      setState(() {
        errorMessage = 'Try again! Unknown error occurred';
      });
    }
    return false;
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
        ResolutionPreset.low,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await cameraController!.initialize();
      if (!mounted) {
        return;
      }

      await cameraController!.startImageStream(processImageStream);
      setState(() {});
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      setState(() {
        errorMessage = 'Could not initialize camera';
      });
    }
  }

  Future<void> processImageStream(CameraImage cameraImage) async {
    if (isDetecting || !mounted) {
      return;
    }

    if (frameCount++ % frameSkip != 0) {
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
        await saveFrameForDebug(bytes, cameraImage.width, cameraImage.height);

        final Size imageSize = Size(
          cameraImage.width.toDouble(),
          cameraImage.height.toDouble(),
        );

        final bytesPerRow = cameraImage.planes.first.bytesPerRow;

        final sensorOrientation =
            cameraController!.description.sensorOrientation;
        final deviceOrientation = NativeDeviceOrientationCommunicator()
            .orientation();

        InputImageRotation rotation = calculateRotation(
          sensorOrientation,
          deviceOrientation,
        );

        final inputImageFormat =
            cameraImage.format.group == ImageFormatGroup.yuv420
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888;

        final inputMetaData = InputImageMetadata(
          size: imageSize,
          rotation: rotation,
          format: inputImageFormat,
          bytesPerRow: bytesPerRow,
        );

        final inputImage = InputImage.fromBytes(
          bytes: bytes,
          metadata: inputMetaData,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Error Processing image stream! $e, $stackTrace');

      setState(() {
        errorMessage = 'Failed to process image streams';
      });
    } finally {
      isDetecting = false;
    }
  }

  Future<void> saveFrameForDebug(Uint8List bytes, int width, int height) async {
    return;
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
