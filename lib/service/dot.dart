import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';

// DNS 记录类型常量
class DnsRecordType {
  static const int A = 1;      // IPv4 地址
  static const int NS = 2;     // 域名服务器
  static const int CNAME = 5;  // 规范名称
  static const int SOA = 6;    // 起始授权机构
  static const int PTR = 12;   // 指针
  static const int MX = 15;    // 邮件交换
  static const int TXT = 16;   // 文本
  static const int AAAA = 28;  // IPv6 地址
  static const int ANY = 255;  // 所有记录类型
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

// 获取记录类型名称
String getRecordTypeName(int type) {
  switch (type) {
    case DnsRecordType.A: return 'A';
    case DnsRecordType.NS: return 'NS';
    case DnsRecordType.CNAME: return 'CNAME';
    case DnsRecordType.SOA: return 'SOA';
    case DnsRecordType.PTR: return 'PTR';
    case DnsRecordType.MX: return 'MX';
    case DnsRecordType.TXT: return 'TXT';
    case DnsRecordType.AAAA: return 'AAAA';
    case DnsRecordType.ANY: return 'ANY';
    default: return 'TYPE$type';
  }
}

// 解析 SOA 记录
String parseSOARecord(Uint8List data, int offset) {
  String mname = readDomainName(data, offset);
  int currentOffset = offset;
  while (currentOffset < data.length && data[currentOffset] != 0) {
    currentOffset += data[currentOffset] + 1;
  }
  currentOffset++;
  String rname = readDomainName(data, currentOffset);
  
  // 跳过序列号、刷新、重试、过期和最小 TTL
  currentOffset += 20;
  
  return '主域名服务器: $mname\n管理员邮箱: $rname';
}

// 解析 MX 记录
String parseMXRecord(Uint8List data, int offset) {
  int preference = (data[offset] << 8) | data[offset + 1];
  String exchange = readDomainName(data, offset + 2);
  return '优先级: $preference\n邮件服务器: $exchange';
}

// 解析 TXT 记录
String parseTXTRecord(Uint8List data, int offset, int length) {
  List<String> strings = [];
  int currentOffset = offset;
  
  while (currentOffset < offset + length) {
    int stringLength = data[currentOffset];
    currentOffset++;
    if (currentOffset + stringLength > offset + length) break;
    
    String txt = String.fromCharCodes(
      data.sublist(currentOffset, currentOffset + stringLength)
    );
    strings.add(txt);
    currentOffset += stringLength;
  }
  
  return strings.join(' ');
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

        // 根据记录类型解析数据
        result.writeln('\n${getRecordTypeName(type)} 记录:');
        result.writeln('域名: $name');
        result.writeln('TTL: $ttl 秒');

        switch (type) {
          case DnsRecordType.A: // A 记录
            if (dataLength == 4) {
              String ip = '${responseBytes[offset]}.${responseBytes[offset + 1]}.'
                         '${responseBytes[offset + 2]}.${responseBytes[offset + 3]}';
              result.writeln('IPv4 地址: $ip');
            }
            break;
          case DnsRecordType.NS: // NS 记录
            String ns = readDomainName(responseBytes, offset);
            result.writeln('域名服务器: $ns');
            break;
          case DnsRecordType.CNAME: // CNAME 记录
            String cname = readDomainName(responseBytes, offset);
            result.writeln('规范名称: $cname');
            break;
          case DnsRecordType.SOA: // SOA 记录
            result.writeln(parseSOARecord(responseBytes, offset));
            break;
          case DnsRecordType.PTR: // PTR 记录
            String ptr = readDomainName(responseBytes, offset);
            result.writeln('指针: $ptr');
            break;
          case DnsRecordType.MX: // MX 记录
            result.writeln(parseMXRecord(responseBytes, offset));
            break;
          case DnsRecordType.TXT: // TXT 记录
            result.writeln('文本: ${parseTXTRecord(responseBytes, offset, dataLength)}');
            break;
          case DnsRecordType.AAAA: // AAAA 记录
            if (dataLength == 16) {
              String ipv6 = responseBytes.sublist(offset, offset + 16)
                  .map((b) => b.toRadixString(16).padLeft(2, '0'))
                  .join(':');
              result.writeln('IPv6 地址: $ipv6');
            }
            break;
          default:
            result.writeln('未知记录类型: $type');
            result.writeln('原始数据: ${responseBytes.sublist(offset, offset + dataLength)}');
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

// 获取记录类型代码
int getRecordTypeCode(String type) {
  switch (type.toUpperCase()) {
    case 'A': return DnsRecordType.A;
    case 'AAAA': return DnsRecordType.AAAA;
    case 'CNAME': return DnsRecordType.CNAME;
    case 'NS': return DnsRecordType.NS;
    case 'MX': return DnsRecordType.MX;
    case 'SOA': return DnsRecordType.SOA;
    case 'TXT': return DnsRecordType.TXT;
    case 'ANY': return DnsRecordType.ANY;
    default: return DnsRecordType.A; // 默认返回 A 记录

  }
}

Future<String> dotQuery(String server, String domain, String queryType, int timeoutMs) async {
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
      // 构造 DNS 查询报文
      final query = buildDnsQuery(domain, getRecordTypeCode(queryType));

      // 发送查询报文
      socket.add(query);

      // 等待响应
      final response = await socket.first;
      
      // 关闭连接
      await socket.close();

      // 返回响应数据
      return response.toString();
    } finally {
      // 确保连接被关闭
      await socket.close();
    }
  } catch (e) {
    return '请求失败。错误信息: $e';
  }
}