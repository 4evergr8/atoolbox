import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';

Future<String> dotQuery(String queryUrl, String domain, int timeoutMs) async {
try {
// 构造 DNS 查询报文
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

// 添加请求长度
final length = dnsQueryBytes.length;
final requestBytes = Uint8List(length + 2);
requestBytes[0] = (length >> 8) & 0xFF;
requestBytes[1] = length & 0xFF;
requestBytes.setRange(2, length + 2, dnsQueryBytes);

// 发送请求
final socket = await SecureSocket.connect(queryUrl, 853, timeout: Duration(milliseconds: timeoutMs));
socket.write(requestBytes);

// 接收响应
final responseBytes = await socket.first.timeout(Duration(milliseconds: timeoutMs));

// 解析响应内容
final responseText = utf8.decode(responseBytes);
return '请求成功。响应内容:\n$responseText';
} catch (e) {
// 捕获所有异常，返回错误信息
return '请求失败。错误信息: $e';
}
}