import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'widgets/bottom_nav_bar.dart';
import 'themes/util.dart';
import 'themes/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = View.of(context).platformDispatcher.platformBrightness;

    // 创建自定义的主题
    TextTheme textTheme = createTextTheme(context, "Noto Sans", "Noto Sans");
    MaterialTheme theme = MaterialTheme(textTheme);

    return MaterialApp(
      title: '一个工具箱',
      theme: brightness == Brightness.light ? theme.light() : theme.dark(),
      home: const HomeScreen(), // 使用 HomeScreen 组件
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

    if (isFirstLaunch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showFirstLaunchDialog();
      });
      await prefs.setBool('isFirstLaunch', false);
    }
  }

  void _showFirstLaunchDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // 禁止点击外部关闭
      builder: (context) {
        return AlertDialog(
          title: const Text('欢迎'),
          content: const Text('欢迎使用，点击下方按钮查看使用方法。'),
          actions: [
            ElevatedButton.icon(
              onPressed: () async {
                final uri = Uri.parse('https://github.com/4evergr8/atoolbox');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('https://github.com/4evergr8/atoolbox')),
                  );
                }
                Navigator.of(context).pop(); // 关闭弹窗
              },
              icon: Icon(Icons.web),
              label: Text('了解更多'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavBar(); // 仅显示底部导航栏
  }
}