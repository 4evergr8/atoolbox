import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';
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
    // 设置状态栏为透明
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    final brightness = View.of(context).platformDispatcher.platformBrightness;

    // 创建自定义的主题
    TextTheme textTheme = createTextTheme(context, "Noto Sans", "Noto Sans");
    MaterialTheme theme = MaterialTheme(textTheme);

    return MaterialApp(
      title: '一个工具箱',
      theme: brightness == Brightness.light ? theme.light() : theme.dark(),
      home: BottomNavBar(), // 使用底部导航栏组件
    );
  }
}