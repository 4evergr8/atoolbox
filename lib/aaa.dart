import 'package:flutter/material.dart';
import 'package:charset_converter/charset_converter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CharsetListScreen(),
    );
  }
}

class CharsetListScreen extends StatefulWidget {
  @override
  _CharsetListScreenState createState() => _CharsetListScreenState();
}

class _CharsetListScreenState extends State<CharsetListScreen> {
  List<String> charsets = [];

  @override
  void initState() {
    super.initState();
    _loadCharsets();
  }

  // 异步加载可用字符集
  Future<void> _loadCharsets() async {
    List<String> availableCharsets = await CharsetConverter.availableCharsets();
    setState(() {
      charsets = availableCharsets;
      print(availableCharsets);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Available Charsets'),
      ),
      body: ListView.builder(
        itemCount: charsets.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(charsets[index]),
          );
        },
      ),
    );
  }
}
