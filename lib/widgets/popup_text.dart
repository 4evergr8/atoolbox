import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void showTextPopup(BuildContext context, String initialText) {
  final theme = Theme.of(context);
  final List<String> tokens = initialText
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
            title: Text('详细信息', style: theme.textTheme.headlineSmall),
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
                            color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            token,
                            style: TextStyle(
                              color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface,
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('已复制选中的内容')),
                  );
                },
                icon: Icon(Icons.copy),
                label: Text('复制'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(Icons.check),
                label: Text('确定'),
              ),
            ],
          );
        },
      );
    },
  );
}