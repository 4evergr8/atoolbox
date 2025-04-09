import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("Regex Input Example")),
        body: RegexInputForm(),
      ),
    );
  }
}

class RegexInputForm extends StatefulWidget {
  @override
  _RegexInputFormState createState() => _RegexInputFormState();
}

class _RegexInputFormState extends State<RegexInputForm> {
  final TextEditingController includeController = TextEditingController(
    text: r'[\x00-\x1F\x80-\x9F\u003F\u00A0-\u00FF\u0370-\u03FF\u1A00-\u1A1F\u2000-\u2BFF\u2200-\u22FF\u2580-\u259F\uE000-\uF8FF\uF900-\uFAFF\uFFFD\u3400-\u4DBF]',
  );

  final TextEditingController excludeController = TextEditingController(
    text: r'[\u0020]', // 默认排除空格 U+0020
  );

  final TextEditingController inputController = TextEditingController();
  String resultMessage = '';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: includeController,
            decoration: InputDecoration(
              labelText: 'Include Regex Pattern',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 12),
          TextField(
            controller: excludeController,
            decoration: InputDecoration(
              labelText: 'Exclude Regex Pattern',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 12),
          TextField(
            controller: inputController,
            decoration: InputDecoration(
              labelText: 'Text to Analyze',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _calculateScore,
            child: Text("Calculate Garbled Score"),
          ),
          SizedBox(height: 16),
          Text(
            resultMessage,
            style: TextStyle(fontSize: 16, color: Colors.blue),
          ),
        ],
      ),
    );
  }

  void _calculateScore() {
    final input = inputController.text;
    final includePatternText = includeController.text;
    final excludePatternText = excludeController.text;

    try {
      final includePattern = RegExp(includePatternText);
      final excludePattern = RegExp(excludePatternText);

      int score = 0;
      for (var char in input.split('')) {
        if (excludePattern.hasMatch(char)) continue;
        if (includePattern.hasMatch(char)) score++;
      }

      setState(() {
        resultMessage = "Garbled character count: $score";
      });
    } catch (e) {
      setState(() {
        resultMessage = "Invalid regex pattern!";
      });
    }
  }
}
