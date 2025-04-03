import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive_io.dart';
import 'package:share_plus/share_plus.dart';

Future<void> fetchAndSaveMedia( String ua, String id) async {
  final headers = {
    'user-agent': ua,
    //'cookie': cookie,
  };

  int pageNumber = 1;
  bool hasMore = true;

  final directory = await getApplicationDocumentsDirectory();
  final baseDir = Directory('${directory.path}/data/$id');

  if (baseDir.existsSync()) {
    baseDir.deleteSync(recursive: true);
  }
  baseDir.createSync(recursive: true);

  while (hasMore) {
    final params = {
      'media_id': id,
      'pn': '$pageNumber',
      'ps': '40',
    };

    final url = Uri.parse('https://api.bilibili.com/x/v3/fav/resource/list')
        .replace(queryParameters: params);

    final res = await http.get(url, headers: headers);
    final status = res.statusCode;
    if (status != 200) throw Exception('http.get error: statusCode= $status');

    final responseBody = jsonDecode(res.body);
    final medias = responseBody['data']['medias'] as List;

    if (medias.length < 40) {
      hasMore = false;
    }

    final pageDir = Directory('${baseDir.path}/page_$pageNumber');
    if (!pageDir.existsSync()) {
      pageDir.createSync(recursive: true);
    }

    // 保存返回内容到 JSON 文件
    final jsonFile = File('${pageDir.path}/response.json');
    jsonFile.writeAsStringSync(jsonEncode(responseBody));

    for (var media in medias) {
      final mediaId = media['id'].toString();
      final coverUrl = media['cover'];
      final coverRes = await http.get(Uri.parse(coverUrl));
      final coverFile = File('${pageDir.path}/$mediaId.jpg');
      await coverFile.writeAsBytes(coverRes.bodyBytes);
    }

    pageNumber++;
  }

  // 确保所有文件都已写入磁盘
  await Future.delayed(Duration(seconds: 1));

  final encoder = ZipFileEncoder();
  encoder.create('${baseDir.path}.zip');
  encoder.addDirectory(baseDir);
  encoder.close();

  Share.shareXFiles([XFile('${baseDir.path}.zip')], text: 'Here is the media data.');
}
