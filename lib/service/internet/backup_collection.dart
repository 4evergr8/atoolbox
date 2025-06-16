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
  final infoUrl = Uri.parse('https://api.bilibili.com/x/web-interface/view?bvid=$id');
  final infoRes = await http.get(infoUrl, headers: headers);
  if (infoRes.statusCode != 200) {
    throw Exception('获取视频信息失败: ${infoRes.statusCode}');
  }

  final infoJson = jsonDecode(infoRes.body);
  final data = infoJson['data'];
  final coverUrl = data['pic'];

  // 保存视频信息
  final infoFile = File('${saveDir.path}/$id.json');
  infoFile.writeAsStringSync(jsonEncode(infoJson));

  // 下载封面图
  final coverRes = await http.get(Uri.parse(coverUrl));
  final coverFile = File('${saveDir.path}/$id.jpg');
  await coverFile.writeAsBytes(coverRes.bodyBytes);

  // 获取所有分P（cid 列表）
  final pages = data['pages'] as List;
  for (var page in pages) {
    final cid = page['cid'].toString();

    // 获取播放地址
    final playUrl = Uri.parse(
      'https://api.bilibili.com/x/player/playurl?bvid=$id&cid=$cid&qn=80',
    );
    final playRes = await http.get(playUrl, headers: headers);
    if (playRes.statusCode != 200) {
      print('获取播放地址失败 cid=$cid');
      continue;
    }

    final playJson = jsonDecode(playRes.body);
    final videoUrl = playJson['data']['durl'][0]['url'];

    // 下载视频
    final videoRes = await http.get(
      Uri.parse(videoUrl),
      headers: {
        ...headers,
        'referer': 'https://www.bilibili.com/video/$id'
      },
    );
    final videoFile = File('${saveDir.path}/${id}_$cid.flv');
    await videoFile.writeAsBytes(videoRes.bodyBytes);
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('已保存视频 $id')),
  );
}



Future<String> fetchRedirectedUrl({required String url}) async {
  HttpClient httpClient = HttpClient();
  HttpClientRequest request = await httpClient.getUrl(Uri.parse(url));
  request.followRedirects = false; // 禁用自动重定向
  HttpClientResponse response = await request.close();

  // 如果响应是重定向，获取新的 URL
  if (response.isRedirect) {
    String? location = response.headers.value(HttpHeaders.locationHeader);
    if (location != null) {
      // 如果是相对路径，需要解析为绝对路径
      Uri originalUri = Uri.parse(url);
      Uri newUri = originalUri.resolve(location);
      httpClient.close();
      return newUri.toString(); // 返回解析后的绝对路径
    }
  }

  // 如果没有重定向，直接返回原始 URL
  httpClient.close();
  return url;
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