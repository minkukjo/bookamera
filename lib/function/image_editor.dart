import 'package:camera/camera.dart';
import 'package:image_cropper/image_cropper.dart';

class ImageEditor {
  Future<XFile?> cropImage({required XFile imageFile}) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
    );
    if (croppedFile == null) return null;

    return XFile(croppedFile.path);
  }
}
