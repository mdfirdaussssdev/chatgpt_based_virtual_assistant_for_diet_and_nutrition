import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/constants/user_details.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/auth/auth_service.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/cloud/cloud_storage_exceptions.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/cloud/cloud_user_details.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/cloud/firebase_cloud_storage.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/widgets/custom_dropdowns_user_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multiselect/multiselect.dart';

class EditUserProfileView extends StatefulWidget {
  const EditUserProfileView({super.key});

  @override
  State<EditUserProfileView> createState() => _EditUserProfileViewState();
}

class _EditUserProfileViewState extends State<EditUserProfileView> {
  late final TextEditingController _heightController;
  late final TextEditingController _weightController;
  late final TextEditingController _dateOfBirthController;
  late final FirebaseCloudStorage _firebaseCloudService;
  String _docId = '';
  String _originalGender = '';
  String _originalGoal = '';
  String _originalActivityLevel = '';
  int _originalHeight = 0;
  int _originalWeight = 0;
  List<String> _originalUserDiseases = [];
  DateTime _originalDateOfBirth =
      DateTime.parse('1999-12-21T08:00:00Z').toLocal();
  DateTime? _selectedDate; // Store selected date
  String? _selectedActivityLevel;
  String? _selectedGoal;
  String? _selectedGender;
  String? _activityLevelExplanation;
  List<String> _selectedValues = [];
  String _activityLevel = '';
  String _gender = '';
  String _goal = '';
  int _height = 0;
  int _weight = 0;

  List<String> _userDiseases = [];
  // Parse the UTC date string and convert it to local time
  DateTime _dateOfBirth = DateTime.parse('1999-12-21T08:00:00Z').toLocal();
  void _onChanged(List<String> selectedValues) {
    setState(() {
      _selectedValues = selectedValues;
    });
  }

  Future<void> _fetchUserDetails() async {
    try {
      final userId = AuthService.firebase().currentUser?.id;
      if (userId == null) {
        throw Exception("User ID is null");
      }

      // Fetch user details excluding email
      final CloudUserDetails userDetails =
          await _firebaseCloudService.getUserDetails(ownerUserId: userId);

      setState(
        () {
          _docId = userDetails.documentId;
          _originalActivityLevel = userDetails.userActivityLevel;
          _originalDateOfBirth = userDetails.userDateOfBirth;
          _originalUserDiseases = userDetails.userDiseases;
          _originalGender = userDetails.userGender;
          _originalGoal = userDetails.userGoal;
          _originalHeight = userDetails.userHeight;
          _originalWeight = userDetails.userWeight;
        },
      );
    } catch (e) {
      throw CouldNotGetUserDetailsException();
    }
  }

  void updateUserProfile() async {
    // Here, you'll gather all the new values
    if (_userDiseases.isNotEmpty && _userDiseases[0] == 'Not Selected') {
      _userDiseases = _originalUserDiseases;
    } else {
      _userDiseases = _selectedValues;
    }
    if (_gender == 'Not Selected') {
      _gender = _originalGender;
    } else {
      _gender = _selectedGender!;
    }
    if (_goal == 'Not Selected') {
      _goal = _originalGoal;
    } else {
      _goal = _selectedGoal!;
    }
    if (_activityLevel == 'Not Selected') {
      _activityLevel = _originalActivityLevel;
    } else {
      _activityLevel = _selectedActivityLevel!;
    }
    if (_height == -1) {
      _height = _originalHeight;
    } else {
      _height = int.parse(_heightController.text);
    }
    if (_weight == -1) {
      _weight = _originalWeight;
    } else {
      _weight = int.parse(_weightController.text);
    }
    if (_dateOfBirth == DateTime.parse('1999-12-21T08:00:00Z').toLocal()) {
      _dateOfBirth = _originalDateOfBirth;
    }

    DateTime newDateOfBirth = _selectedDate ?? _originalDateOfBirth;
    // Now you can use these values to update the user profile in the database
    try {
      await _firebaseCloudService.updateUserDetails(
        documentId: _docId,
        userId: AuthService.firebase().currentUser!.id,
        userGender: _gender,
        userGoal: _goal,
        userActivityLevel: _activityLevel,
        userHeight: _height,
        userWeight: _weight,
        userDateOfBirth: newDateOfBirth,
        userDiseases: _userDiseases,
      );

      // Optionally, show a success message or navigate back
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    } catch (e) {
      // Handle errors appropriately
      // print('Error updating profile: $e');
      return;
    }
  }

