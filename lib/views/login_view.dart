import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/constants/routes.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/auth/auth_exceptions.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/auth/auth_service.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/utilities/dialogs/error_dialog.dart';
import 'package:flutter/material.dart';
// import 'dart:developer' as devtools show log;

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: appBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
          child: Column(
            children: [
              _emailAddressField(),
              SizedBox(height: screenHeight * 0.02),
              _passwordField(),
              SizedBox(height: screenHeight * 0.02),
              SizedBox(
                width: double.infinity,
                child: _loginButton(context, screenHeight, screenWidth),
              ),
              _signUpButton(context)
            ],
          ),
        ),
      ),
    );
  }

  TextButton _signUpButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.of(context)
            .pushNamedAndRemoveUntil(signUpRoute, (route) => false);
      },
      child: const Text('Not signed up yet? Sign up here!'),
    );
  }

  TextField _passwordField() {
    return TextField(
      controller: _password,
      obscureText: !_isPasswordVisible,
      enableSuggestions: false,
      autocorrect: false,
      decoration: InputDecoration(
        hintText: 'Password',
        suffixIcon: IconButton(
          onPressed: () {
            setState(
              () {
                _isPasswordVisible = !_isPasswordVisible;
              },
            );
          },
          icon: Icon(
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off),
        ),
      ),
    );
  }

  TextButton _loginButton(BuildContext context, screenHeight, screenWidth) {
    return TextButton(
      onPressed: () async {
        final email = _email.text;
        final password = _password.text;
        try {
          await AuthService.firebase().logIn(
            id: email,
            password: password,
          );
          final user = AuthService.firebase().currentUser;
          if (user?.isEmailVerified ?? false) {
            // user's email is verified
            if (context.mounted) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                userHomePageRoute,
                (route) => false,
              );
            }
          } else {
            // user's email is not verified
            if (context.mounted) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                verifyEmailRoute,
                (route) => false,
              );
            }
          }
        } on InvalidCredentialsAuthException {
          if (context.mounted) {
            await showErrorDialog(
              context,
              'User not found or wrong password',
            );
          }
        } on InvalidEmailAuthException {
          if (context.mounted) {
            await showErrorDialog(
              context,
              'Invalid email format, enter a proper email',
            );
          }
        } on GenericAuthException {
          if (context.mounted) {
            await showErrorDialog(
              context,
              'Authentication error',
            );
          }
        }
      },
      style: TextButton.styleFrom(
        backgroundColor: Colors.blue, // Fill color
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero, // Rounded edges
        ),
        padding: EdgeInsets.symmetric(
          vertical: screenHeight * 0.02,
          horizontal: screenWidth * 0.03,
        ),
      ),
      child: const Text(
        'Login',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  TextField _emailAddressField() {
    return TextField(
      controller: _email,
      enableSuggestions: false,
      autocorrect: false,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        hintText: 'Email',
      ),
    );
  }

  AppBar appBar() {
    return AppBar(
      title: const Text(
        'LOGIN',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF28AADC),
        ),
      ),
      centerTitle: true,
    );
  }
}
