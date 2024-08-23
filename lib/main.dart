import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'camera_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  runApp(MyApp(camera: firstCamera));
}

class MyApp extends StatelessWidget {
  final CameraDescription camera;

  MyApp({required this.camera});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Car Plate Recognition',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CameraScreen(camera: camera),
    );
  }
}
