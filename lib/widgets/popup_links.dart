import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart'; // 用于操作剪贴板

// 弹窗函数
void showLinkButtonsPopup(BuildContext context, List<List<String>> links) {
  final theme = Theme.of(context);

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('链接选项', style: theme.textTheme.headlineSmall),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.6, // 弹窗宽度占屏幕宽度的 60%
            maxHeight: MediaQuery.of(context).size.height * 0.35, // 弹窗高度占屏幕高度的 50%
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // 确保内容尽可能紧凑
            children: [
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // 确保按钮紧凑
                    children: links.map((link) {
                      return ElevatedButton(
                        onPressed: () async {

                          // 打开链接
                          final uri = Uri.parse(link[1]);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('无法打开链接 ${link[1]}')),
                            );
                          }
                        },
                        onLongPress: () {
                          // 复制链接到剪贴板
                          Clipboard.setData(ClipboardData(text: link[1])).then((_) {

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('链接已复制: ${link[1]}')),
                            );
                          });
                        },
                        child: Text(link[0]),
                      );
                    }).toList(),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop(); // 关闭弹窗
                    },
                    icon: Icon(Icons.check), // 添加确认图标
                    label: Text('了解'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}