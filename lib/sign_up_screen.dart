import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crop_prediction_system/classes/user_profile.dart';
import 'package:crop_prediction_system/leaf_disease_detection_screen.dart';
import 'package:crop_prediction_system/login_with_otp.dart';
import 'package:crop_prediction_system/soil_report_screen.dart';
import 'package:crop_prediction_system/weather_report.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SignupScreen extends StatefulWidget {

  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  String name = "";
  String gender = "Male";
  String place = "";
  String email = "";
  String mobile = "";
  String pincode = "";
  String state = "";

  Future<bool> isMobileAlreadyRegistered(String mobile) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(mobile).get();
    return doc.exists;
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
    // localization.signup
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign Up", style: const TextStyle(color: Colors.white, fontSize: 13)),
        backgroundColor: Colors.green[700],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>  {
            Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => OtpLoginScreen()),
            )
          }
        ),
      ),
      backgroundColor: Colors.grey[100],
      body: Stack(children: [
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
                color: Colors.white.withOpacity(0.65),
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildTextField(
                          label: localization.edit_profile_name,
                          onChanged: (val) => setState(() => name = val),
                        ),
                        const SizedBox(height: 15),
                        DropdownButtonFormField<String>(
                          value: gender,
                          decoration: _inputDecoration(localization.edit_profile_gender_other),
                          items: [
                            DropdownMenuItem(value: "Male", child: Text(localization.edit_profile_gender_male)),
                            DropdownMenuItem(value: "Female", child: Text(localization.edit_profile_gender_female)),
                            DropdownMenuItem(value: "Other", child: Text(localization.edit_profile_gender_other)),
                          ],
                          onChanged: (value) => setState(() => gender = value!),
                        ),
                        const SizedBox(height: 15),
                        _buildTextField(
                          label: localization.edit_profile_place,
                          onChanged: (val) => setState(() => place = val),
                        ),
                        const SizedBox(height: 15),
                        _buildTextField(
                          label: localization.edit_profile_email,
                          onChanged: (val) => setState(() => email = val),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 15),
                        _buildTextField(
                          label: localization.edit_profile_mobile,
                          onChanged: (val) => setState(() => mobile = val),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required field';
                            } else if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                              return 'Enter a valid 10-digit mobile number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),
                        _buildTextField(
                          label: localization.edit_profile_pincode,
                          onChanged: (val) => setState(() => pincode = val),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 15),
                        _buildTextField(
                          label: localization.edit_profile_state,
                          onChanged: (val) => setState(() => state = val),
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.person_add, color: Colors.black),
                            label: Text("sign up", style: const TextStyle(color: Colors.black)),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: Colors.yellow,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              textStyle: const TextStyle(fontSize: 16),
                            ),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                print("form validated.");

                                if (!RegExp(r'^\d{10}$').hasMatch(mobile)) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Enter a valid 10-digit mobile number")),
                                  );
                                  return;
                                }

                                bool emailExists = await isMobileAlreadyRegistered(mobile);


                                print("email id exists $emailExists.");
                                if (emailExists) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Mobile number already registered")),
                                  );
                                  return;
                                }

                                final user = UserProfile(
                                  name: name,
                                  gender: gender,
                                  place: place,
                                  email: email,
                                  mobile: mobile,
                                  pincode: pincode,
                                  state: state,
                                );

                                await saveUserProfile(user);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Signup Successful")),
                                );
                                // Optional: Navigate to next screen
                              }else {
                                print("form not validated.");
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
        ),
      ]),
    );
  }

  Widget _buildTextField({
    required String label,
    required void Function(String) onChanged,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      decoration: _inputDecoration(label),
      onChanged: onChanged,
      keyboardType: keyboardType,
      validator: (value) => (value == null || value.isEmpty) ? 'Required field' : null,
    );
  }

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
