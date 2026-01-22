// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get settings => '設定';

  @override
  String get strokeColor => '線の色';

  @override
  String strokeWidth(String width) {
    return '線の太さ: $width';
  }

  @override
  String get undo => '元に戻す';

  @override
  String get clear => 'クリア';

  @override
  String get menu => 'メニュー';

  @override
  String get termsOfService => '利用規約';

  @override
  String get privacyPolicy => 'プライバシーポリシー';

  @override
  String get licenses => 'ライセンス';

  @override
  String version(String version) {
    return 'バージョン $version';
  }
}
