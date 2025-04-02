import 'package:flutter/material.dart';
import '../screens/ocr_screen.dart';
import '../screens/translate_screen.dart';
import '/screens/port_screen.dart';
import '/screens/address_screen.dart';


class IntranetPage extends StatelessWidget {
  const IntranetPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('离线功能', style: theme.textTheme.headlineMedium),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Intranet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 20),
            _buildFunctionItem(
              context,
              icon: Icons.wifi_find,
              title: '局域网扫描',
              subtitle: '扫描局域网内的设备',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddressScreen()),
                );
              },
            ),
            SizedBox(height: 16),
            _buildFunctionItem(
              context,
              icon: Icons.import_export,
              title: '端口扫描',
              subtitle: '扫描设备端口',
              onTap: () {
                // 假设跳转到路由器设置页面
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PortScreen()),
                );
              },
            ),
            SizedBox(height: 16),
            _buildFunctionItem(
              context,
              icon: Icons.pageview,
              title: '离线OCR',
              subtitle: '从图片中提取文字',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const OfflineOCRScreen()),
                );
              },
            ),
            SizedBox(height: 16),
            _buildFunctionItem(
              context,
              icon: Icons.translate,
              title: '离线翻译',
              subtitle: '离线翻译，支持检测语言',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TranslateScreen()),
                );
              },
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildFunctionItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required VoidCallback onTap,
      }) {
    return Card(
      elevation: 4, // 添加阴影
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // 圆角
      ),
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
        onTap: onTap,
      ),
    );
  }
}

// 假设的局域网设备页面
class LocalNetworkDevicesScreen extends StatelessWidget {
  const LocalNetworkDevicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('局域网设备')),
      body: Center(child: Text('这是局域网设备页面')),
    );
  }
}



