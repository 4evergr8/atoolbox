import 'package:http/http.dart' as http;
import 'dart:async';

Future<String> dohPtrV6Query(String queryUrl, String ip, int timeoutMs) async {
  try {
    // 将 IPv6 地址转换为 PTR 查询格式
    final ptrDomain = convertIPv6ToPtr(ip);

    // 设置请求头
    final headers = {
      'accept': 'application/dns-json',
    };

    // 构造查询参数
    final params = {
      'name': ptrDomain,
      'type': 'PTR',
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

// 将 IPv6 地址转换为 PTR 查询格式
String convertIPv6ToPtr(String ip) {
  // 移除可能的方括号
  ip = ip.replaceAll(RegExp(r'[\[\]]'), '');
  
  // 展开压缩的 IPv6 地址
  final parts = ip.split(':');
  final expandedParts = <String>[];
  
  for (var part in parts) {
    if (part.isEmpty) {
      // 处理压缩部分
      final zeros = 8 - parts.length + 1;
      for (var i = 0; i < zeros; i++) {
        expandedParts.add('0000');
      }
    } else {
      // 补齐每个部分到4位
      expandedParts.add(part.padLeft(4, '0'));
    }
  }
  
  // 合并所有部分
  final fullIp = expandedParts.join('');
  
  // 转换为 nibble 格式并添加 ip6.arpa 后缀
  final nibbles = fullIp.split('').reversed.join('.');
  return '$nibbles.ip6.arpa';
}
