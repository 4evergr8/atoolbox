import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:yaml/yaml.dart';

Future<String> fetchVideoInfo(String bvid, String cid, String ua) async {
  final url = Uri.parse('https://api.bilibili.com/x/player/playurl').replace(
    queryParameters: {'bvid': bvid, 'cid': cid, 'fnval': '1', 'fnver': '0'},
  );

  final headers = {'User-Agent': ua};
  final res = await http.get(url, headers: headers);

  if (res.statusCode != 200) {
    return '请求失败，状态码: ${res.statusCode}';
  }

  final data = jsonDecode(res.body);
  if (data['code'] == 0 && data['data'] != null && data['data']['durl'] != null) {
    final videoUrl = data['data']['durl'][0]['url'];
    return '视频链接: $videoUrl';
  } else {
    return '未找到视频链接或数据异常';
  }
}

Future<String> processYamlAndFetchInfo(String yamlStr, String ua) async {
  final yamlMap = loadYaml(yamlStr);
  final medias = yamlMap['data']['medias'];

  List<String> result = [];

  for (var media in medias) {
    final bvid = media['bvid'];
    final cid = media['ugc']?['first_cid'];

    // Only proceed if both bvid and cid are available
    if (bvid != null && cid != null) {
      // Await the result of each fetchVideoInfo call sequentially
      final videoInfo = await fetchVideoInfo(bvid, cid.toString(), ua);
      result.add(videoInfo);
    }
  }

  // Join the results with a newline and return
  return result.join('\n');
}

void main() async {
  // Example usage
  const yamlString = '''code: 0
message: "0"
ttl: 1
data:
  info:
    id: 3559391700
    fid: 35593917
    mid: 3546816836537000
    attr: 22
    title: 测试
    cover: http://i2.hdslb.com/bfs/archive/b5f844ab33c0a23d52efef7cdef6f1840acb23cf.jpg
    upper:
      mid: 3546816836537000
      name: 4evergr8
      face: https://i2.hdslb.com/bfs/face/8f259b1e5e06a62a4c9c482d1b16aed44491cce0.jpg
      followed: false
      vip_type: 0
      vip_statue: 0
    cover_type: 2
    cnt_info:
      collect: 0
      play: 0
      thumb_up: 0
      share: 0
    type: 11
    intro:
    ctime: 1743590388
    mtime: 1743590388
    state: 0
    fav_state: 0
    like_state: 0
    media_count: 6
    is_top: false
  medias:
    - id: 114268376667493
      type: 2
      title: 老少咸宜
      cover: http://i2.hdslb.com/bfs/archive/b5f844ab33c0a23d52efef7cdef6f1840acb23cf.jpg
      intro: -
      page: 1
      duration: 14
      upper:
        mid: 3546565698390894
        name: 枫叶园_
        face: https://i0.hdslb.com/bfs/face/07d49953ec3e9bf0d8fa7e202b10de895e0ac376.jpg
      attr: 0
      cnt_info:
        collect: 87
        play: 531659
        danmaku: 9
        vt: 0
        play_switch: 0
        reply: 0
        view_text_1: 53.2万
      link: bilibili://video/114268376667493
      ctime: 1743597158
      pubtime: 1743597193
      fav_time: 1743666714
      bv_id: BV1FgfKYqEKv
      bvid: BV1FgfKYqEKv
      season:
      ugc:
        first_cid: 29201073230
      media_list_link: "bilibili://music/playlist/playpage/3546820395928700?page_type=3&oid=114268376667493&otype=2"
    # Add more media as needed
  has_more: false
  ttl: 1743666756''';

  final ua = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36';

  try {
    final result = await processYamlAndFetchInfo(yamlString, ua);
    print(result);  // Output will contain the result of each video fetch
  } catch (e) {
    print('发生错误: $e');
  }
}
