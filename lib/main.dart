import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart';
import 'l10n/app_localizations.dart';
import 'pages/mirror_drawing_page.dart';
import 'services/review_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await ReviewService().incrementAppLaunchCount();
  runApp(const SimpleHandwritingChatApp());
}

class SimpleHandwritingChatApp extends StatefulWidget {
  const SimpleHandwritingChatApp({super.key});

  static void setLocale(BuildContext context, Locale? locale) {
    final state = context
        .findAncestorStateOfType<_SimpleHandwritingChatAppState>();
    state?.setLocale(locale);
  }

  @override
  State<SimpleHandwritingChatApp> createState() =>
      _SimpleHandwritingChatAppState();
}

class _SimpleHandwritingChatAppState extends State<SimpleHandwritingChatApp> {
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(languagePreferenceKey);
    if (languageCode != null) {
      setState(() {
        _locale = Locale(languageCode);
      });
    }
  }

  Future<void> setLocale(Locale? locale) async {
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(languagePreferenceKey);
    } else {
      await prefs.setString(languagePreferenceKey, locale.languageCode);
    }
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Handwriting Chat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      locale: _locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const MirrorDrawingPage(),
    );
  }
}
