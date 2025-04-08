import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '/service/intranet/qrcode.dart';
import '/widgets/popup_infinity.dart';
import '/widgets/popup_text.dart'; // 导入二维码识别函数

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
        title: Text('二维码扫描', style: theme.textTheme.headlineMedium),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        // 使用 SingleChildScrollView 包裹整个内容
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('二维码扫描', style: theme.textTheme.headlineSmall),
            SizedBox(height: 20),
            _buildSettingCard(
              context,
              icon: Icons.image,
              title: '选择图片',
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
                          final pickedFile = await picker.pickImage(
                            source: ImageSource.gallery,
                          );
                          if (pickedFile != null) {
                            setState(() {
                              _imageFile = File(pickedFile.path);
                              _isImageSelected = true; // 标记图片已选择
                            });
                          }
                        },
                        child: Text('选择图片'),
                      ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                DialogUtils.showLoadingDialog(
                  context: context,
                  title: '扫描中...',
                  content: '请稍候，正在识别...',
                );
                if (_imageFile != null) {
                  final result = await scanQRCodeFromImage(context,_imageFile!.path,);
                  // 将二维码内容显示在弹窗中
                  Navigator.of(context).pop();
                  showTextPopup(context, result);
                } else {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('请选择一张图片')));
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min, // 使内容紧凑
                children: [
                  Icon(Icons.qr_code), // 添加二维码图标
                  SizedBox(width: 8), // 图标和文本之间的间距
                  Text('扫描二维码'), // 按钮文本
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
