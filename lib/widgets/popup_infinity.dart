import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';


class DialogUtils {
  static Future<void> showLoadingDialog({
    required BuildContext context,
    required String title,
    required String content,
  }) async {
    // 在弹窗显示时启用唤醒锁
    await WakelockPlus.enable();

    // 弹窗显示
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
                // 用户点击取消按钮时关闭弹窗
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.cancel),
              label: Text('取消'),
            ),
          ],
        );
      },
    ).whenComplete(() {
      // 弹窗关闭后恢复设备休眠
      WakelockPlus.disable();
    });
  }
}
