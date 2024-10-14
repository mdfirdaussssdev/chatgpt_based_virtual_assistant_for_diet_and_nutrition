import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/auth/auth_service.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/cloud/cloud_storage_exceptions.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/cloud/cloud_user_daily_water_intake.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/cloud/cloud_user_details.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/cloud/firebase_cloud_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HydrationTrackerView extends StatefulWidget {
  const HydrationTrackerView({super.key});

  @override
  State<HydrationTrackerView> createState() => _HydrationTrackerViewState();
}

class _HydrationTrackerViewState extends State<HydrationTrackerView> {
  double? userWeightInKg; // User's weight (fetched later)
  String documentId = '';
  double recommendedMinWaterIntakeInLiters = 0.0;
  double recommendedMaxWaterIntakeInLiters = 0.0;
  String dateOfIntake = '';
  double yesterdayWaterIntake = 0.0;
  String userId = AuthService.firebase().currentUser!.id;
  double waterIntakeInLiters = 0.0; // Current water intake in liters
  late final FirebaseCloudStorage _userDailyWaterIntakeService;

  @override
  void initState() {
    super.initState();
    _userDailyWaterIntakeService = FirebaseCloudStorage();
    _fetchUserWeight();
    _fetchUserDailyWaterIntake();
  }

  Future<void> _fetchUserDailyWaterIntake() async {
    try {
      final CloudUserDailyWaterIntake userDailyWaterIntake =
          await _userDailyWaterIntakeService.getUserDailyWaterIntake(
              ownerUserId: userId);
      recommendedMinWaterIntakeInLiters =
          userDailyWaterIntake.recommendedMinWaterIntake;
      recommendedMaxWaterIntakeInLiters =
          userDailyWaterIntake.recommendedMaxWaterIntake;
      dateOfIntake = userDailyWaterIntake.dateOfIntake;
      yesterdayWaterIntake = userDailyWaterIntake.yesterdayWaterIntake;
      waterIntakeInLiters = userDailyWaterIntake.currentWaterIntake;
      documentId = userDailyWaterIntake.documentId;

      // Define the format
      DateFormat dateFormat = DateFormat('yyyy-MM-dd');
      // Parse the string to DateTime object
      DateTime dateOfIntakeDT = dateFormat.parse(dateOfIntake);
      DateTime today = DateTime.now();
      today = DateTime(today.year, today.month, today.day);
      if (dateOfIntakeDT != today) {
        _calculateWaterIntake();
        yesterdayWaterIntake = waterIntakeInLiters;
        waterIntakeInLiters = 0;
        try {
          await _userDailyWaterIntakeService.updateUserDailyWaterIntake(
              documentId: documentId,
              dateOfIntake: DateFormat('yyyy-MM-dd').format(DateTime.now()),
              recommendedMinWaterIntake: recommendedMinWaterIntakeInLiters,
              recommendedMaxWaterIntake: recommendedMaxWaterIntakeInLiters,
              currentWaterIntake: waterIntakeInLiters,
              yesterdayWaterIntake: yesterdayWaterIntake);
        } on CouldNotUpdateUserDailyWaterIntakeException {
          return;
        }
      }
    } on CouldNotGetUserDailyWaterIntakeException {
      try {
        _calculateWaterIntake();
        final newDocumentId =
            await _userDailyWaterIntakeService.createNewUserDailyWaterIntake(
                ownerUserId: userId,
                dateOfIntake: DateFormat('yyyy-MM-dd').format(DateTime.now()),
                recommendedMinWaterIntake: recommendedMinWaterIntakeInLiters,
                recommendedMaxWaterIntake: recommendedMaxWaterIntakeInLiters,
                currentWaterIntake: 0,
                yesterdayWaterIntake: yesterdayWaterIntake);
        documentId = newDocumentId;
      } catch (e) {
        return;
      }
    }
  }

  // Fetch user weight from firebase
  Future<void> _fetchUserWeight() async {
    final CloudUserDetails userDetails =
        await _userDailyWaterIntakeService.getUserDetails(ownerUserId: userId);
    setState(() {
      userWeightInKg = userDetails.userWeight
          .toDouble(); // Example user weight, fetched from a source
      _calculateWaterIntake();
    });
  }

  // Calculate recommended water intake based on user's weight
  void _calculateWaterIntake() {
    if (userWeightInKg != null) {
      double minIntakeInOunces = userWeightInKg! * 2.2 * 0.5;
      double maxIntakeInOunces = userWeightInKg! * 2.2 * 0.67;

      setState(() {
        // Convert from ounces to liters (1 liter = 33.814 oz)
        recommendedMinWaterIntakeInLiters = minIntakeInOunces / 33.814;
        recommendedMaxWaterIntakeInLiters = maxIntakeInOunces / 33.814;
      });
    }
  }

