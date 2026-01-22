import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';
import '../services/ad_service.dart';
import 'webview_page.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  String? _currentLanguage;
  NativeAd? _nativeAd;
  bool _isNativeAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentLanguage();
    _loadNativeAd();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  void _loadNativeAd() {
    _nativeAd = AdService().createNativeAd(
      onAdLoaded: (ad) {
        setState(() {
          _isNativeAdLoaded = true;
        });
      },
      onAdFailedToLoad: (ad, error) {
        debugPrint('Native ad failed to load: $error');
        ad.dispose();
      },
    );
    _nativeAd!.load();
  }

  Future<void> _loadCurrentLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentLanguage = prefs.getString(languagePreferenceKey);
    });
  }

  void _openWebView(BuildContext context, String title, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebViewPage(title: title, url: url),
      ),
    );
  }

  String _getLanguageDisplayName(AppLocalizations l10n, String? code) {
    switch (code) {
      case 'en':
        return l10n.languageEnglish;
      case 'ja':
        return l10n.languageJapanese;
      default:
        return l10n.languageSystem;
    }
  }

  void _showLanguageDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text(l10n.language),
          children: [
            _buildLanguageOption(l10n, null, l10n.languageSystem),
            _buildLanguageOption(l10n, 'en', l10n.languageEnglish),
            _buildLanguageOption(l10n, 'ja', l10n.languageJapanese),
          ],
        );
      },
    );
  }

  Widget _buildLanguageOption(
    AppLocalizations l10n,
    String? code,
    String label,
  ) {
    final isSelected = _currentLanguage == code;
    return SimpleDialogOption(
      onPressed: () {
        setState(() {
          _currentLanguage = code;
        });
        SimpleHandwritingChatApp.setLocale(
          context,
          code != null ? Locale(code) : null,
        );
        Navigator.pop(context);
      },
      child: Row(
        children: [
          Expanded(child: Text(label)),
          if (isSelected) const Icon(Icons.check, color: Colors.teal),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.menu)),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<PackageInfo>(
                future: PackageInfo.fromPlatform(),
                builder: (context, snapshot) {
                  final version = snapshot.hasData
                      ? '${snapshot.data!.version}+${snapshot.data!.buildNumber}'
                      : '';

                  return ListView(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.language),
                        title: Text(l10n.language),
                        subtitle: Text(
                          _getLanguageDisplayName(l10n, _currentLanguage),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: _showLanguageDialog,
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.description_outlined),
                        title: Text(l10n.termsOfService),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _openWebView(
                          context,
                          l10n.termsOfService,
                          termsOfServiceUrl,
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.privacy_tip_outlined),
                        title: Text(l10n.privacyPolicy),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _openWebView(
                          context,
                          l10n.privacyPolicy,
                          privacyPolicyUrl,
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.article_outlined),
                        title: Text(l10n.licenses),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          showLicensePage(
                            context: context,
                            applicationName: 'Simple Handwriting Chat',
                            applicationVersion: version,
                          );
                        },
                      ),
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          l10n.version(version),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            if (_isNativeAdLoaded && _nativeAd != null)
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: SizedBox(height: 300, child: AdWidget(ad: _nativeAd!)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
