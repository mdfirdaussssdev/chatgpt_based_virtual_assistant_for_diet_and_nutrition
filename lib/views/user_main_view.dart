import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/constants/routes.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/models/user_actions_model.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/api/api_exceptions.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/api/api_fetch_quote.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/api/api_openai_api_function.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/auth/auth_service.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/cloud/cloud_storage_exceptions.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/cloud/cloud_user_details.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/cloud/cloud_user_intake.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/cloud/firebase_cloud_storage.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/utilities/dialogs/logout_dialog.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/utilities/user_intake_helper.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/widgets/calorie_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

class UserMainView extends StatefulWidget {
  const UserMainView({super.key});

  @override
  State<UserMainView> createState() => _UserMainViewState();
}

class _UserMainViewState extends State<UserMainView> {
  List<UserMainActionsModel> userMainActions = [];
  late final FirebaseCloudStorage _userFirebaseService;

  String dailyQuote = '';
  int recommendedCalorieIntake = 0;
  int currentCalorieIntake = 0;
  String latestIntakeExplanation = '';
  String documentId = '';

  void _getInitialInfo() {
    userMainActions = UserMainActionsModel.getUserMainActions();
  }

  Future<void> _fetchDetails() async {
    try {
      final userId = AuthService.firebase().currentUser?.id;
      if (userId == null) {
        throw Exception("User ID is null");
      }
      await _userFirebaseService.getUserDetails(ownerUserId: userId);
      if (!mounted) return;
    } on CouldNotGetUserDetailsException {
      Navigator.of(context).pushNamedAndRemoveUntil(
        userNoUserDetailsRoute,
        (route) => false,
      );
    }
  }

  Future<void> _fetchUserIntakeForToday() async {
    String userId = AuthService.firebase().currentUser!.id;
    try {
      // Get today's date in required format
      final String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      // Fetch user intake from your cloud storage
      final CloudUserIntake userIntake =
          await _userFirebaseService.getUserIntake(
        ownerUserId: userId,
        dateOfIntake: todayDate,
      );

      setState(() {
        recommendedCalorieIntake = userIntake.recommendedCalorieIntake;
        currentCalorieIntake = userIntake.currentCalorieIntake;
        latestIntakeExplanation = userIntake.latestIntakeExplanation;
        documentId = userIntake.documentId;
      });
    } on CouldNotGetUserIntakeException {
      CloudUserDetails userDetails =
          await _userFirebaseService.getUserDetails(ownerUserId: userId);
      int userAge = UserIntakeHelper.calculateAge(userDetails.userDateOfBirth);
      final getRecommendedCalorieIntake =
          UserIntakeHelper.calculateRecommendedCalorieIntake(
        userDetails.userGender,
        userDetails.userWeight,
        userDetails.userHeight,
        userAge,
        userDetails.userActivityLevel,
        userDetails.userGoal,
      );

      try {
        final newDocumentId = await _userFirebaseService.createNewUserIntake(
          ownerUserId: userId,
          dateOfIntake: DateFormat('yyyy-MM-dd').format(DateTime.now()),
          breakfast: [],
          lunch: [],
          dinner: [],
          recommendedCalorieIntake: getRecommendedCalorieIntake,
          currentCalorieIntake: 0,
          latestIntakeExplanation: await UserIntakeHelper.generateExplanation(
              currentCalorieIntake, recommendedCalorieIntake),
        );
        recommendedCalorieIntake = getRecommendedCalorieIntake;
        documentId = newDocumentId;
      } catch (e) {
        print("Error parsing valid string: $e");
      }
    } catch (e) {
      return;
    }
  }

  Future<void> _fetchQuote() async {
    try {
      final quote = await fetchQuote(); // Example async call
      setState(() {
        dailyQuote = quote;
      });
    } catch (e) {
      throw ApiExceptions();
    }
  }

