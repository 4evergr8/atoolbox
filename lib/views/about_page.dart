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
                leading: const Icon(Icons.video_camera_front),
                title: const Text('哔哩哔哩'),
                subtitle: const Text('可以给UP投个币吗🪙'),
                onTap: () {
                  launchUrl(
                    Uri.parse('https://space.bilibili.com/3546816836537000'),
                    mode: LaunchMode.externalApplication,
                  );
                },
              ),

              ListTile(
                leading: const Icon(Icons.code),
                title: const Text('Github'),
                subtitle: const Text('软件源代码'),
                onTap: () {
                  launchUrl(
                    Uri.parse('https://github.com/4evergr8/atoolbox'),
                    mode: LaunchMode.externalApplication,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.music_note),
                title: const Text('音乐分享'),
                subtitle: const Text('我爱听的歌'),
                onTap: () {
                  launchUrl(
                    Uri.parse('https://github.com/4evergr8/Music'),
                    mode: LaunchMode.externalApplication,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.web),
                title: const Text('GithubPages'),
                subtitle: const Text('个人网页'),
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
                  Text(
                    '   源代码作者为KimiAI和ChatGPT，感谢二位开发者的付出。',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8), // 添加段落间距
                  Text(
                    '   此软件使用IntelliJ IDEA作为编译器。',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8), // 添加段落间距
                  Text(
                    '   GithubCopilot插件彻底干亖了Cursor，免费，还有三种模式。',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8), // 添加段落间距
                  Text(
                    '   软件使用了Flutter框架和Dart语言。',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8), // 添加段落间距
                  Text(
                    '   本地搜图功能借助了CloudflareWorker和R2存储桶。',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8), // 添加段落间距
                  Text(
                    '   在线搜图功能灵感来源于搜图Bot酱。',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8), // 添加段落间距
                  Text(
                    '   OCR功能来自google_mlkit_text_recognition。',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8), // 添加段落间距
                  Text(
                    '   语言检测功能来自google_mlkit_language_id。',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8), // 添加段落间距
                  Text(
                    '   离线翻译功能来自google_mlkit_translation。',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8), // 添加段落间距
                  Text(
                    '   软件内图标来自GoogleMaterialIcon。',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8), // 添加段落间距
                  Text(
                    '   软件图标和我的头像均使用GoogleEmojiKitchen制作。',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
