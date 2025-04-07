import 'package:flutter/material.dart';
import 'package:share_handler_platform_interface/share_handler_platform_interface.dart';
import '/views/share_screen.dart';


// ShareHandlerService 负责初始化和监听分享内容
class ShareHandlerService {
  SharedMedia? media;

  Future<void> initPlatformState(BuildContext context) async {
    final handler = ShareHandlerPlatform.instance;
    media = await handler.getInitialSharedMedia();

    if (media != null && (media!.content != null || media!.attachments != null)) {
      // 如果有分享内容，跳转到分享页面
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ShareReceiverPage(media: media!),
        ),
      );
    }

    handler.sharedMediaStream.listen((SharedMedia newMedia) {
      media = newMedia;
      if (media != null && (media!.content != null || media!.attachments != null)) {
        // 如果有新的分享内容，跳转到分享页面
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ShareReceiverPage(media: media!),
          ),
        );
      }
    });
  }
}