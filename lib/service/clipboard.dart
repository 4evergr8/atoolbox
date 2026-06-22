import 'package:flutter/services.dart';

Future<void> clipboard_copy(String text) async {
  await Clipboard.setData(ClipboardData(text: text));
}

Future<String> clipboard_paste() async {
  ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
  return data?.text ?? '';
}