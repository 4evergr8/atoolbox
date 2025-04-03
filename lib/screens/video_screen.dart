import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:web_tools/screens/yaml_process.dart';

import '../service/cid_fetcher.dart';
import '../service/video_download.dart';
import '../widgets/popup_infinity.dart';
import '../widgets/popup_text.dart'; // 用于选择文件

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  bool _isDefaultMode = true;
  final TextEditingController _uaController = TextEditingController();
  final TextEditingController _bvController = TextEditingController();
  File? _yamlFile;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _uaController.text = prefs.getString('ua') ?? 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36';
  }

  Future<void> _saveSettings(String ua) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('ua', ua);
  }

  void _startDownload() async {
    if (_isDefaultMode) {
      DialogUtils.showLoadingDialog(
        context: context,
        title: '下载中...',
        content: '请稍候，视频正在下载...',
      );
      final cid =await fetchCid(_bvController.text,_uaController.text);
      final result = await videoDownload(cid, _bvController.text, _uaController.text);
      Navigator.of(context).pop(); // 关闭加载对话框
      showTextPopup(context, result);
    } else {
      if (_yamlFile != null) {
        DialogUtils.showLoadingDialog(
          context: context,
          title: '下载中...',
          content: '请稍候，视频正在下载...',
        );
        final result = await yamlProcess(_yamlFile!.path, _uaController.text);
        Navigator.of(context).pop(); // 关闭加载对话框
        showTextPopup(context, result);

      } else {
        // 提示用户选择文件
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('请选择一个 YAML 文件')),
        );
      }
    }
    await _saveSettings(_uaController.text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('视频下载', style: theme.textTheme.headlineMedium),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '下载设置',
              style: theme.textTheme.headlineSmall,
            ),
            SizedBox(height: 20),
            _buildSettingCard(
              context,
              icon: Icons.cloud,
              title: '下载模式',
              child: SwitchListTile(
                value: _isDefaultMode,
                onChanged: (value) {
                  setState(() {
                    _isDefaultMode = value;
                    _yamlFile = null; // 清空已选择的文件
                  });
                },
                title: Text(_isDefaultMode ? '默认模式' : '切换模式'),
                subtitle: Text(_isDefaultMode
                    ? '通过输入 BV 号进行下载'
                    : '通过选择 YAML 文件进行下载'),
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
            if (_isDefaultMode) ...[
              SizedBox(height: 16),
              _buildSettingCard(
                context,
                icon: Icons.perm_identity,
                title: 'BV 号',
                child: TextField(
                  controller: _bvController..text = 'BV1GJ411x7h7', // 设置默认值
                  decoration: InputDecoration(
                    labelText: 'BV 号',
                    hintText: '请输入 BV 号',
                  ),
                ),
              ),

            ] else ...[
              SizedBox(height: 16),
              _buildSettingCard(
                context,
                icon: Icons.file_present,
                title: '选择 YAML 文件',
                child: ElevatedButton(
                  onPressed: () async {
                    FilePickerResult? result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['yaml'],
                    );
                    if (result != null) {
                      setState(() {
                        _yamlFile = File(result.files.single.path!);
                      });
                    }
                  },
                  child: Text('选择文件'),
                ),
              ),
              if (_yamlFile != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text('已选择文件: ${_yamlFile!.path}'),
                ),
            ],
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _startDownload,
              icon: Icon(Icons.download),
              label: Text('开始下载'),
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
