import 'dart:convert';

Future<String> decodeBase64(String base64String) async {
  try {
    List<int> base64DecodedBytes = base64Decode(base64String);
    String utf8Decoded = utf8.decode(base64DecodedBytes);
    return utf8Decoded;
  } catch (e) {
    throw Exception('解码失败: $e');
  }
}

// 将输入的字符串用 UTF-8 编码后用 Base64 编码
Future<String> encodeToBase64(String utf8String) async {
  try {
    List<int> utf8Bytes = utf8.encode(utf8String);
    String base64Encoded = base64Encode(utf8Bytes);
    return base64Encoded;
  } catch (e) {
    throw Exception('编码失败: $e');
  }
}