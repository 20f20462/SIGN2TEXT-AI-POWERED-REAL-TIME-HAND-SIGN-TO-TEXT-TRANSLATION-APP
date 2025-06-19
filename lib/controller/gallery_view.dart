import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;

class GalleryView extends StatefulWidget {
  const GalleryView({super.key});

  @override
  State<GalleryView> createState() => _GalleryViewState();
}

class _GalleryViewState extends State<GalleryView> {
  final ImagePicker _picker = ImagePicker();
  File? _image;
  String _prediction = '';
  double _confidence = 0.0;
  late tfl.Interpreter _interpreter;
  late List<String> _labels;

  final List<String> presetLetters = List.generate(
    26,
    (i) => String.fromCharCode(65 + i),
  );

  String? _selectedPresetImagePath;

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future<void> loadModel() async {
    try {
      _interpreter = await tfl.Interpreter.fromAsset(
        'assets/model_unquant.tflite',
      );
      final labelsRaw = await DefaultAssetBundle.of(
        context,
      ).loadString('assets/labels.txt');
      _labels =
          labelsRaw
              .split('\n')
              .where((label) => label.trim().isNotEmpty)
              .toList();
    } catch (e) {
      print("Error loading model: $e");
    }
  }

  Future<void> pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile == null) return;

    setState(() {
      _image = File(pickedFile.path);
      _selectedPresetImagePath = null;
      _prediction = '';
    });

    await runModelOnImage(File(pickedFile.path));
  }

  Future<void> onPresetImageTap(String imagePath) async {
    setState(() {
      _selectedPresetImagePath = imagePath;
      _image = null;
      _prediction = '';
    });

    try {
      final byteData = await DefaultAssetBundle.of(context).load(imagePath);
      final bytes = byteData.buffer.asUint8List();

      final decodedImage = img.decodeImage(bytes);
      if (decodedImage == null) return;

      final resized = img.copyResize(decodedImage, width: 224, height: 224);
      final input = imageToByteList(resized);
      final output = List.filled(1, List.filled(_labels.length, 0.0));

      _interpreter.run(input, output);

      final maxProb = output[0].reduce(max);
      final index = output[0].indexOf(maxProb);

      setState(() {
        _confidence = maxProb * 100;
        _prediction =
            maxProb < 0.7
                ? 'No hand sign detected'
                : 'Prediction: ${_labels[index]} (${_confidence.toStringAsFixed(2)}%)';
      });
    } catch (e) {
      print("Error processing preset image: $e");
    }
  }

  Future<void> runModelOnImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final decodedImage = img.decodeImage(bytes);
    if (decodedImage == null) return;

    final resized = img.copyResize(decodedImage, width: 224, height: 224);
    final input = imageToByteList(resized);
    final output = List.filled(1, List.filled(_labels.length, 0.0));

    _interpreter.run(input, output);

    final maxProb = output[0].reduce(max);
    final index = output[0].indexOf(maxProb);

    setState(() {
      _confidence = maxProb * 100;
      _prediction =
          maxProb < 0.7
              ? 'No hand sign detected'
              : 'Prediction: ${_labels[index]} (${_confidence.toStringAsFixed(2)}%)';
    });
  }

  List<List<List<List<double>>>> imageToByteList(img.Image image) {
    return List.generate(
      1,
      (_) => List.generate(
        224,
        (y) => List.generate(224, (x) {
          final pixel = image.getPixel(x, y);
          return [
            (img.getRed(pixel) / 255.0) * 2.0 - 1.0,
            (img.getGreen(pixel) / 255.0) * 2.0 - 1.0,
            (img.getBlue(pixel) / 255.0) * 2.0 - 1.0,
          ];
        }),
      ),
    );
  }

  Widget buildPresetImagesGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: presetLetters.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        final letter = presetLetters[index];
        final path = 'assets/letters/$letter.jpg';

        return GestureDetector(
          onTap: () => onPresetImageTap(path),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color:
                    _selectedPresetImagePath == path
                        ? Colors.blue
                        : Colors.grey,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Image.asset(path),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _interpreter.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload & Detect")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text(
                "Or select a hand sign image below:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              buildPresetImagesGrid(),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: pickImage,
                icon: const Icon(Icons.upload_file),
                label: const Text("Choose Image from Gallery"),
              ),
              const SizedBox(height: 16),
              if (_image != null) Image.file(_image!, height: 200),
              if (_selectedPresetImagePath != null)
                Image.asset(_selectedPresetImagePath!, height: 200),
              const SizedBox(height: 16),
              Text(
                _prediction,
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
