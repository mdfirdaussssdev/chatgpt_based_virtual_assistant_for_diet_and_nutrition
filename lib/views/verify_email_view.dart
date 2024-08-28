import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/constants/routes.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/auth/auth_service.dart';
import 'package:flutter/material.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final email = AuthService.firebase().currentUser?.email;

    return Scaffold(
      appBar: appBar(),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
          child: Column(
            mainAxisAlignment: MainAxisAlignment
                .start, // Center the column contents vertically
            children: [
              _verifyEmailTexts(email, screenHeight),
              SizedBox(
                  height:
                      screenHeight * 0.03), // Adds spacing before the button
              _sendEmailVerificationButton(), // Place the button here
            ],
          ),
        ),
      ),
    );
  }

  Column _verifyEmailTexts(String? email, double screenHeight) {
    return Column(
      children: [
        const Icon(
          Icons.email,
          size: 100, // Adjust the size as needed
          color: Colors.blue, // Adjust the color as needed
        ),
        Text.rich(
          TextSpan(
            children: [
              const TextSpan(
                text: "You're almost there! We sent an email to ",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              TextSpan(
                text: email ?? 'your email address',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: screenHeight * 0.02),
        const Text(
            'Just click on the link in that email to complete your sign up. Still can\'t find the email? No problem.',
            textAlign: TextAlign.center),
        SizedBox(height: screenHeight * 0.03),
      ],
    );
  }

  TextButton _sendEmailVerificationButton() {
    return TextButton(
      onPressed: () async {
        await AuthService.firebase().sendEmailVerification();
      },
      style: TextButton.styleFrom(
        backgroundColor: Colors.blue,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
      ),
      child: const Text(
        'Resend Verification Email',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  AppBar appBar() {
    return AppBar(
      title: const Text(
        'EMAIL VERIFICATION',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF28AADC),
        ),
      ),
      centerTitle: true,
      leading: IconButton(
        onPressed: () async {
          await AuthService.firebase().logOut();
          if (mounted) {
            Navigator.of(context)
                .pushNamedAndRemoveUntil(loginRoute, (route) => false);
          }
        },
        icon: const Icon(Icons.arrow_back),
      ),
    );
  }
}
