// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get welcome => '欢迎';

  @override
  String get welcome_full => '欢迎使用，点击下方按钮查看使用方法。';

  @override
  String get more => '了解更多';

  @override
  String get online => '在线';

  @override
  String get offline => '离线';

  @override
  String get about => '关于';

  @override
  String get cancel => '取消';

  @override
  String get link_options => '链接选项';

  @override
  String get can_not_open_link => '无法打开链接';

  @override
  String get link_copied => '链接已复制:';

  @override
  String get dismiss => '了解';

  @override
  String get detail_info => '详细信息';

  @override
  String get selected_copied => '已复制选中的内容';

  @override
  String get copy => '复制';

  @override
  String get conform => '确认';

  @override
  String get source_code => '软件源代码';

  @override
  String get from => '此软件来源于无聊时的瞎想';

  @override
  String get website => '搜图网站';

  @override
  String get need_connection => '需要联网';

  @override
  String get reverse => '反向搜图';

  @override
  String get find_sourse => '寻找图片的出处';

  @override
  String get artwork => '封面搜图';

  @override
  String get artwork_sourse => '寻找视频封面的出处，目前仅支持哔哩哔哩';

  @override
  String get backup => '视频备份';

  @override
  String get backup_video => '哔哩哔哩视频备份，无需登录';

  @override
  String get speedtest => '网速测试';

  @override
  String get test_down => '网络下载速度测试';

  @override
  String get dns => 'DNS 查询';

  @override
  String get dns_test => '加密DNS查询测试';

  @override
  String get ip => 'IP反查域名';

  @override
  String get ip_reverse => 'DoHPTR查询测试';

  @override
  String get note1 => '软件使用了Flutter框架和Dart语言。';

  @override
  String get note2 => '本地搜图功能借助了CloudflareWorker和R2存储桶。';

  @override
  String get note3 => '在线搜图功能灵感来源于搜图Bot酱。';

  @override
  String get note4 => 'OCR功能来自google_mlkit_text_recognition。';

  @override
  String get note5 => '兽音译者功能来自CATT-L/MeowTranslator';

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
}
