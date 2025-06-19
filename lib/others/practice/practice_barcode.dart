import 'dart:convert';
import 'package:get/get.dart';
import 'package:afri/core/barCode/decode_data.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:native_device_orientation/native_device_orientation.dart';

class PracticeBarcode extends StatefulWidget {
  const PracticeBarcode({super.key});

  @override
  State<PracticeBarcode> createState() => _PracticeBarcodeState();
}

class _PracticeBarcodeState extends State<PracticeBarcode>
    with WidgetsBindingObserver {
  CameraController? cameraController;
  BarcodeScanner? barcodeScanner;
  late String? errorMessage = '';
  late String barcodeText;
  int frameCount = 0;
  int frameSkip = 5;
  bool isDetecting = true;
  bool isFlashon = false;
  Map<String, String>? decodedResult;

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
          errorMessage = 'Grant the app Camera access in the system settings';
        });
      }
    });
  }

  Future<void> initCamera() async {
    try {
      final camera = await availableCameras();
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

      await cameraController!.startImageStream(processImageFrame);
      setState(() {});
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      setState(() {
        errorMessage = 'Faild to access the camera try again';
      });
    }
  }

  Future<void> processImageFrame(CameraImage cameraImage) async {
    if (frameCount++ % frameSkip != 0) {
      return;
    }
    if (isDetecting || !mounted) {
      return;
    }

    isDetecting = true;

    if (frameCount == frameSkip) {
      try {
        final WriteBuffer allBytes = WriteBuffer();
        for (final plane in cameraImage.planes) {
          allBytes.putUint8List(plane.bytes);
        }
        final bytes = allBytes.done().buffer.asUint8List();

        final bytesPerRow = cameraImage.planes.first.bytesPerRow;

        final Size imageSize = Size(
          cameraImage.width.toDouble(),
          cameraImage.width.toDouble(),
        );

        final sensorOrientation =
            cameraController!.description.sensorOrientation;
        final deviceOrientation = await NativeDeviceOrientationCommunicator()
            .orientation();

        InputImageRotation rotation = calculateRotation(
          sensorOrientation,
          deviceOrientation,
        );

        final inputImageFormat =
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
        debugPrint('Detected ${barcodes.length} barcodes');
        if (barcodes.isNotEmpty && mounted) {
          final barcodeValue = barcodes.first.displayValue;
          debugPrint(
            'Barcode Detected: $barcodeValue, Type ${barcodes.first.format}',
          );
          if (barcodeValue != null) {
            final result = decodeBarcodeData(barcodeValue);
            setState(() {
              decodedResult = result;
            });
            await cameraController?.stopImageStream();
            isDetecting = false;

            if (mounted) {
              Get.to(() => DecodedDataScreen(decodedData: result))!.then((_) {
                if (mounted) {
                  cameraController!.startImageStream(processImageFrame);
                }
              });
            }
          }
        }
      } catch (e) {
        debugPrint('Lexus');
        setState(() {
          errorMessage = 'Could not process barcode frames';
        });
      }
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
      final response = await Permission.camera.request();
      if (response.isGranted) {
        return true;
      } else if (response.isPermanentlyDenied) {
        openAppSettings();
        return false;
      }
      return false;
    } catch (e) {
      debugPrint('Error! Could not get camera permission');
      setState(() {
        errorMessage = 'Error getting camera permission';
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

    for (int i = 0; i < parts.length; i++) {
      final raw = parts[i];

      try {
        // Try base64 decoding
        final decoded = utf8.decode(base64Decode(raw));
        decodedData['Field $i (Decoded)'] = decoded;
      } catch (_) {
        // If not base64, handle known structured fields
        switch (i) {
          case 2:
            decodedData['Date of Birth'] = _formatDate(raw);
            break;
          case 3:
            decodedData['Issue Date'] = _formatDate(raw);
            break;
          case 4:
            decodedData['Expiry Date'] = _formatDate(raw);
            break;
          case 6:
            decodedData['ID Number'] = raw;
            break;
          default:
            decodedData['Field $i'] = raw;
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
    } else if (state == AppLifecycleState.resumed) {
      cameraController!.startImageStream(processImageFrame);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(errorMessage != null){
          if (errorMessage != null) {
        return Scaffold(
          appBar: AppBar(title: Text('Barcode Scanner'), centerTitle: true),
          body: Center(
            child: Text(
              errorMessage ?? '',
              style: TextStyle(color: Colors.red),
            ),
          ),
        );
      }
    }
      if (cameraController == null || !cameraController!.value.isInitialized) {
        return Scaffold(
          appBar: AppBar(title: Text('Barcode Scanner'), centerTitle: true),
          body: Center(child: CircularProgressIndicator()),
        );
      }
       
     return Scaffold(
      appBar: AppBar(
        title: Text('Barcode Scanner'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              try {
                await cameraController!.setFlashMode(
                  isFlashon ? FlashMode.off : FlashMode.torch,
                );
                if (mounted) {
                  setState(() {
                    isFlashon = !isFlashon;
                  });
                }
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
          GestureDetector(
            onTapDown: (details) {
              final offSet = Offset(
                details.localPosition.dx / MediaQuery.of(context).size.width,
                details.localPosition.dy / MediaQuery.of(context).size.height,
              );
              cameraController!.setFocusPoint(offSet);
              debugPrint('Focus Mode set to : $offSet');
            },
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
                  style: TextStyle(
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


  

