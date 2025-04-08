import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 用于操作剪贴板
import '/service/intranet/avbv.dart';


class AVBV extends StatefulWidget {
  const AVBV({super.key});

  @override
  _AVBVState createState() => _AVBVState();
}

class _AVBVState extends State<AVBV> {
  final TextEditingController _decodeController = TextEditingController();
  final TextEditingController _encodeController = TextEditingController();

  // 解码并复制到剪贴板
  void _BV2AVAndCopy() async {
    String input = _decodeController.text;
    try {
      String decodedString =  bv2av(input);
      await Clipboard.setData(ClipboardData(text: decodedString));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('转换成功，已复制到剪贴板')),
      );
      _encodeController.text = decodedString; // 将解码后的值显示在上方输入框内
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('转换失败: $e')),
      );
    }
  }

  // 编码并复制到剪贴板
  void _AV2BVAndCopy() async {
    String input = _encodeController.text;
    try {
      String encodedString =  bv2av(input);
      await Clipboard.setData(ClipboardData(text: encodedString));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('转换成功，已复制到剪贴板')),
      );
      _decodeController.text = encodedString; // 将编码后的值显示在下方输入框内
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('转换失败: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('AVBV互转', style: theme.textTheme.headlineMedium),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AVBV互转',
              style: theme.textTheme.headlineSmall,
            ),
            SizedBox(height: 20),

            // 第一组：解码
            _buildSettingCard(
              context,
              icon: Icons.rotate_left,
              title: 'BV转AV',
              child: TextField(
                controller: _decodeController,
                decoration: InputDecoration(
                  labelText: '输入BV号',
                  hintText:'例如：BV17x411w7KC',
                ),
                maxLines: null, // 允许多行输入
                minLines: 3, // 最小行数
                expands: false, // 不自动填充剩余空间
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _BV2AVAndCopy,
              icon: Icon(Icons.content_copy),
              label: Text('转换并复制'),
            ),
            SizedBox(height: 20),

            // 第二组：编码
            _buildSettingCard(
              context,
              icon: Icons.rotate_right,
              title: 'AV转BV',
              child: TextField(
                controller: _encodeController,
                decoration: InputDecoration(
                  labelText: '输入AV号',
                  hintText:'例如：170001',
                ),
                maxLines: null, // 允许多行输入
                minLines: 3, // 最小行数
                expands: false, // 不自动填充剩余空间
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _AV2BVAndCopy,
              icon: Icon(Icons.content_copy),
              label: Text('转换并复制'),
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

