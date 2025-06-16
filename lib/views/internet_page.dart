import 'package:flutter/material.dart';
import 'internet/backup_screen.dart';
import 'internet/ptr_screen.dart';
import 'internet/netspeed_screen.dart';
import 'internet/dns_screen.dart';
import 'internet/thumbnail_screen.dart';
import 'internet/image_screen.dart';

class InternetPage extends StatelessWidget {
  const InternetPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('在线', style: theme.textTheme.headlineMedium),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '需要联网',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 20),
              _buildFunctionItem(
                context,
                icon: Icons.image,
                title: '以图搜图',
                subtitle: '寻找图片的出处',
                onTap: () {
                  // 假设跳转到设置页面
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ImageSearchScreen(),
                    ),
                  );
                },
              ),
              SizedBox(height: 16),
              _buildFunctionItem(
                context,
                icon: Icons.search,
                title: '视频封面搜图',
                subtitle: '寻找视频封面的出处，目前仅支持哔哩哔哩',
                onTap: () {
                  // 假设跳转到关于页面
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ThumbnailSearchScreen(),
                    ),
                  );
                },
              ),
              SizedBox(height: 16),
              _buildFunctionItem(
                context,
                icon: Icons.settings_backup_restore,
                title: '视频备份',
                subtitle: '哔哩哔哩视频备份，无需登录',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BackupScreen(),
                    ),
                  );
                },
              ),
              SizedBox(height: 16),
              _buildFunctionItem(
                context,
                icon: Icons.speed,
                title: '网速测试',
                subtitle: '网络下载速度测试',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SpeedTestScreen(),
                    ),
                  );
                },
              ),
              SizedBox(height: 16),
              _buildFunctionItem(
                context,
                icon: Icons.dns,
                title: 'DNS 查询',
                subtitle: '加密DNS查询测试',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DNSScreen()),
                  );
                },
              ),
              SizedBox(height: 16),
              _buildFunctionItem(
                context,
                icon: Icons.web,
                title: 'IP反查域名',
                subtitle: 'DoHPTR查询测试',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PTRScreen()),
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
