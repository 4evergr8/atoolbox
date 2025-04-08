import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

Future<String> scanQRCodeFromImage(
    BuildContext context,
    String filePath,
    ) async {
  final inputImage = InputImage.fromFilePath(filePath);
  final formats = [BarcodeFormat.all];
  final barcodeScanner = BarcodeScanner(formats: formats);
  try {
    final List<Barcode> barcodes = await barcodeScanner.processImage(inputImage);

    await barcodeScanner.close();

    if (barcodes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('没有识别到二维码')));
      return '没有识别到二维码';
    }

    // 使用换行符连接所有二维码内容
    final String result = barcodes.map((barcode) => barcode.rawValue.toString()).join('\n');

    return result;
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('二维码识别失败: $e')));
    return '二维码识别失败: $e';
  }
}
