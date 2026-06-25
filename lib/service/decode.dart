import 'dart:convert';

class MeowTranslator {
  late List<String> charMap;

  void setCharMap(String str) {
    charMap = [str[0], str[1], str[2], str[3]];
  }

  void setCharMapFromMeow(String str) {
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
    throw Exception("$e");
  }
}

Future<String> decodeBeast(String cipher, String dict) async {
    final translator = MeowTranslator();

    bool isValidDict(String d) {
      return d.length == 4 && d.split('').toSet().length == 4;
    }

    bool cipherHasDict = cipher.length >= 4;

    if (cipherHasDict) {
      translator.setCharMapFromMeow(cipher);
      return translator.parseToHuman(cipher);
    }

    if (!cipherHasDict && isValidDict(dict)) {
      translator.setCharMap(dict);

      final standardCipher = translator.parseToMeow(translator.hexToStr(translator.strToHex("")));

      final body = cipher;
      final map = translator.getCharMapToMeow();

      final rebuiltCipher = map[0] + map[1] + map[2] + body + map[3];

      translator.setCharMap(dict);
      return translator.parseToHuman(rebuiltCipher);
    }

    throw Exception();

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
