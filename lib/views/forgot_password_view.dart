import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/constants/routes.dart';
import 'package:flutter/material.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/auth/auth_provider.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/auth/firebase_auth_provider.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/auth/auth_exceptions.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  late final TextEditingController _controller;
  late final AuthProvider _authProvider;
  String? _errorMessage;
  bool _isSuccess = false; // New variable to track success

  @override
  void initState() {
    _controller = TextEditingController();
    _authProvider =
        FirebaseAuthProvider(); // Initialize your FirebaseAuthProvider
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return emailRegex.hasMatch(email);
  }

  Future<void> _sendPasswordResetEmail() async {
    final email = _controller.text.trim();
    if (email.isEmpty) {
      setState(() {
        _errorMessage = "Please enter your email.";
        _isSuccess = false;
      });
      return;
    }

    if (!_isValidEmail(email)) {
      setState(() {
        _errorMessage = "Please enter a valid email address.";
        _isSuccess = false;
      });
      return;
    }

    try {
      // Use your provider's sendPasswordReset method
      await _authProvider.sendPasswordReset(toEmail: email);
      setState(() {
        _errorMessage = "Password reset email sent. Check your inbox.";
        _isSuccess = true; // Mark as success
      });
    } on InvalidEmailAuthException {
      setState(() {
        _errorMessage = "The email address is invalid.";
        _isSuccess = false;
      });
    } on UserNotFoundAuthException {
      setState(() {
        _errorMessage = "No user found with this email.";
        _isSuccess = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Something went wrong. Please try again.";
        _isSuccess = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Forget Password',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            if (context.mounted) {
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(loginRoute, (route) => false);
            }
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your email to receive a password reset link:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your email',
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: _isSuccess
                        ? Colors.green
                        : Colors.grey, // Change border color based on success
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: _isSuccess
                        ? Colors.green
                        : Colors.blue, // Green on success
                  ),
                ),
                errorText: _isSuccess
                    ? null
                    : (_errorMessage?.isNotEmpty == true
                        ? _errorMessage
                        : null),
                helperText: _isSuccess
                    ? _errorMessage
                    : null, // Green success message below TextField
                helperStyle: TextStyle(
                  color: Colors.green, // Green color for success message
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _sendPasswordResetEmail,
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blue.shade300,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                child: const Text(
                  'Send Password Link',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
