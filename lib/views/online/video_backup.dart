import 'package:flutter/material.dart';
import 'package:picorigin/service/video_download.dart';
import 'package:picorigin/widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  _BackupScreenState createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  final TextEditingController _uaController = TextEditingController();
  final TextEditingController _idController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _uaController.text =
        prefs.getString('ua') ??
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36';
    _idController.text = prefs.getString('id') ?? '';
  }

  Future<void> _saveSettings(String ua, String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('ua', ua);
    await prefs.setString('id', id);
  }

  void _startBackup() async {
    String ua = _uaController.text;
    String inputUrl = _idController.text;
    final close = await showLoadingDialogGlobal();

    try {} catch (e) {
      showErrorSnackBarGlobal('$e');
    } finally {
      close();
    }
    final bvid = await extractBvId(inputUrl);
    await fetchAndSaveVideo(context, ua, bvid);

    // 关闭备份中的弹窗
    Navigator.of(context).pop();

    // 保存设置
    await _saveSettings(ua, id);
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
            Text('备份设置', style: theme.textTheme.headlineSmall),
            SizedBox(height: 20),
            _buildSettingCard(
              context,
              icon: Icons.browser_updated,
              title: 'UA',
              child: TextField(
                controller: _uaController,
                decoration: InputDecoration(labelText: 'UserAgent字符串', hintText: '请输入UserAgent'),
              ),
            ),
            SizedBox(height: 16),
            _buildSettingCard(
              context,
              icon: Icons.video_collection,
              title: 'BV',
              child: TextField(
                controller: _idController,
                decoration: InputDecoration(labelText: '支持视频链接、BV号、b23短链', hintText: '请输入BV号'),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _startBackup,
              icon: Icon(Icons.settings_backup_restore),
              label: Text('开始备份'),
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
