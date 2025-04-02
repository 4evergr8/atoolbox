import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:typed_data';

Future<String> dohQuery(String queryUrl, String domain, int timeoutMs) async {
  try {
    // 构造 DNS 查询报文
    // DNS 查询报文的格式：ID(2字节) + 标志(2字节) + 问题数(2字节) + 回答数(2字节) + 权威记录数(2字节) + 额外记录数(2字节)
    // 问题部分：域名(长度字节+数据字节)+类型(2字节)+类别(2字节)
    // 这里构造一个简单的查询报文
    final id = 0x1234; // 随机ID
    final flags = 0x0100; // 标准查询
    final questions = 1; // 一个问题
    final answerRRs = 0; // 无回答
    final authorityRRs = 0; // 无权威记录
    final additionalRRs = 0; // 无额外记录

    // 构造域名部分
    List<int> domainBytes = [];
    for (var part in domain.split('.')) {
      domainBytes.add(part.length);
      domainBytes.addAll(utf8.encode(part));
    }
    domainBytes.add(0); // 结尾

    // 构造问题部分
    final questionType = 1; // A记录
    final questionClass = 1; // IN
    domainBytes.addAll([questionType >> 8, questionType & 0xFF]);
    domainBytes.addAll([questionClass >> 8, questionClass & 0xFF]);

    // 构造报文头
    final header = [
      id >> 8, id & 0xFF,
      flags >> 8, flags & 0xFF,
      questions >> 8, questions & 0xFF,
      answerRRs >> 8, answerRRs & 0xFF,
      authorityRRs >> 8, authorityRRs & 0xFF,
      additionalRRs >> 8, additionalRRs & 0xFF,
    ];

    // 合并报文
    final dnsQueryBytes = Uint8List.fromList(header + domainBytes);

    // 将二进制数据进行 Base64 编码
    final query = base64Url.encode(dnsQueryBytes);

    // 构造请求 URL
    final url = Uri.parse('$queryUrl?dns=$query');

    // 设置请求头
    final headers = {
      'Accept': 'application/dns-message',
      'Content-Type': 'application/dns-message'
    };

    // 发送 GET 请求
    final response = await http.get(url, headers: headers).timeout(Duration(milliseconds: timeoutMs));

    if (response.statusCode == 200) {
      // 请求成功，解析响应内容
      // 这里简单地返回原始响应数据，实际应用中需要解析 DNS 响应报文
      return '请求成功。响应内容:\n${response.bodyBytes}';
    } else {
      // 请求失败，返回错误信息
      return '请求失败。状态码: ${response.statusCode}';
    }
  } catch (e) {
    // 捕获所有异常，返回错误信息
    return '请求失败。错误信息: $e';
  }
}