  @override
  void initState() {
    super.initState();
    _userFirebaseService = FirebaseCloudStorage();
    _getInitialInfo();
    _fetchQuote();
    _fetchDetails();
    _fetchUserIntakeForToday();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Scaffold(
      appBar: appBar(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _userActionsSection(userMainActions),
            SizedBox(height: screenHeight * 0.03),

            // StreamBuilder for calorie intake
            StreamBuilder<CloudUserIntake>(
              stream: FirebaseCloudStorage().getUserIntakeStream(
                ownerUserId: AuthService.firebase().currentUser!.id,
                dateOfIntake: todayDate,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator(); // Loading state
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData) {
                  return const Text('No data found.');
                }

                // Get the latest intake
                final userTodayIntake = snapshot.data!;

                return _todayCalorieProgressBar(
                  userTodayIntake.currentCalorieIntake,
                  userTodayIntake.recommendedCalorieIntake,
                  screenWidth,
                  screenHeight,
                );
              },
            ),

            _healthToolsSection(screenWidth, screenHeight, context),
            _motivationalQuoteSection(screenWidth, dailyQuote),
          ],
        ),
      ),
    );
  }

  AppBar appBar(BuildContext context) {
    return AppBar(
      title: const Text(
        'For You',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        // User profile icon
        IconButton(
          icon: const Icon(Icons.account_circle), // Profile icon
          onPressed: () {
            Navigator.pushNamed(context, userProfileRoute);
          },
        ),
        // Logout button
        IconButton(
          onPressed: () async {
            final shouldLogout = await showLogOutDialog(context);
            if (shouldLogout) {
              await AuthService.firebase().logOut();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  loginRoute,
                  (_) => false,
                );
              }
            }
          },
          icon: const Icon(Icons.logout_sharp),
        ),
      ],
    );
  }
}

Container _todayCalorieProgressBar(int currentCalorieIntake,
    int recommendedCalorieIntake, screenWidth, screenHeight) {
  print('Current Calorie Intake: $currentCalorieIntake');
  print('Recommended Calorie Intake: $recommendedCalorieIntake');
  return Container(
    width: double.infinity,
    color: Colors.blue.shade100,
    padding: EdgeInsets.all(screenWidth * 0.05),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          "Today's Calorie Intake Progress Bar",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: screenHeight * 0.02),
        CalorieProgressBar(
            currentCalorieIntake: currentCalorieIntake,
            recommendedCalorieIntake: recommendedCalorieIntake),
      ],
    ),
  );
}

Container _healthToolsSection(
    double screenWidth, double screenHeight, BuildContext context) {
  return Container(
    width: double.infinity,
    color: Colors.grey.shade200,
    padding: EdgeInsets.all(screenWidth * 0.05),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Health Tools',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: screenHeight * 0.02),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, bmiCalculatorRoute);
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.black,
                      width: 1.0,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SvgPicture.asset(
                          'assets/images/bmi_cal.svg',
                          width: 20,
                          height: 20,
                        ),
                        SizedBox(width: screenWidth * 0.03),
                        const Text(
                          'BMI Calculator',
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.black,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, userHydrationTrackerRoute);
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.black,
                      width: 1.0,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SvgPicture.asset(
                          'assets/images/water_intake.svg',
                          width: 20,
                          height: 20,
                        ),
                        SizedBox(width: screenWidth * 0.03),
                        const Text(
                          'Daily Water Intake',
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.black,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            GestureDetector(
              onTap: () async {
                String randomDailyAffirmation =
                    await generateRandomDailyAffirmationFromOpenAI();
                showDialog(
                  // ignore: use_build_context_synchronously
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text(
                        'Here’s a random daily affirmation for you:',
                        textAlign: TextAlign.center,
                      ),
                      content: Text(randomDailyAffirmation),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.black,
                      width: 1.0,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SvgPicture.asset(
                          'assets/images/quote.svg',
                          width: 20,
                          height: 20,
                        ),
                        SizedBox(width: screenWidth * 0.03),
                        const Text(
                          'Daily Affirmations',
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.black,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Container _motivationalQuoteSection(double screenWidth, dailyQuote) {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.all(screenWidth * 0.05),
    color: Colors.blue.shade100,
    child: dailyQuote.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : Text(
            dailyQuote,
            style: const TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
  );
}

SizedBox _userActionsSection(List<UserMainActionsModel> userMainActions) {
  return SizedBox(
    height: 120, // Set the desired height for the container
    child: ListView.separated(
      itemCount: userMainActions.length,
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      separatorBuilder: (context, index) => const SizedBox(width: 25),
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, userMainActions[index].routeName);
          },
          child: Container(
            width: 100,
            decoration: BoxDecoration(
              color: userMainActions[index].boxColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SvgPicture.asset(userMainActions[index].iconPath),
                  ),
                ),
                Text(
                  userMainActions[index].name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}
