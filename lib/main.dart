import 'package:bookamera/view/take_picture.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final cameras = await availableCameras();

  final firstCamera = cameras.first;

  runApp(
    MaterialApp(
      theme: ThemeData.dark(),
      // 최초 화면은 무조건 카메라 찍는 화면
      home: TakePictureScreen(
        camera: firstCamera,
      ),
    ),
  );
}
