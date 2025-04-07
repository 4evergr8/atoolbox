import 'dart:io';
import 'dart:async';

// 测试服务器或域名的连通性
Future<String> port(
    String target, // 域名或 IP 地址
    int startPort, // 起始端口
    int endPort, // 终止端口
    int timeoutMs, // 超时时间（毫秒）
    ) async {
  if (startPort > endPort) {
    throw '起始端口必须小于或等于终止端口';
  }

  List<String> results = []; // 用于存储每个端口的测试结果

  for (int port = startPort; port <= endPort; port++) {
    try {
      // 尝试连接到指定端口
      await Socket.connect(target, port, timeout: Duration(milliseconds: timeoutMs));
      results.add('端口 $port: 连接成功');
    } on SocketException {
      // 如果连接失败，记录失败信息
      results.add('端口 $port: 连接失败');
    } catch (e) {
      // 捕获其他异常
      results.add('端口 $port: 测试时发生错误: $e');
    }
  }

  // 返回所有测试结果，格式化为一个字符串
  return results.join('\n');
}