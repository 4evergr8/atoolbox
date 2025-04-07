import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../service/internet/image_search.dart';
import '/widgets/popup_links.dart';
import '/widgets/popup_infinity.dart';

class ImageSearchScreen extends StatefulWidget {
  const ImageSearchScreen({super.key});

  @override
  _ImageSearchScreenState createState() => _ImageSearchScreenState();
}

class _ImageSearchScreenState extends State<ImageSearchScreen> {
  bool _isLocalImage = true; // 默认为搜索本地图片文件
  String _imageUrl = 'https://picsum.photos/200/200?random=1'; // 默认图片链接
  File? _imageFile; // 用于存储选择的本地图片文件
  bool _isImageSelected = false; // 标记是否选择了图片
  String _workerUrl = 'https://image.4evergr8.workers.dev'; // 默认 Worker 链接

  // 提升 TextEditingController 到类级别
  late TextEditingController _imageUrlController;
  late TextEditingController _workerUrlController;

  @override
  void initState() {
    super.initState();
    // 初始化控制器
    _imageUrlController = TextEditingController(text: _imageUrl);
    _workerUrlController = TextEditingController(text: _workerUrl);
  }

  @override
  void dispose() {
    // 释放控制器
    _imageUrlController.dispose();
    _workerUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('图片搜索', style: theme.textTheme.headlineMedium),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView( // 使用 SingleChildScrollView 包裹整个内容
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '图片搜索',
              style: theme.textTheme.headlineSmall,
            ),
            SizedBox(height: 20),
            _buildSettingCard(
              context,
              icon: Icons.cloud,
              title: '搜索方式',
              child: SwitchListTile(
                value: _isLocalImage,
                onChanged: (value) {
                  setState(() {
                    _isLocalImage = value;
                    _isImageSelected = false; // 重置图片选择状态
                    _imageFile = null; // 清空已选择的图片
                  });
                },
                title: Text(_isLocalImage ? '搜索本地图片' : '搜索图片链接'),
                subtitle: Text(_isLocalImage
                    ? '从本地选择图片进行搜索'
                    : '输入图片链接进行搜索'),
              ),
            ),
            SizedBox(height: 16),
            _buildSettingCard(
              context,
              icon: Icons.link,
              title: 'Worker 链接',
              child: TextField(
                controller: _workerUrlController,
                onChanged: (value) => setState(() => _workerUrl = value),
                decoration: InputDecoration(
                  labelText: 'Worker URL',
                ),
              ),
            ),
            if (_isLocalImage) ...[
              if (!_isImageSelected)
                _buildSettingCard(
                  context,
                  icon: Icons.image,
                  title: '选择图片',
                  child: ElevatedButton(
                    onPressed: () async {
                      final picker = ImagePicker();
                      final pickedFile = await picker.pickImage(
                        source: ImageSource.gallery,
                      );
                      if (pickedFile != null) {
                        setState(() {
                          _imageFile = File(pickedFile.path);
                          _isImageSelected = true; // 标记图片已选择
                        });
                      }
                    },
                    child: Text('选择图片'),
                  ),
                ),
              if (_isImageSelected)
                _buildSettingCard(
                  context,
                  icon: Icons.image,
                  title: '已选择图片',
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Image.file(
                        _imageFile!,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            _isImageSelected = false; // 重置图片选择状态
                            _imageFile = null; // 清空已选择的图片
                          });
                        },
                      ),
                    ],
                  ),
                ),
            ] else ...[
              _buildSettingCard(
                context,
                icon: Icons.link,
                title: '图片链接',
                child: TextField(
                  controller: _imageUrlController,
                  onChanged: (value) => setState(() => _imageUrl = value),
                  decoration: InputDecoration(
                    labelText: 'Image URL',
                  ),
                ),
              ),
            ],
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_isLocalImage) {
                  if (_imageFile != null) {
                    try {
                      DialogUtils.showLoadingDialog(
                        context: context,
                        title: '上传中...',
                        content: '请稍候，正在上传图片...',
                      );
                      final imageUrl = await searchLocalImage(_imageFile!, _workerUrl);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('图片上传成功，URL: $imageUrl')),
                      );
                      final result = generateReverseImageSearchUrls(imageUrl);
                      Navigator.of(context).pop();

                      showLinkButtonsPopup(context, result);


                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('出现错误: ${e.toString()}')),
                      );
                    }
                  } else {
                    // 提示用户选择图片
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('请选择一张图片')),
                    );
                  }
                } else {
                  try {
                    final result = generateReverseImageSearchUrls(_imageUrl);
                    showLinkButtonsPopup(context, result);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('出现错误: ${e.toString()}')),
                    );
                  }
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min, // 使内容紧凑
                children: [
                  Icon(Icons.search), // 添加搜索图标
                  SizedBox(width: 8), // 图标和文本之间的间距
                  Text('搜索'), // 按钮文本
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