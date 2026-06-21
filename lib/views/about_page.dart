import 'package:atoolbox/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.about, style: Theme.of(context).textTheme.headlineMedium),
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
                backgroundImage: const AssetImage('assets/aaa.png'),
              ),
              const SizedBox(height: 20),

              Text(
                'PicOrigin',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 10),
              // 开发者简介
              Text(
                AppLocalizations.of(context)!.from,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),



              ListTile(
                leading: const Icon(Icons.code),
                title: Text(AppLocalizations.of(context)!.source_code),
                subtitle: const Text('Github'),
                onTap: () {
                  launchUrl(
                    Uri.parse('https://github.com/4evergr8/FlutterPicOrigin'),
                    mode: LaunchMode.externalApplication,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.web),
                title: Text(AppLocalizations.of(context)!.website),
                subtitle: const Text('Blogger'),
                onTap: () {
                  launchUrl(
                    Uri.parse('https://fourevergreight.blogspot.com/p/image.html'),
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
                          AppLocalizations.of(context)!.note1,
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
                          AppLocalizations.of(context)!.note2,
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
                          AppLocalizations.of(context)!.note3,
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
                          AppLocalizations.of(context)!.note4,
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
                          AppLocalizations.of(context)!.note5,
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
