import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:picorigin/widget.dart';

Future<void> fetchAndSaveVideo(
    String ua,
    String id,
    ) async {
  final headers = {
    'User-Agent': ua,
  };

  final downloadsDirectory = Directory('/storage/emulated/0/Download');
  if (!downloadsDirectory.existsSync()) {
    throw Exception("无法访问下载目录");
  }

  final saveDir = Directory('${downloadsDirectory.path}/.备份');
  if (!saveDir.existsSync()) {
    saveDir.createSync(recursive: true);
  }

  // 获取视频信息
  final infoUrl = Uri.parse('https://api.bilibili.com/x/web-interface/view?bvid=$id');
  final infoRes = await http.get(infoUrl, headers: headers);
  if (infoRes.statusCode != 200) {
    throw Exception('获取视频信息失败: ${infoRes.statusCode}');
  }

  final infoJson = jsonDecode(infoRes.body);
  final data = infoJson['data'];
  final coverUrl = data['pic'];

// 保存视频信息（格式化为多行）
  final infoFile = File('${saveDir.path}/$id.json');
  final encoder = JsonEncoder.withIndent('  ');
  infoFile.writeAsStringSync(encoder.convert(infoJson));


  // 下载封面图
  final coverRes = await http.get(Uri.parse(coverUrl));
  final coverFile = File('${saveDir.path}/$id.jpg');
  await coverFile.writeAsBytes(coverRes.bodyBytes);

  // 遍历所有分P，逐个下载视频（单片段，没合并）
  final pages = data['pages'] as List;
  for (var page in pages) {
    final cid = page['cid'].toString();

    final params = {
      'bvid': id,
      'cid': cid,
      'fnval': '1',
      'fnver': '0',
      'qn': '64',
    };

    final playUrl = Uri.parse('https://api.bilibili.com/x/player/playurl').replace(queryParameters: params);

    final playRes = await http.get(playUrl, headers: headers);


    final playJson = jsonDecode(playRes.body);


    final videoUrl = playJson['data']['durl'][0]['url'];

    final downloadHeaders = {
      'User-Agent': ua,
      'Referer': 'https://www.bilibili.com/video/$id',
    };

    final videoRes = await http.get(Uri.parse(videoUrl), headers: downloadHeaders);


    final videoFile = File('${saveDir.path}/${id}_$cid.mp4');
    await videoFile.writeAsBytes(videoRes.bodyBytes);
  }
  showSnackBarGlobal('已保存视频 $id');
}

