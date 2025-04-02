import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'widgets/bottom_nav_bar.dart';
import 'util.dart'; // 假设 util.dart 包含 createTextTheme 函数
import 'theme.dart'; // 假设 theme.dart 包含 MaterialTheme 类

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
  bool _isFirstLaunch = false;

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

    if (isFirstLaunch) {
      setState(() {
        _isFirstLaunch = true;
      });
      await prefs.setBool('isFirstLaunch', false);
    }
  }

  void _launchURL() async {
    const url = 'https://example.com';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BottomNavBar(), // 使用底部导航栏组件
        if (_isFirstLaunch)
          _buildFirstLaunchDialog(),
      ],
    );
  }

  Widget _buildFirstLaunchDialog() {
    return AlertDialog(
      title: const Text('欢迎'),
      content: const Text('感谢您使用我们的应用！点击下方按钮以了解更多信息。'),
      actions: [
        TextButton(
          onPressed: () {
            _launchURL();
            setState(() {
              _isFirstLaunch = false;
            });
          },
          child: const Text('了解更多'),
        ),
      ],
    );
  }
}
