import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // 用于选择本地图片
import 'dart:io'; // 用于处理文件
import '../../service/intranet/ocr.dart';
import '/widgets/popup_text.dart';


enum Language { chinese, english, japanese }

class OfflineOCRScreen extends StatefulWidget {
  const OfflineOCRScreen({super.key});

  @override
  _OfflineOCRScreenState createState() => _OfflineOCRScreenState();
}

class _OfflineOCRScreenState extends State<OfflineOCRScreen> {
  File? _imageFile; // 用于存储选择的本地图片文件
  bool _isImageSelected = false; // 标记是否选择了图片
  Language _selectedLanguage = Language.chinese; // 默认为中文


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('离线OCR识别', style: theme.textTheme.headlineMedium),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('离线OCR识别', style: theme.textTheme.headlineSmall),
            SizedBox(height: 20),

            // 图片选择块
            _buildSettingCard(
              context,
              icon: Icons.image,
              title: '选择图片',
              child: _isImageSelected
                  ? Stack(
                alignment: Alignment.topRight,
                children: [
                  Image.file(
                    _imageFile!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _isImageSelected = false;
                        _imageFile = null;
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
                      _isImageSelected = true; // 图片已选择
                    });
                  }
                },
                child: Text('选择图片'),
              ),
            ),

            SizedBox(height: 20),

            // 语言选择块
            _buildSettingCard(
              context,
              icon: Icons.language,
              title: '选择识别语言',
              child: Column(
                children: [
                  RadioListTile<Language>(
                    title: Text('中文字符'),
                    value: Language.chinese,
                    groupValue: _selectedLanguage,
                    onChanged: (Language? value) {
                      setState(() {
                        _selectedLanguage = value!;
                      });
                    },
                  ),
                  RadioListTile<Language>(
                    title: Text('拉丁字符'),
                    value: Language.english,
                    groupValue: _selectedLanguage,
                    onChanged: (Language? value) {
                      setState(() {
                        _selectedLanguage = value!;
                      });
                    },
                  ),
                  RadioListTile<Language>(
                    title: Text('日文字符'),
                    value: Language.japanese,
                    groupValue: _selectedLanguage,
                    onChanged: (Language? value) {
                      setState(() {
                        _selectedLanguage = value!;
                      });
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // 开始OCR识别按钮
            ElevatedButton(
              onPressed: _startOCR,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search),
                  SizedBox(width: 8),
                  Text('开始识别'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startOCR() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('请选择图片')),
      );
      return;
    }

    try {
      final recognizedText = await performOCR(_imageFile!, _selectedLanguage);
      showTextPopup(context, recognizedText);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OCR识别失败: ${e.toString()}')),
      );
    }
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