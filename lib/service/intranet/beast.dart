import 'dart:convert';

class MeowTranslator {
  late List<String> charMap;

  void setCharMap(String str) {
    if (str.length != 4) {
      throw Exception("字典必须为4个字符");
    }
    charMap = [str[0], str[1], str[2], str[3]];
  }

  void setCharMapFromMeow(String str) {
    if (str.length < 4) {
      throw Exception("密文无效");
    }
    charMap = List.filled(4, '');
    charMap[0] = str[2];
    charMap[1] = str[1];
    charMap[2] = str[str.length - 1];
    charMap[3] = str[0];
  }

  List<String> getCharMapToMeow() {
    return [
      charMap[3],
      charMap[1],
      charMap[0],
      charMap[2],
    ];
  }

  String strToHex(String str) {
    String hex = "";
    for (int i = 0; i < str.length; i++) {
      hex += str.codeUnitAt(i).toRadixString(16).padLeft(4, '0');
    }
    return hex.toUpperCase();
  }

  String hexToStr(String hex) {
    String str = "";
    for (int i = 0; i < hex.length; i += 4) {
      str += String.fromCharCode(
        int.parse(hex.substring(i, i + 4), radix: 16),
      );
    }
    return str;
  }

  String hexToMeow(String hex) {
    String result = "";
    for (int i = 0; i < hex.length; i++) {
      int k = (int.parse(hex[i], radix: 16) + i % 16) % 16;
      result += charMap[k ~/ 4];
      result += charMap[k % 4];
    }
    return result;
  }

  String meowToHex(String meow) {
    String hex = "";
    for (int i = 0; i < meow.length; i += 2) {
      int j = charMap.indexOf(meow[i]);
      int k = charMap.indexOf(meow[i + 1]);
      if (j == -1 || k == -1) {
        throw Exception("密文包含非法字符");
      }
      int val = (j * 4 + k - (i ~/ 2) % 16 + 16) % 16;
      hex += val.toRadixString(16);
    }
    return hex.toUpperCase();
  }

  String parseToMeow(String human) {
    String hex = strToHex(human);
    String body = hexToMeow(hex);
    List<String> map = getCharMapToMeow();
    return map[0] + map[1] + map[2] + body + map[3];
  }

  String parseToHuman(String meow) {
    setCharMapFromMeow(meow);
    String body = meow.substring(3, meow.length - 1);
    String hex = meowToHex(body);
    return hexToStr(hex);
  }
}

Future<String> encrypt(String dict, String plain) async {
  try {
    final translator = MeowTranslator();
    translator.setCharMap(dict);
    return translator.parseToMeow(plain);
  } catch (e) {
    throw Exception("加密失败: $e");
  }
}

Future<String> decrypt(String cipher) async {
  try {
    final translator = MeowTranslator();
    return translator.parseToHuman(cipher);
  } catch (e) {
    throw Exception("解密失败: $e");
  }
}