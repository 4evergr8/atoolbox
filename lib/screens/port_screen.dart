import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import '/service/scan_port.dart';
import '/widgets/popup_text.dart';
import '/widgets/popup_infinity.dart'; // 导入通用弹窗工具类

class PortScreen extends StatefulWidget {
  const PortScreen({super.key});

  @override
  _PortScreenState createState() => _PortScreenState();
}

class _PortScreenState extends State<PortScreen> {
  final TextEditingController _targetController = TextEditingController();
  final TextEditingController _startPortController = TextEditingController();
  final TextEditingController _endPortController = TextEditingController();
  final TextEditingController _timeoutController = TextEditingController();

  String _currentIp = 'Unknown';

  @override
  void initState() {
    super.initState();
    _getCurrentIp();
    _startPortController.text = '1';
    _endPortController.text = '65535';
    _timeoutController.text = '25';
  }

  Future<void> _getCurrentIp() async {
    final NetworkInfo networkInfo = NetworkInfo();
    try {
      String? wifiIP = await networkInfo.getWifiIP();
      setState(() {
        _currentIp = wifiIP ?? 'Unknown';
        if (_currentIp != 'Unknown') {
          _targetController.text = _calculateStartIp(_currentIp);
        }
      });
    } catch (e) {
      print('Failed to get current IP address: $e');
    }
  }

  String _calculateStartIp(String currentIp) {
    List<String> parts = currentIp.split('.');
    parts[3] = '1';
    return parts.join('.');
  }

  void _startTest() async {
    String target = _targetController.text;
    int startPort = int.tryParse(_startPortController.text) ?? 1;
    int endPort = int.tryParse(_endPortController.text) ?? 65535;
    int timeoutMs = int.tryParse(_timeoutController.text) ?? 25;

    // 显示带有无限进度条的弹窗
    DialogUtils.showLoadingDialog(
      context: context,
      title: '扫描中...',
      content: '请稍候，扫描正在进行...',
    );

    // 执行扫描操作
    final result = await port(target, startPort, endPort, timeoutMs);

    // 关闭扫描中的弹窗
    Navigator.of(context).pop();

    // 显示扫描结果
    showTextPopup(context, result);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('端口扫描', style: theme.textTheme.headlineMedium),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '端口扫描',
              style: theme.textTheme.headlineSmall,
            ),
            SizedBox(height: 20),
            _buildSettingCard(
              context,
              icon: Icons.pin_drop,
              title: '当前设备内网地址',
              child: Text(
                _currentIp,
                style: theme.textTheme.bodyLarge,
              ),
            ),
            SizedBox(height: 16),
            _buildSettingCard(
              context,
              icon: Icons.devices,
              title: '目标地址',
              child: TextField(
                controller: _targetController,
                decoration: InputDecoration(
                  labelText: '目标地址（IP）',
                ),
              ),
            ),
            SizedBox(height: 16),
            _buildSettingCard(
              context,
              icon: Icons.login,
              title: '起始端口',
              child: TextField(
                controller: _startPortController,
                decoration: InputDecoration(
                  labelText: '起始端口',
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(height: 16),
            _buildSettingCard(
              context,
              icon: Icons.logout,
              title: '终止端口',
              child: TextField(
                controller: _endPortController,
                decoration: InputDecoration(
                  labelText: '终止端口',
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(height: 16),
            _buildSettingCard(
              context,
              icon: Icons.timer,
              title: '超时时间',
              child: TextField(
                controller: _timeoutController,
                decoration: InputDecoration(
                  labelText: '超时时间（毫秒）',
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _startTest,
              icon: Icon(Icons.perm_scan_wifi),
              label: Text('开始测试'),
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