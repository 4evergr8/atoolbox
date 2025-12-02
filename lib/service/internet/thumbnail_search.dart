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

Future<List<List<String>>?> extractAndSearchUrls(String input) async {
  try {
    RegExp urlRegex = RegExp(r'https?://\S+');
    RegExp bvRegex = RegExp(r'BV[0-9A-Za-z]{10}');

    String? url;
    String? bv;

    // ========== 情况 4：纯 BV 输入 ==========
    bv = bvRegex.firstMatch(input)?.group(0);
    if (bv != null && input.trim() == bv) {
      // 纯 BV，已经提取到 bv，不需要 URL
    } else {
      // ========== 情况 1 或 2：文本中包含 URL ==========
      Match? urlMatch = urlRegex.firstMatch(input);
      if (urlMatch != null) {
        url = urlMatch.group(0);
      }

      // ========== 情况 3：b23.tv 重定向 ==========
      if (url != null && url.contains("b23.tv")) {
        url = await fetchRedirectedUrl(url: url);
      }

      // URL 中提取 BV
      if (bv == null && url != null) {
        bv = bvRegex.firstMatch(url)?.group(0);
      }
    }

    // ====== ❌ 四种情况都失败 → BV 无法提取 → 输入无效 ======
    if (bv == null) {
      // ⚠️ 直接返回 null，让 UI 层弹 snackbar
      return null;
    }

    // ========== 请求 B 站 API ==========
    var apiResponse = await http.get(
      Uri.parse('https://api.bilibili.com/x/web-interface/view?bvid=$bv'),
    );
    var jsonResponse = jsonDecode(apiResponse.body);

    if (jsonResponse['code'] != 0) {
      return null; // 返回 null，UI 提示错误
    }

    // ========== 取封面 ==========
    String picUrl = jsonResponse['data']['pic'];

    // ========== 构造反搜链接 ==========
    return [
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
  } catch (e) {
    // 程序异常也返回 null，让 UI 给 snackbar
    return null;
  }
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