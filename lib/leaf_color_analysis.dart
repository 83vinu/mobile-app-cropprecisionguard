import 'package:crop_prediction_system/chatgpt-calls.dart';
import 'package:crop_prediction_system/soil_report_screen.dart';
import 'package:crop_prediction_system/weather_report.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

  class LeafColorCodeAnalysisScreen extends StatefulWidget {
    const LeafColorCodeAnalysisScreen({super.key});

    @override
    State<LeafColorCodeAnalysisScreen> createState() => _LeafColorCodeAnalysisScreenState();
  }

  class _LeafColorCodeAnalysisScreenState extends State<LeafColorCodeAnalysisScreen> {
    File? _image;
    final picker = ImagePicker();
    Uint8List? imageBytes;
    String? base64Image;
    bool loading = false;
    String? matchedColorHex;
    String? colorName;
    String? healthStatus;
    String? description;

    final List<Map<String, String>> colorChart = [
      {"name": "Dark Green", "hex": "#006400"},
      {"name": "Healthy Green", "hex": "#228B22"},
      {"name": "Light Green", "hex": "#7CFC00"},
      {"name": "Yellowish Green", "hex": "#A4C639"},
      {"name": "Yellow", "hex": "#FFFF00"},
      {"name": "Brown", "hex": "#8B4513"},
    ];

    Future<void> pickImage(BuildContext context, ImageSource source) async {
      if (kIsWeb) {
        FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
        if (result != null && result.files.single.bytes != null) {
          imageBytes = result.files.single.bytes;
          base64Image = base64Encode(imageBytes!);
          callColourImage();
        }
      } else {
        final XFile? pickedFile = await picker.pickImage(source: source);
        if (pickedFile != null) {
          _image = File(pickedFile.path);
          imageBytes = await _image!.readAsBytes();
          base64Image = base64Encode(imageBytes!);
          callColourImage();
        }
      }


    }

    Future<void> callColourImage() async {
      setState(() {
        loading = true;
      });

      try {
        // Mock API response

        final locale = Localizations.localeOf(context).languageCode;
        final response = await get_image_colorcode_with_chatgpt(base64Image!, locale);
        print(response);
        final mockResponse = json.decode(extractJsonString(response).toString());
        print(mockResponse);
        /*
        final mockResponse = {
          "dominant_color": "#A4C639",
          "color_name": "Yellowish Green",
          "health_status": "Mild nitrogen deficiency",
          "description": "The leaf appears slightly yellowish, indicating a possible lack of nitrogen."
        };*/

        setState(() {
          matchedColorHex = mockResponse['dominant_color'];
          colorName = mockResponse['color_name'];
          healthStatus = mockResponse['health_status'];
          description = mockResponse['description'];
          loading = false;
        });
      } catch (e) {
        print("Error: $e");
        setState(() => loading = false);
      }
    }

    void showImageSourceDialog(BuildContext context) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Select Image Source"),
          actions: [
            TextButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text("Camera"),
              onPressed: () {
                Navigator.of(context).pop();
                pickImage(context, ImageSource.camera);
              },
            ),
            TextButton.icon(
              icon: const Icon(Icons.photo),
              label: const Text("Gallery"),
              onPressed: () {
                Navigator.of(context).pop();
                pickImage(context, ImageSource.gallery);
              },
            ),
          ],
        ),
      );
    }

    String? extractJsonString(String input) {
      final regex = RegExp(r'\{.*\}', dotAll: true); // Matches first JSON object
      final match = regex.firstMatch(input);

      if (match != null) {
        return match.group(0);
      }
      return "";
    }

    Widget buildColorChart(String? matchedHex) {
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: colorChart.map((color) {
          bool isMatch = color['hex']!.toLowerCase() == matchedHex?.toLowerCase();
          return Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: HexColor.fromHex(color['hex']!),
                  border: isMatch ? Border.all(color: Colors.red, width: 4) : Border.all(color: Colors.grey, width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 4),
              Text(color['name']!, style: const TextStyle(fontSize: 12)),
            ],
          );
        }).toList(),
      );
    }

    Widget buildColorSummary() {
      final localization = AppLocalizations.of(context)!;
      if (colorName == null) return Container();
      return Card(
        margin: const EdgeInsets.only(top: 30),
        color: Colors.white.withOpacity(0.9),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${localization.lcc_detected_color} $colorName", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("${localization.lcc_health_status}: $healthStatus", style: const TextStyle(fontSize: 15)),
              const SizedBox(height: 8),
              Text(description ?? '', style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
      );
    }

    @override
    Widget build(BuildContext context) {
      final localization = AppLocalizations.of(context)!;
      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(localization.lcc_title, style: TextStyle(color: Colors.white, fontSize: 13),),
          backgroundColor: Colors.green[800]?.withOpacity(0.8),
          centerTitle: true,
          elevation: 0,
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: imageBytes != null
                          ? Card(
                        color: Colors.white.withOpacity(0.85),
                        elevation: 5,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(imageBytes!, height: 200, fit: BoxFit.cover),
                        ),
                      )
                          : Icon(Icons.image, size: 100, color: Colors.grey[300]),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () => showImageSourceDialog(context),
                      icon: const Icon(Icons.upload_file, color: Colors.black),
                      label: Text(localization.lcc_upload_image, style: TextStyle(color: Colors.black)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow,
                        minimumSize: const Size(double.infinity, 50),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 30),
                    buildColorChart(matchedColorHex),
                    buildColorSummary(),
                    const SizedBox(height: 30),
                    if (loading)
                      Column(
                        children:  [
                          CircularProgressIndicator(strokeWidth: 4, color: Colors.green),
                          SizedBox(height: 16),
                          Text(localization.lcc_loader_text, style: TextStyle(fontSize: 16, color: Colors.black)),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  class HexColor extends Color {
    HexColor(final int hex) : super(hex);

    static Color fromHex(String hexString) {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    }
  }