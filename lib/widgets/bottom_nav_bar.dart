import 'package:flutter/material.dart';
import '/views/internet_page.dart';
import '/views/intranet_page.dart';
import '/service/share_handler.dart';
import '/views/about_page.dart'; // 引用处理分享的逻辑


class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    InternetPage(),
    IntranetPage(),
    AboutPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    // 初始化分享内容的接收
    ShareHandlerService().initPlatformState(context);
  }

  @override
  Widget build(BuildContext context) {
    // 获取当前主题
    final theme = Theme.of(context);

    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.cloud),
            label: '在线',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.network_check),
            label: '离线',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: '关于',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: theme.colorScheme.secondary, // 使用主题中的颜色
        unselectedItemColor: theme.colorScheme.onSurface, // 使用主题中的未选中颜色
        backgroundColor: theme.colorScheme.surface, // 使用主题中的背景颜色
        onTap: _onItemTapped,
      ),
    );
  }
}

