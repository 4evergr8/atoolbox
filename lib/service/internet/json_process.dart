import 'dart:convert';
import 'package:flutter/material.dart';
import 'video_download.dart';

Future<String> jsonProcess(BuildContext context,String jsonString, String ua) async {
  final jsonMap = jsonDecode(jsonString);
  final medias = jsonMap['data']['medias'];

  List<String> result = [];

  for (var media in medias) {
    final bvid = media['bvid'];
    final cid = media['ugc']?['first_cid'];

    // Only proceed if both bvid and cid are available
    if (bvid != null && cid != null) {
      // Await the result of each fetchVideoInfo call sequentially
      final videoInfo = await videoDownload(context,bvid, cid.toString(), ua);
      result.add(videoInfo);
    }
  }

  // Join the results with a newline and return
  return result.join('\n');
}

