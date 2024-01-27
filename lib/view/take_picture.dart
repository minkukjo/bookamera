import 'package:bookamera/view/recognition_result.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../function/image_editor.dart';
import '../function/recognition.dart';
import '../model/empty_app_bar.dart';
import '../model/full_screen_camera_preview.dart';

// 사진 찍는 View에 해당하는 클래스
class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
    super.key,
    required this.camera,
  });

  final CameraDescription camera;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.camera, ResolutionPreset.max,
        enableAudio: false);

    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const EmptyAppBar(),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            final mediaSize = MediaQuery.of(context).size;
            return const FullScreenCameraPreview().of(_controller, mediaSize);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            // 카메라 초기화 대기
            await _initializeControllerFuture;

            // 플래시 끔
            _controller.setFlashMode(FlashMode.off);

            // 사진 찍을 때 까지 대기
            final originImage = await _controller.takePicture();

            // 앞에서 사진 찍으면 이미지 수정 뷰로 스무스하게 넘어가는 코드
            final croppedImage =
                await ImageEditor().cropImage(imageFile: originImage);
            if (croppedImage == null) return;

            var recognizedText =
                await TextRecognition().getRecognizedText(croppedImage);

            if (!mounted) return;

            // If the picture was taken, display it on a new screen.
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => RecognitionResultView(
                  // Pass the automatically generated path to
                  // the DisplayPictureScreen widget.
                  text: recognizedText,
                ),
              ),
            );
          } catch (e) {
            // If an error occurs, log the error to the console.
            print(e);
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
