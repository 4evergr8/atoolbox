import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String> fetchCid(String bvid, String ua) async {
  final headers = {
    'user-agent': ua,
  };

  final params = {
    'bvid': bvid,
  };

  final url = Uri.parse('https://api.bilibili.com/x/web-interface/view')
      .replace(queryParameters: params);

  final res = await http.get(url, headers: headers);
  if (res.statusCode != 200) {
    throw Exception('请求失败，状态码: ${res.statusCode}');
  }

  final data = jsonDecode(res.body);

  // 提取pages下面的第一个cid
  if (data['code'] == 0 && data['data']['pages'] != null && data['data']['pages'].isNotEmpty) {
    final cid = data['data']['pages'][0]['cid'];
    return cid.toString();
  } else {
    throw Exception('未找到cid');
  }
}

void main() async {

    String bvid = 'BV1FgfKYqEKv';
    String ua = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36';
    String cid = await fetchCid(bvid, ua);
    print('提取的cid: $cid');

}
