import 'dart:convert';
import 'video_download.dart';

Future<String> jsonProcess(String jsonString, String ua) async {
  final jsonMap = jsonDecode(jsonString);
  final medias = jsonMap['data']['medias'];

  List<String> result = [];

  for (var media in medias) {
    final bvid = media['bvid'];
    final cid = media['ugc']?['first_cid'];

    // Only proceed if both bvid and cid are available
    if (bvid != null && cid != null) {
      // Await the result of each fetchVideoInfo call sequentially
      final videoInfo = await videoDownload(bvid, cid.toString(), ua);
      result.add(videoInfo);
    }
  }

  // Join the results with a newline and return
  return result.join('\n');
}

void main() async {
  // Example usage
  const jsonString = '{"code":0,"message":"0","ttl":1,"data":{"info":{"id":3559391700,"fid":35593917,"mid":3546816836537000,"attr":22,"title":"测试","cover":"http://i0.hdslb.com/bfs/archive/d9552b31c79cae49b617c8c4e232d33ebf043d11.jpg","upper":{"mid":3546816836537000,"name":"4evergr8","face":"https://i2.hdslb.com/bfs/face/8f259b1e5e06a62a4c9c482d1b16aed44491cce0.jpg","followed":false,"vip_type":0,"vip_statue":0},"cover_type":2,"cnt_info":{"collect":0,"play":0,"thumb_up":0,"share":0},"type":11,"intro":"","ctime":1743590388,"mtime":1743590388,"state":0,"fav_state":0,"like_state":0,"media_count":3,"is_top":false},"medias":[{"id":114265843372806,"type":2,"title":"小花生","cover":"http://i0.hdslb.com/bfs/archive/d9552b31c79cae49b617c8c4e232d33ebf043d11.jpg","intro":"-","page":1,"duration":90,"upper":{"mid":2081589285,"name":"暗杀夜蚊子","face":"https://i0.hdslb.com/bfs/face/bbf7bf2c538a1efbf3b10ede4a9c00a2db4d71d4.jpg"},"attr":0,"cnt_info":{"collect":6719,"play":440896,"danmaku":258,"vt":0,"play_switch":0,"reply":0,"view_text_1":"44.1万"},"link":"bilibili://video/114265843372806","ctime":1743558522,"pubtime":1743558521,"fav_time":1743666704,"bv_id":"BV1SNfAYVEoU","bvid":"BV1SNfAYVEoU","season":null,"ogv":null,"ugc":{"first_cid":29191834913},"media_list_link":"bilibili://music/playlist/playpage/3546820395928700?page_type=3&oid=114265843372806&otype=2"}]}}';

  final ua = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36';

  try {
    final result = await jsonProcess(jsonString, ua);
    print(result);  // Output will contain the result of each video fetch
  } catch (e) {
    print('发生错误: $e');
  }
}
