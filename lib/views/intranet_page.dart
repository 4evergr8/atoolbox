import 'package:flutter/material.dart';
import 'internet/url_decode.dart';
import 'intranet/avbv.dart';
import 'intranet/base64.dart';
import 'intranet/garbled_screen.dart';
import 'intranet/ocr_screen.dart';
import 'intranet/qrcode.dart';
import 'intranet/address_screen.dart';

class IntranetPage extends StatelessWidget {
  const IntranetPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('离线', style: theme.textTheme.headlineMedium),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '无需联网',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 20),
              _buildFunctionItem(
                context,
                icon: Icons.import_export,
                title: 'URL解码',
                subtitle: 'URL解码与编辑',
                onTap: () {
                  // 假设跳转到路由器设置页面
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const URLDecode()),
                  );
                },
              ),
              SizedBox(height: 16),
              _buildFunctionItem(
                context,
                icon: Icons.lock_open,
                title: 'Base64解码',
                subtitle: 'Base64编码与解码',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EncodeDecode(),
                    ),
                  );
                },
              ),
              SizedBox(height: 16),
              _buildFunctionItem(
                context,
                icon: Icons.qr_code,
                title: '图片扫码',
                subtitle: '识别图片中的码，支持识别多个',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const QRCodeScan(),
                    ),
                  );
                },
              ),
              SizedBox(height: 16),
              _buildFunctionItem(
                context,
                icon: Icons.transform,
                title: '乱码恢复',
                subtitle: '将乱码恢复成人类语言',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GarbledRecovery(),
                    ),
                  );
                },
              ),
              SizedBox(height: 16),
              _buildFunctionItem(
                context,
                icon: Icons.rotate_90_degrees_ccw,
                title: 'AVBV互转',
                subtitle: 'AV号和BV号转换',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AVBV(),
                    ),
                  );
                },
              ),

              SizedBox(height: 16),
              _buildFunctionItem(
                context,
                icon: Icons.wifi_find,
                title: '局域网扫描',
                subtitle: '扫描局域网内的设备',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddressScreen(),
                    ),
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
                    MaterialPageRoute(
                      builder: (context) => const OfflineOCRScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
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
