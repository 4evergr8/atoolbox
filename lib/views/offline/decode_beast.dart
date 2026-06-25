import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:picorigin/l10n/app_localizations.dart';
import 'package:picorigin/service/decode.dart';
import 'package:picorigin/widget.dart';

class BeastEncodeDecode extends StatefulWidget {
  const BeastEncodeDecode({super.key});

  @override
  _BeastEncodeDecodeState createState() => _BeastEncodeDecodeState();
}

class _BeastEncodeDecodeState extends State<BeastEncodeDecode> {
  final TextEditingController _cipherController = TextEditingController(text: ''); // 密文
  final TextEditingController _plainController = TextEditingController(text: ''); // 明文
  final TextEditingController _dictController = TextEditingController(text: ''); // 字典

  // 加密并复制
  void _encryptAndCopy() async {
    String dict = _dictController.text;
    String plain = _plainController.text;


    try {
      String cipher = await encodeBeast(dict, plain);
      _cipherController.text = cipher;
      await Clipboard.setData(ClipboardData(text: cipher));
      showSnackBarGlobal("success",AppLocalizations.of(context)!.copied);
    } catch (e) {
      showSnackBarGlobal("error", '$e');
    }
  }

  // 解密并复制
  void _decryptAndCopy() async {
    String cipher = _cipherController.text;
    String dict = _dictController.text;

    try {
      String plain = await decodeBeast(cipher, dict);
      _plainController.text = plain;
      await Clipboard.setData(ClipboardData(text: plain));
      showSnackBarGlobal("success", AppLocalizations.of(context)!.copied);
    } catch (e) {
      showSnackBarGlobal("error", '$e');
    }
  }

  // 粘贴到密文输入框
  void _pasteToCipher() async {
    String text = (await Clipboard.getData(Clipboard.kTextPlain))?.text ?? '';
    if (text.isNotEmpty) {
      _cipherController.text = text;
    }
  }

  // 粘贴到明文输入框
  void _pasteToPlain() async {
    String text = (await Clipboard.getData(Clipboard.kTextPlain))?.text ?? '';
    if (text.isNotEmpty) {
      _plainController.text = text;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.beast, style: theme.textTheme.headlineMedium),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 字典输入
            _buildSettingCard(
              context,
              icon: Icons.view_array,
              title:AppLocalizations.of(context)!. dict,
              child: TextField(
                controller: _dictController,
                decoration:  InputDecoration(labelText: AppLocalizations.of(context)!.dict_enter),
                maxLength: 4,
              ),
            ),
            const SizedBox(height: 20),

            // 密文输入
            _buildSettingCard(
              context,
              icon: Icons.password,
              title: AppLocalizations.of(context)!.decode,
              child: TextField(
                controller: _cipherController,
                decoration:  InputDecoration(labelText: AppLocalizations.of(context)!.decode_enter),
                maxLines: null,
                minLines: 3,
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _decryptAndCopy,
                  icon: const Icon(Icons.content_copy),
                  label: Text(AppLocalizations.of(context)!.decode_copy),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _pasteToCipher,
                  icon: const Icon(Icons.assignment_returned),
                  label: Text(AppLocalizations.of(context)!.paste),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 明文输入
            _buildSettingCard(
              context,
              icon: Icons.text_fields,
              title: AppLocalizations.of(context)!.encode,
              child: TextField(
                controller: _plainController,
                decoration:  InputDecoration(labelText: AppLocalizations.of(context)!.encode_enter),
                maxLines: null,
                minLines: 3,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _encryptAndCopy,
                  icon: const Icon(Icons.content_copy),
                  label: Text(AppLocalizations.of(context)!.encode_copy),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _pasteToPlain,
                  icon: const Icon(Icons.assignment_returned),
                  label: Text(AppLocalizations.of(context)!.paste),
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
