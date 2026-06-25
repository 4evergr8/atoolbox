import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:picorigin/l10n/app_localizations.dart';
import 'package:picorigin/service/qrcode.dart';
import 'package:picorigin/widget.dart';

class QRCodeScan extends StatefulWidget {
  const QRCodeScan({super.key});

  @override
  _QRCodeScanScreenState createState() => _QRCodeScanScreenState();
}

class _QRCodeScanScreenState extends State<QRCodeScan> {
  File? _imageFile; // 用于存储选择的本地图片文件
  bool _isImageSelected = false; // 标记是否选择了图片

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.qr_code, style: theme.textTheme.headlineMedium),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        // 使用 SingleChildScrollView 包裹整个内容
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSettingCard(
              context,
              icon: Icons.image,
              title: AppLocalizations.of(context)!.choose_pic,
              child:
                  _isImageSelected
                      ? Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Image.file(
                            _imageFile!,
                            width: double.infinity, // 图片填满整个宽度
                            height: 200, // 设置高度
                            fit: BoxFit.cover, // 图片缩放填充
                          ),
                          IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () {
                              setState(() {
                                _isImageSelected = false; // 重置图片选择状态
                                _imageFile = null; // 清空已选择的图片
                              });
                            },
                          ),
                        ],
                      )
                      : ElevatedButton(
                        onPressed: () async {
                          final picker = ImagePicker();
                          final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                          if (pickedFile != null) {
                            setState(() {
                              _imageFile = File(pickedFile.path);
                              _isImageSelected = true; // 标记图片已选择
                            });
                          }
                        },
                        child: Text(AppLocalizations.of(context)!.choose_pic),
                      ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_imageFile != null) {
                  final result = await scanQRCodeFromImage(context, _imageFile!.path);
                  showTextPopup(context, result);
                } else {
                  showSnackBarGlobal("error", AppLocalizations.of(context)!.choose_pic);
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min, // 使内容紧凑
                children: [
                  Icon(Icons.qr_code), // 添加二维码图标
                  SizedBox(width: 8), // 图标和文本之间的间距
                  Text(AppLocalizations.of(context)!.qr_code), // 按钮文本
                ],
              ),
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
