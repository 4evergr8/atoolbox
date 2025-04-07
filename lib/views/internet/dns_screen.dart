import 'package:flutter/material.dart';
import '/service/internet/doh.dart';
import '/service/internet/dot.dart';
import '/widgets/popup_text.dart';
import '/widgets/popup_infinity.dart'; // 导入通用弹窗工具类

class DNSScreen extends StatefulWidget {
  const DNSScreen({super.key});

  @override
  _DNSScreenState createState() => _DNSScreenState();
}

class _DNSScreenState extends State<DNSScreen> {
  bool _isDoh = true; // 默认为 DoH
  String _queryUrl = 'https://doh.pub/dns-query'; // 默认 DoH 地址
  final String _queryPort = ':853'; // 默认 DoT 端口
  String _domain = 'baidu.com'; // 默认查询域名
  String _type = 'A'; // 默认查询类型
  int _timeout = 5000; // 默认超时时长（毫秒）

  // 提升 TextEditingController 到类级别
  late TextEditingController _queryUrlController;
  late TextEditingController _domainController;
  late TextEditingController _timeoutController;

  // DNS 记录类型列表
  final List<String> _dnsTypes = [
    'A',      // IPv4 地址
    'AAAA',   // IPv6 地址
    'CNAME',  // 规范名称
    'NS',     // 域名服务器
    'MX',     // 邮件交换
    'SOA',    // 起始授权机构
    'TXT',    // 文本
    'ANY',
  ];

  @override
  void initState() {
    super.initState();
    // 初始化控制器
    _queryUrlController = TextEditingController(text: _queryUrl);
    _domainController = TextEditingController(text: _domain);
    _timeoutController = TextEditingController(text: _timeout.toString());
  }

  @override
  void dispose() {
    // 释放控制器
    _queryUrlController.dispose();
    _domainController.dispose();
    _timeoutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('DNS查询', style: theme.textTheme.headlineMedium),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView( // 使用 SingleChildScrollView 包裹整个内容
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '加密DNS测试',
              style: theme.textTheme.headlineSmall,
            ),
            SizedBox(height: 20),
            _buildSettingCard(
              context,
              icon: Icons.cloud,
              title: '协议选择',
              child: SwitchListTile(
                value: _isDoh,
                onChanged: (value) {
                  setState(() {
                    _isDoh = value;
                    if (_isDoh) {
                      _queryUrl = 'https://doh.pub/dns-query'; // DoH 地址
                    } else {
                      _queryUrl = 'dot.pub'; // DoT 地址
                    }
                    _queryUrlController.text = _queryUrl; // 更新控制器内容
                  });
                },
                title: Text(_isDoh ? 'DoH' : 'DoT'),
                subtitle: Text(_isDoh ? 'DNS over HTTPS' : 'DNS over TLS（仅支持A类型）'),
              ),
            ),
            SizedBox(height: 16),
            _buildSettingCard(
              context,
              icon: Icons.link,
              title: '查询地址',
              child: TextField(
                controller: _queryUrlController, // 使用类级别的控制器
                onChanged: (value) => setState(() => _queryUrl = value),
                decoration: InputDecoration(
                  labelText: _isDoh ? 'DoH URL' : 'DoT URL',
                  suffixText: _isDoh ? '' : _queryPort,
                ),
              ),
            ),
            SizedBox(height: 16),
            _buildSettingCard(
              context,
              icon: Icons.domain,
              title: '查询域名',
              child: TextField(
                controller: _domainController,
                onChanged: (value) => setState(() => _domain = value),
                decoration: InputDecoration(
                  labelText: 'Domain',
                ),
              ),
            ),
            if (_isDoh) ...[
              SizedBox(height: 16),
              _buildSettingCard(
                context,
                icon: Icons.type_specimen,
                title: '查询类型',
                child: DropdownButtonFormField<String>(
                  value: _type,
                  decoration: InputDecoration(
                    labelText: 'Type',
                  ),
                  items: _dnsTypes.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _type = newValue;
                      });
                    }
                  },
                ),
              ),
            ],
            SizedBox(height: 16),
            _buildSettingCard(
              context,
              icon: Icons.timer,
              title: '超时时长',
              child: TextField(
                controller: _timeoutController, // 使用类级别的控制器
                onChanged: (value) {
                  setState(() {
                    _timeout = int.tryParse(value) ?? 5000; // 默认值为5000ms
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Timeout',
                  suffixText: 'ms', // 添加单位提示
                ),
                keyboardType: TextInputType.number, // 限制输入数字
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                dynamic result;
                if (_isDoh) {


                  DialogUtils.showLoadingDialog(
                    context: context,
                    title: '查询中...',
                    content: '请稍候，查询正在进行...',
                  );

                  // 调用 DoH 查询函数
                  result = await dohQuery(_queryUrl, _domain, _type, _timeout);
                  // 关闭扫描中的弹窗
                  Navigator.of(context).pop();

                } else {
                  DialogUtils.showLoadingDialog(
                    context: context,
                    title: '查询中...',
                    content: '请稍候，查询正在进行...',
                  );
                  // 调用 DoT 查询函数
                  result = await dotQuery(_queryUrl, _domain, _timeout);
                  Navigator.of(context).pop();
                }
                //
                showTextPopup(context, result.toString());
              },
              child: Row(
                mainAxisSize: MainAxisSize.min, // 使内容紧凑
                children: [
                  Icon(Icons.dns), // 添加 DNS 图标
                  SizedBox(width: 8), // 图标和文本之间的间距
                  Text('查询'), // 按钮文本
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
      elevation: 4, // 添加阴影
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // 圆角
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