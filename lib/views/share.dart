import 'dart:io';

import 'package:flutter/material.dart';
import 'package:picorigin/l10n/app_localizations.dart';
import 'package:picorigin/service/ocr.dart';
import 'package:picorigin/service/qrcode.dart';
import 'package:picorigin/service/thumbnail_search.dart';
import 'package:picorigin/service/video_download.dart';
import 'package:picorigin/views/offline/image_ocr.dart';
import 'package:picorigin/widget.dart';
import 'package:picorigin/widgets/popup_links.dart';
import 'package:picorigin/widgets/popup_text.dart';
import 'package:share_handler_platform_interface/share_handler_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../service/image_search.dart';

// ShareReceiverPage 负责显示和处理分享内容
class ShareReceiverPage extends StatefulWidget {
  final SharedMedia media;

  const ShareReceiverPage({super.key, required this.media});

  @override
  _ShareReceiverPageState createState() => _ShareReceiverPageState();
}

class _ShareReceiverPageState extends State<ShareReceiverPage> {
  late TextEditingController _workerUrlController;
  String _workerUrl = 'https://image-6eu.pages.dev'; // 默认 Worker URL

  @override
  void initState() {
    super.initState();
    _workerUrlController = TextEditingController(text: _workerUrl);
    WidgetsBinding.instance.addPostFrameCallback((_) {});
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
      showTextPopup(context, '${AppLocalizations.of(context)!.ocr_fail} ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.share_process, style: theme.textTheme.headlineMedium),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.media.content != null) ...[
              Text(AppLocalizations.of(context)!.get_text, style: theme.textTheme.titleMedium),
              SizedBox(height: 12),
              Container(
                constraints: BoxConstraints(minHeight: 120, maxHeight: 300),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.all(12),
                child: SingleChildScrollView(
                  child: SelectableText(widget.media.content!, style: theme.textTheme.bodyMedium),
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
                    label: Text(AppLocalizations.of(context)!.artwork),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final close = await showLoadingDialogGlobal();

                      try {
                        if (widget.media.content != null) {
                          String BV = await extractBvId(widget.media.content!);
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          final ua =
                              prefs.getString('ua') ??
                              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36';
                          await fetchAndSaveVideo(context, ua, BV);
                          Navigator.of(context).pop();
                        }
                      } catch (e) {
                        showErrorSnackBarGlobal('$e');
                      } finally {
                        close();
                      }
                    },
                    icon: Icon(Icons.settings_backup_restore),
                    label: Text(AppLocalizations.of(context)!.backup),
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
                        child: Image.file(File(path), fit: BoxFit.cover),
                      ),
                      SizedBox(height: 20),
                      _buildSettingCard(
                        context,
                        icon: Icons.link,
                        title: 'Worker URL',
                        child: TextField(
                          controller: _workerUrlController,
                          onChanged: (value) => setState(() => _workerUrl = value),
                          decoration: InputDecoration(labelText: 'Worker URL', hintText: ' Worker URL'),
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () async {
                              final close = await showLoadingDialogGlobal();

                              try {
                                final imageUrl = await searchLocalImage(File(path), _workerUrlController.text);
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('${AppLocalizations.of(context)!.upload_success}$imageUrl')),
                                );
                                final result = generateReverseImageSearchUrls(imageUrl);
                                showLinkButtonsPopup(context, result);
                              } catch (e) {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${AppLocalizations.of(context)!.upload_fail} ${e.toString()}'),
                                  ),
                                );
                              } finally {
                                close();
                              }
                            },
                            icon: Icon(Icons.search),
                            label: Text(AppLocalizations.of(context)!.reverse),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => handleImageOCR(context, path, Language.chinese),
                            icon: Icon(Icons.translate),
                            label: Text(AppLocalizations.of(context)!.ocr_zh),
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
                            label: Text(AppLocalizations.of(context)!.ocr_en),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => handleImageOCR(context, path, Language.japanese),
                            icon: Icon(Icons.language),
                            label: Text(AppLocalizations.of(context)!.ocr_ja),
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
                            label: Text(AppLocalizations.of(context)!.qr_code),
                          ),
                        ],
                      ),
                    ],
                  );
                } else {
                  return Text("${attachment?.type}  ${attachment?.path}");
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
