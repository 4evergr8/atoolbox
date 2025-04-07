import 'package:flutter/material.dart';
import '/service/internet/thumbnail_search.dart';
import '/widgets/popup_links.dart';


class ThumbnailSearchScreen extends StatefulWidget {
  const ThumbnailSearchScreen({super.key});

  @override
  _ThumbnailSearchScreenState createState() => _ThumbnailSearchScreenState();
}

class _ThumbnailSearchScreenState extends State<ThumbnailSearchScreen> {
  String _searchKeyword = 'https://b23.tv/pigt3PQ'; // 默认搜索关键词
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('视频封面搜图', style: theme.textTheme.headlineMedium),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView( // 使用 SingleChildScrollView 包裹整个内容
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '寻找封面出处',
              style: theme.textTheme.headlineSmall,
            ),
            SizedBox(height: 20),
            _buildSettingCard(
              context,
              icon: Icons.link,
              title: '视频封面搜图',
              child: TextField(
                controller: _searchController, // 使用类级别的控制器
                onChanged: (value) => setState(() => _searchKeyword = value),
                decoration: InputDecoration(
                  labelText: '支持视频链接、BV号、b23短链',
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // 触发异步搜索函数
                final result = await extractAndSearchUrls(_searchKeyword);
                showLinkButtonsPopup(context,result);

              },
              child: Row(
                mainAxisSize: MainAxisSize.min, // 使内容紧凑
                children: [
                  Icon(Icons.search), // 添加搜索图标
                  SizedBox(width: 8), // 图标和文本之间的间距
                  Text('搜索'), // 按钮文本
                ],
              ),
            )
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