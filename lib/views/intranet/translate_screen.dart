import 'package:flutter/material.dart';
import '../../service/intranet/language_identify.dart';
import '/widgets/popup_text.dart';


class TranslateScreen extends StatefulWidget {
  const TranslateScreen({super.key});

  @override
  _TranslateScreenState createState() => _TranslateScreenState();
}

class _TranslateScreenState extends State<TranslateScreen> {
  final TextEditingController _textController = TextEditingController();
  String _sourceLanguage = '检测'; // 源语言，默认值为检测
  String _targetLanguage = 'zh'; // 目标语言，默认值为中文




  void _startTranslate() async {
    String text = _textController.text;

    // 检查源语言值
    if (_sourceLanguage == '检测') {
      // 如果是检测，则调用检测函数
      String detectedLang = await identifyLanguage(text);
      // 再调用翻译函数
      String result = await translateText(detectedLang,  _targetLanguage,text);
      // 显示翻译结果
      showTextPopup(context,result);
    } else {
      // 如果已选定语言，直接调用翻译函数
      String result = await translateText(_sourceLanguage,  _targetLanguage,text);
      // 显示翻译结果
      showTextPopup(context,result);
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('翻译', style: theme.textTheme.headlineMedium),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '翻译',
              style: theme.textTheme.headlineSmall,
            ),
            SizedBox(height: 20),
            _buildSettingCard(
              context,
              icon: Icons.text_fields,
              title: '待翻译语句',
              child: TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  labelText: '请输入待翻译语句',
                ),
                maxLines: 5, // 设置多行输入
              ),
            ),
            SizedBox(height: 16),
            _buildSettingCard(
              context,
              icon: Icons.language,
              title: '源语言',
              child: DropdownButton<String>(
                value: _sourceLanguage,
                items: const [
                  DropdownMenuItem(value: '检测', child: Text('检测')),
                  DropdownMenuItem(value: 'zh', child: Text('汉语')),
                  DropdownMenuItem(value: 'en', child: Text('英语')),
                  DropdownMenuItem(value: 'ja', child: Text('日语')),
                  DropdownMenuItem(value: 'kr', child: Text('韩语')),
                  DropdownMenuItem(value: 'ru', child: Text('俄语')),
                  // 可以根据需要添加更多语言选项
                ],
                onChanged: (value) {
                  setState(() {
                    _sourceLanguage = value!;
                  });
                },
              ),
            ),
            SizedBox(height: 16),
            _buildSettingCard(
              context,
              icon: Icons.language,
              title: '目标语言',
              child: DropdownButton<String>(
                value: _targetLanguage,
                items: const [
                  DropdownMenuItem(value: 'zh', child: Text('汉语')),
                  DropdownMenuItem(value: 'en', child: Text('英语')),
                  DropdownMenuItem(value: 'ja', child: Text('日语')),
                  DropdownMenuItem(value: 'kr', child: Text('韩语')),
                  DropdownMenuItem(value: 'ru', child: Text('俄语')),
                  // 可以根据需要添加更多语言选项
                ],
                onChanged: (value) {
                  setState(() {
                    _targetLanguage = value!;
                  });
                },
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _startTranslate,
              icon: const Icon(Icons.translate),
              label: const Text('翻译'),
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
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
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