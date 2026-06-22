import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:picorigin/service/decode.dart';
import 'package:picorigin/widget.dart';

class EncodeDecode extends StatefulWidget {
  const EncodeDecode({super.key});

  @override
  _EncodeDecodeScreenState createState() => _EncodeDecodeScreenState();
}

class _EncodeDecodeScreenState extends State<EncodeDecode> {
  final TextEditingController _decodeController = TextEditingController(text: '5L2g5aW9'); // 设置默认解码值
  final TextEditingController _encodeController = TextEditingController(text: '你好'); // 设置默认编码值

  // 解码并复制到剪贴板
  void _decodeAndCopy() async {
    try {
      String decodedString = await decodeBase64(_decodeController.text);
      await Clipboard.setData(ClipboardData(text: decodedString));

      showSnackBarGlobal("success", '已复制到剪贴板');
      _encodeController.text = decodedString; // 将解码后的值显示在上方输入框内
    } catch (e) {
      showSnackBarGlobal("fail", '$e');
    }
  }

  // 编码并复制到剪贴板
  void _encodeAndCopy() async {
    String input = _encodeController.text;
    try {
      String encodedString = await encodeBase64(input);
      await Clipboard.setData(ClipboardData(text: encodedString));
      showSnackBarGlobal("fail", '已复制到剪贴板');
      _decodeController.text = encodedString; // 将编码后的值显示在下方输入框内
    } catch (e) {
      showSnackBarGlobal("fail", '$e');
    }
  }

  // 粘贴到解码输入框
  void _pasteToDecode() async {
    String text = (await Clipboard.getData(Clipboard.kTextPlain))?.text ?? '';
    if (text.isNotEmpty) {
      _decodeController.text = text;
    }
  }

  // 粘贴到编码输入框
  void _pasteToEncode() async {
    String text = (await Clipboard.getData(Clipboard.kTextPlain))?.text ?? '';
    if (text.isNotEmpty) {
      _encodeController.text = text;
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
            // 第一组：解码
            _buildSettingCard(
              context,
              icon: Icons.lock_open,
              title: 'Base64 解码',
              child: TextField(
                controller: _decodeController,
                decoration: const InputDecoration(labelText: '输入 Base64 编码的字符串', hintText: '例如：SGVsbG8gV29ybGQh'),
                maxLines: null,
                // 允许多行输入
                minLines: 3,
                // 最小行数
                expands: false, // 不自动填充剩余空间
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _decodeAndCopy,
                  icon: const Icon(Icons.content_copy),
                  label: const Text('解码并复制'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _pasteToDecode,
                  icon: const Icon(Icons.assignment_returned),
                  label: const Text('粘贴'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 第二组：编码
            _buildSettingCard(
              context,
              icon: Icons.lock,
              title: 'Base64 编码',
              child: TextField(
                controller: _encodeController,
                decoration: const InputDecoration(labelText: '输入需要编码的字符串', hintText: '例如：Hello World!'),
                maxLines: null,
                // 允许多行输入
                minLines: 3,
                // 最小行数
                expands: false, // 不自动填充剩余空间
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _encodeAndCopy,
                  icon: const Icon(Icons.content_copy),
                  label: const Text('编码并复制'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _pasteToEncode,
                  icon: const Icon(Icons.assignment_returned),
                  label: const Text('粘贴'),
                ),
              ],
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 24),
                const SizedBox(width: 16),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
