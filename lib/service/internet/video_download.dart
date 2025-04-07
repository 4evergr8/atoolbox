import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<String> videoDownload(BuildContext context, String bvid, String cid, String ua) async {
  final headers = {
    'User-Agent': ua,
  };

  final params = {
    'bvid': bvid,
    'cid': cid,
    'fnval': '1',
    'fnver': '0',
  };

  final url = Uri.parse('https://api.bilibili.com/x/player/playurl')
      .replace(queryParameters: params);

  final res = await http.get(url, headers: headers);
  if (res.statusCode != 200) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('请求失败，状态码: ${res.statusCode}')));
    throw Exception('请求失败，状态码: ${res.statusCode}');
  }

  final data = jsonDecode(res.body);

  if (data['code'] == 0 && data['data'] != null && data['data']['durl'] != null) {
    final durlList = data['data']['durl'] as List;
    final videoUrl = durlList.first['url']; // 获取第一个播放链接
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('视频链接: $videoUrl')));

    final downloadHeaders = {
      "User-Agent": ua,
      "Referer": "https://www.bilibili.com/video/$bvid"
    };

    final videoRes = await http.get(Uri.parse(videoUrl), headers: downloadHeaders);

    if (videoRes.statusCode == 200) {
      // 获取设备的下载目录路径
      final downloadsDirectory = await getExternalStorageDirectory();
      if (downloadsDirectory == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('无法获取下载目录')));
        throw Exception('无法获取下载目录');
      }

      // 设置文件保存路径为下载目录
      final file = File('${downloadsDirectory.path}/$bvid.mp4');

      // 将视频文件保存到下载目录
      await file.writeAsBytes(videoRes.bodyBytes);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('文件下载完成: ${file.absolute.path}')));
      return '文件下载完成: ${file.absolute.path}';
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('下载失败, HTTP 状态码: ${videoRes.statusCode}')));
      return '下载失败, HTTP 状态码: ${videoRes.statusCode}';
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('未找到可用的播放 URL，BVID: $bvid, CID: $cid')));
    return '未找到可用的播放 URL，BVID: $bvid, CID: $cid';
  }
}

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('视频下载示例'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              try {
                String bvid = 'BV1GJ411x7h7';
                String cid = '137649199';
                String ua = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36';
                await videoDownload(context, bvid, cid, ua);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('发生错误: $e')));
              }
            },
            child: Text('下载视频'),
          ),
        ),
      ),
    );
  }
}
