import 'dart:convert';

Future<String> base64_decode(String base64String) async {
  List<int> base64DecodedBytes = base64Decode(base64String);
  String utf8Decoded = utf8.decode(base64DecodedBytes);
  return utf8Decoded;
}

// 将输入的字符串用 UTF-8 编码后用 Base64 编码
Future<String> base64_encode(String utf8String) async {
  List<int> utf8Bytes = utf8.encode(utf8String);
  String base64Encoded = base64Encode(utf8Bytes);
  return base64Encoded;
}

// 1. 核心加密入口
Future<String> beast_encode(String dict, String plain) async {
  if (dict.length != 4) throw Exception("字典必须为4个字符");

  List<String> charMap = dict.split('');
  String hex = plain.codeUnits.map((code) => code.toRadixString(16).padLeft(4, '0').toUpperCase()).join();

  String body =
      List.generate(hex.length, (i) {
        int k = (int.parse(hex[i], radix: 16) + i % 16) % 16;
        return charMap[k ~/ 4] + charMap[k % 4];
      }).join();

  return charMap[3] + charMap[1] + charMap[0] + body + charMap[2];
}

// 2. 核心解密入口
Future<String> beast_decode(String cipher) async {
  if (cipher.length < 4) throw Exception("密文无效");

  List<String> charMap = [cipher[3], cipher[1], cipher[2], cipher[cipher.length - 1]];
  String body = cipher.substring(3, cipher.length - 1);

  String hex =
      List.generate(body.length ~/ 2, (i) {
        int j = charMap.indexOf(body[i * 2]);
        int k = charMap.indexOf(body[i * 2 + 1]);
        if (j == -1 || k == -1) throw Exception("密文包含非法字符");
        return ((j * 4 + k - i % 16 + 16) % 16).toRadixString(16).toUpperCase();
      }).join();

  return List.generate(
    hex.length ~/ 4,
    (i) => String.fromCharCode(int.parse(hex.substring(i * 4, i * 4 + 4), radix: 16)),
  ).join();
}
