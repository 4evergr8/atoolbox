import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:typed_data';

// 从 DNS 响应中读取域名
String readDomainName(Uint8List data, int offset) {
  StringBuffer domain = StringBuffer();
  int currentOffset = offset;
  
  while (currentOffset < data.length) {
    int length = data[currentOffset];
    if (length == 0) break;
    
    // 检查是否是压缩指针
    if ((length & 0xC0) == 0xC0) {
      int pointerOffset = ((length & 0x3F) << 8) | data[currentOffset + 1];
      return readDomainName(data, pointerOffset);
    }
    
    if (domain.length > 0) domain.write('.');
    domain.write(String.fromCharCodes(
      data.sublist(currentOffset + 1, currentOffset + 1 + length)
    ));
    currentOffset += length + 1;
  }
  
  return domain.toString();
}

// 解析 DNS 响应
String parseDnsResponse(Uint8List responseBytes) {
  try {
    if (responseBytes.length < 12) {
      return '响应数据太短，无法解析';
    }

    // 解析头部
    final id = (responseBytes[0] << 8) | responseBytes[1];
    final flags = (responseBytes[2] << 8) | responseBytes[3];
    final questions = (responseBytes[4] << 8) | responseBytes[5];
    final answerRRs = (responseBytes[6] << 8) | responseBytes[7];
    final authorityRRs = (responseBytes[8] << 8) | responseBytes[9];
    final additionalRRs = (responseBytes[10] << 8) | responseBytes[11];

    StringBuffer result = StringBuffer();
    result.writeln('DNS 查询结果:');
    result.writeln('查询ID: 0x${id.toRadixString(16).padLeft(4, '0')}');
    result.writeln('响应标志: 0x${flags.toRadixString(16).padLeft(4, '0')}');
    result.writeln('问题数: $questions');
    result.writeln('回答数: $answerRRs');

    // 解析问题部分
    int offset = 12;
    String queryDomain = readDomainName(responseBytes, offset);
    result.writeln('\n查询域名: $queryDomain');
    
    // 跳过问题部分的类型和类别
    while (offset < responseBytes.length && responseBytes[offset] != 0) {
      offset += responseBytes[offset] + 1;
    }
    offset += 5; // 跳过类型和类别

    // 解析回答部分
    if (answerRRs > 0) {
      result.writeln('\n解析结果:');
      for (int i = 0; i < answerRRs; i++) {
        if (offset >= responseBytes.length) break;

        // 读取域名
        String name = readDomainName(responseBytes, offset);
        offset += 2; // 跳过压缩指针

        // 读取类型和类别
        int type = (responseBytes[offset] << 8) | responseBytes[offset + 1];
        offset += 4; // 跳过类型和类别

        // 读取 TTL
        int ttl = (responseBytes[offset] << 24) |
                  (responseBytes[offset + 1] << 16) |
                  (responseBytes[offset + 2] << 8) |
                  responseBytes[offset + 3];
        offset += 4;

        // 读取数据长度
        int dataLength = (responseBytes[offset] << 8) | responseBytes[offset + 1];
        offset += 2;

        // 根据记录类型解析数据
        if (type == 1) { // A 记录
          if (dataLength == 4) {
            String ip = '${responseBytes[offset]}.${responseBytes[offset + 1]}.'
                       '${responseBytes[offset + 2]}.${responseBytes[offset + 3]}';
            result.writeln('A 记录: $ip');
          }
        } else if (type == 28) { // AAAA 记录
          if (dataLength == 16) {
            String ipv6 = responseBytes.sublist(offset, offset + 16)
                .map((b) => b.toRadixString(16).padLeft(2, '0'))
                .join(':');
            result.writeln('AAAA 记录: $ipv6');
          }
        } else if (type == 5) { // CNAME 记录
          String cname = readDomainName(responseBytes, offset);
          result.writeln('CNAME 记录: $cname');
        }

        offset += dataLength;
      }
    }

    return result.toString();
  } catch (e) {
    return '解析响应时出错: $e';
  }
}

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
      // 解析 DNS 响应
      return parseDnsResponse(response.bodyBytes);
    } else {
      // 请求失败，返回错误信息
      return '请求失败。状态码: ${response.statusCode}';
    }
  } catch (e) {
    // 捕获所有异常，返回错误信息
    return '请求失败。错误信息: $e';
  }
}