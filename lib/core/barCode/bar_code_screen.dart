import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class BarCodeScreen extends StatefulWidget {
  const BarCodeScreen({super.key});

  @override
  State<BarCodeScreen> createState() => _BarCodeScreenState();
}

class _BarCodeScreenState extends State<BarCodeScreen> with WidgetsBindingObserver {
  CameraController? _cameraController;
  late BarcodeScanner _barcodeScanner;
  bool _isDetecting = false;
  String barcodeText = 'Scan a barcode...';
  String? _errorMessage;
  int _frameCount = 0;
  static const int _frameSkip = 5;
  bool _isFlashOn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _barcodeScanner = BarcodeScanner(formats: [BarcodeFormat.all]);
    _requestCameraPermission().then((granted) {
      if (granted) {
        _initCamera();
      } else {
        setState(() {
          _errorMessage = 'Camera permission denied. Please grant permission in settings.';
        });
      }
    });
  }

  Future<bool> _requestCameraPermission() async {
    try {
      final status = await Permission.camera.request();
      debugPrint('Camera permission status: $status');
      if (status.isGranted) {
        return true;
      } else if (status.isPermanentlyDenied) {
        openAppSettings();
        return false;
      }
      return false;
    } catch (e) {
      debugPrint('Error requesting camera permission: $e');
      setState(() {
        _errorMessage = 'Failed to request camera permission: $e';
      });
      return false;
    }
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      final backCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => throw Exception('No back camera found'),
      );

      _cameraController = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _cameraController!.initialize();
      if (!mounted) return;

      await _cameraController!.startImageStream(_processCameraImage);
      setState(() {});
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to initialize camera: $e';
        });
      }
      debugPrint('Camera initialization error: $e');
    }
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_frameCount++ % _frameSkip != 0) return;
    if (_isDetecting || !mounted) return;

    debugPrint('Processing image: format=${image.format.group}, raw=${image.format.raw}, '
        'width=${image.width}, height=${image.height}, bytesPerRow=${image.planes.first.bytesPerRow}');
        
    _isDetecting = true;

    try {
      final WriteBuffer allBytes = WriteBuffer();
      for (final plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();
      debugPrint('Image bytes length: ${bytes.length}');

      // Save the first frame for debugging
      if (_frameCount == _frameSkip) {
        await _saveFrameForDebugging(bytes, image.width, image.height);
      }

      final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());
      final bytesPerRow = image.planes.first.bytesPerRow;

      final sensorOrientation = _cameraController!.description.sensorOrientation;
      final deviceOrientation = await NativeDeviceOrientationCommunicator().orientation();
      InputImageRotation rotation = _calculateInputRotation(sensorOrientation, deviceOrientation);

      debugPrint('Camera sensor orientation: $sensorOrientation, Device orientation: $deviceOrientation, Rotation: $rotation');

      final inputImageFormat = image.format.group == ImageFormatGroup.yuv420
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

      final List<Barcode> barcodes = await _barcodeScanner.processImage(inputImage);

      debugPrint('Detected ${barcodes.length} barcodes');
      if (barcodes.isNotEmpty && mounted) {
        final barcodeValue = barcodes.first.displayValue ?? 'No value';
        debugPrint('Barcode detected: $barcodeValue (Type: ${barcodes.first.format})');
        setState(() {
          barcodeText = 'Barcode: $barcodeValue';
        });
      } else {
        debugPrint('No barcodes detected in this frame');
        setState(() {
          barcodeText = 'No barcode detected. Center barcode in the green box, adjust distance (15-30 cm), ensure good lighting.';
        });
      }
    } catch (e, stackTrace) {
      debugPrint('Error processing image: $e, StackTrace: $stackTrace');
      setState(() {
        barcodeText = 'Error: $e';
      });
    } finally {
      _isDetecting = false;
    }
  }

  Future<void> _saveFrameForDebugging(Uint8List bytes, int width, int height) async {
    try {
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/debug_frame_${DateTime.now().millisecondsSinceEpoch}.yuv';
      await File(filePath).writeAsBytes(bytes);
      debugPrint('Saved debug frame to: $filePath');
    } catch (e) {
      debugPrint('Error saving debug frame: $e');
    }
  }

  InputImageRotation _calculateInputRotation(int sensorOrientation, NativeDeviceOrientation deviceOrientation) {
    int rotationDegrees;
    switch (deviceOrientation) {
      case NativeDeviceOrientation.landscapeLeft:
        rotationDegrees = 90;
        break;
      case NativeDeviceOrientation.landscapeRight:
        rotationDegrees = 270;
        break;
      case NativeDeviceOrientation.portraitDown:
        rotationDegrees = 180;
        break;
      case NativeDeviceOrientation.portraitUp:
      default:
        rotationDegrees = 0;
    }

    final totalRotation = (sensorOrientation - rotationDegrees + 360) % 360;

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
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    if (state == AppLifecycleState.paused) {
      _cameraController!.stopImageStream();
      debugPrint('Camera stream stopped due to app pause');
    } else if (state == AppLifecycleState.resumed) {
      _cameraController!.startImageStream(_processCameraImage);
      debugPrint('Camera stream resumed');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.stopImageStream();
    _cameraController?.dispose();
    _barcodeScanner.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Barcode Scanner')),
        body: Center(
          child: Text(_errorMessage!,
           style: TextStyle(color: Colors.red),
           ),
           ),
      );
    }

    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator()
        ,),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Barcode Scanner'),
        actions: [
          IconButton(
            icon: Icon(_isFlashOn ? Icons.flash_off : Icons.flash_on),
            onPressed: () async {
              try {
                await _cameraController!.setFlashMode(
                  _isFlashOn ? FlashMode.off : FlashMode.torch,
                );
                setState(() {
                  _isFlashOn = !_isFlashOn;
                });
              } catch (e) {
                debugPrint('Error toggling flash: $e');
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          GestureDetector(
            onTapDown: (details) {
              final offset = Offset(
                details.localPosition.dx / MediaQuery.of(context).size.width,
                details.localPosition.dy / MediaQuery.of(context).size.height,
              );
              _cameraController?.setFocusPoint(offset);
              debugPrint('Focus set to: $offset');
            },
            child: CameraPreview(_cameraController!),
          ),
          // Enhanced scanning overlay
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.7,
              height: MediaQuery.of(context).size.height * 0.5,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green, width: 3),
                borderRadius: BorderRadius.circular(12),
                color: Colors.transparent,
              ),
              child: const Center(
                child: Text(
                  'Place barcode here',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              color: Colors.black54,
              child: Text(
                barcodeText,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}