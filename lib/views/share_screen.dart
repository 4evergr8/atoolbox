import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_handler_platform_interface/share_handler_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/service/internet/video_download.dart';
import '/service/intranet/qrcode.dart';
import '/service/internet/image_search.dart';
import '/service/intranet/ocr.dart';
import '/widgets/popup_infinity.dart';
import 'intranet/ocr_screen.dart';
import '/service/internet/thumbnail_search.dart';
import '/widgets/popup_links.dart';
import '/widgets/popup_text.dart';

// ShareReceiverPage 负责显示和处理分享内容
class ShareReceiverPage extends StatefulWidget {
  final SharedMedia media;

  const ShareReceiverPage({super.key, required this.media});

  @override
  _ShareReceiverPageState createState() => _ShareReceiverPageState();
}

class _ShareReceiverPageState extends State<ShareReceiverPage> {
  late TextEditingController _workerUrlController;
  String _workerUrl = 'https://image.4evergr8.workers.dev'; // 默认 Worker URL

  @override
  void initState() {
    super.initState();
    _workerUrlController = TextEditingController(text: _workerUrl);
    WidgetsBinding.instance.addPostFrameCallback((_) {

    });
  }

  @override
  void dispose() {
    _workerUrlController.dispose();
    super.dispose();
  }



  // 处理图片的OCR功能
  Future<void> handleImageOCR(BuildContext context, String imagePath, Language language) async {
    try {
      final recognizedText = await performOCR(File(imagePath), language);
      showTextPopup(context, recognizedText);
    } catch (e) {
      showTextPopup(context, 'OCR识别失败: ${e.toString()}');
    }
  }









  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('分享内容处理', style: theme.textTheme.headlineMedium),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.media.content != null) ...[
              Text(
                '接收到的文本',
                style: theme.textTheme.titleMedium,
              ),
              SizedBox(height: 12),
              Container(
                constraints: BoxConstraints(
                  minHeight: 120,
                  maxHeight: 300,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.all(12),
                child: SingleChildScrollView(
                  child: SelectableText(
                    widget.media.content!,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      if (widget.media.content != null) {
                        final links = await extractAndSearchUrls(widget.media.content!);
                        showLinkButtonsPopup(context, links);
                      }
                    },
                    icon: Icon(Icons.link),
                    label: Text('封面搜图'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      if (widget.media.content != null) {

                        DialogUtils.showLoadingDialog(
                          context: context,
                          title: '下载中...',
                          content: '请稍候，正在备份视频...',
                        );

                        String BV = await extractBvId(widget.media.content!);
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        final ua = prefs.getString('ua') ?? 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36';
                        await fetchAndSaveVideo(context, ua,BV );
                        Navigator.of(context).pop();
                      }
                    },
                    icon: Icon(Icons.settings_backup_restore),
                    label: Text('视频备份'),
                  ),
                ],
              ),
            ] else if (widget.media.attachments != null) ...[
              ...(widget.media.attachments ?? []).map((attachment) {
                final path = attachment?.path;
                if (path != null && attachment?.type == SharedAttachmentType.image) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.file(
                          File(path),
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(height: 20),
                      _buildSettingCard(
                        context,
                        icon: Icons.link,
                        title: 'Worker URL',
                        child: TextField(
                          controller: _workerUrlController,
                          onChanged: (value) => setState(() => _workerUrl = value),
                          decoration: InputDecoration(
                            labelText: 'Worker URL',
                            hintText: '请输入 Worker URL',
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () async {
                              DialogUtils.showLoadingDialog(
                                context: context,
                                title: '上传中...',
                                content: '请稍候，正在上传图片...',
                              );
                              try {
                                final imageUrl = await searchLocalImage(File(path), _workerUrlController.text);
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('图片上传成功，URL: $imageUrl')),
                                );
                                final result = generateReverseImageSearchUrls(imageUrl);
                                showLinkButtonsPopup(context, result);
                              } catch (e) {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('图片上传失败: ${e.toString()}')),
                                );
                              }
                            },
                            icon: Icon(Icons.search),
                            label: Text('搜索图片来源'),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => handleImageOCR(context, path, Language.chinese),
                            icon: Icon(Icons.translate),
                            label: Text('中文字符提取'),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => handleImageOCR(context, path, Language.english),
                            icon: Icon(Icons.abc),
                            label: Text('拉丁字符提取'),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => handleImageOCR(context, path, Language.japanese),
                            icon: Icon(Icons.language),
                            label: Text('日文字符提取'),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () async {
                              final result = await scanQRCodeFromImage(context, path);
                              showTextPopup(context, result);
                            },
                            icon: Icon(Icons.qr_code),
                            label: Text('图片扫码识别'),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => handleImageOCR(context, path, Language.japanese),
                            icon: Icon(Icons.language),
                            label: Text('日文字符提取'),
                          ),
                        ],
                      ),
                    ],
                  );
                } else {
                  return Text("${attachment?.type} 附件: ${attachment?.path}");
                }
              }),
            ],
          ],
        ),
      ),
    );
  }


  Widget _buildSettingCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required Widget child,
      }) {
    return Card(
      elevation: 4, // 添加阴影
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // 圆角
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 24),
                SizedBox(width: 16),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}