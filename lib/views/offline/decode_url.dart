import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
        _decodedUrlControllers.add({'key': TextEditingController(text: key), 'value': TextEditingController(text: '=')});
        _decodedUrlControllers.add({'key': TextEditingController(text: value), 'value': TextEditingController(text: '&')});
      });
      // Remove the last '&' if it exists
      if (_decodedUrlControllers.isNotEmpty && _decodedUrlControllers.last['value']!.text == '&') {
        _decodedUrlControllers.last['value']!.text = '';
      }
      _isDecoded = true;
    });
  }

  void _copyToClipboard() {
    final List<String> parts = [];
    for (var controllerMap in _decodedUrlControllers) {
      parts.add(controllerMap['key']!.text);
      if (controllerMap['value']!.text.isNotEmpty) {
        parts.add(controllerMap['value']!.text);
      }
    }
    final editedUrl = parts.join('');
    Clipboard.setData(ClipboardData(text: editedUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('链接已复制到剪贴板')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('URL 解码与编辑', style: theme.textTheme.headlineMedium),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'URL 解码与编辑',
              style: theme.textTheme.headlineSmall,
            ),
            SizedBox(height: 20),
            _buildSettingCard(
              context,
              icon: Icons.link,
              title: '待解码链接',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _urlController,
                    decoration: InputDecoration(
                      labelText: '输入待解码链接',
                      hintText: '例如: ',
                    ),
                    maxLines: 1,
                    scrollPhysics: ClampingScrollPhysics(),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _decodeUrl,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.dns),
                        SizedBox(width: 8),
                        Text('解码'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
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
                          SizedBox(width: 8),
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
                            SizedBox(width: 8),
                            TextButton(
                              onPressed: () {}, // 按钮无反应
                              child: Text(_decodedUrlControllers[i + 1]['value']!.text),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _copyToClipboard,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.copy),
                  SizedBox(width: 8),
                  Text('复制链接'),
                ],
              ),
            ),
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 24),
                SizedBox(width: 16),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}