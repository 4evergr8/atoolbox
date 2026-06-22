import 'package:flutter/material.dart';
import 'package:picorigin/service/clipboard.dart';
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
    String text = await clipboard_paste();
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
        title: Text('视频封面搜图', style: theme.textTheme.headlineMedium),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        // 使用 SingleChildScrollView 包裹整个内容
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('寻找封面出处', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 20),
            _buildSettingCard(
              context,
              icon: Icons.link,
              title: '视频封面搜图',
              child: TextField(
                controller: _searchController, // 使用类级别的控制器
                onChanged: (value) => setState(() => _searchKeyword = value),
                decoration: const InputDecoration(labelText: '支持视频链接、BV号、b23短链'),
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
                  label: const Text('搜索'), // 按钮文本
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _pasteFromClipboard,
                  icon: const Icon(Icons.assignment_returned),
                  label: const Text('粘贴'),
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
