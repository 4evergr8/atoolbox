import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String> fetchRedirectedUrl({required String url}) async {
  HttpClient httpClient = HttpClient();
  HttpClientRequest request = await httpClient.getUrl(Uri.parse(url));
  request.followRedirects = false; // 禁用自动重定向
  HttpClientResponse response = await request.close();

  // 如果响应是重定向，获取新的 URL
  if (response.isRedirect) {
    String? location = response.headers.value(HttpHeaders.locationHeader);
    if (location != null) {
      // 如果是相对路径，需要解析为绝对路径
      Uri originalUri = Uri.parse(url);
      Uri newUri = originalUri.resolve(location);
      httpClient.close();
      return newUri.toString(); // 返回解析后的绝对路径
    }
  }

  // 如果没有重定向，直接返回原始 URL
  httpClient.close();
  return url;
}

Future<List<List<String>>> extractAndSearchUrls(String inputUrl) async {
  // 正则表达式用于提取有效的 URL
  RegExp urlRegex = RegExp(r'https?://\S+');
  RegExp bvRegex = RegExp(r'BV\w+');

  String? bv;
  String? extractedUrl;

  // 从输入字符串中提取有效的 URL
  Match? urlMatch = urlRegex.firstMatch(inputUrl);
  if (urlMatch != null) {
    extractedUrl = urlMatch.group(0);
  } else {
    throw Exception('无法提取有效的 URL');
  }

  // 检查是否包含 b23.tv
  if (extractedUrl!.contains('b23.tv')) {
    // 获取跳转后的链接
    String finalUrl = await fetchRedirectedUrl(url: extractedUrl);
    // 从最终 URL 中提取 BV 号
    bv = bvRegex.firstMatch(finalUrl)?.group(0);
  } else {
    // 如果不包含 b23.tv，直接从输入链接中提取 BV 号
    bv = bvRegex.firstMatch(extractedUrl)?.group(0);
  }

  if (bv == null) {
    throw Exception('无法提取 BV 号');
  }

  // 使用 Bilibili API 获取视频信息
  var apiResponse = await http.get(
      Uri.parse('https://api.bilibili.com/x/web-interface/view?bvid=$bv'));
  var jsonResponse = jsonDecode(apiResponse.body);

  if (jsonResponse['code'] != 0) {
    throw Exception('Bilibili API 请求失败');
  }

  // 提取视频封面图片链接
  String picUrl = jsonResponse['data']['pic'];

  // 构造反向图片搜索链接
  List<List<String>> searchUrls = [
    ['Google', 'https://www.google.com/searchbyimage?client=app&image_url=$picUrl'],
    ['Google Lens', 'https://lens.google.com/uploadbyurl?url=$picUrl'],
    ['Yandex.eu', 'https://yandex.eu/images/search?url=$picUrl&rpt=imageview'],
    ['Yandex.ru', 'https://yandex.ru/images/search?url=$picUrl&rpt=imageview'],
    ['Bing', 'https://www.bing.com/images/search?q=imgurl:$picUrl&view=detailv2&iss=sbi'],
    ['TinEye', 'https://tineye.com/search/?url=$picUrl'],

    ['3DIQDB', 'https://3d.iqdb.org/?url=$picUrl'],

    ['IQDB', 'https://iqdb.org/?url=$picUrl'],
    ['SauceNAO', 'https://saucenao.com/search.php?url=$picUrl'],
    ['ascii2d', 'https://ascii2d.net/search/url/$picUrl'],
    ['WAIT', 'https://trace.moe/?url=$picUrl'],
    ['Trace.moe', 'https://trace.moe/?url=$picUrl'],



  ];
  return searchUrls;

}

void main() async {
  String inputUrl = '剩下的从法国v会比较那么快   aahttps://b23.tv/pigt3PQ ';
  try {
    List<List<String>> searchUrls = await extractAndSearchUrls(inputUrl);
    for (var url in searchUrls) {
      print('Description: ${url[0]}, URL: ${url[1]}');
    }
  } catch (e) {
    print('发生错误：$e');
  }
}