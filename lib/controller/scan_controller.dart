import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;
import 'package:image/image.dart' as img;

class ScanController extends GetxController {
  late CameraController cameraController;
  late List<CameraDescription> cameras;
  late tfl.Interpreter interpreter;
  late List<String> labels;

  var isCameraInitialized = false.obs;
  var recognizedText = "".obs;
  var confidence = 0.0.obs;
  var boundingBox = Rect.zero.obs;
  var isHandDetected = false.obs;
  var cameraAspectRatio = 1.0.obs;

  int frameCounter = 0;
  bool _isProcessing = false;

  @override
  void onInit() async {
    super.onInit();
    await loadModel();
    await initCamera();
  }

  @override
  void dispose() {
    super.dispose();
    cameraController.dispose();
    interpreter.close();
  }

  Future<void> loadModel() async {
    try {
      interpreter = await tfl.Interpreter.fromAsset(
        'assets/model_unquant.tflite',
      );
      labels = await loadLabels('assets/labels.txt');
    } catch (e) {
      print("Error loading model: $e");
    }
  }

  Future<List<String>> loadLabels(String assetPath) async {
    final labelsRaw = await rootBundle.loadString(assetPath);
    return labelsRaw
        .split('\n')
        .map((label) => label.trim())
        .where((label) => label.isNotEmpty)
        .toList();
  }

  Future<void> initCamera() async {
    if (await Permission.camera.request().isGranted) {
      cameras = await availableCameras();
      cameraController = CameraController(cameras[0], ResolutionPreset.high);
      await cameraController.initialize().then((_) {
        isCameraInitialized(true);
        cameraAspectRatio.value = cameraController.value.aspectRatio;
        startHandSignDetection();
        update();
      });
    } else {
      print("No camera permission");
    }
  }

  void startHandSignDetection() {
    cameraController.startImageStream((CameraImage image) async {
      if (!_isProcessing && frameCounter % 10 == 0) {
        _isProcessing = true;
        String result = await processFrame(image);
        recognizedText.value = result;
        _isProcessing = false;
        update();
      }
      frameCounter++;
    });
  }

  Future<String> processFrame(CameraImage image) async {
    try {
      img.Image rgbImage = convertYUV420ToImage(image);
      img.Image resizedImage = img.copyResize(
        rgbImage,
        width: 224,
        height: 224,
      );
      var input = imageToByteList(resizedImage);
      var output = List.filled(1, List.filled(labels.length, 0.0));
      interpreter.run(input, output);

      var maxProbability = output[0].reduce(max);
      int predictedIndex = output[0].indexOf(maxProbability);

      double threshold = 0.7;
      isHandDetected.value = maxProbability >= threshold;
      confidence.value = maxProbability * 100;

      final width = image.width.toDouble();
      final height = image.height.toDouble();
      boundingBox.value = Rect.fromLTWH(
        width * 0.25,
        height * 0.25,
        width * 0.5,
        height * 0.5,
      );

      if (maxProbability < threshold) {
        return "No hand sign detected";
      } else {
        return "Predicted Sign: ${labels[predictedIndex]}";
      }
    } catch (e) {
      print("Error processing frame: $e");
      isHandDetected.value = false;
      confidence.value = 0.0;
      return "Error";
    }
  }

  img.Image convertYUV420ToImage(CameraImage cameraImage) {
    final int width = cameraImage.width;
    final int height = cameraImage.height;
    final img.Image image = img.Image(width, height);

    final int uvRowStride = cameraImage.planes[1].bytesPerRow;
    final int uvPixelStride = cameraImage.planes[1].bytesPerPixel!;

    for (int y = 0; y < height; y++) {
      final int uvRow = uvRowStride * (y >> 1);
      for (int x = 0; x < width; x++) {
        final int uvPixel = uvRow + (x >> 1) * uvPixelStride;

        final int yp = cameraImage.planes[0].bytes[y * width + x];
        final int up = cameraImage.planes[1].bytes[uvPixel];
        final int vp = cameraImage.planes[2].bytes[uvPixel];

        int r = (yp + 1.403 * (vp - 128)).round();
        int g = (yp - 0.344 * (up - 128) - 0.714 * (vp - 128)).round();
        int b = (yp + 1.770 * (up - 128)).round();

        image.setPixel(
          x,
          y,
          img.getColor(r.clamp(0, 255), g.clamp(0, 255), b.clamp(0, 255)),
        );
      }
    }

    return image;
  }

  List<List<List<List<double>>>> imageToByteList(img.Image image) {
    return [
      List.generate(
        224,
        (y) => List.generate(224, (x) {
          var pixel = image.getPixel(x, y);
          return [
            (img.getRed(pixel) / 255.0) * 2.0 - 1.0,
            (img.getGreen(pixel) / 255.0) * 2.0 - 1.0,
            (img.getBlue(pixel) / 255.0) * 2.0 - 1.0,
          ];
        }),
      ),
    ];
  }
}
