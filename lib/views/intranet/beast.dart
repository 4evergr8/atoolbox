import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 用于操作剪贴板
import '/service/intranet/beast.dart'; // 刚才的加解密代码

class BeastEncodeDecode extends StatefulWidget {
  const BeastEncodeDecode({super.key});

  @override
  _BeastEncodeDecodeState createState() => _BeastEncodeDecodeState();
}

class _BeastEncodeDecodeState extends State<BeastEncodeDecode> {
  final TextEditingController _cipherController = TextEditingController(text: '理的说的说说说道说说理道的理道理的的说道'); // 密文
  final TextEditingController _plainController = TextEditingController(text: '你好'); // 明文
  final TextEditingController _dictController = TextEditingController(text: '说的道理'); // 字典

  // 加密并复制
  void _encryptAndCopy() async {
    String dict = _dictController.text;
    String plain = _plainController.text;

    if (dict.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('字典必须为4个字符')),
      );
      return;
    }

    try {
      String cipher = await encrypt(dict, plain);
      _cipherController.text = cipher;
      await Clipboard.setData(ClipboardData(text: cipher));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('加密成功，已复制到剪贴板')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('加密失败: $e')),
      );
    }
  }

  // 解密并复制
  void _decryptAndCopy() async {
    String cipher = _cipherController.text;

    try {
      String plain = await decrypt(cipher);
      _plainController.text = plain;
      await Clipboard.setData(ClipboardData(text: plain));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('解密成功，已复制到剪贴板')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('解密失败: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('兽音加解密工具', style: theme.textTheme.headlineMedium),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('兽音加解密工具', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 20),

            // 密文输入
            _buildSettingCard(
              context,
              icon: Icons.password,
              title: '密文',
              child: TextField(
                controller: _cipherController,
                decoration: const InputDecoration(
                  labelText: '请输入密文',
                  hintText: '你好',
                ),
                maxLines: null,
                minLines: 3,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _decryptAndCopy,
              icon: const Icon(Icons.content_copy),
              label: const Text('解密并复制'),
            ),
            const SizedBox(height: 20),

            // 字典输入
            _buildSettingCard(
              context,
              icon: Icons.view_array,
              title: '字典（4字符）',
              child: TextField(
                controller: _dictController,
                decoration: const InputDecoration(
                  labelText: '请输入字典',
                  hintText: '说的道理',
                ),
                maxLength: 4,
              ),
            ),
            const SizedBox(height: 16),

            // 明文输入
            _buildSettingCard(
              context,
              icon: Icons.text_fields,
              title: '明文',
              child: TextField(
                controller: _plainController,
                decoration: const InputDecoration(
                  labelText: '请输入明文',
                  hintText: '你好',
                ),
                maxLines: null,
                minLines: 3,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _encryptAndCopy,
              icon: const Icon(Icons.content_copy),
              label: const Text('加密并复制'),
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