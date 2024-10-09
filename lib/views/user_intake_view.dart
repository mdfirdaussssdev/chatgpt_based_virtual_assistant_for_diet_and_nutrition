import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/constants/routes.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/models/intake_item.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/api/api_openai_api_function.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/auth/auth_service.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/cloud/cloud_storage_exceptions.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/cloud/cloud_user_details.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/cloud/cloud_user_intake.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/cloud/firebase_cloud_storage.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/utilities/dialogs/error_dialog.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/views/view_exceptions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:recase/recase.dart';
import 'package:fl_chart/fl_chart.dart';

class UserIntakeView extends StatefulWidget {
  const UserIntakeView({super.key});

  @override
  State<UserIntakeView> createState() => _UserIntakeViewState();
}

class _UserIntakeViewState extends State<UserIntakeView> {
  bool _isLoading = true;
  @override
  void initState() {
    _userIntakeService = FirebaseCloudStorage();
    _intakeItemName = TextEditingController();
    _intakeServingCount = TextEditingController();
    _intakeDate = TextEditingController(text: _formatDate(DateTime.now()));
    _fetchUserIntakeForToday();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<IntakeItem> breakfastItems = [];
  List<IntakeItem> lunchItems = [];
  List<IntakeItem> dinnerItems = [];
  int recommendedCalorieIntake = 0;
  int currentCalorieIntake = 0;
  String latestIntakeExplanation = '';
  String documentId = '';
  final List<String> _meals = [
    'Breakfast',
    'Lunch',
    'Dinner',
  ];
  String? _selectedMeal;
  bool _enterNewMeal = false;
  // Controllers for the input fields
  late final TextEditingController _intakeItemName;
  late final TextEditingController _intakeServingCount;
  late final TextEditingController _intakeDate;
  late final FirebaseCloudStorage _userIntakeService;

  int calculateAge(DateTime dateOfBirth) {
    final today = DateTime.now();
    int age = today.year - dateOfBirth.year;

    // Adjust age if the user has not yet had their birthday this year
    if (today.month < dateOfBirth.month ||
        (today.month == dateOfBirth.month && today.day < dateOfBirth.day)) {
      age--;
    }

    return age;
  }

  int calculateRecommendedCalorieIntake(
    String gender,
    int weight,
    int height,
    int age,
    String activityLevel,
    String goal,
  ) {
    double bmr;

    // Calculate BMR based on gender
    if (gender.toLowerCase() == 'male') {
      bmr = 10 * weight + 6.25 * height - 5 * age + 5;
    } else if (gender.toLowerCase() == 'female') {
      bmr = 10 * weight + 6.25 * height - 5 * age - 161;
    } else {
      throw ArgumentError('Invalid gender provided: $gender');
    }

    // Define activity factors
    double activityFactor;
    switch (activityLevel.toLowerCase()) {
      case 'sedentary':
        activityFactor = 1.2;
        break;
      case 'lightly active':
        activityFactor = 1.375;
        break;
      case 'moderately active':
        activityFactor = 1.55;
        break;
      case 'very active':
        activityFactor = 1.725;
        break;
      case 'super active':
        activityFactor = 1.9;
        break;
      default:
        throw ArgumentError('Invalid activity level provided: $activityLevel');
    }

    // Calculate total calorie intake
    double totalCalories = bmr * activityFactor;

    // Adjust calories based on goal
    if (goal.toLowerCase() == 'lose weight') {
      totalCalories -= 500; // Subtract 500 kcal for weight loss
    } else if (goal.toLowerCase() == 'gain weight') {
      totalCalories += 300; // Add 300 kcal for weight gain
    } else if (goal.toLowerCase() != 'maintain weight') {
      throw ArgumentError('Invalid goal provided: $goal');
    }

    return totalCalories.round(); // Return calculated value
  }

  Future<void> _fetchUserIntakeForToday() async {
    String userid = AuthService.firebase().currentUser!.id;
    try {
      // Get today's date in required format
      final String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      // Fetch user intake from your cloud storage
      final CloudUserIntake userIntake = await _userIntakeService.getUserIntake(
        ownerUserId: userid,
        dateOfIntake: todayDate,
      );

      // Populate the breakfast, lunch, and dinner items with fetched data
      setState(() {
        breakfastItems = userIntake.breakfast
            .map((item) => IntakeItem(
                name: item.name,
                calories: item.calories,
                servings: item.servings))
            .toList();
        lunchItems = userIntake.lunch
            .map((item) => IntakeItem(
                name: item.name,
                calories: item.calories,
                servings: item.servings))
            .toList();
        dinnerItems = userIntake.dinner
            .map((item) => IntakeItem(
                name: item.name,
                calories: item.calories,
                servings: item.servings))
            .toList();
        recommendedCalorieIntake = userIntake.recommendedCalorieIntake;
        currentCalorieIntake = userIntake.currentCalorieIntake;
        latestIntakeExplanation = userIntake.latestIntakeExplanation;
        documentId = userIntake.documentId;
      });
    } on CouldNotGetUserIntakeException {
      CloudUserDetails userDetails =
          await _userIntakeService.getUserDetails(ownerUserId: userid);
      int userAge = calculateAge(userDetails.userDateOfBirth);
      final getRecommendedCalorieIntake = calculateRecommendedCalorieIntake(
        userDetails.userGender,
        userDetails.userWeight,
        userDetails.userHeight,
        userAge,
        userDetails.userActivityLevel,
        userDetails.userGoal,
      );

      try {
        final newDocumentId = await _userIntakeService.createNewUserIntake(
          ownerUserId: userid,
          dateOfIntake: DateFormat('yyyy-MM-dd').format(DateTime.now()),
          breakfast: breakfastItems,
          lunch: lunchItems,
          dinner: dinnerItems,
          recommendedCalorieIntake: getRecommendedCalorieIntake,
          currentCalorieIntake: 0,
          latestIntakeExplanation: latestIntakeExplanation,
        );
        recommendedCalorieIntake = getRecommendedCalorieIntake;
        documentId = newDocumentId;
      } catch (e) {
        print("Error parsing valid string: $e");
      }
    } catch (e) {
      return;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String formatDateString(String date) {
    // Split the input date string
    final parts = date.split('/');

    // Check if the input has exactly three parts
    if (parts.length != 3) {
      throw const FormatException('Invalid date format. Expected dd/MM/yyyy.');
    }

    // Rearrange to yyyy-MM-dd format
    final formattedDate =
        '${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}';

    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: appBar(context),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _dateSelector(screenHeight),
                    _displayCurrentMeals(),
                    const Divider(
                      color: Colors.black,
                      thickness: 1,
                      height: 20,
                    ),
                    if (_enterNewMeal) _enterYourMeal(screenHeight),
                    if (!_enterNewMeal) _currentMealsDetails(screenHeight),
                  ],
                ),
              ),
            ),
    );
  }

  PieChart _buildCaloriePieChart() {
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            value: currentCalorieIntake.toDouble(),
            color: Colors.green.shade700,
            title:
                '$currentCalorieIntake kcal\n(${((currentCalorieIntake / recommendedCalorieIntake) * 100).toStringAsFixed(1)}%)',
            radius: 50,
            titlePositionPercentageOffset: 0.55,
          ),
          PieChartSectionData(
            value: (recommendedCalorieIntake - currentCalorieIntake).toDouble(),
            color: Colors.red.shade700,
            title:
                '${recommendedCalorieIntake - currentCalorieIntake} kcal\n(${(((recommendedCalorieIntake - currentCalorieIntake) / recommendedCalorieIntake) * 100).toStringAsFixed(1)}%)',
            radius: 50,
            titlePositionPercentageOffset: 0.55,
          ),
        ],
        centerSpaceRadius: 50,
        sectionsSpace: 2,
        startDegreeOffset: 180,
      ),
    );
  }

  Column _dateSelector(double screenHeight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: screenHeight * 0.02),
        TextField(
          controller: _intakeDate,
          readOnly: true,
          decoration: InputDecoration(
            labelText: 'Date',
            suffixIcon: IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: _pickDate,
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
          ),
        ),
        SizedBox(height: screenHeight * 0.02),
      ],
    );
  }

  Future<void> _pickDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (selectedDate != null) {
      try {
        final CloudUserIntake userIntake =
            await _userIntakeService.getUserIntake(
          ownerUserId: AuthService.firebase().currentUser!.id,
          dateOfIntake: DateFormat('yyyy-MM-dd').format(selectedDate),
        );
        setState(() {
          _intakeDate.text = _formatDate(selectedDate);
          breakfastItems = userIntake.breakfast
              .map((item) => IntakeItem(
                  name: item.name,
                  calories: item.calories,
                  servings: item.servings))
              .toList();
          lunchItems = userIntake.lunch
              .map((item) => IntakeItem(
                  name: item.name,
                  calories: item.calories,
                  servings: item.servings))
              .toList();
          dinnerItems = userIntake.dinner
              .map((item) => IntakeItem(
                  name: item.name,
                  calories: item.calories,
                  servings: item.servings))
              .toList();
          recommendedCalorieIntake = userIntake.recommendedCalorieIntake;
          currentCalorieIntake = userIntake.currentCalorieIntake;
          latestIntakeExplanation = userIntake.latestIntakeExplanation;
          documentId = userIntake.documentId;
        });
      } on CouldNotGetUserIntakeException {
        CloudUserDetails userDetails = await _userIntakeService.getUserDetails(
            ownerUserId: AuthService.firebase().currentUser!.id);
        int userAge = calculateAge(userDetails.userDateOfBirth);
        final getRecommendedCalorieIntake = calculateRecommendedCalorieIntake(
          userDetails.userGender,
          userDetails.userWeight,
          userDetails.userHeight,
          userAge,
          userDetails.userActivityLevel,
          userDetails.userGoal,
        );
        breakfastItems = [];
        lunchItems = [];
        dinnerItems = [];
        print("Breakfast items: $breakfastItems");
        print("Lunch items: $lunchItems");
        print("Dinner items: $dinnerItems");
        print(
            "Date of intake: ${DateFormat('yyyy-MM-dd').format(selectedDate)}");

        try {
          final newDocumentId = await _userIntakeService.createNewUserIntake(
            ownerUserId: AuthService.firebase().currentUser!.id,
            dateOfIntake: DateFormat('yyyy-MM-dd').format(selectedDate),
            breakfast: breakfastItems,
            lunch: lunchItems,
            dinner: dinnerItems,
            recommendedCalorieIntake: getRecommendedCalorieIntake,
            currentCalorieIntake: 0,
            latestIntakeExplanation: latestIntakeExplanation,
          );
          recommendedCalorieIntake = getRecommendedCalorieIntake;
          documentId = newDocumentId;
          final CloudUserIntake userIntake =
              await _userIntakeService.getUserIntake(
            ownerUserId: AuthService.firebase().currentUser!.id,
            dateOfIntake: DateFormat('yyyy-MM-dd').format(selectedDate),
          );
          setState(() {
            _intakeDate.text = _formatDate(selectedDate);
            breakfastItems = userIntake.breakfast
                .map((item) => IntakeItem(
                    name: item.name,
                    calories: item.calories,
                    servings: item.servings))
                .toList();
            lunchItems = userIntake.lunch
                .map((item) => IntakeItem(
                    name: item.name,
                    calories: item.calories,
                    servings: item.servings))
                .toList();
            dinnerItems = userIntake.dinner
                .map((item) => IntakeItem(
                    name: item.name,
                    calories: item.calories,
                    servings: item.servings))
                .toList();
            recommendedCalorieIntake = userIntake.recommendedCalorieIntake;
            currentCalorieIntake = userIntake.currentCalorieIntake;
            latestIntakeExplanation = userIntake.latestIntakeExplanation;
            documentId = userIntake.documentId;
          });
        } catch (e) {
          print("Error parsing valid string: $e");
        }
      } catch (e) {
        return;
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Column _displayCurrentMeals() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMealSection('Breakfast', breakfastItems),
        const Divider(
          color: Colors.black,
          thickness: 1,
          height: 20,
        ),
        _buildMealSection('Lunch', lunchItems),
        const Divider(
          color: Colors.black,
          thickness: 1,
          height: 20,
        ),
        _buildMealSection('Dinner', dinnerItems),
      ],
    );
  }

  Widget _buildMealSection(String mealType, List<IntakeItem> items) {
    if (items.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            mealType,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Text(
            'No $mealType entered yet.',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.grey),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          mealType,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        ...items.map(
          (item) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${item.name}: ${item.calories} kcal, ${item.servings} serving(s)',
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  _removeItem(item, mealType);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _removeItem(IntakeItem item, String mealType) async {
    setState(() {
      // Remove the item locally based on meal type
      if (mealType == 'Breakfast') {
        breakfastItems.remove(item);
      } else if (mealType == 'Lunch') {
        lunchItems.remove(item);
      } else if (mealType == 'Dinner') {
        dinnerItems.remove(item);
      }

      // Recalculate the current calorie intake
      currentCalorieIntake = currentCalorieIntake - item.calories;
    });
    try {
      // Update the intake data in the cloud storage
      await _userIntakeService.updateUserIntake(
        dateOfIntake: _intakeDate.text,
        recommendedCalorieIntake: recommendedCalorieIntake,
        latestIntakeExplanation: latestIntakeExplanation,
        documentId: documentId, // Document ID fetched from the cloud
        breakfast: breakfastItems,
        lunch: lunchItems,
        dinner: dinnerItems,
        currentCalorieIntake: currentCalorieIntake,
      );
    } catch (e) {
      print('Error removing item: $e');
    }
  }

  Column _currentMealsDetails(screenHeight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _enterNewMealButton(),
        SizedBox(height: screenHeight * 0.02),
        SizedBox(
          height: screenHeight * 0.3,
          child: _buildCaloriePieChart(),
        ),
        Text('Recommended Calorie Intake: $recommendedCalorieIntake kcal'),
        Text('Current Total Calorie Intake: $currentCalorieIntake kcal'),
        Text(latestIntakeExplanation),
      ],
    );
  }

  Column _enterYourMeal(screenHeight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cancel Button
        _cancelNewMealButton(),
        SizedBox(height: screenHeight * 0.02),
        // Select Meal Type
        _selectMealType(),
        if (_selectedMeal != null) ...[
          SizedBox(height: screenHeight * 0.02),
          // Food Name Text Field
          _intakeNameField(),
          SizedBox(height: screenHeight * 0.02),
          // Serving Count
          _intakeServingCountField(),
          SizedBox(height: screenHeight * 0.02),
          _submitMealButton()
        ],
      ],
    );
  }

  TextButton _enterNewMealButton() {
    return TextButton(
      onPressed: () {
        setState(() {
          // Clear the selected meal and input fields
          _enterNewMeal = true;
        });
      },
      style: TextButton.styleFrom(
        backgroundColor: Colors.red,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
      ),
      child: const Text(
        'Enter New Meal',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  TextButton _cancelNewMealButton() {
    return TextButton(
      onPressed: () {
        setState(() {
          // Clear the selected meal and input fields
          _enterNewMeal = false;
          _selectedMeal = null;
          _intakeItemName.clear();
          _intakeServingCount.clear();
        });
      },
      style: TextButton.styleFrom(
        backgroundColor: Colors.red,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
      ),
      child: const Text(
        'Cancel New Meal',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  SizedBox _submitMealButton() {
    return SizedBox(
        width: double.infinity,
        child: TextButton(
          onPressed: () async {
            final foodName = _intakeItemName.text;
            final servings = int.tryParse(_intakeServingCount.text) ?? 0;
            final mealType = _selectedMeal;
            final selectedDate = _intakeDate.text;
            try {
              if (_intakeItemName.text.isEmpty ||
                  _intakeServingCount.text.isEmpty ||
                  _selectedMeal == null) {
                throw EmptyFieldViewException('All fields must be filled');
              }
              final foodCalorieCount =
                  await getFoodCalorieCountFromOpenAI(foodName, servings);
              if (foodCalorieCount == 'food name not found') {
                throw InvalidFieldViewException();
              }
              int foodCalorieCountInteger = int.parse(foodCalorieCount);
              if (mealType == 'Breakfast') {
                IntakeItem newBreakfastItem = IntakeItem(
                    name: foodName.titleCase,
                    calories: foodCalorieCountInteger,
                    servings: servings);
                breakfastItems.add(newBreakfastItem);
              } else if (mealType == 'Lunch') {
                IntakeItem newLunchItem = IntakeItem(
                    name: foodName.titleCase,
                    calories: foodCalorieCountInteger,
                    servings: servings);
                lunchItems.add(newLunchItem);
              } else if (mealType == 'Dinner') {
                IntakeItem newDinnerItem = IntakeItem(
                    name: foodName.titleCase,
                    calories: foodCalorieCountInteger,
                    servings: servings);
                dinnerItems.add(newDinnerItem);
              }
              await _userIntakeService.updateUserIntake(
                documentId: documentId,
                dateOfIntake: formatDateString(selectedDate),
                breakfast: breakfastItems,
                lunch: lunchItems,
                dinner: dinnerItems,
                recommendedCalorieIntake: recommendedCalorieIntake,
                currentCalorieIntake:
                    (currentCalorieIntake + foodCalorieCountInteger),
                latestIntakeExplanation: latestIntakeExplanation,
              );
              currentCalorieIntake =
                  currentCalorieIntake + foodCalorieCountInteger;
              setState(() {
                // Clear the selected meal and input fields
                _enterNewMeal = false;
                _selectedMeal = null;
                _intakeItemName.clear();
                _intakeServingCount.clear();
              });
            } on EmptyFieldViewException {
              await showErrorDialog(
                context,
                'Please fill in all the fields',
              );
            } on InvalidFieldViewException {
              await showErrorDialog(
                context,
                'Please fill in a proper food name',
              );
            } catch (e) {
              print(e);
            }
          },
          style: TextButton.styleFrom(
            backgroundColor: Colors.blue,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
          ),
          child: const Text(
            'Submit Meal',
            style: TextStyle(color: Colors.white),
          ),
        ));
  }

  TextField _intakeServingCountField() {
    return TextField(
      controller: _intakeServingCount,
      enableSuggestions: false,
      autocorrect: false,
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly
      ],
      decoration: const InputDecoration(
        hintText: 'Serving',
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
        ),
      ),
    );
  }

  TextField _intakeNameField() {
    return TextField(
      controller: _intakeItemName,
      enableSuggestions: true,
      autocorrect: false,
      keyboardType: TextInputType.text,
      decoration: const InputDecoration(
        hintText: 'Food Name',
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
        ),
      ),
    );
  }

  DropdownButtonFormField<String> _selectMealType() {
    return DropdownButtonFormField<String>(
      value: _selectedMeal,
      hint: const Text('Meal?'),
      decoration: const InputDecoration(
        labelText: 'Select Meal Type',
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
        ),
      ),
      items: _meals.map((String goal) {
        return DropdownMenuItem<String>(
          value: goal,
          child: Text(goal),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedMeal = newValue;
        });
      },
    );
  }

  AppBar appBar(BuildContext context) {
    return AppBar(
      title: const Text(
        'USER INTAKE',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF28AADC),
        ),
      ),
      centerTitle: true,
      leading: IconButton(
        onPressed: () async {
          await AuthService.firebase().logOut();
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
