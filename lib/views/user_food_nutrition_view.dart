import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/models/eat_less_model.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/models/eat_more_model.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/api/api_openai_api_function.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/auth/auth_service.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/cloud/cloud_storage_exceptions.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/cloud/firebase_cloud_storage.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/utilities/dialogs/error_dialog.dart';
import 'package:flutter/material.dart';

class UserFoodNutritionView extends StatefulWidget {
  const UserFoodNutritionView({super.key});

  @override
  State<UserFoodNutritionView> createState() => _UserFoodNutritionViewState();
}

class _UserFoodNutritionViewState extends State<UserFoodNutritionView> {
  late final TextEditingController _foodName;
  late final TextEditingController _servingCount;
  List<EatMoreModel> eatMore = [];
  List<EatLessModel> eatLess = [];
  String _result = '';
  late final FirebaseCloudStorage _userFoodNutritionQueryService;
  bool _isLoading = false;

  void _getInitialInfo() {
    eatMore = EatMoreModel.getEatMore();
    eatLess = EatLessModel.getEatLess();
  }

  @override
  void initState() {
    _foodName = TextEditingController();
    _servingCount = TextEditingController();
    _getInitialInfo();
    _userFoodNutritionQueryService = FirebaseCloudStorage();
    super.initState();
    _initializeResult();
  }

