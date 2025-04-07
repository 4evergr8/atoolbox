import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:io';

import '/views/intranet/ocr_screen.dart';


Future<String> performOCR(File imageFile, Language language) async {
  TextRecognizer textRecognizer;
  switch (language) {
    case Language.chinese:
      textRecognizer = TextRecognizer(script: TextRecognitionScript.chinese);
      break;
    case Language.english:
      textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      break;
    case Language.japanese:
      textRecognizer = TextRecognizer(script: TextRecognitionScript.japanese);
      break;
  }

  final inputImage = InputImage.fromFile(imageFile);
  final result = await textRecognizer.processImage(inputImage);
  return result.text;
}