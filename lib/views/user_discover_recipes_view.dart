import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/api/api_openai_api_function.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/api/api_recipe_get_image.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/auth/auth_exceptions.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/auth/auth_service.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/cloud/cloud_storage_exceptions.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/cloud/cloud_user_details.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/cloud/cloud_user_latest_food_recipe_query.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/cloud/firebase_cloud_storage.dart';
import 'package:flutter/material.dart';

class UserDiscoverRecipesView extends StatefulWidget {
  const UserDiscoverRecipesView({super.key});

  @override
  State<UserDiscoverRecipesView> createState() =>
      _UserDiscoverRecipesViewState();
}

class _UserDiscoverRecipesViewState extends State<UserDiscoverRecipesView> {
  late final TextEditingController _region;
  late final FirebaseCloudStorage _firebaseCloudService;

  String _output = '';
  String userGoal = '';
  String? _imageUrl;
  String _title = '';
  String _reason = '';
  List<String> _ingredients = [];
  List<String> _instructions = [];
  List<bool> _checkedIngredients = [];
  List<bool> _checkedInstructions = [];
  String _docId = '';

  @override
  void initState() {
    _region = TextEditingController();
    _firebaseCloudService = FirebaseCloudStorage();
    _fetchUserDetails();
    super.initState();
    _initializeResult();
  }

  @override
  void dispose() {
    _region.dispose();
    super.dispose();
  }

  Future<void> _initializeResult() async {
    try {
      final userDoc = await _firebaseCloudService.getUserFoodRecipeQueryDetails(
        ownerUserId: AuthService.firebase().currentUser!.id,
      );
      setState(() {
        _docId = userDoc.documentId;
        _imageUrl = userDoc.imageUrl;
        _title = userDoc.title;
        _reason = userDoc.reason;
        _ingredients = userDoc.ingredients;
        _instructions = userDoc.instructions;
        _checkedIngredients = userDoc.checkedIngredients;
        _checkedInstructions = userDoc.checkedInstructions;
      });
    } on CouldNotGetFoodRecipeQueryException {
      // No result found, leave _result as an empty string
      setState(() {
        _ingredients = [];
        _instructions = [];
      });
    }
  }

  Future<void> _fetchUserDetails() async {
    try {
      final userId = AuthService.firebase().currentUser?.id;
      if (userId == null) {
        throw UserNotLoggedInAuthException();
      }
      final CloudUserDetails userDetails =
          await _firebaseCloudService.getUserDetails(ownerUserId: userId);
      setState(() {
        // Gain Weight || Lose Weight || Maintain Weight
        userGoal = userDetails.userGoal;
      });
    } catch (e) {
      throw CouldNotGetUserDetailsException();
    }
  }

  Future<void> _performSearch() async {
    if (_region.text.isNotEmpty) {
      String region = _region.text;
      final recipeTitle = await getRandomRecipeFoodName(region, userGoal);
      // recipe title will be error if region input is invalid
      if (recipeTitle == 'error') {
        setState(() {
          _output = 'Please enter a valid region.';
        });
      } else {
        final result = await getRecipeFromOpenAI(recipeTitle, userGoal);
        String imageUrl = await getImageForRecipe(recipeTitle);
        _parseOutput(result);
        _checkedIngredients = List.filled(_ingredients.length, false);
        _checkedInstructions = List.filled(_instructions.length, false);
        await _firebaseCloudService.createNewUserFoodRecipeQuery(
          ownerUserId: AuthService.firebase().currentUser!.id,
          imageUrl: imageUrl,
          title: recipeTitle,
          reason: _reason,
          ingredients: _ingredients,
          instructions: _instructions,
          checkedIngredients: _checkedIngredients,
          checkedInstructions: _checkedInstructions,
        );
        final CloudUserLatestFoodRecipeQuery userLatestFoodRecipeQuery =
            await _firebaseCloudService.getUserFoodRecipeQueryDetails(
          ownerUserId: AuthService.firebase().currentUser!.id,
        );
        _docId = userLatestFoodRecipeQuery.documentId;
        setState(() {
          _output = '';
          _imageUrl = imageUrl;
        });
      }
    } else {
      setState(() {
        _output = 'Please enter a valid region.';
      });
    }
  }

