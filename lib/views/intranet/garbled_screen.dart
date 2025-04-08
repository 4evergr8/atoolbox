import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web_tools/widgets/popup_text.dart';
import '/service/intranet/garbled_recovery.dart';
import '/widgets/popup_infinity.dart'; // 弹窗展示恢复结果

class GarbledRecovery extends StatefulWidget {
  const GarbledRecovery({super.key});

  @override
  _GarbledRecoveryState createState() => _GarbledRecoveryState();
}

class _GarbledRecoveryState extends State<GarbledRecovery> {
  final TextEditingController _inputController = TextEditingController();

  void _recoverAndCopy() async {
    DialogUtils.showLoadingDialog(
      context: context,
      title: '转换中...',
      content: '请稍候，正在恢复乱码...',
    );
    final result = await recoverGarbledText(_inputController.text);
    await Clipboard.setData(ClipboardData(text: result));
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
                  hintText: '例如：锘挎槬鐪犱笉瑙夋檽锛屽澶勯椈鍟奸笩',
                  border: OutlineInputBorder(),
                ),
                maxLines: null,
                minLines: 6,
                keyboardType: TextInputType.multiline,
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
