import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? _image;
  final picker = ImagePicker();
  Interpreter? _interpreter;
  List<String> _labels = [];
  String _prediction = '';
  double _confidence = 0.0;

  static const int inputSize = 96;

  @override
  void initState() {
    super.initState();
    loadModelAndLabels();
  }

  Future<void> loadModelAndLabels() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/model.tflite');
      final labelsData = await rootBundle.loadString('assets/labels.txt');
      _labels =
          labelsData
              .split('\n')
              .where((line) => line.trim().isNotEmpty)
              .toList();
    } catch (e) {
      print('Error loading model or labels: $e');
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() {
      _image = File(pickedFile.path);
    });

    await classifyImage(_image!);
  }

  Uint8List imageToByteListFloat32(img.Image image) {
    var convertedBytes = Float32List(inputSize * inputSize * 3);
    var buffer = convertedBytes.buffer.asFloat32List();
    int pixelIndex = 0;

    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        final pixel = image.getPixelSafe(x, y);
        buffer[pixelIndex++] = pixel.r - 127.5 / 127.5;
        buffer[pixelIndex++] = pixel.g - 127.5 / 127.5;
        buffer[pixelIndex++] = pixel.b - 127.5 / 127.5;
      }
    }

    return convertedBytes.buffer.asUint8List();
  }

  Future<void> classifyImage(File imageFile) async {
    if (_interpreter == null || _labels.isEmpty) return;

    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) return;

    final resizedImage = img.copyResize(
      image,
      width: inputSize,
      height: inputSize,
    );
    final floatInput = imageToByteListFloat32(resizedImage);
    final inputAsFloat32 = floatInput.buffer.asFloat32List();

    final input4D = List.generate(
      1,
      (_) => List.generate(
        inputSize,
        (y) => List.generate(inputSize, (x) {
          final i = (y * inputSize + x) * 3;
          return [
            inputAsFloat32[i],
            inputAsFloat32[i + 1],
            inputAsFloat32[i + 2],
          ];
        }),
      ),
    );

    final output = List.filled(
      _labels.length,
      0.0,
    ).reshape([1, _labels.length]);
    _interpreter!.run(input4D, output);

    final scores = output[0].cast<double>();
    int maxIndex = 0;
    double maxScore = scores[0];

    for (int i = 1; i < scores.length; i++) {
      if (scores[i] > maxScore) {
        maxScore = scores[i];
        maxIndex = i;
      }
    }

    setState(() {
      _prediction = _labels[maxIndex];
      _confidence = maxScore;
    });
  }

  @override
  void dispose() {
    _interpreter?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FD),
      appBar: AppBar(
        title: Text(
          'Traffic Sign Classifier',
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF4263EB),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
          child: Column(
            children: [
              if (_image != null)
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(_image!, height: 200),
                  ),
                )
              else
                const Text(
                  'No image selected',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),

              const SizedBox(height: 20),

              if (_prediction.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 6),
                    ],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Prediction:',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _prediction,
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Confidence: ${(_confidence * 100).toStringAsFixed(2)}%',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Text(
                  'No prediction yet.',
                  style: GoogleFonts.poppins(fontSize: 16),
                ),

              const SizedBox(height: 30),

              ElevatedButton.icon(
                onPressed: pickImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4263EB),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.image, color: Colors.white),
                label: Text(
                  'Pick Image',
                  style: TextStyle(
                    fontFamily: GoogleFonts.poppins().fontFamily,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
