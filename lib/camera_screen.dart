import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'api_service.dart';

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;

  CameraScreen({required this.camera});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _captureAndRecognizePlate() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();
      String extractedText = await FlutterTesseractOcr.extractText(image.path);

      // Assuming the number plate is the first text extracted
      String plateNumber = extractedText.split('\n').first;

      // Check if the plate exists in the backend
      var matchResponse = await ApiService.matchPlate(plateNumber);

      if (matchResponse['match']) {
        // Show the matched details
        _showMatchDialog(matchResponse['details']);
      } else {
        // Save the new plate to the backend
        await ApiService.savePlate(plateNumber, "Car details here...");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('New plate saved: $plateNumber')),
        );
      }
    } catch (e) {
      print(e);
    }
  }

  void _showMatchDialog(String details) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Car Matched!"),
        content: Text("Details: $details"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Capture Number Plate')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _captureAndRecognizePlate,
        tooltip: 'Capture',
        child: Icon(Icons.camera_alt),
      ),
    );
  }
}
