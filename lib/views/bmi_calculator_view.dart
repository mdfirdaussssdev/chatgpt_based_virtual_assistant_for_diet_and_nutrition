import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/auth/auth_service.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/cloud/cloud_storage_exceptions.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/cloud/cloud_user_details.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/cloud/firebase_cloud_storage.dart';
import 'package:flutter/material.dart';

class BMICalculatorView extends StatefulWidget {
  const BMICalculatorView({super.key});

  @override
  BMICalculatorViewState createState() => BMICalculatorViewState();
}

class BMICalculatorViewState extends State<BMICalculatorView> {
  late final TextEditingController heightController = TextEditingController();
  late final TextEditingController weightController = TextEditingController();
  late final FirebaseCloudStorage _userDetailsService;

  @override
  void initState() {
    super.initState();
    _userDetailsService = FirebaseCloudStorage();
    _fetchUserDetails();
  }

  int height = 0;
  int weight = 0;
  double bmi = 0;
  String bmiCategory = '';

  Future<void> _fetchUserDetails() async {
    try {
      final userId = AuthService.firebase().currentUser?.id;
      if (userId == null) {
        throw Exception("User ID is null");
      }
      final CloudUserDetails userDetails =
          await _userDetailsService.getUserDetails(ownerUserId: userId);
      setState(() {
        height = userDetails.userHeight;
        heightController.text = height.toString();
        weight = userDetails.userWeight;
        weightController.text = weight.toString();
      });
    } catch (e) {
      throw CouldNotGetUserDetailsException();
    }
  }

  void calculateBMI() {
    final double? height = double.tryParse(heightController.text);
    final double? weight = double.tryParse(weightController.text);

    if (height != null && weight != null && height > 0 && weight > 0) {
      setState(() {
        // BMI formula: weight (kg) / [height (m)]^2
        double heightInMeters = height / 100;
        bmi = weight / (heightInMeters * heightInMeters);

        if (bmi < 18.5) {
          bmiCategory = "You have a UnderWeight\n(BMI less than 18.5)";
        } else if (bmi >= 18.5 && bmi <= 24.9) {
          bmiCategory = "You have a Normal weight\n(BMI 18.5 - 24.9)";
        } else if (bmi >= 25 && bmi <= 29.9) {
          bmiCategory = "You have a OverWeight\n(BMI 25 - 29.9)";
        } else {
          bmiCategory = "Obesity\n(BMI 30 or higher)";
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "BMI CALCULATOR",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF28AADC),
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05, // 5% of screen width
          vertical: screenHeight * 0.02, // 2% of screen height
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              width: screenWidth * 0.9, // 90% of screen width
              child: TextField(
                controller: heightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Height (cm)",
                  labelStyle: const TextStyle(color: Colors.black),
                  fillColor: Colors.white38,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            SizedBox(
              width: screenWidth * 0.9, // 90% of screen width
              child: TextField(
                controller: weightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Weight (kg)",
                  labelStyle: const TextStyle(color: Colors.black),
                  fillColor: Colors.white38,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: screenWidth * 0.9,
              child: TextButton(
                onPressed: calculateBMI,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue, // Background color
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero, // No rounded corners
                  ),
                  padding: EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0), // Text color
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text("Calculate BMI"),
              ),
            ),
            const SizedBox(height: 20),
            Column(
              children: [
                Text(
                  bmi == 0 ? '' : "Your BMI: ${bmi.toStringAsFixed(1)} kg/m²",
                  style: TextStyle(
                    fontSize:
                        screenWidth * 0.05, // Font size based on screen width
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  bmiCategory,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: bmiCategory.contains("Normal")
                        ? Colors.green
                        : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.04,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
