import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/barCode/decode_data.dart';

class PracticeBarcode extends StatefulWidget {
  const PracticeBarcode({super.key});

  @override
  State<PracticeBarcode> createState() => _PracticeBarcodeState();
}

class _PracticeBarcodeState extends State<PracticeBarcode>
    with WidgetsBindingObserver {
  CameraController? cameraController;
  BarcodeScanner? barcodeScanner;
  String? errorMessage = '';
  String barcodeText = 'Place Barcode here';
  int frameCount = 0;
  int frameSkip = 5;
  bool isDetecting = false;
  bool isFlashon = false;
  Map<String, String>? decodedResult;
  bool shouldRestartCamera = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    barcodeScanner = BarcodeScanner(formats: [BarcodeFormat.pdf417]);
    requestCameraPermission().then((granted) {
      if (granted) {
        initCamera();
      } else {
        setState(() {
          errorMessage = 'Grant the app Camera access in the system settings';
        });
      }
    });
  }

  Future<void> initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          errorMessage = 'No cameras available on this device.';
        });
        return;
      }
      final backCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      cameraController = CameraController(
        backCamera,
        ResolutionPreset.veryHigh,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await cameraController!.initialize();
      if (!mounted) return;

      await cameraController!.startImageStream((image) async {
        await processImageFrame(image);
      });

      setState(() {});
    } catch (e, stackTrace) {
      print('Debug print: Exception in availableCameras: $e');
      print(stackTrace);
      debugPrint('Debug print: Error initializing camera: $e');
      setState(() {
        errorMessage = 'Failed to initialize camera: $e';
      });
    }
  }

  Future<void> processImageFrame(CameraImage cameraImage) async {
    if (isDetecting || !mounted) return;

    isDetecting = true;
    try {
      if (frameCount++ % frameSkip != 0) return;
      final WriteBuffer allBytes = WriteBuffer();
      for (final plane in cameraImage.planes) {
        allBytes.putUint8List(plane.bytes);
      }

      final bytes = allBytes.done().buffer.asUint8List();

      final Size imageSize = Size(
        cameraImage.width.toDouble(),
        cameraImage.height.toDouble(),
      );

      final bytesPerRow = cameraImage.planes.first.bytesPerRow;

      final sensorOrientation = cameraController!.description.sensorOrientation;
      final deviceOrientation = await NativeDeviceOrientationCommunicator()
          .orientation();

      final InputImageRotation rotation = calculateRotation(
        sensorOrientation,
        deviceOrientation,
      );

      final InputImageFormat inputImageFormat =
          cameraImage.format.group == ImageFormatGroup.yuv420
          ? InputImageFormat.nv21
          : InputImageFormat.bgra8888;

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
      final List<Barcode> barcodes = await barcodeScanner!.processImage(
        inputImage,
      );

      debugPrint('Debug print:  Detected ${barcodes.length} barcode(s)');
      if (barcodes.isNotEmpty) {
        final barcodeValue = barcodes.first.displayValue ?? 'No value';
        debugPrint(
          'Debug print:  Barcode: $barcodeValue, Format: ${barcodes.first.format}',
        );
        final result = decodeBarcodeData(barcodeValue);
        setState(() {
          decodedResult = result;
        });

        await cameraController?.stopImageStream();
        isDetecting = false;

        if (!mounted) return;

        debugPrint('Debug Print: Navigating to decoded screen...');
        Future.delayed(Duration.zero, () async {
          await Get.to(() => DecodedDataScreen(decodedData: result));
          if (mounted) {
            debugPrint(' Returned from decoded screen, restarting stream...');
            await cameraController?.startImageStream(processImageFrame);
          }
        });
      } else {
        debugPrint('Debug print:  No barcode detected in frame');
      }
    } catch (e, stackTrace) {
      debugPrint('Debug print: Exception in processCameraImage: $e');
      debugPrint('Debug print: Stack trace:\n$stackTrace');
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
    int rotationDegress;
    switch (deviceOrientation) {
      case NativeDeviceOrientation.landscapeLeft:
        rotationDegress = 90;
        break;
      case NativeDeviceOrientation.landscapeRight:
        rotationDegress = 270;
        break;
      case NativeDeviceOrientation.portraitDown:
        rotationDegress = 180;
        break;
      case NativeDeviceOrientation.portraitUp:
      default:
        rotationDegress = 0;
        break;
    }

    final totlaRotation = (sensorOrientation - rotationDegress + 360) % 360;

    switch (totlaRotation) {
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

  Future<bool> requestCameraPermission() async {
    try {
      final status = await Permission.camera.status;
      if (status.isGranted) {
        return true;
      }
      final response = await Permission.camera.request();
      if (response.isGranted) {
        return true;
      } else if (response.isPermanentlyDenied) {
        setState(() {
          errorMessage =
              'Camera permission permanently denied. Please enable it in settings.';
        });
        await openAppSettings();
        return false;
      } else {
        setState(() {
          errorMessage =
              'Camera permission denied. Please grant permission to use the camera.';
        });
        return false;
      }
    } catch (e) {
      debugPrint('Error requesting camera permission: $e');
      setState(() {
        errorMessage = 'Error requesting camera permission: $e';
      });
      return false;
    }
  }

  Map<String, String> decodeBarcodeData(String? barcodeValue) {
    final decodedData = <String, String>{};

    if (barcodeValue == null || barcodeValue.isEmpty) {
      decodedData['Error'] = 'No barcode data found';
      return decodedData;
    }

    final parts = barcodeValue.split(';');

    final fieldLabels = <int, String>{
      0: 'Surname',
      1: 'Given Name',
      2: 'Nationality',
      3: 'Date of Birth',
      4: 'Issue Date',
      5: 'Date of Expiry',
      6: 'NIN',
      7: 'Card NO.',
    };

    final values = parts.length;
    print(values);

    for (int i = 0; i < parts.length; i++) {
      if (i == 2 || i == 8 || i == 9 || i == 10) {
        continue;
      }
      final raw = parts[i];
      final label = fieldLabels[i] ?? 'Field $i';

      try {
        // Attempt base64 decode
        final decoded = utf8.decode(base64Decode(raw));
        decodedData[label] = decoded;
      } catch (_) {
        // Custom parsing for specific fields
        if (i == 2 || i == 3 || i == 4) {
          decodedData[label] = _formatDate(raw); // Format as DD/MM/YYYY
        } else {
          decodedData[label] = raw;
        }
      }
    }

    return decodedData;
  }

  String _formatDate(String dateStr) {
    if (dateStr.length == 8 && RegExp(r'^\d{8}$').hasMatch(dateStr)) {
      final day = dateStr.substring(0, 2);
      final month = dateStr.substring(2, 4);
      final year = dateStr.substring(4);
      return '$day/$month/$year';
    }
    return dateStr;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.paused) {
      cameraController!.stopImageStream();
    } else if (shouldRestartCamera) {
      cameraController!.startImageStream(processImageFrame);
      shouldRestartCamera = false;
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
  @override
  Widget build(BuildContext context) {
    if (errorMessage != null && errorMessage!.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Barcode Scanner'), centerTitle: true),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(errorMessage!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    errorMessage = null;
                  });
                  requestCameraPermission().then((granted) {
                    if (granted) initCamera();
                  });
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (cameraController == null || !cameraController!.value.isInitialized) {
      return Scaffold(
        appBar: AppBar(title: const Text('Barcode Scanner'), centerTitle: true),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Barcode Scanner'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              try {
                await cameraController!.setFlashMode(
                  isFlashon ? FlashMode.off : FlashMode.torch,
                );
                setState(() {
                  isFlashon = !isFlashon;
                });
              } catch (e) {
                debugPrint('Error toggling flash: $e');
              }
            },
            icon: Icon(isFlashon ? Icons.flash_off : Icons.flash_on),
          ),
        ],
      ),
      body: Stack(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: CameraPreview(cameraController!),
          ),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.7,
              height: MediaQuery.of(context).size.height * 0.5,
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(color: Colors.green),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  barcodeText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
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
