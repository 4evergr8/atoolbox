import 'package:http/http.dart' as http;
import 'dart:async';

Future<String> dohQuery(String queryUrl, String domain, String queryType, int timeoutMs) async {
  try {
    // 设置请求头
    final headers = {
      'accept': 'application/dns-json',
    };

    // 构造查询参数
    final params = {
      'name': domain,
      'type': queryType,
    };

    // 构造请求 URL
    final url = Uri.parse(queryUrl).replace(queryParameters: params);

    // 发送 GET 请求
    final response = await http.get(url, headers: headers)
        .timeout(Duration(milliseconds: timeoutMs));

    if (response.statusCode == 200) {
      return response.body;
    } else {
      return '请求失败。状态码: ${response.statusCode}\n响应内容: ${response.body}';
    }
  } catch (e) {
    return '请求失败。错误信息: $e';
  }
}