  void _parseOutput(String output) {
    final parts = output.split('\n');

    if (parts.isEmpty) return;

    final foodName = parts[0].trim();
    _title = foodName;

    _ingredients.clear();
    _instructions.clear();

    bool inIngredients = false;
    bool inInstructions = false;

    for (var line in parts) {
      final trimmedLine = line.trim();

      if (trimmedLine.startsWith('Reason:')) {
        _reason = trimmedLine.substring('Reason:'.length).trim();
      } else if (trimmedLine.startsWith('Ingredient List:')) {
        inIngredients = true;
        inInstructions = false;
      } else if (trimmedLine.startsWith('Instructions:')) {
        inIngredients = false;
        inInstructions = true;
      } else if (inIngredients && trimmedLine.isNotEmpty) {
        _ingredients.add(trimmedLine);
      } else if (inInstructions && trimmedLine.isNotEmpty) {
        _instructions.add(trimmedLine);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: appBar(context),
      backgroundColor: Colors.grey.shade200,
      body: Container(
        color: Colors.grey.shade200,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _regionField(screenWidth, screenHeight),
              SizedBox(height: screenHeight * 0.01),
              if (_output != '') _errorOutput(),
              SizedBox(height: screenHeight * 0.01),
              if (_ingredients.isNotEmpty && _instructions.isNotEmpty) ...[
                if (_imageUrl != null) _recipeImage(screenWidth, screenHeight),
                SizedBox(height: screenHeight * 0.01),
                _titleText(),
                SizedBox(height: screenHeight * 0.01),
                _reasonText(),
                SizedBox(height: screenHeight * 0.02),
                _ingredientsSectionHeader(screenWidth, _ingredients.length),
                SizedBox(height: screenHeight * 0.01),
                _ingredientsSection(_ingredients, screenHeight, screenWidth),
                _instructionsSectionHeader(screenWidth),
                _instructionsSection(_instructions, screenHeight, screenWidth),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Image _recipeImage(double screenWidth, double screenHeight) {
    return Image.network(
      _imageUrl!,
      width: screenWidth,
      height: screenHeight * 0.35,
      fit:
          BoxFit.cover, // Optionally use BoxFit to control how the image scales
    );
  }

  Text _reasonText() {
    return Text(
      _reason,
      style: const TextStyle(
        fontSize: 16,
      ),
    );
  }

  Text _titleText() {
    return Text(
      _title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  Text _errorOutput() {
    return Text(
      _output,
      style: const TextStyle(
        fontSize: 16,
      ),
    );
  }

  SizedBox _ingredientsSectionHeader(double screenWidth, int itemCount) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.all(screenWidth * 0.02),
              color: Colors.red.shade300,
              child: const Text(
                'Ingredients Required',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(screenWidth * 0.02),
            color: Colors.white,
            child: Text(
              '$itemCount items',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  SizedBox _instructionsSectionHeader(double screenWidth) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.all(screenWidth * 0.02),
              color: Colors.red.shade300,
              child: const Text(
                'Instructions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  SizedBox _instructionsSection(
      List<String> instructions, double screenHeight, double screenWidth) {
    return SizedBox(
      child: Container(
        padding: EdgeInsets.all(screenWidth * 0.02),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true, // Important for preventing overflow
              physics:
                  const NeverScrollableScrollPhysics(), // Disable scrolling here
              itemCount: instructions.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    CheckboxListTile(
                      value: _checkedInstructions[index],
                      activeColor: Colors.red,
                      onChanged: (bool? value) {
                        setState(() {
                          _checkedInstructions[index] = value ?? false;
                        });
                        _firebaseCloudService.updateUserFoodRecipeQuery(
                          documentId: _docId,
                          imageUrl: _imageUrl!,
                          title: _title,
                          reason: _reason,
                          ingredients: _ingredients,
                          instructions: _instructions,
                          checkedIngredients: _checkedIngredients,
                          checkedInstructions: _checkedInstructions,
                        );
                      },
                      title: Text(
                        instructions[index],
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    // Add a line separator between items
                    if (index < instructions.length - 1) const Divider(),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  SizedBox _ingredientsSection(
      List<String> ingredients, double screenHeight, double screenWidth) {
    return SizedBox(
      child: Container(
        padding: EdgeInsets.all(screenWidth * 0.02),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true, // Prevent overflow
              physics:
                  const NeverScrollableScrollPhysics(), // Disable scrolling
              itemCount: ingredients.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    CheckboxListTile(
                      value: _checkedIngredients[index],
                      activeColor: Colors.red,
                      onChanged: (bool? value) {
                        setState(() {
                          _checkedIngredients[index] = value ?? false;
                        });
                        _firebaseCloudService.updateUserFoodRecipeQuery(
                          documentId: _docId,
                          imageUrl: _imageUrl!,
                          title: _title,
                          reason: _reason,
                          ingredients: _ingredients,
                          instructions: _instructions,
                          checkedIngredients: _checkedIngredients,
                          checkedInstructions: _checkedInstructions,
                        );
                      },
                      title: Text(
                        ingredients[index],
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    // Add a line separator between items
                    if (index < ingredients.length - 1) const Divider(),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Column _regionField(screenWidth, screenHeight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 0.01 * screenHeight),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: TextField(
            controller: _region,
            enableSuggestions: true,
            autocorrect: false,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              hintText: "Region to discover its cuisine",
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
              suffixIcon: IconButton(
                icon: const Icon(
                  Icons.search,
                  color: Colors.black,
                ),
                onPressed: _performSearch,
              ),
            ),
          ),
        )
      ],
    );
  }

  AppBar appBar(BuildContext context) {
    return AppBar(
      title: const Text(
        'Discover Recipes',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 201, 31, 31),
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.grey.shade200,
    );
  }
}
