import 'package:crop_prediction_system/chatgpt-calls.dart';
import 'package:crop_prediction_system/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class SoilReportScreen extends StatefulWidget {
  const SoilReportScreen({super.key});

  @override
  _SoilReportScreenState createState() => _SoilReportScreenState();
}

class _SoilReportScreenState extends State<SoilReportScreen> {
  final TextEditingController _locationController = TextEditingController();
  String soilReport = '';
  bool loading = false;

  Future<void> fetchData() async {
    final locale = Localizations.localeOf(context).languageCode;
    setState(() {
      loading = true;
      soilReport = '';
    });

    try {
      final response = await predict_soil_health(_locationController.text, locale);
      print(response);
      setState(() {
        soilReport = response;
        loading = false;
      });
    } catch (e) {
      print('Exception: $e');
      setState(() {
        loading = false;
      });
    }
  }

  void fetchSoilReport(BuildContext context) {
    if (_locationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your location.")),
      );
      return;
    }
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.soil_report_title, style: TextStyle(color: Colors.white, fontSize: 13),),
        backgroundColor: Colors.green[700],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => {
            Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
            )
          }
        ),
      ),
      body: Stack(
        children: [
      Container(
      decoration: const BoxDecoration(
      image: DecorationImage(
          image: AssetImage("assets/page_bk.jpg"),
      fit: BoxFit.cover,
    ),
    ),
    ),
    SafeArea(
    child:
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // 🔸 Location Input
                TextField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                    labelText: AppLocalizations.of(context)!.soil_report_placeholder,
                    prefixIcon: const Icon(Icons.location_on),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 🔸 Fetch Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.search, color: Colors.black),
                    label: Text(AppLocalizations.of(context)!.soil_report_button, style: TextStyle(color: Colors.black)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: Colors.yellow,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => fetchSoilReport(context),
                  ),
                ),
                const SizedBox(height: 30),

                // 🔸 Report Card
                if (soilReport.isNotEmpty)
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: Colors.white.withOpacity(0.95),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.soil_report_title,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            soilReport,
                            style: const TextStyle(fontSize: 16, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  ),

                // 🔸 Loader
                if (loading)
                  Column(
                    children: [
                      const SizedBox(height: 20),
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context)!.soil_report_loader_text,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
