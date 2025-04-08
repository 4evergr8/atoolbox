import 'package:charset_converter/charset_converter.dart';

Future<String> recoverGarbledText(String input) async {
  List<String> encodings = await CharsetConverter.availableCharsets();
  List<List<String>> file = [];
  List<List<String>> result = [];
  List<Map<String, String>> results = [];
  int score = 0;

  for (var encA in encodings) {
    for (var encB in encodings) {
      if (encA != encB) {
        try {
          var bytes = await CharsetConverter.encode(encA, input);
          String recovered;
          try {
            recovered = await CharsetConverter.decode(encB, bytes);
            file.add([encA, encB, recovered]);
            file.add([encA, encB, recovered]);


          } catch (e) {
            file.add([encA, encB, '解码失败']);
          }

        } catch (e) {
          file.add([encA, encB, '编码失败']);
        }
      }
    }
  }

  results.sort((a, b) {
    int scoreA = calculateReadability(a['恢复结果']!);
    int scoreB = calculateReadability(b['恢复结果']!);
    return scoreB.compareTo(scoreA);
  });
}

int calculateReadability(String text) {
  int score = 0;

  // 遍历文本中的每个字符
  for (var char in text.split('')) {
    // 如果字符是字母、数字或任何语言的字符，则给一分
    if (RegExp(
      r'[A-Za-z0-9\u4e00-\u9fa5\u3040-\u30ff\uac00-\ud7af\u0800-\u4e00]',
    ).hasMatch(char)) {
      score += 1;
    }
  }

  return score;
}

void main() async {
  String garbledText = "锘挎槬鐪犱笉瑙夋檽锛屽澶勯椈鍟奸笩";
  String result = await recoverGarbledText(garbledText);
  print(result);
}
