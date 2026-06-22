import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:http/http.dart' as http;

// 1. 核心功能：根据图片 URL 拼凑各大引擎的反搜链接
List<List<String>> generateUrls(String picUrl) {
  return [
    ['Google Lens', 'https://lens.google.com/uploadbyurl?url=$picUrl'],
    ['Yandex.ru', 'https://yandex.ru/images/search?url=$picUrl&rpt=imageview'],
    ['Lenso.ai', 'https://lenso.ai/en/search-by-url?url=$picUrl&utm_source=sbi'],
    ['Google', 'https://www.google.com/searchbyimage?client=app&image_url=$picUrl'],
    ['SauceNAO', 'https://saucenao.com/search.php?url=$picUrl'],
    ['ascii2d', 'https://ascii2d.net/search/url/$picUrl'],
    ['TinEye', 'https://tineye.com/search/?url=$picUrl'],
    ['3DIQDB', 'https://3d.iqdb.org/?url=$picUrl'],
    ['IQDB', 'https://iqdb.org/?url=$picUrl'],
    ['WAIT', 'https://trace.moe/?url=$picUrl'],
    ['Trace.moe', 'https://trace.moe/?url=$picUrl'],
  ];
}

// 3. 核心功能：上传本地图片到 Cloudflare Worker 并返回下载/反搜链接
Future<String> searchLocalImage(File imageFile, String workerUrl) async {
  const String characters = 'abcdefghijklmnopqrstuvwxyz';
  Random random = Random();
  String randomKey = List.generate(5, (index) => characters[random.nextInt(characters.length)]).join();
  int timestamp = DateTime.now().millisecondsSinceEpoch;
  timestamp = 9999999999999 - timestamp;
  String key = '${timestamp.toString().padLeft(13, '0')}$randomKey-APP';
  String uploadUrl = '$workerUrl/upload/$key';
  List<int> imageBytes = await imageFile.readAsBytes();

  var request = http.MultipartRequest('POST', Uri.parse(uploadUrl))
    ..files.add(http.MultipartFile.fromBytes('file', imageBytes, filename: imageFile.path.split('/').last));

  var response = await request.send();

  if (response.statusCode == 200) {
    return '$workerUrl/download/$key';
  } else {
    String errorMsg = await response.stream.bytesToString();
    throw Exception('Failed to upload image. Status: ${response.statusCode}, Response: $errorMsg');
  }
}

// 4. 辅助功能：获取短链重定向后的真实 URL
Future<String> fetchRedirectedUrl({required String url}) async {
  HttpClient httpClient = HttpClient();
  HttpClientRequest request = await httpClient.getUrl(Uri.parse(url));
  request.followRedirects = false;
  HttpClientResponse response = await request.close();

  if (response.isRedirect) {
    String? location = response.headers.value(HttpHeaders.locationHeader);
    if (location != null) {
      Uri originalUri = Uri.parse(url);
      Uri newUri = originalUri.resolve(location);
      httpClient.close();
      return newUri.toString();
    }
  }

  httpClient.close();
  return url;
}

Future<String> extractBvid(String input) async {
  final RegExp bvRegex = RegExp(r'BV[0-9A-Za-z]{10}');
  final String trimmedInput = input.trim();

  // 1. 情况一：输入本身就是纯 BV 号
  if (bvRegex.hasMatch(trimmedInput) && trimmedInput.length == 12) {
    return bvRegex.firstMatch(trimmedInput)?.group(0) ?? '';
  }

  // 2. 情况二：寻找输入中是否存在 URL
  final RegExp urlRegex = RegExp(r'https?://\S+');
  String? url = urlRegex.firstMatch(trimmedInput)?.group(0);

  if (url != null) {
    // 如果是 b23.tv 短链，则请求追踪其重定向后的真实长链
    if (url.contains("b23.tv")) {
      url = await fetchRedirectedUrl(url: url);
    }
    // 从解析后（或原本就是）的长链中提取 BV 号
    return bvRegex.firstMatch(url)?.group(0) ?? '';
  }

  // 3. 情况三：输入不是纯 URL，但文本中夹杂着 BV 号（如分享文本）
  return bvRegex.firstMatch(trimmedInput)?.group(0) ?? '';
}

// 2. 根据 BV 号请求 B 站 API 获取封面图片链接字符串
Future<String> fetchBilibiliCover(String bvid) async {
  var apiResponse = await http.get(Uri.parse('https://api.bilibili.com/x/web-interface/view?bvid=$bvid'));
  var jsonResponse = jsonDecode(apiResponse.body);

  if (jsonResponse['code'] != 0) {
    return '';
  }

  return jsonResponse['data']['pic'] ?? '';
}
