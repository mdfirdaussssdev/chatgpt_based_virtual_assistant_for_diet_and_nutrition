import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/constants/routes.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/models/user_actions_model.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/api/api_exceptions.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/api/fetch_quote.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/auth/auth_service.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/utilities/dialogs/logout_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class UserMainView extends StatefulWidget {
  const UserMainView({super.key});

  @override
  State<UserMainView> createState() => _UserMainViewState();
}

class _UserMainViewState extends State<UserMainView> {
  List<UserMainActionsModel> userMainActions = [];

  String dailyQuote = '';

  void _getInitialInfo() {
    userMainActions = UserMainActionsModel.getUserMainActions();
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
    _getInitialInfo();
    _fetchQuote();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: appBar(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _userActionsSection(userMainActions),
            SizedBox(height: screenHeight * 0.03),
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

Container _healthToolsSection(
    double screenWidth, double screenHeight, BuildContext context) {
  return Container(
    width: double.infinity,
    color: Colors.blue.shade100,
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
                Navigator.of(context).pushNamedAndRemoveUntil(
                    userHomePageRoute, (route) => false);
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
                          'assets/images/calorie_cal.svg',
                          width: 20,
                          height: 20,
                        ),
                        SizedBox(width: screenWidth * 0.03),
                        const Text(
                          'Calorie Calculator',
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
    color: Colors.orange.shade100,
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
