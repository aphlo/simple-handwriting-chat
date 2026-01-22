// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get settings => 'Settings';

  @override
  String get strokeColor => 'Stroke Color';

  @override
  String strokeWidth(String width) {
    return 'Stroke Width: $width';
  }

  @override
  String get undo => 'Undo';

  @override
  String get clear => 'Clear';

  @override
  String get menu => 'Menu';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get licenses => 'Licenses';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System Default';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageJapanese => 'Japanese';
}
