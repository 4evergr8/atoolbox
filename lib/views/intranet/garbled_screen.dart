import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/widgets/popup_text.dart';
import '/service/intranet/garbled_recovery.dart';
import '/widgets/popup_infinity.dart'; // 弹窗展示恢复结果

class GarbledRecovery extends StatefulWidget {
  const GarbledRecovery({super.key});

  @override
  _GarbledRecoveryState createState() => _GarbledRecoveryState();
}

class _GarbledRecoveryState extends State<GarbledRecovery> {
  final TextEditingController _inputController = TextEditingController(
    text: '鐢辨湀瑕佸ソ濂藉涔犲ぉ澶╁悜涓?',
  ); // 默认乱码文本
  final TextEditingController _excludeController = TextEditingController(
    text: r'[\u0020]',
  ); // 默认排除空格
  final TextEditingController _includeController = TextEditingController(
    text: r'[\x00-\x1F\x80-\x9F\u003F\u00A0-\u00FF\u0370-\u03FF\u1A00-\u1A1F\u2000-\u2BFF\u2200-\u22FF\u2580-\u259F\uE000-\uF8FF\uF900-\uFAFF\uFFFD\u3400-\u4DBF]',
  );

  final TextEditingController _thresholdController = TextEditingController(
    text: '3',
  ); // 默认阈值

  void _recoverAndCopy() async {
    DialogUtils.showLoadingDialog(
      context: context,
      title: '转换中...',
      content: '请稍候，正在恢复乱码...',
    );

    // 获取输入的排除字符、包含字符和阈值
    String excludePattern = _excludeController.text;
    String includePattern = _includeController.text;
    int threshold = int.tryParse(_thresholdController.text) ?? 3; // 默认阈值为3

    final result = await recoverGarbledText(
      _inputController.text,
      includePattern,
      excludePattern,
      threshold,
    );

    Navigator.of(context).pop(); // 关闭加载对话框
    showTextPopup(context, result);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('恢复成功，结果已复制到剪贴板')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('乱码恢复工具', style: theme.textTheme.headlineMedium),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('乱码恢复', style: theme.textTheme.headlineSmall),
            SizedBox(height: 20),
            _buildSettingCard(
              context,
              icon: Icons.build,
              title: '输入乱码文本',
              child: TextField(
                controller: _inputController,
                decoration: InputDecoration(
                  labelText: '请输入可能乱码的文本',
                  hintText: '例如：鐢辨湀瑕佸ソ濂藉涔犲ぉ澶╁悜涓?',
                  border: OutlineInputBorder(),
                ),
                maxLines: null,
                minLines: 6,
                keyboardType: TextInputType.multiline,
              ),
            ),
            SizedBox(height: 16),
            _buildSettingCard(
              context,
              icon: Icons.filter_alt_outlined,
              title: '排除字符',
              child: TextField(
                controller: _excludeController,
                decoration: InputDecoration(
                  labelText: '请输入排除的字符（正则）',
                  hintText: '例如：[\\u0020]',
                  border: OutlineInputBorder(),
                ),
                maxLines: null,
                minLines: 1,
                keyboardType: TextInputType.multiline,
              ),
            ),
            SizedBox(height: 16),
            _buildSettingCard(
              context,
              icon: Icons.filter_alt_outlined,
              title: '包含字符',
              child: TextField(
                controller: _includeController,
                decoration: InputDecoration(
                  labelText: '请输入包含的字符（正则）',
                  hintText: '例如：\\x00-\\x1F \\u003F \\u00A0-\\u00FF',
                  border: OutlineInputBorder(),
                ),
                maxLines: null,
                minLines: 1,
                keyboardType: TextInputType.multiline,
              ),
            ),
            SizedBox(height: 16),
            _buildSettingCard(
              context,
              icon: Icons.settings,
              title: '阈值',
              child: TextField(
                controller: _thresholdController,
                decoration: InputDecoration(
                  labelText: '请输入阈值（整数）',
                  hintText: '例如：3',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _recoverAndCopy,
              icon: Icon(Icons.refresh),
              label: Text('恢复并复制'),
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
        padding: const EdgeInsets.all(16),
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
