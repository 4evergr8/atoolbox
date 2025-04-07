import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<String> videoDownload(String bvid, String cid, String ua) async {
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
    throw Exception('请求失败，状态码: ${res.statusCode}');
  }

  final data = jsonDecode(res.body);

  if (data['code'] == 0 && data['data'] != null && data['data']['durl'] != null) {
    final durlList = data['data']['durl'] as List;
    final videoUrl = durlList.first['url']; // 获取第一个播放链接
    print('视频链接: $videoUrl');

    final downloadHeaders = {
      "User-Agent": ua,
      "Referer": "https://www.bilibili.com/video/$bvid"
    };

    final videoRes = await http.get(Uri.parse(videoUrl), headers: downloadHeaders);

    if (videoRes.statusCode == 200) {
      // 获取设备的下载目录路径
      final downloadsDirectory = await getExternalStorageDirectory();
      if (downloadsDirectory == null) {
        throw Exception('无法获取下载目录');
      }

      // 设置文件保存路径为下载目录
      final file = File('${downloadsDirectory.path}/$bvid.mp4');

      // 将视频文件保存到下载目录
      await file.writeAsBytes(videoRes.bodyBytes);
      return('文件下载完成: ${file.absolute.path}');
    } else {
      return('下载失败, HTTP 状态码: ${videoRes.statusCode}');
    }
  } else {
    return('未找到可用的播放 URL，BVID: $bvid,CID: $cid');
  }
}

void main() async {
  try {
    String bvid = 'BV1GJ411x7h7';
    String cid = '137649199';
    String ua = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36';

    await videoDownload(bvid, cid, ua);
  } catch (e) {
    print('发生错误: $e');
  }
}
