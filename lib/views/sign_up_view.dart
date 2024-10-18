import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/constants/routes.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/constants/user_details.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/auth/auth_exceptions.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/auth/auth_service.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/auth/auth_user.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/cloud/firebase_cloud_storage.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/utilities/dialogs/error_dialog.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/views/view_exceptions.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/widgets/custom_dropdowns_user_details.dart';
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
  String? _selectedGender;
  String? _selectedActivityLevel;
  String? _activityLevelExplanation;

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
        _dateOfBirth.text = "${picked.day}/${picked.month}/${picked.year}";
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    // Determine the explanation based on the selected activity level
    if (_selectedActivityLevel != null) {
      if (_selectedActivityLevel == 'Sedentary') {
        _activityLevelExplanation =
            'Sedentary (little to no exercise)\nExample: Primarily sitting throughout the day with minimal movement.';
      } else if (_selectedActivityLevel == 'Lightly Active') {
        _activityLevelExplanation =
            'Lightly Active (light exercise or sports 1-3 days a week)\nExample: Walking, light jogging, or casual sports activities.';
      } else if (_selectedActivityLevel == 'Moderately Active') {
        _activityLevelExplanation =
            'Moderately Active (moderate exercise/sports 3-5 days a week)\nExample: Regular exercise or physical activity like brisk walking, cycling, or going to the gym a few times a week.';
      } else if (_selectedActivityLevel == 'Very Active') {
        _activityLevelExplanation =
            'Very Active (hard exercise/sports 6-7 days a week)\nExample: Daily intense exercise, such as weight training, running, or playing sports.';
      } else if (_selectedActivityLevel == 'Super Active') {
        _activityLevelExplanation =
            'Super Active (very hard exercise, physical job, or training twice a day)\nExample: Intense daily training or those with very physically demanding jobs, like construction workers or athletes.';
      }
    }

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
              _selectYourGender(),
              SizedBox(height: screenHeight * 0.03),
              _selectYourGoal(),
              SizedBox(height: screenHeight * 0.02),
              _selectYourActivityLevel(),
              SizedBox(height: screenHeight * 0.02),
              SizedBox(
                  width: double.infinity,
                  child: _signUpButton(context, screenWidth, screenHeight)),
              SizedBox(height: screenHeight * 0.02),
              _orDividerRow(),
              _loginButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Row _orDividerRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: Colors.grey.withOpacity(0.5),
          ),
        ),
        const Text(
          "  Or  ",
          style: TextStyle(color: Colors.black, fontSize: 12),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: Colors.grey.withOpacity(0.5),
          ),
        ),
      ],
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
              _selectedGoal == null ||
              _selectedGender == null ||
              _selectedActivityLevel == null) {
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
            userGender: _selectedGender!,
            userGoal: _selectedGoal!,
            userActivityLevel: _selectedActivityLevel!,
          );
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
      options: listOfDiseases,
      onChanged: _onChanged,
      selectedValues: _selectedValues,
      // hint: const Text('data'),
      whenEmpty: 'Diseases (if applicable)',
      decoration: const InputDecoration(),
    );
  }

  Column _selectYourGender() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomDropdownUserDetails(
          selectedValue: _selectedGender,
          items: genders, // Use the imported constant
          hint: 'Gender?',
          onChanged: (String? newValue) {
            setState(() {
              _selectedGender = newValue;
            });
          },
        ),
      ],
    );
  }

  Column _selectYourGoal() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomDropdownUserDetails(
          selectedValue: _selectedGoal,
          items: goals, // Use the imported constant
          hint: 'Goal?',
          onChanged: (String? newValue) {
            setState(() {
              _selectedGoal = newValue;
            });
          },
        ),
      ],
    );
  }

  Column _selectYourActivityLevel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomDropdownUserDetails(
          selectedValue: _selectedActivityLevel,
          items: activityLevels, // Use the imported constant
          hint: 'Activity Level?',
          onChanged: (String? newValue) {
            setState(() {
              _selectedActivityLevel = newValue;
            });
          },
        ),
        const SizedBox(height: 10),
        if (_activityLevelExplanation != null)
          Text(
            _activityLevelExplanation!,
            style: const TextStyle(fontSize: 14),
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
        hintText: 'Date of birth',
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
        hintText: 'Password',
        prefixIcon: const ImageIcon(AssetImage('assets/images/lock.png')),
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
          hintText: 'Email',
          prefixIcon: ImageIcon(AssetImage('assets/images/email.png'))),
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
