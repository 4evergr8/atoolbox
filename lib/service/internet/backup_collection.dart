import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:archive/archive.dart';
import 'package:share_plus/share_plus.dart';
import 'package:json2yaml/json2yaml.dart';
import 'package:flutter/material.dart';

Future<void> fetchAndSaveMedia(
  BuildContext context,
  String ua,
  String id,
) async {
  final headers = {'user-agent': ua};

  int pageNumber = 1;
  bool hasMore = true;

  final downloadsDirectory = Directory('/storage/emulated/0/Download');
  if (!downloadsDirectory.existsSync()) {
    throw Exception("无法访问下载目录");
  }

  final baseDir = Directory('${downloadsDirectory.path}/data/$id');
  if (baseDir.existsSync()) {
    baseDir.deleteSync(recursive: true);
  }
  baseDir.createSync(recursive: true);

  while (hasMore) {
    final params = {'media_id': id, 'pn': '$pageNumber', 'ps': '40'};

    final url = Uri.parse(
      'https://api.bilibili.com/x/v3/fav/resource/list',
    ).replace(queryParameters: params);

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

    final jsonFile = File('${pageDir.path}/response.json');
    jsonFile.writeAsStringSync(jsonEncode(responseBody));

    final yamlString = json2yaml(responseBody);
    final yamlFile = File('${pageDir.path}/response.yaml');
    yamlFile.writeAsStringSync(yamlString);

    for (var media in medias) {
      final mediaId = media['id'].toString();
      final coverUrl = media['cover'];
      final coverRes = await http.get(Uri.parse(coverUrl));
      final coverFile = File('${pageDir.path}/$mediaId.jpg');
      await coverFile.writeAsBytes(coverRes.bodyBytes);
    }

    pageNumber++;
  }

  await Future.delayed(Duration(seconds: 1));

  final zipPath = '${downloadsDirectory.path}/$id.zip';
  final zipFile = File(zipPath);
  final archive = Archive();

  await for (final file in baseDir.list(recursive: true, followLinks: false)) {
    if (file is File) {
      final relativePath = file.path.substring(baseDir.parent.path.length + 1);
      final bytes = await file.readAsBytes();
      archive.addFile(ArchiveFile(relativePath, bytes.length, bytes));
    }
  }

  final zipData = ZipEncoder().encode(archive);
  await zipFile.writeAsBytes(zipData);

  if (!zipFile.existsSync() || zipFile.lengthSync() == 0) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('创建压缩包出错: $zipPath')));
  }

  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text('成功保存备份: $zipPath')));

  await Share.shareXFiles([XFile(zipPath)], text: '收藏夹ID：$id');
}
