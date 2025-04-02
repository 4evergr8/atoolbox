import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class FileBrowserPage extends StatefulWidget {
  const FileBrowserPage({super.key});

  @override
  _FileBrowserPageState createState() => _FileBrowserPageState();
}

class _FileBrowserPageState extends State<FileBrowserPage> {
  late Directory historyDir;
  List<FileSystemEntity> _folders = [];

  @override
  void initState() {
    super.initState();
    _loadHistoryDirectory();
  }

  Future<void> _loadHistoryDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    historyDir = Directory(p.join(appDir.path, 'history'));
    if (!await historyDir.exists()) {
      await historyDir.create(recursive: true);
    }
    _folders = historyDir.listSync().whereType<Directory>().toList();
    setState(() {});
  }

  Future<void> _deleteAllFolders() async {
    if (_folders.isNotEmpty) {
      // 显示确认对话框
      final confirmed = await _showDeleteConfirmationDialog(_folders.length);
      if (confirmed) {
        for (final folder in _folders) {
          await folder.delete(recursive: true);
        }
        _loadHistoryDirectory(); // 重新加载文件夹列表
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('没有需要删除的文件夹')),
      );
    }
  }

  Future<bool> _showDeleteConfirmationDialog(int folderCount) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('确认删除'),
          content: Text('您确定要删除 $folderCount 个文件夹吗？'),
          actions: [
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context, false),
              icon: Icon(Icons.cancel), // 添加复制图标
              label: Text('取消'),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context, true),
              icon: Icon(Icons.check), // 添加复制图标
              label: Text('确定'),
            ),
          ],
        );
      },
    ) ?? false;
  }

  Widget _buildFolderTree(Directory folder) {
    return ExpansionTile(
      initiallyExpanded: false,
      title: Text(p.basename(folder.path)),
      children: [
        FutureBuilder<List<FileSystemEntity>>(
          future: _getFolderContents(folder),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              return Column(
                children: snapshot.data!
                    .map((entity) => _buildFileOrFolder(entity, isNested: true))
                    .toList(),
              );
            }
          },
        ),
      ],
    );
  }

  Future<List<FileSystemEntity>> _getFolderContents(Directory folder) async {
    return folder.listSync();
  }

  Widget _buildFileOrFolder(FileSystemEntity entity, {bool isNested = false}) {
    if (entity is Directory) {
      return _buildFolderTree(entity);
    } else if (entity is File) {
      return ListTile(
        title: Text(p.basename(entity.path)),
        onTap: () async {
          await OpenFile.open(entity.path);
        },
        contentPadding: EdgeInsets.only(
          left: isNested ? 40.0 : 16.0, // 对嵌套文件增加缩进
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('历史记录', style: theme.textTheme.headlineMedium),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'History',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _deleteAllFolders,
                  icon: Icon(Icons.delete), // 添加复制图标
                  label: Text('删除所有'),
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _folders.length,
                itemBuilder: (context, index) {
                  return _buildFolderTree(_folders[index] as Directory);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}