import 'package:crop_prediction_system/MySession.dart';
import 'package:crop_prediction_system/firebase_options.dart';
import 'package:crop_prediction_system/home_screen.dart';
import 'package:crop_prediction_system/login_with_otp.dart';
import 'package:crop_prediction_system/onboarding_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const CropPredictionSystemApp());
}

class CropPredictionSystemApp extends StatefulWidget {
  const CropPredictionSystemApp({super.key});

  @override
  State<CropPredictionSystemApp> createState() => _CropPredictionSystemAppState();
}

class _CropPredictionSystemAppState extends State<CropPredictionSystemApp> {
  Locale _locale = const Locale('en', '');

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Crop Prediction System',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFF6D8E4E),
      ),
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ta', ''),
        Locale('en', ''),
        Locale('hi', ''),
      ],
      home: LanguageSelectionScreen(setLocale: setLocale),
    );
  }
}

class LanguageSelectionScreen extends StatefulWidget {
  final Function(Locale) setLocale;
  const LanguageSelectionScreen({super.key, required this.setLocale});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/language_selection.jpg',
            fit: BoxFit.cover,
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo in the center
                Image.asset(
                  'assets/logo.png',
                  height: 250,
                ),
                const SizedBox(height: 40),
                _languageButton(context, 'தமிழ்', const Locale('ta')),
                _languageButton(context, 'English', const Locale('en')),
                _languageButton(context, 'हिंदी', const Locale('hi')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _languageButton(BuildContext context, String language, Locale locale) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () async {
          widget.setLocale(locale);

          final name = await MySession.instance().getSession('name');
          final email = await MySession.instance().getSession('email');

          final prefs = await SharedPreferences.getInstance();
final onboardingDone = prefs.getBool('onboarding_complete') ?? false;

if (!onboardingDone) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => OnboardingScreen(
        navigateToNext: () {
          final route = (name != null && email != null && name.isNotEmpty && email.isNotEmpty)
              ? const HomeScreen()
              : const OtpLoginScreen();
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => route));
        }, languageCode: '',
      ),
    ),
  );
} else {
  final route = (name != null && email != null && name.isNotEmpty && email.isNotEmpty)
      ? const HomeScreen()
      : const OtpLoginScreen();
  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => route));
}

        },
        child: Container(
          width: 380,
          padding: const EdgeInsets.symmetric(vertical: 15),
          margin: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color.fromARGB(255, 12, 112, 34), Color.fromARGB(255, 158, 149, 29)], // Darker green gradient
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              language,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
