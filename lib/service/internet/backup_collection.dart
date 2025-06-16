import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

Future<void> fetchAndSaveVideo(
    BuildContext context,
    String ua,
    String id,
    ) async {
  final headers = {'user-agent': ua};

  final downloadsDirectory = Directory('/storage/emulated/0/Download');
  if (!downloadsDirectory.existsSync()) {
    throw Exception("无法访问下载目录");
  }

  final saveDir = Directory('${downloadsDirectory.path}/Backup/$id');
  if (saveDir.existsSync()) {
    saveDir.deleteSync(recursive: true);
  }
  saveDir.createSync(recursive: true);

  // 获取视频信息
  final infoUrl = Uri.parse(
    'https://api.bilibili.com/x/web-interface/view?bvid=$id',
  );
  final infoRes = await http.get(infoUrl, headers: headers);
  if (infoRes.statusCode != 200) {
    throw Exception('获取视频信息失败: ${infoRes.statusCode}');
  }

  final infoJson = jsonDecode(infoRes.body);
  final data = infoJson['data'];
  final cid = data['cid'].toString();
  final coverUrl = data['pic'];

  // 1. 保存视频信息
  final infoFile = File('${saveDir.path}/$id.json');
  infoFile.writeAsStringSync(jsonEncode(infoJson));

  // 2. 下载封面图
  final coverRes = await http.get(Uri.parse(coverUrl));
  final coverFile = File('${saveDir.path}/$id.jpg');
  await coverFile.writeAsBytes(coverRes.bodyBytes);

  // 3. 获取视频下载地址并下载
  final playUrl = Uri.parse(
    'https://api.bilibili.com/x/player/playurl?bvid=$id&cid=$cid&qn=80',
  );
  final playRes = await http.get(playUrl, headers: headers);
  if (playRes.statusCode != 200) {
    throw Exception('获取播放地址失败: ${playRes.statusCode}');
  }

  final playJson = jsonDecode(playRes.body);
  final videoUrl = playJson['data']['durl'][0]['url'];

  final videoRes = await http.get(Uri.parse(videoUrl), headers: headers);
  final videoFile = File('${saveDir.path}/$id.mp4');
  await videoFile.writeAsBytes(videoRes.bodyBytes);

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('已保存视频 $id')),
  );
}


Future<String> fetchRedirectedUrl({required String url}) async {
  final res = await http.get(Uri.parse(url), headers: {'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36'});
  return res.request?.url.toString() ?? url;
}

Future<String> extractBvId(String inputUrl) async {
  // 正则表达式用于提取有效的 URL
  RegExp urlRegex = RegExp(r'https?://\S+');
  RegExp bvRegex = RegExp(r'BV\w+');
  String? bv;
  String? extractedUrl;
  // 从输入字符串中提取有效的 URL
  Match? urlMatch = urlRegex.firstMatch(inputUrl);
  if (urlMatch != null) {
    extractedUrl = urlMatch.group(0);
  } else {
    throw Exception('无法提取有效的 URL');
  }

  // 检查是否包含 b23.tv
  if (extractedUrl!.contains('b23.tv')) {
    // 获取跳转后的链接
    String finalUrl = await fetchRedirectedUrl(url: extractedUrl);
    // 从最终 URL 中提取 BV 号
    bv = bvRegex.firstMatch(finalUrl)?.group(0);
  } else {
    // 如果不包含 b23.tv，直接从输入链接中提取 BV 号
    bv = bvRegex.firstMatch(extractedUrl)?.group(0);
  }

  if (bv == null) {
    throw Exception('无法提取 BV 号');
  }

  return bv;
}