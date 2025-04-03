import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart'; // 导入剪贴板库
import '/widgets/popup_text.dart';
import '/service/backup_collection.dart'; // 假设 backup_collection.dart 包含 fetchAndSaveMedia 函数
import '/widgets/popup_infinity.dart'; // 导入通用弹窗工具类

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  _BackupScreenState createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  final TextEditingController _cookieController = TextEditingController();
  final TextEditingController _uaController = TextEditingController();
  final TextEditingController _idController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _cookieController.text = prefs.getString('cookie') ?? "";
    _uaController.text = prefs.getString('ua') ?? 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36';
  }

  Future<void> _saveSettings(String cookie, String ua) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('cookie', cookie);
    await prefs.setString('ua', ua);
  }

  void _startBackup() async {
    String cookie = _cookieController.text;
    String ua = _uaController.text;
    String id = _idController.text;

    // 显示带有无限进度条的弹窗
    DialogUtils.showLoadingDialog(
      context: context,
      title: '备份中...',
      content: '请稍候，备份正在进行...',
    );

    // 执行备份操作
    await fetchAndSaveMedia(cookie, ua, id);

    // 关闭备份中的弹窗
    Navigator.of(context).pop();

    // 保存设置
    await _saveSettings(cookie, ua);

    // 显示备份完成提示
    showTextPopup(context, '备份完成');
  }

  void _copyCookieCode() {
    const cookieCode = "javascript:(function(){prompt('',document.cookie);})();";
    Clipboard.setData(ClipboardData(text: cookieCode));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已将代码复制到剪贴板')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('备份', style: theme.textTheme.headlineMedium),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '备份设置',
              style: theme.textTheme.headlineSmall,
            ),
            SizedBox(height: 20),
            _buildSettingCard(
              context,
              icon: Icons.cookie,
              title: 'COOKIE',
              child: TextField(
                controller: _cookieController,
                decoration: InputDecoration(
                  labelText: 'COOKIE',
                  hintText: '请在浏览器中获取',
                ),
              ),
            ),
            SizedBox(height: 16),
            _buildSettingCard(
              context,
              icon: Icons.browser_updated,
              title: 'UA',
              child: TextField(
                controller: _uaController,
                decoration: InputDecoration(
                  labelText: 'UA',
                  hintText: '请输入UserAgent',
                ),
              ),
            ),
            SizedBox(height: 16),
            _buildSettingCard(
              context,
              icon: Icons.perm_identity,
              title: 'ID',
              child: TextField(
                controller: _idController,
                decoration: InputDecoration(
                  labelText: 'ID',
                  hintText: '请输入收藏夹ID',
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _startBackup,
                  icon: Icon(Icons.settings_backup_restore),
                  label: Text('开始备份'),
                ),
                ElevatedButton.icon(
                  onPressed: _copyCookieCode,
                  icon: Icon(Icons.code),
                  label: Text('cookie代码'),
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