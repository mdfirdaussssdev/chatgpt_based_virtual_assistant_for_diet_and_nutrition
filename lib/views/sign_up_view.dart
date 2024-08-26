import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/constants/routes.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/auth/auth_exceptions.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/auth/auth_service.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/utilities/dialogs/error_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  late final TextEditingController _dateOfBirth;
  late final TextEditingController _weight;
  late final TextEditingController _height;
  bool _isPasswordVisible = false;

  // Declare the picked DateTime object
  DateTime? _selectedDate;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    _dateOfBirth = TextEditingController();
    _weight = TextEditingController();
    _height = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _dateOfBirth.dispose();
    _weight.dispose();
    _height.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dateOfBirth.text = "${picked.day}-${picked.month}-${picked.year}";
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _email,
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'Enter your email here',
            ),
          ),
          // insert space
          const SizedBox(height: 20),
          TextField(
            controller: _password,
            // if its visible, obscureText should be false
            obscureText: !_isPasswordVisible,
            enableSuggestions: false,
            autocorrect: false,
            decoration: InputDecoration(
              hintText: 'Enter your password here',
              suffixIcon: IconButton(
                onPressed: () {
                  setState(
                    () {
                      _isPasswordVisible = !_isPasswordVisible;
                    },
                  );
                },
                icon: Icon(_isPasswordVisible
                    ? Icons.visibility
                    : Icons.visibility_off),
              ),
            ),
          ),
          // insert space
          const SizedBox(height: 20),
          TextField(
            controller: _dateOfBirth,
            readOnly: true,
            decoration: InputDecoration(
              hintText: 'Select your date of birth',
              filled: true,
              prefixIcon: IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () => _selectDate(context),
              ),
            ),
          ),
          // insert space
          const SizedBox(height: 20),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextField(
                        controller: _weight,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: const InputDecoration(
                          suffixText: '(kg)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      // insert space in between the textbox and text
                      const SizedBox(height: 8),
                      const Text('Weight', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
                // insert space in between
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextField(
                        controller: _height,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: const InputDecoration(
                          suffixText: '(cm)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      // insert space in between the textbox and text
                      const SizedBox(height: 8),
                      const Text('Height', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () async {
              final email = _email.text;
              final password = _password.text;
              try {
                await AuthService.firebase().createUser(
                  id: email,
                  password: password,
                );
                await AuthService.firebase().sendEmailVerification();
                if (context.mounted) {
                  Navigator.of(context).pushNamed(verifyEmailRoute);
                }
              } on WeakPasswordAuthException {
                if (context.mounted) {
                  await showErrorDialog(
                    context,
                    'Weak Password',
                  );
                }
              } on EmailAlreadyInUseAuthException {
                if (context.mounted) {
                  await showErrorDialog(
                    context,
                    'Email already in use',
                  );
                }
              } on InvalidEmailAuthException {
                if (context.mounted) {
                  await showErrorDialog(
                    context,
                    'Invalid Email Entered',
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
            child: const Text('Sign Up'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                loginRoute,
                (route) => false,
              );
            },
            child: const Text("Have an account? Login here!"),
          )
        ],
      ),
    );
  }
}
