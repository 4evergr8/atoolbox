import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:picorigin/l10n/app_localizations.dart';
import 'package:picorigin/main.dart';
import 'package:picorigin/service/share_handler.dart';
import 'package:picorigin/views/about.dart';
import 'package:picorigin/views/offline.dart';
import 'package:picorigin/views/online.dart';
import 'package:url_launcher/url_launcher.dart';

VoidCallback showSnackBarGlobal(String type, String text) {
  final messenger = scaffoldMessengerKey.currentState;
  if (messenger == null) return () {};

  final context = messenger.context;

  if (type == "load") {
    messenger.showSnackBar(
      SnackBar(
        duration: const Duration(hours: 1),
        content: Row(
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(text)),
          ],
        ),
      ),
    );
  } else if (type == "success") {
    messenger.showSnackBar(
      SnackBar(
        content: GestureDetector(
          onTap: () {
            Clipboard.setData(ClipboardData(text: text));
          },
          child: Row(
            children: [
              Icon(Icons.check_circle, size: 16, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 3),
              Expanded(child: Text(text)),
            ],
          ),
        ),
      ),
    );
  } else {
    messenger.showSnackBar(
      SnackBar(
        content: GestureDetector(
          onTap: () {
            Clipboard.setData(ClipboardData(text: text));
          },
          child: Row(
            children: [
              Icon(Icons.error, size: 16, color: Theme.of(context).colorScheme.error),
              const SizedBox(width: 8),
              Expanded(child: Text(text)),
            ],
          ),
        ),
      ),
    );
  }

  return () {
    scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
  };
}


// 弹窗函数
void showLinkButtonsPopup(BuildContext context, List<List<String>> links) {
  final theme = Theme.of(context);

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(AppLocalizations.of(context)!.link_options, style: theme.textTheme.headlineSmall),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.6, // 弹窗宽度占屏幕宽度的 60%
            maxHeight: MediaQuery.of(context).size.height * 0.35, // 弹窗高度占屏幕高度的 50%
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // 确保内容尽可能紧凑
            children: [
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // 确保按钮紧凑
                    children:
                        links.map((link) {
                          return ElevatedButton(
                            onPressed: () async {
                              // 打开链接
                              final uri = Uri.parse(link[1]);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri, mode: LaunchMode.externalApplication);
                              } else {
                                showSnackBarGlobal(
                                  "fail",
                                  '${AppLocalizations.of(context)!.can_not_open_link} ${link[1]}',
                                );
                              }
                            },

                            child: Text(link[0]),
                          );
                        }).toList(),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop(); // 关闭弹窗
                    },
                    icon: Icon(Icons.check), // 添加确认图标
                    label: Text(AppLocalizations.of(context)!.dismiss),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  BottomNavBarState createState() => BottomNavBarState();
}

class BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[InternetPage(), IntranetPage(), AboutPage()];

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
          BottomNavigationBarItem(icon: const Icon(Icons.cloud), label: AppLocalizations.of(context)!.online),
          BottomNavigationBarItem(icon: const Icon(Icons.cloud_off), label: AppLocalizations.of(context)!.offline),
          BottomNavigationBarItem(icon: const Icon(Icons.perm_identity), label: AppLocalizations.of(context)!.about),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: theme.colorScheme.secondary,
        // 使用主题中的颜色
        unselectedItemColor: theme.colorScheme.onSurface,
        // 使用主题中的未选中颜色
        backgroundColor: theme.colorScheme.surface,
        // 使用主题中的背景颜色
        onTap: _onItemTapped,
      ),
    );
  }
}

void showTextPopup(BuildContext context, String initialText) {
  final theme = Theme.of(context);
  final List<String> tokens =
      initialText
          .replaceAll('\n', ' \n ') // 保留换行符作为单独的 token
          .split(RegExp(r'\s+')) // 按空格和换行拆分
          .where((element) => element.isNotEmpty)
          .toList();

  final Set<int> selectedIndices = {};

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          bool isSelecting = false;

          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.detail_info, style: theme.textTheme.headlineSmall),
            content: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.6,
                maxHeight: MediaQuery.of(context).size.height * 0.35,
              ),
              child: GestureDetector(
                onPanStart: (_) => isSelecting = true,
                onPanEnd: (_) => isSelecting = false,
                onPanCancel: () => isSelecting = false,
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: List.generate(tokens.length, (index) {
                      String token = tokens[index];
                      if (token == '\n') {
                        return SizedBox(width: double.infinity); // 换行
                      }

                      bool isSelected = selectedIndices.contains(index);

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              selectedIndices.remove(index);
                            } else {
                              selectedIndices.add(index);
                            }
                          });
                        },
                        onPanUpdate: (details) {
                          RenderBox renderBox = context.findRenderObject() as RenderBox;
                          Offset localPosition = renderBox.globalToLocal(details.globalPosition);

                          for (int i = 0; i < tokens.length; i++) {
                            final key = GlobalObjectKey(i);
                            final box = key.currentContext?.findRenderObject() as RenderBox?;
                            if (box != null) {
                              final offset = box.localToGlobal(Offset.zero);
                              final size = box.size;
                              final rect = offset & size;
                              if (rect.contains(details.globalPosition)) {
                                setState(() {
                                  selectedIndices.add(i);
                                });
                                break;
                              }
                            }
                          }
                        },
                        child: Container(
                          key: GlobalObjectKey(index),
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            token,
                            style: TextStyle(
                              color:
                                  isSelected
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
            actions: [
              ElevatedButton.icon(
                onPressed: () {
                  final selectedText = selectedIndices
                      .map((i) => tokens[i])
                      .join(' ')
                      .replaceAll(' \n ', '\n'); // 恢复换行
                  Clipboard.setData(ClipboardData(text: selectedText));
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.selected_copied)));
                },
                icon: Icon(Icons.copy),
                label: Text(AppLocalizations.of(context)!.copy),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(Icons.check),
                label: Text(AppLocalizations.of(context)!.conform),
              ),
            ],
          );
        },
      );
    },
  );
}
