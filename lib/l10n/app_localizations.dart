import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en'), Locale('zh')];

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @welcome_full.
  ///
  /// In en, this message translates to:
  /// **'Welcome, tap the button below to see instructions.'**
  String get welcome_full;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'Learn more'**
  String get more;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @link_options.
  ///
  /// In en, this message translates to:
  /// **'Link options'**
  String get link_options;

  /// No description provided for @can_not_open_link.
  ///
  /// In en, this message translates to:
  /// **'Unable to open link'**
  String get can_not_open_link;

  /// No description provided for @link_copied.
  ///
  /// In en, this message translates to:
  /// **'Link copied:'**
  String get link_copied;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get dismiss;

  /// No description provided for @detail_info.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get detail_info;

  /// No description provided for @selected_copied.
  ///
  /// In en, this message translates to:
  /// **'Selected content copied'**
  String get selected_copied;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @conform.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get conform;

  /// No description provided for @source_code.
  ///
  /// In en, this message translates to:
  /// **'Source code'**
  String get source_code;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'This software originated from a random idea during boredom'**
  String get from;

  /// No description provided for @website.
  ///
  /// In en, this message translates to:
  /// **'Image search website'**
  String get website;

  /// No description provided for @need_connection.
  ///
  /// In en, this message translates to:
  /// **'Internet connection required'**
  String get need_connection;

  /// No description provided for @reverse.
  ///
  /// In en, this message translates to:
  /// **'Reverse image search'**
  String get reverse;

  /// No description provided for @find_sourse.
  ///
  /// In en, this message translates to:
  /// **'Find image source'**
  String get find_sourse;

  /// No description provided for @artwork.
  ///
  /// In en, this message translates to:
  /// **'Cover image search'**
  String get artwork;

  /// No description provided for @artwork_sourse.
  ///
  /// In en, this message translates to:
  /// **'Find video cover source, currently only supports Bilibili'**
  String get artwork_sourse;

  /// No description provided for @backup.
  ///
  /// In en, this message translates to:
  /// **'Video backup'**
  String get backup;

  /// No description provided for @backup_video.
  ///
  /// In en, this message translates to:
  /// **'Bilibili video backup, no login required'**
  String get backup_video;

  /// No description provided for @speedtest.
  ///
  /// In en, this message translates to:
  /// **'Network speed test'**
  String get speedtest;

  /// No description provided for @test_down.
  ///
  /// In en, this message translates to:
  /// **'Download speed test'**
  String get test_down;

  /// No description provided for @dns.
  ///
  /// In en, this message translates to:
  /// **'DNS query'**
  String get dns;

  /// No description provided for @dns_test.
  ///
  /// In en, this message translates to:
  /// **'Encrypted DNS query test'**
  String get dns_test;

  /// No description provided for @ip.
  ///
  /// In en, this message translates to:
  /// **'IP reverse lookup domain'**
  String get ip;

  /// No description provided for @ip_reverse.
  ///
  /// In en, this message translates to:
  /// **'DoHPTR query test'**
  String get ip_reverse;

  /// No description provided for @note1.
  ///
  /// In en, this message translates to:
  /// **'The app uses Flutter framework and Dart language.'**
  String get note1;

  /// No description provided for @note2.
  ///
  /// In en, this message translates to:
  /// **'Local image search uses Cloudflare Worker and R2 storage bucket.'**
  String get note2;

  /// No description provided for @note3.
  ///
  /// In en, this message translates to:
  /// **'Online image search is inspired by Search Bot Chan.'**
  String get note3;

  /// No description provided for @note4.
  ///
  /// In en, this message translates to:
  /// **'OCR functionality uses google_mlkit_text_recognition.'**
  String get note4;

  /// No description provided for @note5.
  ///
  /// In en, this message translates to:
  /// **'Beast language translator is based on CATT-L/MeowTranslator'**
  String get note5;

  /// No description provided for @ocr_fail.
  ///
  /// In en, this message translates to:
  /// **'OCR recognition failed'**
  String get ocr_fail;

  /// No description provided for @share_process.
  ///
  /// In en, this message translates to:
  /// **'Processing shared content'**
  String get share_process;

  /// No description provided for @get_text.
  ///
  /// In en, this message translates to:
  /// **'Received text'**
  String get get_text;

  /// No description provided for @downloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading...'**
  String get downloading;

  /// No description provided for @downloading_vid.
  ///
  /// In en, this message translates to:
  /// **'Please wait, backing up video...'**
  String get downloading_vid;

  /// No description provided for @uploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading...'**
  String get uploading;

  /// No description provided for @uploading_pic.
  ///
  /// In en, this message translates to:
  /// **'Please wait, uploading image...'**
  String get uploading_pic;

  /// No description provided for @upload_success.
  ///
  /// In en, this message translates to:
  /// **'Image uploaded successfully, URL: '**
  String get upload_success;

  /// No description provided for @upload_fail.
  ///
  /// In en, this message translates to:
  /// **'Image upload failed:'**
  String get upload_fail;

  /// No description provided for @ocr_zh.
  ///
  /// In en, this message translates to:
  /// **'Chinese character extraction'**
  String get ocr_zh;

  /// No description provided for @ocr_en.
  ///
  /// In en, this message translates to:
  /// **'Latin character extraction'**
  String get ocr_en;

  /// No description provided for @ocr_ja.
  ///
  /// In en, this message translates to:
  /// **'Japanese character extraction'**
  String get ocr_ja;

  /// No description provided for @qr_code.
  ///
  /// In en, this message translates to:
  /// **'QR code scan'**
  String get qr_code;

  /// No description provided for @choose_pic.
  ///
  /// In en, this message translates to:
  /// **'Select image'**
  String get choose_pic;

  /// No description provided for @waiting.
  ///
  /// In en, this message translates to:
  /// **'Please wait...'**
  String get waiting;

  /// No description provided for @success_video.
  ///
  /// In en, this message translates to:
  /// **'Video backup completed'**
  String get success_video;

  /// No description provided for @decode.
  ///
  /// In en, this message translates to:
  /// **'Decode'**
  String get decode;

  /// No description provided for @decode_enter.
  ///
  /// In en, this message translates to:
  /// **'Enter content to decode'**
  String get decode_enter;

  /// No description provided for @decode_copy.
  ///
  /// In en, this message translates to:
  /// **'Decode and copy'**
  String get decode_copy;

  /// No description provided for @encode_copy.
  ///
  /// In en, this message translates to:
  /// **'Encode and copy'**
  String get encode_copy;

  /// No description provided for @paste.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get paste;

  /// No description provided for @encode.
  ///
  /// In en, this message translates to:
  /// **'Encode'**
  String get encode;

  /// No description provided for @dict.
  ///
  /// In en, this message translates to:
  /// **'Dictionary'**
  String get dict;

  /// No description provided for @dict_enter.
  ///
  /// In en, this message translates to:
  /// **'Please enter dictionary'**
  String get dict_enter;

  /// No description provided for @encode_enter.
  ///
  /// In en, this message translates to:
  /// **'Enter content to encode'**
  String get encode_enter;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copied;

  /// No description provided for @beast.
  ///
  /// In en, this message translates to:
  /// **'Beast translator'**
  String get beast;

  /// No description provided for @ocr_offline.
  ///
  /// In en, this message translates to:
  /// **'Offline OCR'**
  String get ocr_offline;

  /// No description provided for @choose_char.
  ///
  /// In en, this message translates to:
  /// **'Select recognition characters'**
  String get choose_char;

  /// No description provided for @char_chinese.
  ///
  /// In en, this message translates to:
  /// **'Chinese characters'**
  String get char_chinese;

  /// No description provided for @char_lartin.
  ///
  /// In en, this message translates to:
  /// **'Latin characters'**
  String get char_lartin;

  /// No description provided for @char_japanese.
  ///
  /// In en, this message translates to:
  /// **'Japanese characters'**
  String get char_japanese;

  /// No description provided for @image_search.
  ///
  /// In en, this message translates to:
  /// **'Image search'**
  String get image_search;

  /// No description provided for @image_search_method.
  ///
  /// In en, this message translates to:
  /// **'Search method'**
  String get image_search_method;

  /// No description provided for @image_local.
  ///
  /// In en, this message translates to:
  /// **'Local image'**
  String get image_local;

  /// No description provided for @image_local_text.
  ///
  /// In en, this message translates to:
  /// **'Select image from local device for search'**
  String get image_local_text;

  /// No description provided for @image_link.
  ///
  /// In en, this message translates to:
  /// **'Image link'**
  String get image_link;

  /// No description provided for @image_link_text.
  ///
  /// In en, this message translates to:
  /// **'Enter image URL for search'**
  String get image_link_text;

  /// No description provided for @worker_link.
  ///
  /// In en, this message translates to:
  /// **'Image hosting link'**
  String get worker_link;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @image_thumbnail.
  ///
  /// In en, this message translates to:
  /// **'Video cover search'**
  String get image_thumbnail;

  /// No description provided for @image_thumbnail_text.
  ///
  /// In en, this message translates to:
  /// **'Supports video links, BV ID, and b23 short links'**
  String get image_thumbnail_text;

  /// No description provided for @video_backup.
  ///
  /// In en, this message translates to:
  /// **'Bilibili video backup'**
  String get video_backup;

  /// No description provided for @ua_string.
  ///
  /// In en, this message translates to:
  /// **'User-Agent string'**
  String get ua_string;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
