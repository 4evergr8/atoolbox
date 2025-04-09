import 'dart:io';
import 'package:charset_converter/charset_converter.dart';

Future<String> recoverGarbledText(
  String input,
  String include,
  String exclude,
  int score,
) async {
  List<String> encodings = await CharsetConverter.availableCharsets();

  List<List<String>> file = [];
  List<List<String>> result = [];

  final downloadsDirectory = Directory('/storage/emulated/0/Download');
  if (!downloadsDirectory.existsSync()) {
    throw Exception("无法访问下载目录");
  }

  for (var encA in encodings) {
    for (var encB in encodings) {
      if (encA != encB) {
        try {
          var bytes = await CharsetConverter.encode(encA, input);
          String recovered;
          try {
            recovered = await CharsetConverter.decode(encB, bytes);
            file.add([encA, encB, recovered]);

            int i = 0;
            for (var char in recovered.split('')) {
              // 如果是排除的字符，就跳过
              if (RegExp(exclude, unicode: true).hasMatch(char)) {
                continue;
              }
              if (RegExp(include, unicode: true).hasMatch(char)) {
                i += 1;
              }
            }

            if (i < score) {
              result.insert(0, [encA, encB, recovered]);
            }
          } catch (e) {
            file.add([encA, encB, '解码失败']);
          }
        } catch (e) {
          file.add([encA, encB, '编码失败']);
        }
      }
    }
  }

  var buffer = StringBuffer();
  for (var row in file) {
    if (row.length == 3) {
      buffer.writeln('现编码:${row[0]} 原编码:${row[1]} 恢复内容: ${row[2]}');
    }
  }
  final recordFile = File('${downloadsDirectory.path}/record.txt');
  await recordFile.writeAsString(
    buffer.toString(),
    mode: FileMode.write,
  ); // 覆盖写入

  buffer = StringBuffer();
  for (var row in result) {
    if (row.length == 3) {
      buffer.writeln('现编码:${row[0]} 原编码:${row[1]} 恢复内容: ${row[2]}');
    }
  }
  final resultFile = File('${downloadsDirectory.path}/result.txt');
  await resultFile.writeAsString(
    buffer.toString(),
    mode: FileMode.write,
  ); // 覆盖写入
  return buffer.toString();
}
