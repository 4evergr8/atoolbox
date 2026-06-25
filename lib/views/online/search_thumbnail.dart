import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:picorigin/l10n/app_localizations.dart';
import 'package:picorigin/service/image_search.dart';
import 'package:picorigin/widget.dart';

class ThumbnailSearchScreen extends StatefulWidget {
  const ThumbnailSearchScreen({super.key});

  @override
  ThumbnailSearchScreenState createState() => ThumbnailSearchScreenState();
}

class ThumbnailSearchScreenState extends State<ThumbnailSearchScreen> {
  String _searchKeyword = 'BV1GJ411x7h7'; // 默认搜索关键词
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    // 初始化控制器
    _searchController = TextEditingController(text: _searchKeyword);
  }

  @override
  void dispose() {
    // 释放控制器
    _searchController.dispose();
    super.dispose();
  }

  // 从剪贴板粘贴
  void _pasteFromClipboard() async {
    String text = (await Clipboard.getData(Clipboard.kTextPlain))?.text ?? '';
    if (text.isNotEmpty) {
      setState(() {
        _searchController.text = text;
        _searchKeyword = text;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.image_thumbnail, style: theme.textTheme.headlineMedium),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        // 使用 SingleChildScrollView 包裹整个内容
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSettingCard(
              context,
              icon: Icons.link,
              title: AppLocalizations.of(context)!.image_thumbnail,
              child: TextField(
                controller: _searchController, // 使用类级别的控制器
                onChanged: (value) => setState(() => _searchKeyword = value),
                decoration:  InputDecoration(labelText: AppLocalizations.of(context)!.image_thumbnail_text),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    final bvid = await extractBvid(_searchKeyword);
                    final picUrl = await fetchBilibiliCover(bvid);
                    final results = generateUrls(picUrl);
                    showLinkButtonsPopup(context, results);
                  },
                  icon: const Icon(Icons.search), // 添加搜索图标
                  label:  Text(AppLocalizations.of(context)!.search), // 按钮文本
                ),
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
    );
  }

  Widget _buildSettingCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Card(
      elevation: 4, // 添加阴影
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // 圆角
      ),
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
