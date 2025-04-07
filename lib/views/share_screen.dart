import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_handler_platform_interface/share_handler_platform_interface.dart';
import '/service/intranet/language_identify.dart';
import '/service/internet/image_search.dart';
import '/service/intranet/ocr.dart';
import '/widgets/popup_infinity.dart';
import 'intranet/ocr_screen.dart'; // 确保导入了 performOCR 函数和 Language 枚举
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
      if (widget.media.content != null) {
        handleText(context);
      }
    });
  }

  @override
  void dispose() {
    _workerUrlController.dispose();
    super.dispose();
  }

  Future<void> handleText(BuildContext context) async {
    final url = widget.media.content;
    if (url != null) {
      final result = await extractAndSearchUrls(url);
      showLinkButtonsPopup(context, result);
    }
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
            Text(
              '接收的分享内容',
              style: theme.textTheme.headlineSmall,
            ),
            SizedBox(height: 20),

            if (widget.media.content != null)
              Column(
                children: [
                  Text(
                    "分享文本: ${widget.media.content}",
                    style: theme.textTheme.bodyMedium,
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async{
                          if (widget.media.content != null) {

                            final links = await extractAndSearchUrls(widget.media.content !);
                            showLinkButtonsPopup(context, links);
                          }
                        },
                        icon: Icon(Icons.link),
                        label: Text('处理链接'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () async{
                          if (widget.media.content != null) {
                            String detectedLang = await identifyLanguage(widget.media.content!);
                            // 再调用翻译函数
                            String result = await translateText(detectedLang,'zh',widget.media.content!);
                            // 显示翻译结果
                            showTextPopup(context,result);
                          }
                        },
                        icon: Icon(Icons.translate),
                        label: Text('翻译语句'),
                      ),
                    ],
                  ),
                ],
              )
            else if (widget.media.attachments != null)
              Column(
                children: [
                  ...(widget.media.attachments ?? []).map((attachment) {
                    final path = attachment?.path;
                    if (path != null && attachment?.type == SharedAttachmentType.image) {
                      return Stack(
                        children: [
                          Image.file(File(path)),  // 显示图片
                          Positioned(
                            top: 0, // 与图片上端对齐
                            left: 0,
                            right: 0,
                            child: Column(
                              children: [
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
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('图片上传成功，URL: $imageUrl')),
                                          );
                                          final result = generateReverseImageSearchUrls(imageUrl);
                                          Navigator.of(context).pop();
                                          showLinkButtonsPopup(context, result);
                                        } catch (e) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('图片上传失败: ${e.toString()}')),
                                          );
                                          Navigator.of(context).pop();
                                        }
                                      },
                                      icon: Icon(Icons.search),
                                      label: Text('搜索图片来源'),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        handleImageOCR(context, path, Language.chinese);
                                      },
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
                                      onPressed: () {
                                        handleImageOCR(context, path, Language.english);
                                      },
                                      icon: Icon(Icons.abc),
                                      label: Text('拉丁字符提取'),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        handleImageOCR(context, path, Language.japanese);
                                      },
                                      icon: Icon(Icons.language),
                                      label: Text('日文字符提取'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Text("${attachment?.type} Attachment: ${attachment?.path}");
                    }
                  }),
                ],
              ),
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