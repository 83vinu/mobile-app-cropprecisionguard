import 'package:crop_prediction_system/MySession.dart';
import 'package:crop_prediction_system/chatbot-modal.dart';
import 'package:crop_prediction_system/leaf_color_analysis.dart';
import 'package:crop_prediction_system/leaf_disease_detection_screen.dart';
import 'package:crop_prediction_system/main.dart';
import 'package:crop_prediction_system/profile_edit_screen.dart';
import 'package:crop_prediction_system/sign_up_screen.dart';
import 'package:crop_prediction_system/soil_report_screen.dart';
import 'package:crop_prediction_system/weather_report.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lottie/lottie.dart';

import 'login_with_otp.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? name;
  String? email;

  @override
  void initState() {
    super.initState();
    loadName();
  }

  void loadName() async {
    final name1 = await  MySession.instance().getSession('name');
    final email1 = await  MySession.instance().getSession('email');
    setState(() {
      name = name1;
      email = email1;
    });
  }

  void _openChatBot(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ChatBotModal(),
    );
  }

  @override
  Widget build(BuildContext context)  {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appTitle, style: TextStyle(color: Colors.white, fontSize: 13),),
        backgroundColor: const Color(0xFF4A6F3F),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFF4A6F3F),
              ),
              child: Text(
                AppLocalizations.of(context)!.appTitle,
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10), // uniform padding
              child: Text(
                name ?? "",
                style: const TextStyle(color: Colors.deepPurple, fontSize: 16),
              ),
            ),
    Padding(
    padding: EdgeInsets.all(10), // uniform padding
    child:
    Text(
              email ?? "",
              style: const TextStyle(color: Colors.blueAccent, fontSize: 14),
            )),

            ListTile(
              leading: const Icon(Icons.terrain),
              title: Text(AppLocalizations.of(context)!.soilHealth),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SoilReportScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.cloud),
              title: Text(AppLocalizations.of(context)!.weather),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WeatherScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.eco),
              title: Text(AppLocalizations.of(context)!.lccAnalysis),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LeafColorCodeAnalysisScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.healing),
              title: Text(AppLocalizations.of(context)!.leafDiseaseAnalysis),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LeafDiseaseDetectionScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(AppLocalizations.of(context)!.profile),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileEditScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: Text(AppLocalizations.of(context)!.logout),
              onTap: () {
                logout();
              },
            ),
          ],
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.asset(
            'assets/nature.jpg',
            fit: BoxFit.cover,
          ),
          Container(
            color: Colors.black.withOpacity(0.3),
          ),
          const SizedBox(height: 15),
          Text(AppLocalizations.of(context)!.appTitle,textAlign: TextAlign.center,   style: TextStyle(color: Colors.white),),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [

                _buildGridTile(context, Icons.terrain, AppLocalizations.of(context)!.soilHealth, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SoilReportScreen()),
                  );
                }),
                _buildGridTile(context, Icons.cloud, AppLocalizations.of(context)!.weather, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const WeatherScreen()),
                  );
                }),
                _buildGridTile(context, Icons.eco, AppLocalizations.of(context)!.lccAnalysis, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LeafColorCodeAnalysisScreen()),
                  );
                }),
                _buildGridTile(context, Icons.healing, AppLocalizations.of(context)!.leafDiseaseAnalysis, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LeafDiseaseDetectionScreen()),
                  );
                }),
                _buildGridTile(context, Icons.person, AppLocalizations.of(context)!.profile, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileEditScreen()),
                  );
                }),
                _buildGridTile(context, Icons.logout, AppLocalizations.of(context)!.logout, () {
                  logout();

                }),
              ],
            ),
          )
        ],
      ),
        floatingActionButton: GestureDetector(
  onTap: () => _openChatBot(context),
  child: SizedBox(
    height: 140, // adjust size as needed
    width: 140,
    child: Lottie.asset(
      'assets/bot.json',
      repeat: true,
      fit: BoxFit.contain,
    ),
  ),
),


    );
  }

  void logout ()  {
    MySession.instance().clearSession();

    Navigator.pushAndRemoveUntil(
      context,
        MaterialPageRoute(builder: (context) => LanguageSelectionScreen(setLocale: (Locale locale) {
          // Example of how you might handle changing the locale
          Locale myLocale = locale;
          // Update the app's locale here
        },)), // or OtpLoginScreen()
          (Route<dynamic> route) => false, // Remove all routes
    );
  }

  Widget _buildGridTile(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.yellow.withOpacity(0.85),
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Color(0xFF4A6F3F)),
            const SizedBox(height: 12),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
