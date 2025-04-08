import 'package:charset_converter/charset_converter.dart';

Future<String> recoverGarbledText(String garbledText) async {
  List<String> encodings = [
    "windows-1250", "windows-1251", "windows-1252", "windows-1253", "windows-1254",
    "windows-1255", "windows-1256", "windows-1257", "windows-1258", "iso-8859-1",
    "iso-8859-2", "iso-8859-3", "iso-8859-4", "iso-8859-5", "iso-8859-6", "iso-8859-7",
    "iso-8859-8", "iso-8859-9", "iso-8859-10", "iso-8859-11", "iso-8859-13", "iso-8859-14",
    "iso-8859-15", "iso-8859-16", "utf-8", "utf-16", "utf-32", "gbk", "big5", "shift_jis",
    "euc-jp", "euc-kr", "tis-620", "koi8-r"
  ];

  StringBuffer allAttempts = StringBuffer();
  List<Map<String, String>> results = [];

  for (var encA in encodings) {
    for (var encB in encodings) {
      if (encA != encB) {
        try {
          // 步骤1: 乱码转换为字节
          var garbledBytes = await CharsetConverter.encode(encA, garbledText);

          // 步骤2: 强制转换字节为文本，即使失败也记录
          String recovered;
          try {
            recovered = await CharsetConverter.decode(encB, garbledBytes);
          } catch (e) {
            // 如果解码失败，输出原始乱码内容并继续
            recovered = "<解码失败>: $garbledText";
          }

          // 记录所有尝试的结果
          allAttempts.writeln("$encA -> $encB: $recovered");

          // 保存有效的恢复结果
          if (recovered != "<解码失败>: $garbledText") {
            results.add({
              '错误编码': encA,
              '原编码': encB,
              '恢复结果': recovered
            });
          }

        } catch (e) {
          // 如果编码失败，记录编码失败信息
          allAttempts.writeln("编码失败：$encA -> $encB");
        }
      }
    }
  }

  // 排序并显示前3个最可能的恢复结果
  allAttempts.writeln("\n前3个恢复结果：");

  results.sort((a, b) {
    int scoreA = calculateReadability(a['恢复结果']!);
    int scoreB = calculateReadability(b['恢复结果']!);
    return scoreB.compareTo(scoreA);
  });

  // 输出前3个恢复结果
  for (int i = 0; i < 3 && i < results.length; i++) {
    var result = results[i];
    allAttempts.writeln("${result['错误编码']} -> ${result['原编码']}: ${result['恢复结果']}");
  }

  return allAttempts.toString();
}

// 计算恢复文本的可读性分数
int calculateReadability(String text) {
  // 中文、英文、数字任意一个命中就给高分
  if (RegExp(r'[A-Za-z0-9\u4e00-\u9fa5]').hasMatch(text)) {
    return 100;
  }
  return 0;
}

void main() async {
  String garbledText = "锘挎槬鐪犱笉瑙夋檽锛屽澶勯椈鍟奸笩";
  String result = await recoverGarbledText(garbledText);
  print(result);
}
