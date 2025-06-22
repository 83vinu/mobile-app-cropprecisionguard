import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crop_prediction_system/MySession.dart';
import 'package:crop_prediction_system/classes/user_profile.dart';
import 'package:crop_prediction_system/leaf_disease_detection_screen.dart';
import 'package:crop_prediction_system/soil_report_screen.dart';
import 'package:crop_prediction_system/weather_report.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  // Controllers for TextFormFields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();

  String name = "";
  String gender = "Male";
  String place = "";
  String email = "";
  String mobile = "";
  String pincode = "";
  String state = "";

  Future<void> loadProfile() async {
    final mobile = await  MySession.instance().getSession('mobile');
    print(mobile);
      try {
      // Check if the phone number exists in Firestore
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('mobile', isEqualTo: mobile)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {


        return;
      }
      final userData = snapshot.docs.first
          .data(); // This returns a Map<String, dynamic>
      final userId = snapshot.docs.first.id; // Firestore document ID

      print('User ID: $userId');
      print('User Name: ${userData['name']}');
      print('User Email: ${userData['email']}');

      _nameController.text = userData['name'];
      _placeController.text = userData['place'];
      _emailController.text = userData['email'];
      _mobileController.text = userData['mobile'];
      _pincodeController.text = userData['pincode'];
      _stateController.text = userData['state'];

    } catch (e) {


    }
  }

  Future<void> saveUserProfile(UserProfile user) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.mobile).set(user.toMap());
    } on FirebaseException catch (e) {
      print('Firebase error: ${e.message}');
    } catch (e) {
      print('Unexpected error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localization.edit_profile, style: TextStyle(color: Colors.white, fontSize: 13)),
        backgroundColor: Colors.green[700],
        elevation: 0,
      ),
      backgroundColor: Colors.grey[100],
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
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: Card(
                  color: Colors.white.withOpacity(0.65), // Opacity background
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Name Field
                          _buildTextField(
                            controller: _nameController,
                            label: localization.edit_profile_name,
                            onChanged: (val) => setState(() => name = val),
                          ),
                          const SizedBox(height: 15),

                          // Gender Dropdown
                          DropdownButtonFormField<String>(
                            value: gender,
                            decoration: _inputDecoration(localization.edit_profile_gender_other),
                            items: [
                              DropdownMenuItem(
                                value: "Male",
                                child: Text(localization.edit_profile_gender_male),
                              ),
                              DropdownMenuItem(
                                value: "Female",
                                child: Text(localization.edit_profile_gender_female),
                              ),
                              DropdownMenuItem(
                                value: "Other",
                                child: Text(localization.edit_profile_gender_other),
                              ),
                            ],
                            onChanged: (value) => setState(() => gender = value!),
                          ),
                          const SizedBox(height: 15),

                          // Place Field
                          _buildTextField(
                            controller: _placeController,
                            label: localization.edit_profile_place,
                            onChanged: (val) => setState(() => place = val),
                          ),
                          const SizedBox(height: 15),

                          // Email Field
                          _buildTextField(
                            controller: _emailController,
                            label: localization.edit_profile_email,
                            onChanged: (val) => setState(() => email = val),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 15),

                          // Mobile Field
                          _buildTextField(
                            controller: _mobileController,
                            label: localization.edit_profile_mobile,
                            onChanged: (val) => setState(() => mobile = val),
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 15),

                          // Pincode Field
                          _buildTextField(
                            controller: _pincodeController,
                            label: localization.edit_profile_pincode,
                            onChanged: (val) => setState(() => pincode = val),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 15),

                          // State Field
                          _buildTextField(
                            controller: _stateController,
                            label: localization.edit_profile_state,
                            onChanged: (val) => setState(() => state = val),
                          ),
                          const SizedBox(height: 30),

                          // Save Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.save, color: Colors.black),
                              label: Text(localization.edit_profile_save, style: TextStyle(color: Colors.black)),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                backgroundColor: Colors.yellow,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                textStyle: const TextStyle(fontSize: 16),
                              ),
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  final user = UserProfile(
                                    name: _nameController.text,
                                    gender: gender,
                                    place: _placeController.text,
                                    email: _emailController.text,
                                    mobile: _mobileController.text,
                                    pincode: _pincodeController.text ,
                                    state: _stateController.text,
                                  );
                                  saveUserProfile(user);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Profile Updated")),
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  // 🔹 Reusable Text Field Builder
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required void Function(String) onChanged,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      decoration: _inputDecoration(label),
      onChanged: onChanged,
      keyboardType: keyboardType,
      validator: (value) => (value == null || value.isEmpty) ? 'Required field' : null,
    );
  }

  // 🔹 Input Decoration
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey[200],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
