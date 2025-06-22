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

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LeafDiseaseDetectionScreen extends StatefulWidget {
  const LeafDiseaseDetectionScreen({super.key});

  @override
  _LeafDiseaseDetectionScreenState createState() => _LeafDiseaseDetectionScreenState();
}

class _LeafDiseaseDetectionScreenState extends State<LeafDiseaseDetectionScreen> {
  File? _image;
  final picker = ImagePicker();
  String? base64Image;
  Uint8List? imageBytes;
  bool loading = false;
  String diseaseReport = '';

  Future<void> pickImage(BuildContext context, ImageSource source) async {
    if (kIsWeb) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        imageBytes = result.files.single.bytes;
        base64Image = base64Encode(imageBytes!);
        callLeafImageAnalysis();
      }
    } else {
      final XFile? pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        File file = File(pickedFile.path);
        _image = file;
        imageBytes = await file.readAsBytes();
        base64Image = base64Encode(imageBytes!);
        callLeafImageAnalysis();
      }
    }


  }

  Future<void> callLeafImageAnalysis() async {
    setState(() {
      loading = true;
      diseaseReport = '';
    });

    try {
      final locale = Localizations.localeOf(context).languageCode;
      final response = await predict_with_chatgpt(base64Image!, locale);
      setState(() {
        diseaseReport = response;
        loading = false;
      });
    } catch (e) {
      print('Exception: $e');
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


  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(t.leaf_disease_title, style: TextStyle(color: Colors.white, fontSize: 13),),
        backgroundColor: Colors.green[800]?.withOpacity(0.8),
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // 🌿 Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/page_bk.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 🧊 Foreground Content
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
                    label: Text(
                      t.leaf_disease_upload_image,
                      style: const TextStyle(color: Colors.black),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow, // 🌟 Yellow background
                      minimumSize: const Size(double.infinity, 50),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),

                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          t.leaf_disease_sub_title,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        if (diseaseReport.isNotEmpty)
                          Text(
                            diseaseReport,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            textAlign: TextAlign.justify,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  if (loading)
                    Column(
                      children: [
                        const CircularProgressIndicator(strokeWidth: 4, color: Colors.green),
                        const SizedBox(height: 16),
                        Text(
                          t.leaf_disease_loader_text,
                          style: const TextStyle(fontSize: 16, color: Colors.black),
                        ),
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