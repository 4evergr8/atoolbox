import 'dart:io'; // 用于处理文件

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:picorigin/l10n/app_localizations.dart';
import 'package:picorigin/service/ocr.dart';
import 'package:picorigin/widget.dart'; // 用于选择本地图片

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
        title: Text(AppLocalizations.of(context)!.ocr_offline, style: theme.textTheme.headlineMedium),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 图片选择块
            _buildSettingCard(
              context,
              icon: Icons.image,
              title: AppLocalizations.of(context)!.choose_pic,
              child:
                  _isImageSelected
                      ? Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Image.file(_imageFile!, width: double.infinity, height: 200, fit: BoxFit.cover),
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
                          final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                          if (pickedFile != null) {
                            setState(() {
                              _imageFile = File(pickedFile.path);
                              _isImageSelected = true; // 图片已选择
                            });
                          }
                        },
                        child: Text(AppLocalizations.of(context)!.choose_pic),
                      ),
            ),

            SizedBox(height: 20),

            // 语言选择块
            _buildSettingCard(
              context,
              icon: Icons.language,
              title: AppLocalizations.of(context)!.choose_char,
              child: Column(
                children: [
                  RadioListTile<Language>(
                    title: Text(AppLocalizations.of(context)!.char_chinese),
                    value: Language.chinese,
                    groupValue: _selectedLanguage,
                    onChanged: (Language? value) {
                      setState(() {
                        _selectedLanguage = value!;
                      });
                    },
                  ),
                  RadioListTile<Language>(
                    title: Text(AppLocalizations.of(context)!.char_lartin),
                    value: Language.english,
                    groupValue: _selectedLanguage,
                    onChanged: (Language? value) {
                      setState(() {
                        _selectedLanguage = value!;
                      });
                    },
                  ),
                  RadioListTile<Language>(
                    title: Text(AppLocalizations.of(context)!.char_japanese),
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
                children: [Icon(Icons.search), SizedBox(width: 8), Text('OCR')],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startOCR() async {
    if (_imageFile == null) {
      return;
    }

    try {
      final recognizedText = await performOCR(_imageFile!, _selectedLanguage);
      showTextPopup(context, recognizedText);
    } catch (e) {
      showSnackBarGlobal("error", "$e");
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
