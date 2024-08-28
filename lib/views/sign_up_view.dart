import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/constants/routes.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/auth/auth_exceptions.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/auth/auth_service.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/auth/auth_user.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/cloud/firebase_cloud_storage.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/utilities/dialogs/error_dialog.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/views/view_exceptions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multiselect/multiselect.dart';

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
  late final FirebaseCloudStorage _userDetailsService;
  bool _isPasswordVisible = false;
  String? _selectedGoal;

  // For multiselect
  final List<String> _listOfDiseases = ['Diabetes', 'High Blood Pressure'];
  List<String> _selectedValues = [];
  void _onChanged(List<String> selectedValues) {
    setState(() {
      _selectedValues = selectedValues;
    });
  }

  // Declare the picked DateTime object
  DateTime? _selectedDate;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    _dateOfBirth = TextEditingController();
    _weight = TextEditingController();
    _height = TextEditingController();
    _userDetailsService = FirebaseCloudStorage();
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: appBar(context),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
          child: Column(
            children: [
              _emailField(),
              // insert space
              SizedBox(height: screenHeight * 0.03),
              _passwordField(),
              // insert space
              SizedBox(height: screenHeight * 0.03),
              _dateOfBirthField(context),
              // insert space
              SizedBox(height: screenHeight * 0.03),
              _weightAndHeightFields(screenHeight),
              SizedBox(height: screenHeight * 0.03),
              _selectDiseases(),
              SizedBox(height: screenHeight * 0.03),
              _selectYourGoal(),
              SizedBox(height: screenHeight * 0.02),
              SizedBox(
                  width: double.infinity,
                  child: _signUpButton(context, screenWidth, screenHeight)),
              _loginButton(context),
            ],
          ),
        ),
      ),
    );
  }

  TextButton _signUpButton(BuildContext context, screenHeight, screenWidth) {
    return TextButton(
      onPressed: () async {
        final email = _email.text;
        final password = _password.text;
        try {
          if (_selectedDate == null ||
              _weight.text.isEmpty ||
              _height.text.isEmpty ||
              _selectedGoal == null) {
            throw EmptyFieldViewException('All fields must be filled');
          }
          AuthUser newUser = await AuthService.firebase().createUser(
            id: email,
            password: password,
          );
          await _userDetailsService.createNewUserDetails(
              ownerUserId: newUser.id,
              userDateOfBirth: _selectedDate!,
              userWeight: int.parse(_weight.text),
              userHeight: int.parse(_height.text),
              userDiseases: _selectedValues,
              userGoal: _selectedGoal!);
          await AuthService.firebase().sendEmailVerification();
          if (context.mounted) {
            Navigator.of(context).pushNamed(verifyEmailRoute);
          }
        } on EmptyFieldViewException catch (e) {
          if (context.mounted) {
            await showErrorDialog(
              context,
              e.message,
            );
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
      style: TextButton.styleFrom(
        backgroundColor: Colors.blue,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
      ),
      child: const Text(
        'Sign Up',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  TextButton _loginButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.of(context).pushNamedAndRemoveUntil(
          loginRoute,
          (route) => false,
        );
      },
      child: const Text("Have an account? Login here!"),
    );
  }

  DropDownMultiSelect<String> _selectDiseases() {
    return DropDownMultiSelect(
      options: _listOfDiseases,
      onChanged: _onChanged,
      selectedValues: _selectedValues,
      // hint: const Text('data'),
      whenEmpty: 'Select diseases (if applicable)',
      decoration: const InputDecoration(),
    );
  }

  Column _selectYourGoal() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: _selectedGoal,
          hint: const Text('What is your goal?'), // Initial hint text
          decoration: const InputDecoration(
            labelText:
                'Select your Goal', // Label that stays on top when an item is selected
            border: OutlineInputBorder(), // Add a border around the dropdown
          ),
          items: const [
            DropdownMenuItem(
              value: 'Gain Weight',
              child: Text('Gain Weight'),
            ),
            DropdownMenuItem(
              value: 'Lose Weight',
              child: Text('Lose Weight'),
            ),
          ],
          onChanged: (String? newValue) {
            setState(() {
              _selectedGoal = newValue;
            });
          },
        ),
      ],
    );
  }

  Center _weightAndHeightFields(double screenHeight) {
    return Center(
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
                  ),
                ),
                // insert space in between the textbox and text
                SizedBox(height: screenHeight * 0.02),
                const Text(
                  'Weight in kg',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Insert horizontal space between the columns
          SizedBox(width: screenHeight * 0.03),
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
                  ),
                ),
                // insert space in between the textbox and text
                SizedBox(height: screenHeight * 0.02),
                const Text(
                  'Height in cm',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TextField _dateOfBirthField(BuildContext context) {
    return TextField(
      controller: _dateOfBirth,
      readOnly: true,
      decoration: InputDecoration(
        hintText: 'Select your date of birth',
        focusedBorder: const OutlineInputBorder(// Default border color
            ),
        prefixIcon: IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: () => _selectDate(context),
        ),
      ),
    );
  }

  TextField _passwordField() {
    return TextField(
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
          icon: Icon(
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off),
        ),
      ),
    );
  }

  TextField _emailField() {
    return TextField(
      controller: _email,
      enableSuggestions: false,
      autocorrect: false,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        hintText: 'Enter your email here',
      ),
    );
  }

  AppBar appBar(BuildContext context) {
    return AppBar(
      title: const Text(
        'CREATE YOUR ACCOUNT',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF28AADC),
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
    );
  }
}
