import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  final url = Uri.parse(
      '');

  final headers = {
    "User-Agent":
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36",
    "Referer": "https://www.bilibili.com"
  };

  final response = await http.get(url, headers: headers);

  if (response.statusCode == 200) {
    final file = File('Download_video.flv');
    await file.writeAsBytes(response.bodyBytes);
    print('文件下载完成: ${file.absolute.path}');
  } else {
    print('下载失败, HTTP 状态码: ${response.statusCode}');
  }
}
