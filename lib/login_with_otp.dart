import 'package:crop_prediction_system/MySession.dart';
import 'package:crop_prediction_system/home_screen.dart';
import 'package:crop_prediction_system/sign_up_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OtpLoginScreen extends StatefulWidget {



  const OtpLoginScreen({super.key});

  @override
  State<OtpLoginScreen> createState() => _OtpLoginScreenState();
}

class _OtpLoginScreenState extends State<OtpLoginScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  String _verificationId = '';
  bool _otpSent = false;
  bool _loading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _sendOTP() async {

    final enteredPhone = _phoneController.text.trim();
    if (!RegExp(r'^\d{10}$').hasMatch(enteredPhone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid 10-digit mobile number")),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      // Check if the phone number exists in Firestore
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('mobile', isEqualTo: enteredPhone)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Phone number not registered')),
        );
        return;
      }
      final userData = snapshot.docs.first.data(); // This returns a Map<String, dynamic>
      final userId = snapshot.docs.first.id; // Firestore document ID

      print('User ID: $userId');
      print('User Name: ${userData['name']}');
      print('User Email: ${userData['email']}');

      MySession.instance().saveSession('userId', userId);
      MySession.instance().saveSession('name', userData['name']);
      MySession.instance().saveSession('email', userData['email']);
      MySession.instance().saveSession('mobile', userData['mobile']);
/*
 // Proceed with OTP since phone exists
      await _auth.verifyPhoneNumber(
        phoneNumber: enteredPhone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          _navigateToHome();
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() => _loading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Verification failed: ${e.message}')),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _otpSent = true;
            _loading = false;
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
 */
      setState(() {
        _verificationId = "123456";
        _otpSent = true;
        _loading = false;
      });

    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }


  Future<void> _verifyOTP() async {
    setState(() => _loading = true);
    try {
      /*
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _otpController.text,
      );
      await _auth.signInWithCredential(credential);

       */
      print(_verificationId);
      print(_otpController.text);

      if(_verificationId == _otpController.text) {
        _navigateToHome();
      }

    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid OTP')),
      );
    }
  }

  void _navigateToHome() {
    setState(() => _loading = false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen() ),
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
  late Locale _locale;
  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }
  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(localization.login_title, style: TextStyle(color: Colors.white, fontSize: 13)),
        backgroundColor: Colors.green[700],
        elevation: 0,

      ),
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
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Card(
                color: Colors.white.withOpacity(0.65),
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  child: _loading
                      ? const CircularProgressIndicator()
                      : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!_otpSent) ...[
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: _inputDecoration(localization.login_phonenumber),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.send, color: Colors.black),
                            label: Text(localization.login_btn, style: TextStyle(color: Colors.black)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.yellow,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _sendOTP,
                          ),
                        ),
                      ] else ...[
                        TextFormField(
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration(localization.enter_otp),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.verified, color: Colors.black),
                            label: Text(localization.verify_otp_btn, style: TextStyle(color: Colors.black)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.yellow,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _verifyOTP,
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => SignupScreen()),
                          );
                        },
                        child:  Text(
                          localization.signup_btn,
                          style: TextStyle(color: Colors.blueAccent),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        )
      ]),
    );
  }
}
