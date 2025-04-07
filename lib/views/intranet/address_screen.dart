import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import '../../service/intranet/scan_address.dart';
import '/widgets/popup_text.dart';
import '/widgets/popup_infinity.dart'; // 导入通用弹窗工具类

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  _AddressScreenState createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  String _currentIp = 'Unknown';

  @override
  void initState() {
    super.initState();
    _getCurrentIp();
    _timeController.text = '50';
  }

  Future<void> _getCurrentIp() async {
    final NetworkInfo networkInfo = NetworkInfo();
    try {
      String? wifiIP = await networkInfo.getWifiIP();
      setState(() {
        _currentIp = wifiIP ?? 'Unknown';
        if (_currentIp != 'Unknown') {
          _startController.text = _calculateStartIp(_currentIp);
          _endController.text = _calculateEndIp(_currentIp);
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

  String _calculateEndIp(String currentIp) {
    List<String> parts = currentIp.split('.');
    parts[3] = '255';
    return parts.join('.');
  }

  void _startScan() async {
    String start = _startController.text;
    String end = _endController.text;
    int time = int.tryParse(_timeController.text) ?? 25;

    // 显示带有无限进度条的弹窗
    DialogUtils.showLoadingDialog(
      context: context,
      title: '扫描中...',
      content: '请稍候，扫描正在进行...',
    );

    // 执行扫描操作
    final result = await address(start, end, time);

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
        title: Text('地址扫描', style: theme.textTheme.headlineMedium),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '地址扫描',
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
              icon: Icons.first_page,
              title: '起始地址',
              child: TextField(
                controller: _startController,
                decoration: InputDecoration(
                  labelText: '起始地址',
                ),
              ),
            ),
            SizedBox(height: 16),
            _buildSettingCard(
              context,
              icon: Icons.last_page,
              title: '结束地址',
              child: TextField(
                controller: _endController,
                decoration: InputDecoration(
                  labelText: '结束地址',
                ),
              ),
            ),
            SizedBox(height: 16),
            _buildSettingCard(
              context,
              icon: Icons.timer,
              title: '扫描时间',
              child: TextField(
                controller: _timeController,
                decoration: InputDecoration(
                  labelText: '扫描时间（毫秒）',
                  suffixText: 'ms',
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _startScan,
              icon: Icon(Icons.perm_scan_wifi),
              label: Text('开始扫描'),
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