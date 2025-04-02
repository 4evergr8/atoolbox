import 'package:flutter/material.dart';


class DialogUtils {
  static Future<void> showLoadingDialog({
    required BuildContext context,
    required String title,
    required String content,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // 阻止用户通过点击外部区域关闭弹窗
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(), // 无限进度条
              SizedBox(height: 16),
              Text(content),
            ],
          ),
          actions: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop(); // 关闭弹窗
              },
              icon: Icon(Icons.cancel),
              label: Text('取消'),
            ),
          ],
        );
      },
    );
  }
}