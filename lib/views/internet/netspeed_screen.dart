import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

class SpeedTestScreen extends StatefulWidget {
  const SpeedTestScreen({super.key});

  @override
  _SpeedTestScreenState createState() => _SpeedTestScreenState();
}

class _SpeedTestScreenState extends State<SpeedTestScreen> {
  final TextEditingController _domesticUrlController = TextEditingController(text: 'http://updates-http.cdn-apple.com/2019WinterFCS/fullrestores/041-39257/32129B6C-292C-11E9-9E72-4511412B0A59/iPhone_4.7_12.1.4_16D57_Restore.ipsw');
  final TextEditingController _internationalUrlController = TextEditingController(text: 'https://dl.google.com/dl/android/aosp/comet-ad1a.240530.030-factory-77dca584.zip');

  double _domesticDownloadSpeed = 0.0;
  double _internationalDownloadSpeed = 0.0;
  bool _isDomesticTesting = false;
  bool _isInternationalTesting = false;
  StreamSubscription? _domesticSubscription;
  StreamSubscription? _internationalSubscription;

  void _startDomesticTest() async {
    setState(() {
      _isDomesticTesting = true;
      _domesticDownloadSpeed = 0.0;
    });

    final stopwatch = Stopwatch()..start();
    final request = http.Request('GET', Uri.parse(_domesticUrlController.text));
    final streamedResponse = await http.Client().send(request);

    int totalBytes = 0;
    _domesticSubscription = streamedResponse.stream.listen((List<int> bytes) {
      totalBytes += bytes.length;
      setState(() {
        _domesticDownloadSpeed = (totalBytes / (1024 * 1024)) / (stopwatch.elapsedMilliseconds / 1000);
      });
    }, onDone: () {
      setState(() {
        _isDomesticTesting = false;
      });
    });
  }

  void _stopDomesticTest() {
    setState(() {
      _isDomesticTesting = false;
      _domesticDownloadSpeed = 0.0;
    });
    _domesticSubscription?.cancel();
  }

  void _startInternationalTest() async {
    setState(() {
      _isInternationalTesting = true;
      _internationalDownloadSpeed = 0.0;
    });

    final stopwatch = Stopwatch()..start();
    final request = http.Request('GET', Uri.parse(_internationalUrlController.text));
    final streamedResponse = await http.Client().send(request);

    int totalBytes = 0;
    _internationalSubscription = streamedResponse.stream.listen((List<int> bytes) {
      totalBytes += bytes.length;
      setState(() {
        _internationalDownloadSpeed = (totalBytes / (1024 * 1024)) / (stopwatch.elapsedMilliseconds / 1000);
      });
    }, onDone: () {
      setState(() {
        _isInternationalTesting = false;
      });
    });
  }

  void _stopInternationalTest() {
    setState(() {
      _isInternationalTesting = false;
      _internationalDownloadSpeed = 0.0;
    });
    _internationalSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('网速测试', style: theme.textTheme.headlineMedium),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '网速测试',
              style: theme.textTheme.headlineSmall,
            ),
            SizedBox(height: 20),

            // 国内网络测试
            _buildSettingCard(
              context,
              icon: Icons.home,
              title: '国内网络测试',
              child: Column(
                children: [
                  TextField(
                    controller: _domesticUrlController,
                    decoration: InputDecoration(
                      labelText: '测试链接',
                      hintText: '国内网速测试链接',
                    ),
                  ),
                  SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: _isDomesticTesting ? null : _domesticDownloadSpeed / 100,
                  ),
                  SizedBox(height: 8),
                  Text(
                    '下载速度: ${_domesticDownloadSpeed.toStringAsFixed(2)} MB/s',
                    style: theme.textTheme.bodyMedium,
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _isDomesticTesting ? null : _startDomesticTest,
                        icon: Icon(Icons.download),
                        label: Text('开始测试'),
                      ),
                      ElevatedButton.icon(
                        onPressed: _isDomesticTesting ? _stopDomesticTest : null,
                        icon: Icon(Icons.stop),
                        label: Text('停止测试'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // 国际网络测试
            _buildSettingCard(
              context,
              icon: Icons.local_airport,
              title: '国际网络测试',
              child: Column(
                children: [
                  TextField(
                    controller: _internationalUrlController,
                    decoration: InputDecoration(
                      labelText: '测试链接',
                      hintText: '国际网速测试链接',
                    ),
                  ),
                  SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: _isInternationalTesting ? null : _internationalDownloadSpeed / 100,
                  ),
                  SizedBox(height: 8),
                  Text(
                    '下载速度: ${_internationalDownloadSpeed.toStringAsFixed(2)} MB/s',
                    style: theme.textTheme.bodyMedium,
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _isInternationalTesting ? null : _startInternationalTest,
                        icon: Icon(Icons.download),
                        label: Text('开始测试'),
                      ),
                      ElevatedButton.icon(
                        onPressed: _isInternationalTesting ? _stopInternationalTest : null,
                        icon: Icon(Icons.stop),
                        label: Text('停止测试'),
                      ),
                    ],
                  ),
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