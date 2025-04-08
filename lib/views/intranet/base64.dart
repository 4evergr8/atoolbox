import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 用于操作剪贴板
import '/service/intranet/base64.dart'; // 用于 Base64 编解码

class EncodeDecode extends StatefulWidget {
  const EncodeDecode({super.key});

  @override
  _EncodeDecodeScreenState createState() => _EncodeDecodeScreenState();
}

class _EncodeDecodeScreenState extends State<EncodeDecode> {
  final TextEditingController _decodeController = TextEditingController();
  final TextEditingController _encodeController = TextEditingController();

  // 解码并复制到剪贴板
  void _decodeAndCopy() async {

    try {


      String decodedString = await decodeBase64(_decodeController.text);
      await Clipboard.setData(ClipboardData(text: decodedString));



      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('解码成功，已复制到剪贴板')),
      );
      _encodeController.text = decodedString; // 将解码后的值显示在上方输入框内
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('解码失败: $e')),
      );
    }
  }

  // 编码并复制到剪贴板
  void _encodeAndCopy() async {
    String input = _encodeController.text;
    try {
      String encodedString = await encodeToBase64(input);
      await Clipboard.setData(ClipboardData(text: encodedString));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('编码成功，已复制到剪贴板')),
      );
      _decodeController.text = encodedString; // 将编码后的值显示在下方输入框内
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('编码失败: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('编解码工具', style: theme.textTheme.headlineMedium),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '编解码工具',
              style: theme.textTheme.headlineSmall,
            ),
            SizedBox(height: 20),

            // 第一组：解码
            _buildSettingCard(
              context,
              icon: Icons.lock_open,
              title: 'Base64 解码',
              child: TextField(
                controller: _decodeController,
                decoration: InputDecoration(
                  labelText: '输入 Base64 编码的字符串',
                  hintText:'例如：SGVsbG8gV29ybGQh',
                ),
                maxLines: null, // 允许多行输入
                minLines: 3, // 最小行数
                expands: false, // 不自动填充剩余空间
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _decodeAndCopy,
              icon: Icon(Icons.content_copy),
              label: Text('解码并复制'),
            ),
            SizedBox(height: 20),

            // 第二组：编码
            _buildSettingCard(
              context,
              icon: Icons.lock,
              title: 'Base64 编码',
              child: TextField(
                controller: _encodeController,
                decoration: InputDecoration(
                  labelText: '输入需要编码的字符串',
                  hintText:'例如：Hello World!',
                ),
                maxLines: null, // 允许多行输入
                minLines: 3, // 最小行数
                expands: false, // 不自动填充剩余空间
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _encodeAndCopy,
              icon: Icon(Icons.content_copy),
              label: Text('编码并复制'),
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

