import 'package:atoolbox/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/views/internet_page.dart';
import '/views/intranet_page.dart';
import '/service/share_handler.dart';
import '/views/about_page.dart'; // 引用处理分享的逻辑
import 'package:atoolbox/l10n/app_localizations.dart';


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
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.cloud),
            label: AppLocalizations.of(context)!.online,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.cloud_off),
            label: AppLocalizations.of(context)!.offline,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.perm_identity),
            label: AppLocalizations.of(context)!.about,
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


Future<VoidCallback> showLoadingDialogGlobal() async {
  final overlay = navigatorKey.currentState?.overlay;
  if (overlay == null) return () {};

  late OverlayEntry overlayEntry;
  overlayEntry = OverlayEntry(
    builder: (_) => Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Material(
        color: Colors.transparent,
        child: LinearProgressIndicator(
          minHeight: 4,
          backgroundColor: Theme.of(navigatorKey.currentContext!).colorScheme.primaryContainer,
        ),
      ),
    ),
  );

  overlay.insert(overlayEntry);
  return () => overlayEntry.remove();
}
void showErrorSnackBarGlobal(String message) {
  final ctx = navigatorKey.currentContext;
  if (ctx == null) return;

  ScaffoldMessenger.of(ctx).showSnackBar(
    SnackBar(
      content: GestureDetector(
        onTap: () {
          Clipboard.setData(ClipboardData(text: message));
        },
        child: Text(message),
      ),
    ),
  );
}