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

  @override
  String get language => '言語';

  @override
  String get languageSystem => 'システム設定';

  @override
  String get languageEnglish => '英語';

  @override
  String get languageJapanese => '日本語';

  @override
  String get removeAds => '広告を削除';

  @override
  String get removeAdsPurchased => '広告削除済み';

  @override
  String get restorePurchases => '購入を復元';

  @override
  String get purchaseSuccess => '購入が完了しました！広告が非表示になります。';

  @override
  String get purchaseFailed => '購入に失敗しました。もう一度お試しください。';

  @override
  String get restoreSuccess => '購入の復元が完了しました！';

  @override
  String get restoreNoPurchases => '過去の購入が見つかりませんでした。';
}
