import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

Future<void> createHistoryEntry({
  required String type,
  required String content,
  String? file,
}) async {
  // 设置日期和毫秒时间戳
  final now = DateTime.now();
  final date = now.toIso8601String().split('T')[0]; // yyyy-mm-dd
  final timestamp = now.millisecondsSinceEpoch.toString();

  // 获取应用的默认数据路径
  final appDir = await getApplicationDocumentsDirectory();
  final historyDir = Directory(p.join(appDir.path, 'history'));
  if (!await historyDir.exists()) {
    await historyDir.create(recursive: true);
  }

  // 创建日期-毫秒时间戳文件夹
  final entryDir = Directory(p.join(historyDir.path, '$date-$timestamp'));
  await entryDir.create(recursive: true);

  // 构建 YAML 文件内容
  final yamlContent = '''
type: $type
content: |
  $content
''';

  // 创建 YAML 文件
  final yamlFile = File(p.join(entryDir.path, '$date-$timestamp.yaml'));
  await yamlFile.writeAsString(yamlContent);

  // 如果有文件路径或网络链接，下载并存储文件
  if (file != null) {
    if (file.startsWith('http')) {
      // 如果是网络链接，下载文件
      final response = await http.get(Uri.parse(file));
      if (response.statusCode == 200) {
        // 获取文件扩展名
        final fileExtension = p.extension(file);
        final outputFile = File(p.join(entryDir.path, '$timestamp$fileExtension'));
        await outputFile.writeAsBytes(response.bodyBytes);
      } else {
        throw Exception('Failed to download file from $file');
      }
    } else {
      // 如果是本地文件路径，复制文件
      final sourceFile = File(file);
      if (await sourceFile.exists()) {
        // 获取文件扩展名
        final fileExtension = p.extension(file);
        final outputFile = File(p.join(entryDir.path, '$timestamp$fileExtension'));
        await sourceFile.copy(outputFile.path);
      } else {
        throw Exception('File not found at $file');
      }
    }
  }

  print('History entry created successfully at ${entryDir.path}');
}