import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

Future<String> identifyLanguage(String text) async {
  // 初始化语言识别器，置信度阈值固定为 0.5
  final languageIdentifier = LanguageIdentifier(confidenceThreshold: 0.5);

  // 获取所有可能的语言及其置信度
  final List<IdentifiedLanguage> possibleLanguages = await languageIdentifier.identifyPossibleLanguages(text);

  // 如果没有识别到任何语言，返回默认值 "en"
  if (possibleLanguages.isEmpty) {
    return "en";
  }

  // 找到置信度最高的语言
  IdentifiedLanguage highestConfidenceLanguage = possibleLanguages.reduce(
        (current, next) => current.confidence > next.confidence ? current : next,
  );

  // 释放资源
  languageIdentifier.close();

  // 返回置信度最高的语言代码
  return highestConfidenceLanguage.languageTag;
}



// 翻译函数，输入参数为源语言代码、目标语言代码和待翻译文本
Future<String> translateText(String sourceLanguageCode, String targetLanguageCode, String text) async {
  // 将语言代码映射到 TranslateLanguage 枚举值
  TranslateLanguage sourceLanguage = mapLanguageCodeToTranslateLanguage(sourceLanguageCode);
  TranslateLanguage targetLanguage = mapLanguageCodeToTranslateLanguage(targetLanguageCode);

  // 创建翻译器实例
  final onDeviceTranslator = OnDeviceTranslator(
    sourceLanguage: sourceLanguage,
    targetLanguage: targetLanguage,
  );

  try {
    // 确保语言模型已下载
    final modelManager = OnDeviceTranslatorModelManager();
    await modelManager.downloadModel(sourceLanguage.bcpCode);
    await modelManager.downloadModel(targetLanguage.bcpCode);

    // 执行翻译
    final String translatedText = await onDeviceTranslator.translateText(text);
    return translatedText;
  } finally {
    // 释放资源
    await onDeviceTranslator.close();
  }
}

// 映射函数，将 BCP-47 语言代码映射到 TranslateLanguage 枚举值
TranslateLanguage mapLanguageCodeToTranslateLanguage(String languageCode) {
  switch (languageCode) {
    case 'zh': return TranslateLanguage.chinese;
    case 'en': return TranslateLanguage.english;
    case 'ja': return TranslateLanguage.japanese;
    case 'ko': return TranslateLanguage.korean;
    case 'ru': return TranslateLanguage.russian;
    default: throw Exception('Unsupported language code: $languageCode');
  }
}

void main() async {
  try {
    // 调用翻译函数
    String translatedText = await translateText('zh', 'en', '你好，世界！');
    print('翻译结果: $translatedText');
  } catch (e) {
    print('发生错误: $e');
  }
}


void mmain() async {
  String text = "你好，世界！";
  String languageCode = await identifyLanguage(text);
  print('识别到的语言代码: $languageCode');
}