  // Function to log water intake
  Future<void> _logWaterIntake(double liters) async {
    setState(() {
      waterIntakeInLiters += liters;
    });
    try {
      await _userDailyWaterIntakeService.updateUserDailyWaterIntake(
          documentId: documentId,
          dateOfIntake: dateOfIntake,
          recommendedMinWaterIntake: recommendedMinWaterIntakeInLiters,
          recommendedMaxWaterIntake: recommendedMaxWaterIntakeInLiters,
          currentWaterIntake: waterIntakeInLiters,
          yesterdayWaterIntake: yesterdayWaterIntake);
    } on CouldNotUpdateUserDailyWaterIntakeException {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbar(),
      body: userWeightInKg == null
          ? const Center(
              child:
                  CircularProgressIndicator(), // Show loader while fetching weight
            )
          : SingleChildScrollView(
              // Add this to make the content scrollable
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Your Recommended Daily Water Intake:",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "${recommendedMinWaterIntakeInLiters.toStringAsFixed(2)} L - ${recommendedMaxWaterIntakeInLiters.toStringAsFixed(2)} L",
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 30),
                    _trackYourWaterIntakeText(),
                    const SizedBox(height: 10),
                    _progressIndicatorForWaterIntake(),
                    const SizedBox(height: 10),
                    _amountOfWaterConsumed(),
                    const SizedBox(height: 20),
                    _logWaterIntakeText(),
                    const SizedBox(height: 10),
                    _logWaterIntakeButtons(),
                    const SizedBox(height: 20),
                    getWaterIntakeMessage(
                      waterIntakeInLiters,
                      recommendedMinWaterIntakeInLiters,
                      recommendedMaxWaterIntakeInLiters,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget getWaterIntakeMessage(
      double waterIntakeInLiters,
      double recommendedMinWaterIntakeInLiters,
      double recommendedMaxWaterIntakeInLiters) {
    if (waterIntakeInLiters >= recommendedMinWaterIntakeInLiters &&
        waterIntakeInLiters <= recommendedMaxWaterIntakeInLiters) {
      return const Text(
        "Great job! You're meeting your hydration goal.",
        style: TextStyle(color: Colors.green, fontSize: 16),
      );
    } else if (waterIntakeInLiters > recommendedMaxWaterIntakeInLiters) {
      return const Text(
        "You've exceeded the recommended water intake!",
        style: TextStyle(color: Colors.orange, fontSize: 16),
      );
    } else {
      return const Text(
        "You haven't reached your recommended water intake yet.",
        style: TextStyle(fontSize: 16),
      );
    }
  }

  Text _logWaterIntakeText() {
    return const Text(
      "Log Water Intake:",
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Text _trackYourWaterIntakeText() {
    return const Text(
      "Track Your Water Intake:",
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Row _logWaterIntakeButtons() {
    return Row(
      children: [
        TextButton(
          onPressed: () => _logWaterIntake(0.25), // Log 0.25 liters
          style: TextButton.styleFrom(
            backgroundColor: Colors.blue.shade300,
          ),
          child: const Text("0.25 L", style: TextStyle(color: Colors.white)),
        ),
        const SizedBox(width: 10),
        TextButton(
          onPressed: () => _logWaterIntake(0.5), // Log 0.5 liters
          style: TextButton.styleFrom(
            backgroundColor: Colors.blue.shade300,
          ),
          child: const Text("0.5 L", style: TextStyle(color: Colors.white)),
        ),
        const SizedBox(width: 10),
        TextButton(
          onPressed: () => _logWaterIntake(0.75),
          style: TextButton.styleFrom(
            backgroundColor: Colors.blue.shade300,
          ),
          child: const Text("0.75 L", style: TextStyle(color: Colors.white)),
        ),
        const SizedBox(width: 10),
        TextButton(
          onPressed: () => _logWaterIntake(1),
          style: TextButton.styleFrom(
            backgroundColor: Colors.blue.shade300,
          ),
          child: const Text("1 L", style: TextStyle(color: Colors.white)),
        ),
        const SizedBox(width: 10),
        TextButton(
          onPressed: () => _logWaterIntake(-0.25),
          style: TextButton.styleFrom(
            backgroundColor: Colors.red.shade300,
          ),
          child: const Text("- 0.25 L", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Text _amountOfWaterConsumed() {
    return Text(
      "You've consumed ${waterIntakeInLiters.toStringAsFixed(2)} L of water",
      style: const TextStyle(fontSize: 16),
    );
  }

  LinearProgressIndicator _progressIndicatorForWaterIntake() {
    return LinearProgressIndicator(
      value: waterIntakeInLiters / recommendedMaxWaterIntakeInLiters,
      minHeight: 20,
      backgroundColor: Colors.grey[300],
      valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
    );
  }

  AppBar appbar() {
    return AppBar(
      title: const Text(
        "Hydration Tracker",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      centerTitle: true,
    );
  }
}