  Future<void> _initializeResult() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final userDoc =
          await _userFoodNutritionQueryService.getUserFoodNutritionQueryDetails(
        ownerUserId: AuthService.firebase().currentUser!.id,
      );
      setState(() {
        _result = userDoc.foodNutritionQueryResult;
      });
    } on CouldNotGetFoodNutritionQueryException {
      // No result found, leave _result as an empty string
      setState(() {
        _result = '';
      });
    } finally {
      setState(() {
        _isLoading = false; // Set loading to false when done
      });
    }
  }

  @override
  void dispose() {
    _foodName.dispose();
    _servingCount.dispose();
    super.dispose();
  }

  Future<void> _searchNutrition() async {
    final food = _foodName.text;
    const servings = 1;

    setState(() {
      _isLoading = true; // Set loading to true
    });

    final result = await getFoodNutritionFromOpenAI(food, servings);

    setState(() {
      _result = result;
      if (_result ==
          "Unable to query input, error! Please enter a proper food name.") {
        showErrorDialog(context, 'Please enter a proper food name!');
        _initializeResult();
      } else {
        _userFoodNutritionQueryService.createNewUserFoodNutritionQuery(
            ownerUserId: AuthService.firebase().currentUser!.id,
            foodNutritionQueryResult: result);
      }
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: appBar(context),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                _eatMoreSectionHeader(screenWidth),
                _eatMoreSectionDescription(screenWidth),
                _eatMoreSection(eatMore),
                SizedBox(height: screenHeight * 0.01),
                _eatLessSectionHeader(screenWidth),
                _eatLessSectionDescription(screenWidth),
                _eatLessSection(eatLess),
                SizedBox(height: screenHeight * 0.01),
                _queryFoodNutritionHeader(screenWidth),
                SizedBox(height: screenHeight * 0.02),
                SizedBox(
                  width: screenWidth * 0.8,
                  child: _foodNameField(),
                ),
                _buildResultDisplay(),
                SizedBox(height: screenHeight * 0.02),
              ],
            ),
          ),
          if (_isLoading) // Show loading indicator overlay
            Positioned.fill(
              child: Container(
                color: Colors.black54, // Semi-transparent background
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResultDisplay() {
    if (_result.isEmpty) {
      return Container();
    }

    final lines = _result.split('\n');
    final title = lines.isNotEmpty ? lines[0] : '';

    final bool isErrorTitle = title ==
        "Unable to query input, error! Please enter a proper food name.";
    if (isErrorTitle) {
      return Container();
    }

    final healthyOrUnhealthy = lines.isNotEmpty ? lines[1] : '';
    final contentLines = lines.length > 1 ? lines.sublist(2) : [];
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 1.0),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              healthyOrUnhealthy.trim().toLowerCase() == 'healthy'
                  ? 'Healthy'
                  : healthyOrUnhealthy.trim().toLowerCase() == 'unhealthy'
                      ? 'Unhealthy'
                      : healthyOrUnhealthy,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: healthyOrUnhealthy.trim().toLowerCase() == 'healthy'
                    ? Colors.green
                    : healthyOrUnhealthy.trim().toLowerCase() == 'unhealthy'
                        ? Colors.red
                        : Colors.black,
              ),
            ),
          ),
          // Table for content lines
          Table(
            border: TableBorder.all(
              color: Colors.black,
              width: 1,
            ),
            children: contentLines.map((line) {
              final parts = line.split(':');
              final boldPart = parts.isNotEmpty
                  ? parts[0] + ':'
                  : ''; // Bold part (before colon)
              final regularPart = parts.length > 1
                  ? parts.sublist(1).join(':').trim()
                  : ''; // Regular part (after colon)

              return TableRow(
                children: [
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: boldPart,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              text: ' $regularPart',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  TextField _foodNameField() {
    return TextField(
      controller: _foodName,
      enableSuggestions: true,
      autocorrect: false,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        hintText: 'Food',
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
        ),
        suffixIcon: IconButton(
          icon: const Icon(
            Icons.search,
            color: Colors.black,
          ),
          onPressed: _searchNutrition,
        ),
      ),
    );
  }

  // TextButton _searchButton(BuildContext context, screenHeight, screenWidth) {
  //   return TextButton(
  //     onPressed: () async {},
  //     style: TextButton.styleFrom(
  //       backgroundColor: Colors.blue,
  //       shape: const RoundedRectangleBorder(
  //         borderRadius: BorderRadius.zero,
  //       ),
  //     ),
  //     child: const Text(
  //       'Sign Up',
  //       style: TextStyle(color: Colors.white),
  //     ),
  //   );
  // }

  // // TextField _servingCountField() {
  //   return TextField(
  //     controller: _servingCount,
  //     enableSuggestions: false,
  //     autocorrect: false,
  //     keyboardType: TextInputType.number,
  //     decoration: const InputDecoration(
  //       hintText: 'Number of servings',
  //       enabledBorder: OutlineInputBorder(
  //         borderSide: BorderSide(color: Colors.black),
  //       ),
  //     ),
  //     inputFormatters: [
  //       FilteringTextInputFormatter.digitsOnly, // Only allows numeric input
  //     ],
  //   );
  // }

  SizedBox _eatMoreSection(List<EatMoreModel> eatMore) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        itemCount: eatMore.length,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        separatorBuilder: (context, index) => const SizedBox(width: 25),
        itemBuilder: (context, index) {
          return Container(
            width: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(eatMore[index].iconPath),
                  ),
                ),
                const SizedBox(
                    height: 8), // Add some space between the image and the text
                Expanded(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      eatMore[index].name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis, // Handle overflow
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Container _eatMoreSectionHeader(double screenWidth) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.025),
      color: Colors.green.shade400,
      child: const Text(
        'Eat More',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Container _eatMoreSectionDescription(double screenWidth) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.025),
      child: const Text(
        'Boost your health by including these nutrient-rich foods in your daily meals.',
        style: TextStyle(
          fontSize: 14,
          color: Colors.black,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Container _eatLessSectionHeader(double screenWidth) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.025),
      color: Colors.green.shade400,
      child: const Text(
        'Eat Less',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Container _eatLessSectionDescription(double screenWidth) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.025),
      child: const Text(
        'Eating healthily doesn’t require giving up on enjoyable flavors. However, some foods can be detrimental, particularly when consumed in excess.',
        style: TextStyle(
          fontSize: 14,
          color: Colors.black,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  SizedBox _eatLessSection(List<EatLessModel> eatLess) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        itemCount: eatLess.length,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        separatorBuilder: (context, index) => const SizedBox(width: 25),
        itemBuilder: (context, index) {
          return Container(
            width: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(eatLess[index].iconPath),
                  ),
                ),
                const SizedBox(
                    height: 8), // Add some space between the image and the text
                Expanded(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      eatLess[index].name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis, // Handle overflow
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Container _queryFoodNutritionHeader(double screenWidth) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.025),
      color: Colors.green.shade400,
      child: const Text(
        'Review the Nutritional Value of a Food',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  AppBar appBar(BuildContext context) {
    return AppBar(
      title: const Text(
        'Food Nutrition',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );
  }
}
