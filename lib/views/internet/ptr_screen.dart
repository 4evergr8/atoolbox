import 'package:flutter/material.dart';
import '/service/internet/doh_PTR_v4.dart';
import '/service/internet/doh_PTR_v6.dart';
import '/widgets/popup_text.dart';
import '/widgets/popup_infinity.dart';

class PTRScreen extends StatefulWidget {
  const PTRScreen({super.key});

  @override
  _PTRScreenState createState() => _PTRScreenState();
}

class _PTRScreenState extends State<PTRScreen> {
  bool _isIPv4 = true; // 默认为 IPv4
  String _queryUrl = 'https://cloudflare-dns.com/dns-query'; // 默认 DoH 地址
  String _ip = '8.8.8.8'; // 默认查询 IP
  int _timeout = 5000; // 默认超时时长（毫秒）

  // 提升 TextEditingController 到类级别
  late TextEditingController _queryUrlController;
  late TextEditingController _ipController;
  late TextEditingController _timeoutController;

  @override
  void initState() {
    super.initState();
    // 初始化控制器
    _queryUrlController = TextEditingController(text: _queryUrl);
    _ipController = TextEditingController(text: _ip);
    _timeoutController = TextEditingController(text: _timeout.toString());
  }

  @override
  void dispose() {
    // 释放控制器
    _queryUrlController.dispose();
    _ipController.dispose();
    _timeoutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('PTR查询', style: theme.textTheme.headlineMedium),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PTR记录查询',
              style: theme.textTheme.headlineSmall,
            ),
            SizedBox(height: 20),
            _buildSettingCard(
              context,
              icon: Icons.swap_horiz,
              title: 'IP版本选择',
              child: SwitchListTile(
                value: _isIPv4,
                onChanged: (value) {
                  setState(() {
                    _isIPv4 = value;
                    // 根据选择的版本更新默认 IP
                    if (_isIPv4) {
                      _ip = '8.8.8.8';
                      _ipController.text = _ip;
                    } else {
                      _ip = '2001:db8::1';
                      _ipController.text = _ip;
                    }
                  });
                },
                title: Text(_isIPv4 ? 'IPv4' : 'IPv6'),
                subtitle: Text(_isIPv4 ? '查询 IPv4 地址的 PTR 记录' : '查询 IPv6 地址的 PTR 记录'),
              ),
            ),
            SizedBox(height: 16),
            _buildSettingCard(
              context,
              icon: Icons.link,
              title: 'DoH服务器',
              child: TextField(
                controller: _queryUrlController,
                onChanged: (value) => setState(() => _queryUrl = value),
                decoration: InputDecoration(
                  labelText: 'DoH URL',
                ),
              ),
            ),
            SizedBox(height: 16),
            _buildSettingCard(
              context,
              icon: Icons.computer,
              title: 'IP地址',
              child: TextField(
                controller: _ipController,
                onChanged: (value) => setState(() => _ip = value),
                decoration: InputDecoration(
                  labelText: _isIPv4 ? 'IPv4 地址' : 'IPv6 地址',
                  hintText: _isIPv4 ? '例如: 8.8.8.8' : '例如: 2001:4860:4860::8888',
                ),
              ),
            ),
            SizedBox(height: 16),
            _buildSettingCard(
              context,
              icon: Icons.timer,
              title: '超时时长',
              child: TextField(
                controller: _timeoutController,
                onChanged: (value) {
                  setState(() {
                    _timeout = int.tryParse(value) ?? 5000;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Timeout',
                  suffixText: 'ms',
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                dynamic result;
                
                DialogUtils.showLoadingDialog(
                  context: context,
                  title: '查询中...',
                  content: '请稍候，查询正在进行...',
                );

                if (_isIPv4) {
                  result = await dohPtrQuery(_queryUrl, _ip, _timeout);
                } else {
                  result = await dohPtrV6Query(_queryUrl, _ip, _timeout);
                }

                Navigator.of(context).pop();
                showTextPopup(context, result.toString());
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.dns),
                  SizedBox(width: 8),
                  Text('查询'),
                ],
              ),
            )
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
