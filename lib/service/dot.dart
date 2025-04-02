import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';

// DNS 记录类型常量
class DnsRecordType {
  static const int A = 1;      // IPv4 地址
}

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
    result.writeln('权威记录数: $authorityRRs');
    result.writeln('额外记录数: $additionalRRs');

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

        // 只处理 A 记录
        if (type == DnsRecordType.A) {
          result.writeln('\nA 记录:');
          result.writeln('域名: $name');
          result.writeln('TTL: $ttl 秒');
          if (dataLength == 4) {
            String ip = '${responseBytes[offset]}.${responseBytes[offset + 1]}.'
                       '${responseBytes[offset + 2]}.${responseBytes[offset + 3]}';
            result.writeln('IPv4 地址: $ip');
          }
        }

        offset += dataLength;
      }
    }

    return result.toString();
  } catch (e) {
    return '解析响应时出错: $e';
  }
}

// 构造 DNS 查询报文
Uint8List buildDnsQuery(String domain, int queryType) {
  // 构造报文头
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
  final questionClass = 1; // IN
  domainBytes.addAll([queryType >> 8, queryType & 0xFF]);
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
  return Uint8List.fromList(header + domainBytes);
}

Future<String> dotQuery(String server, String domain, int timeoutMs) async {
  try {
    // 解析服务器地址和端口
    final parts = server.split(':');
    final host = parts[0];
    final port = parts.length > 1 ? int.parse(parts[1]) : 853; // 默认端口 853

    // 建立 TLS 连接
    final socket = await SecureSocket.connect(
      host,
      port,
      timeout: Duration(milliseconds: timeoutMs),
    );

    try {
      // 构造 DNS 查询报文，固定查询 A 记录
      final query = buildDnsQuery(domain, DnsRecordType.A);

      // 添加长度字段（2字节）
      final length = query.length;
      final requestBytes = Uint8List(length + 2);
      requestBytes[0] = (length >> 8) & 0xFF;
      requestBytes[1] = length & 0xFF;
      requestBytes.setRange(2, length + 2, query);

      // 发送查询报文
      socket.add(requestBytes);

      // 等待响应
      final response = await socket.first;
      
      // 关闭连接
      await socket.close();

      // 检查响应数据
      if (response.length < 2) {
        return '响应数据太短';
      }

      // 读取响应长度
      final responseLength = (response[0] << 8) | response[1];
      if (response.length < responseLength + 2) {
        return '响应数据不完整';
      }

      // 提取 DNS 响应数据
      final dnsResponse = response.sublist(2, responseLength + 2);

      // 解析并返回完整的响应数据
      return parseDnsResponse(dnsResponse);
    } finally {
      // 确保连接被关闭
      await socket.close();
    }
  } catch (e) {
    return '请求失败。错误信息: $e';
  }
}