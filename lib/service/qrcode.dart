import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:picorigin/widget.dart';

Future<String> scanQRCodeFromImage(BuildContext context, String filePath) async {
  final inputImage = InputImage.fromFilePath(filePath);
  final formats = [BarcodeFormat.all];
  final barcodeScanner = BarcodeScanner(formats: formats);

    final List<Barcode> barcodes = await barcodeScanner.processImage(inputImage);

    await barcodeScanner.close();


    // 使用换行符连接所有二维码内容
    final String result = barcodes.map((barcode) => barcode.rawValue.toString()).join('\n');

    return result;

}