  @override
  void initState() {
    _weightController = TextEditingController();
    _heightController = TextEditingController();
    _dateOfBirthController = TextEditingController();
    _firebaseCloudService = FirebaseCloudStorage();
    _fetchUserDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    _userDiseases = args['userDiseases'] ?? ['Not Selected'];
    _gender = args['gender'] ?? 'Not Selected';
    _goal = args['goal'] ?? 'Not Selected';
    _activityLevel = args['activityLevel'] ?? 'Not Selected';
    _height = args['height'] ?? -1;
    _weight = args['weight'] ?? -1;
    _dateOfBirth =
        args['dateOfBirth'] ?? DateTime.parse('1999-12-21T08:00:00Z').toLocal();

    Future<void> selectDate(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1950),
        lastDate: DateTime.now(),
      );
      if (picked != null) {
        setState(() {
          _dateOfBirthController.text =
              "${picked.day}/${picked.month}/${picked.year}";
          _selectedDate = picked;
        });
      }
    }

    if (_weight != -1) {
      _weightController.text = _weight.toString();
    }

    if (_height != -1) {
      _heightController.text = _height.toString();
    }

    return Scaffold(
      appBar: appBar(),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Prevent stretching
              crossAxisAlignment: CrossAxisAlignment
                  .stretch, // Align children to stretch horizontally
              children: [
                if (_dateOfBirth !=
                    DateTime.parse('1999-12-21T08:00:00Z').toLocal())
                  _dateOfBirthPart(selectDate, context),
                if (_weight != -1) _weightPart(),
                if (_height != -1) _heightPart(),
                if ((_userDiseases.isNotEmpty &&
                        _userDiseases[0] != 'Not Selected') ||
                    _userDiseases.isEmpty)
                  _diseasesPart(),
                if (_gender != 'Not Selected') _genderPart(),
                if (_goal != 'Not Selected') _goalPart(),
                if (_activityLevel != 'Not Selected') _activityLevelPart(),
                const SizedBox(height: 10),
                _updateUserProfileButton()
              ],
            ),
          ),
        ),
      ),
    );
  }

  SizedBox _updateUserProfileButton() {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: updateUserProfile,
        style: TextButton.styleFrom(
          backgroundColor: Colors.blue.shade300,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
        ),
        child: const Text(
          'Update',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Column _activityLevelPart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomDropdownUserDetails(
          selectedValue: _selectedActivityLevel,
          items: activityLevels,
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

  Column _goalPart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomDropdownUserDetails(
          selectedValue: _selectedGoal,
          items: goals,
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

  Column _genderPart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomDropdownUserDetails(
          selectedValue: _selectedGender,
          items: genders,
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

  DropDownMultiSelect<String> _diseasesPart() {
    return DropDownMultiSelect(
      options: listOfDiseases,
      onChanged: _onChanged,
      selectedValues: _selectedValues,
      whenEmpty: 'Diseases (if applicable)',
      decoration: const InputDecoration(
        border: OutlineInputBorder(), // Optional: Add border for consistency
      ),
    );
  }

  TextField _heightPart() {
    return TextField(
      controller: _heightController,
      textAlign: TextAlign.center,
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
      ],
      decoration: const InputDecoration(
        suffixText: '(cm)',
        border: OutlineInputBorder(), // Optional: Add border for consistency
      ),
    );
  }

  TextField _weightPart() {
    return TextField(
      controller: _weightController,
      textAlign: TextAlign.center,
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
      ],
      decoration: const InputDecoration(
        suffixText: '(kg)',
        border: OutlineInputBorder(),
      ),
    );
  }

  TextField _dateOfBirthPart(
      Future<void> Function(BuildContext context) selectDate,
      BuildContext context) {
    return TextField(
      controller: _dateOfBirthController,
      readOnly: true,
      decoration: InputDecoration(
        hintText: 'Date of birth',
        focusedBorder: const OutlineInputBorder(),
        prefixIcon: IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: () => selectDate(context),
        ),
      ),
    );
  }

  AppBar appBar() {
    return AppBar(
      title: const Text(
        'Edit Profile',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      centerTitle: true,
    );
  }
}
