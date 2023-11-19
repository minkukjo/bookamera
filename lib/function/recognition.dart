import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class TextRecognition {
  final TextRecognizer _textRecognizer =
      TextRecognizer(script: TextRecognitionScript.korean);

  Future<String> getRecognizedText(XFile image) async {
    // XFile 이미지를 InputImage 이미지로 변환
    final InputImage inputImage = InputImage.fromFilePath(image.path);

    // 이미지의 텍스트 인식해서 recognizedText에 저장
    RecognizedText recognizedText =
        await _textRecognizer.processImage(inputImage);

    // Release resources
    await _textRecognizer.close();

    // 인식한 텍스트 정보를 scannedText에 저장
    var scannedText = "";
    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        scannedText = "$scannedText${line.text}\n";
      }
    }

    return scannedText;
  }
}
