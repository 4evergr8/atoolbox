// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get welcome => 'Welcome';

  @override
  String get welcome_full => 'Welcome, tap the button below to view instructions.';

  @override
  String get more => 'Learn more';

  @override
  String get online => 'Online';

  @override
  String get offline => 'Offline';

  @override
  String get about => 'About';

  @override
  String get cancel => 'Cancel';

  @override
  String get link_options => 'Link options';

  @override
  String get can_not_open_link => 'Unable to open link';

  @override
  String get link_copied => 'Link copied:';

  @override
  String get dismiss => 'Got it';

  @override
  String get detail_info => 'Details';

  @override
  String get selected_copied => 'Selected content copied';

  @override
  String get copy => 'Copy';

  @override
  String get conform => 'Confirm';

  @override
  String get source_code => 'Source code';

  @override
  String get from => 'This app was created from a random idea during boredom';

  @override
  String get website => 'Image search website';

  @override
  String get need_connection => 'Internet required';

  @override
  String get reverse => 'Reverse image search';

  @override
  String get find_sourse => 'Find image source';

  @override
  String get artwork => 'Cover image search';

  @override
  String get artwork_sourse => 'Find video cover source, currently only supports Bilibili';

  @override
  String get backup => 'Video backup';

  @override
  String get backup_video => 'Bilibili video backup, no login required';

  @override
  String get speedtest => 'Network speed test';

  @override
  String get test_down => 'Download speed test';

  @override
  String get dns => 'DNS query';

  @override
  String get dns_test => 'Encrypted DNS query test';

  @override
  String get ip => 'IP to domain lookup';

  @override
  String get ip_reverse => 'DoH PTR query test';

  @override
  String get note1 => 'The app is built using Flutter and Dart.';

  @override
  String get note2 => 'Local image search uses Cloudflare Workers and R2 storage bucket.';

  @override
  String get note3 => 'Online image search is inspired by the SauceNAO bot.';

  @override
  String get note4 => 'OCR functionality is based on google_mlkit_text_recognition.';

  @override
  String get note5 => 'Animal language translator comes from CATT-L/MeowTranslator';

  @override
  String get ocr_fail => 'OCR识别失败';

  @override
  String get share_process => '分享内容处理';

  @override
  String get get_text => '接收到的文本';

  @override
  String get downloading => '下载中...';

  @override
  String get downloading_vid => '请稍候，正在备份视频...';

  @override
  String get uploading => '上传中...';

  @override
  String get uploading_pic => '请稍候，正在上传图片...';

  @override
  String get upload_success => '图片上传成功，URL: ';

  @override
  String get upload_fail => '图片上传失败:';

  @override
  String get ocr_zh => '中文字符提取';

  @override
  String get ocr_en => '拉丁字符提取';

  @override
  String get ocr_ja => '日文字符提取';

  @override
  String get qr_code => '二维码扫描';

  @override
  String get choose_pic => '选择图片';

  @override
  String get scanning => '扫描中...';

  @override
  String get waiting => '请稍候...';

  @override
  String get success_video => '视频备份完成';
}
