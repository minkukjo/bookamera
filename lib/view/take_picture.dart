import 'package:bookamera/view/phrase_list.dart';
import 'package:bookamera/view/recognition_result.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../function/image_editor.dart';
import '../function/recognition.dart';
import '../model/empty_app_bar.dart';
import '../model/full_screen_camera_preview.dart';
import '../constants/colors.dart';

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

class TakePictureScreenState extends State<TakePictureScreen> with TickerProviderStateMixin {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late AnimationController _cameraAnimationController;
  late AnimationController _listAnimationController;
  late Animation<double> _cameraScaleAnimation;
  late Animation<double> _listScaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera, 
      ResolutionPreset.max,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    _initializeControllerFuture = _controller.initialize().then((_) {
      // 카메라 초기화 후 추가 설정
      _controller.setFlashMode(FlashMode.off);
      return;
    });

    _cameraAnimationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _cameraScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _cameraAnimationController,
      curve: Curves.easeInOut,
    ));

    _listScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _listAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _cameraAnimationController.dispose();
    _listAnimationController.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    try {
      _cameraAnimationController.forward().then((_) => _cameraAnimationController.reverse());
      
      // 카메라 초기화 대기
      await _initializeControllerFuture;

      // 사진 찍을 때 까지 대기
      final originImage = await _controller.takePicture();

      // 앞에서 사진 찍으면 이미지 수정 뷰로 스무스하게 넘어가는 코드
      final croppedImage = await ImageEditor().cropImage(imageFile: originImage);
      if (croppedImage == null) return;

      var recognizedText = await TextRecognition().getRecognizedText(croppedImage);

      if (!mounted) return;

      // If the picture was taken, display it on a new screen.
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => RecognitionResultView(
            text: recognizedText,
          ),
        ),
      );
    } catch (e) {
      print(e);
    }
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
        floatingActionButton: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment(
                  Alignment.bottomRight.x, Alignment.bottomRight.y - 0.2),
              child: ScaleTransition(
                scale: _listScaleAnimation,
                child: FloatingActionButton(
                    heroTag: "list",
                    onPressed: () async {
                      _listAnimationController.forward().then((_) {
                        _listAnimationController.reverse();
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => PhraseListView()),
                        );
                      });
                    },
                    tooltip: 'List View 이동',
                    backgroundColor: AppColors.navyBlue,
                    child: const Icon(Icons.list)),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: ScaleTransition(
                scale: _cameraScaleAnimation,
                child: FloatingActionButton(
                  heroTag: 'camera',
                  onPressed: _takePicture,
                  backgroundColor: AppColors.navyBlue,
                  child: const Icon(Icons.camera_alt),
                ),
              ),
            )
          ],
        ));
  }
}
