import 'package:flutter/services.dart';

Future<void> clipboardCopy(String text) async {
  await Clipboard.setData(ClipboardData(text: text));
}

Future<String> clipboardPaste() async {
  ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
  return data?.text ?? '';
}