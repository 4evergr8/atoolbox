import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:picorigin/l10n/app_localizations.dart';
import 'package:picorigin/widget.dart';

class URLDecode extends StatefulWidget {
  const URLDecode({super.key});

  @override
  _URLDecodeScreenState createState() => _URLDecodeScreenState();
}

class _URLDecodeScreenState extends State<URLDecode> {
  final TextEditingController _urlController = TextEditingController();
  List<Map<String, TextEditingController>> _decodedUrlControllers = [];
  bool _isDecoded = false;

  @override
  void dispose() {
    _urlController.dispose();
    for (var controllerMap in _decodedUrlControllers) {
      for (var controller in controllerMap.values) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  void _decodeUrl() {
    final url = _urlController.text;
    final uri = Uri.parse(url);
    final queryParams = uri.queryParameters;

    setState(() {
      _decodedUrlControllers = [
        {'key': TextEditingController(text: uri.scheme), 'value': TextEditingController(text: '://')},
        {'key': TextEditingController(text: uri.host), 'value': TextEditingController(text: '?')},
      ];
      queryParams.forEach((key, value) {
        _decodedUrlControllers.add({
          'key': TextEditingController(text: key),
          'value': TextEditingController(text: '='),
        });
        _decodedUrlControllers.add({
          'key': TextEditingController(text: value),
          'value': TextEditingController(text: '&'),
        });
      });
      // Remove the last '&' if it exists
      if (_decodedUrlControllers.isNotEmpty && _decodedUrlControllers.last['value']!.text == '&') {
        _decodedUrlControllers.last['value']!.text = '';
      }
      _isDecoded = true;
    });
  }

  void _copyToClipboard() async {
    final List<String> parts = [];
    for (var controllerMap in _decodedUrlControllers) {
      parts.add(controllerMap['key']!.text);
      if (controllerMap['value']!.text.isNotEmpty) {
        parts.add(controllerMap['value']!.text);
      }
    }
    final editedUrl = parts.join('');
    await Clipboard.setData(ClipboardData(text: editedUrl));
    showSnackBarGlobal('success', AppLocalizations.of(context)!.copied);
  }

  // 从剪贴板粘贴到输入框
  void _pasteFromClipboard() async {
    String text = (await Clipboard.getData(Clipboard.kTextPlain))?.text ?? '';
    if (text.isNotEmpty) {
      _urlController.text = text;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('URL', style: theme.textTheme.headlineMedium),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSettingCard(
              context,
              icon: Icons.link,
              title: AppLocalizations.of(context)!.decode,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _urlController,
                    decoration:  InputDecoration(labelText: AppLocalizations.of(context)!.decode_enter),
                    maxLines: 1,
                    scrollPhysics: const ClampingScrollPhysics(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton.icon(onPressed: _decodeUrl, icon: const Icon(Icons.link), label:  Text(AppLocalizations.of(context)!.decode)),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _pasteFromClipboard,
                        icon: const Icon(Icons.assignment_returned),
                        label:  Text(AppLocalizations.of(context)!.paste),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (_isDecoded)
              for (int i = 0; i < _decodedUrlControllers.length; i += 2)
                _buildSettingCard(
                  context,
                  icon: Icons.edit,
                  title: _decodedUrlControllers[i]['key']!.text,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _decodedUrlControllers[i]['key'],
                              onChanged: (value) {
                                setState(() {
                                  _decodedUrlControllers[i]['key']!.text = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () {}, // 按钮无反应
                            child: Text(_decodedUrlControllers[i]['value']!.text),
                          ),
                        ],
                      ),
                      if (i + 1 < _decodedUrlControllers.length)
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _decodedUrlControllers[i + 1]['key'],
                                onChanged: (value) {
                                  setState(() {
                                    _decodedUrlControllers[i + 1]['key']!.text = value;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: () {}, // 按钮无反应
                              child: Text(_decodedUrlControllers[i + 1]['value']!.text),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
            const SizedBox(height: 20),
            ElevatedButton.icon(onPressed: _copyToClipboard, icon: const Icon(Icons.copy), label:  Text(AppLocalizations.of(context)!.copy)),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 24),
                const SizedBox(width: 16),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
