import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('关于', style: Theme.of(context).textTheme.headlineMedium),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 头像
              CircleAvatar(
                radius: 60,
                backgroundImage: const AssetImage('assets/profile.png'),
              ),
              const SizedBox(height: 20),

              Text(
                '4evergr8',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 10),
              // 开发者简介
              Text(
                '此软件来源于无聊时的瞎想',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),



              ListTile(
                leading: const Icon(Icons.code),
                title: const Text('软件源代码'),
                subtitle: const Text('Github'),
                onTap: () {
                  launchUrl(
                    Uri.parse('https://github.com/4evergr8/atoolbox'),
                    mode: LaunchMode.externalApplication,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.group),
                title: const Text('软件下载'),
                subtitle: const Text('迅雷云盘'),
                onTap: () {
                  launchUrl(
                    Uri.parse('https://pan.xunlei.com/s/VOflulv2n-a8wkxd2ZUGmnVjA1?pwd=j3qy'),
                    mode: LaunchMode.externalApplication,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.web),
                title: const Text('搜图网站'),
                subtitle: const Text('GithubPages'),
                onTap: () {
                  launchUrl(
                    Uri.parse('https://4evergr8.github.io'),
                    mode: LaunchMode.externalApplication,
                  );
                },
              ),
              const SizedBox(height: 8), // 添加段落间距
              Column(
                crossAxisAlignment: CrossAxisAlignment.start, // 设置为左对齐
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center, // 确保圆点和文字对齐
                    children: [
                      Icon(Icons.circle_notifications, size: 15), // 更小的圆点
                      const SizedBox(width: 8), // 圆点和文字之间的间距
                      Expanded(
                        child: Text(
                          '源代码作者为Kimi和ChatGPT，感谢二位开发者的付出。',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8), // 添加段落间距
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center, // 确保圆点和文字对齐
                    children: [
                      Icon(Icons.circle_notifications, size: 15), // 更小的圆点
                      const SizedBox(width: 8), // 圆点和文字之间的间距
                      Expanded(
                        child: Text(
                          '软件使用了Flutter框架和Dart语言。',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8), // 添加段落间距
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center, // 确保圆点和文字对齐
                    children: [
                      Icon(Icons.circle_notifications, size: 15), // 更小的圆点
                      const SizedBox(width: 8), // 圆点和文字之间的间距
                      Expanded(
                        child: Text(
                          '本地搜图功能借助了CloudflareWorker和R2存储桶。',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8), // 添加段落间距
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center, // 确保圆点和文字对齐
                    children: [
                      Icon(Icons.circle_notifications, size: 15), // 更小的圆点
                      const SizedBox(width: 8), // 圆点和文字之间的间距
                      Expanded(
                        child: Text(
                          '在线搜图功能灵感来源于搜图Bot酱。',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8), // 添加段落间距
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center, // 确保圆点和文字对齐
                    children: [
                      Icon(Icons.circle_notifications, size: 15), // 更小的圆点
                      const SizedBox(width: 8), // 圆点和文字之间的间距
                      Expanded(
                        child: Text(
                          'OCR功能来自google_mlkit_text_recognition。',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),

                ],
              )

            ],
          ),
        ),
      ),
    );
  }
}
