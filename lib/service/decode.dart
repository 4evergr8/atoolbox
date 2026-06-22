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
    return [charMap[3], charMap[1], charMap[0], charMap[2]];
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
      str += String.fromCharCode(int.parse(hex.substring(i, i + 4), radix: 16));
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

Future<String> encodeBeast(String dict, String plain) async {
  try {
    final translator = MeowTranslator();
    translator.setCharMap(dict);
    return translator.parseToMeow(plain);
  } catch (e) {
    throw Exception("加密失败: $e");
  }
}


Future<String> decodeBeast(String cipher, String dict) async {
  try {
    final translator = MeowTranslator();

    bool isValidDict(String d) {
      return d.length == 4 && d.split('').toSet().length == 4;
    }

    bool cipherHasDict = cipher.length >= 4;

    // =========================
    // CASE 1: 密文有字典
    // =========================
    if (cipherHasDict) {
      translator.setCharMapFromMeow(cipher);
      return translator.parseToHuman(cipher);
    }

    // =========================
    // CASE 2: 密文无字典 + 输入字典合法
    // =========================
    if (!cipherHasDict && isValidDict(dict)) {
      translator.setCharMap(dict);

      // 按原协议拼接成标准密文
      final standardCipher = translator.parseToMeow(
        translator.hexToStr(translator.strToHex("")),
      );

      // ❗关键：不能这样构造内容，正确方式是直接补结构
      // 因为 parseToMeow 会重新编码

      // 正确做法：直接拼 header + body
      final body = cipher;
      final map = translator.getCharMapToMeow();

      final rebuiltCipher =
          map[0] + map[1] + map[2] + body + map[3];

      translator.setCharMap(dict);
      return translator.parseToHuman(rebuiltCipher);
    }

    // =========================
    // CASE 3: 都失败
    // =========================
    throw Exception("无法解密：缺少有效字典");

  } catch (e) {
    throw Exception("解密失败: $e");
  }
}

Future<String> decodeBase64(String base64String) async {
  List<int> base64DecodedBytes = base64Decode(base64String);
  String utf8Decoded = utf8.decode(base64DecodedBytes);
  return utf8Decoded;
}

// 将输入的字符串用 UTF-8 编码后用 Base64 编码
Future<String> encodeBase64(String utf8String) async {
  List<int> utf8Bytes = utf8.encode(utf8String);
  String base64Encoded = base64Encode(utf8Bytes);
  return base64Encoded;
}
