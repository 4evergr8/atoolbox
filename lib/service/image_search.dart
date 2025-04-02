import 'dart:math';
import 'dart:io';
import 'package:http/http.dart' as http;



Future<String> searchLocalImage(File imageFile, String workerUrl) async {
  // 生成随机 5 位小写字母 + 时间戳作为 key
  String randomKey = generateRandomKey();
  String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
  String key = '$randomKey$timestamp';

  // 上传 URL
  String uploadUrl = '$workerUrl/upload/$key';

  // 读取图片文件为字节数据
  List<int> imageBytes = await imageFile.readAsBytes();

  // 创建 MultipartRequest
  var request = http.MultipartRequest('POST', Uri.parse(uploadUrl))
    ..files.add(http.MultipartFile.fromBytes(
      'file',
      imageBytes,
      filename: imageFile.path.split('/').last,
    ));

  // 发送请求并获取响应
  var response = await request.send();

  // 解析响应
  if (response.statusCode == 200) {
    // 构造下载链接
    String downloadUrl = '$workerUrl/download/$key';
    print('图片上传成功，下载链接: $downloadUrl');
    return downloadUrl;
  } else {
    String errorMsg = await response.stream.bytesToString();
    throw Exception('Failed to upload image. Status: ${response.statusCode}, Response: $errorMsg');
  }
}

String generateRandomKey() {
  const String characters = 'abcdefghijklmnopqrstuvwxyz';
  Random random = Random();
  return List.generate(5, (index) => characters[random.nextInt(characters.length)]).join();
}

void main() async {
  try {
    File imageFile = File('D:/Project/WebTools/assets/aaa.jpg'); // 替换为你的图片路径
    String workerUrl = 'https://your-worker-url.workers.dev'; // 替换为你的 Cloudflare Workers 地址
    String imageUrl = await searchLocalImage(imageFile, workerUrl);
    print('图片 URL: $imageUrl');
  } catch (e) {
    print('发生错误: $e');
  }
}


List<List<String>> generateReverseImageSearchUrls(String picUrl) {
  List<List<String>> searchUrls = [
    ['Google Lens', 'https://lens.google.com/uploadbyurl?url=$picUrl'],
    ['Yandex.eu', 'https://yandex.eu/images/search?url=$picUrl&rpt=imageview'],
    ['SauceNAO', 'https://saucenao.com/search.php?url=$picUrl'],
    ['Yandex.ru', 'https://yandex.ru/images/search?url=$picUrl&rpt=imageview'],
    ['Bing', 'https://www.bing.com/images/search?q=imgurl:$picUrl&view=detailv2&iss=sbi'],
    ['WAIT', 'https://trace.moe/?url=$picUrl'],
    ['ascii2d', 'https://ascii2d.net/search/url/$picUrl'],


  ];
  return searchUrls;
}

