import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class MediaSizeClipper extends CustomClipper<Rect> {
  final Size mediaSize;

  const MediaSizeClipper(this.mediaSize);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, mediaSize.width, mediaSize.height);
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) {
    return true;
  }
}

class FullScreenCameraPreview extends ClipRect {
  const FullScreenCameraPreview({super.key});

  ClipRect of(CameraController controller, Size mediaSize) {
    final scale = 1 / (controller.value.aspectRatio * mediaSize.aspectRatio);

    return ClipRect(
      clipper: MediaSizeClipper(mediaSize),
      child: Transform.scale(
        scale: scale,
        alignment: Alignment.topCenter,
        child: CameraPreview(controller),
      ),
    );
  }
}
