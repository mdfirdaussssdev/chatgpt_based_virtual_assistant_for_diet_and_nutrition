import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/constants/routes.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/auth/auth_service.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/views/bmi_calculator_view.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/views/login_view.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/views/sign_up_view.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/views/user_food_nutrition_view.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/views/user_no_user_details_view.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/views/user_intake_view.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/views/user_main_view.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/views/user_discover_recipes_view.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/views/verify_email_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
    print('Environment variables loaded successfully');
  } catch (e) {
    print('Failed to load environment variables: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF28AADC)),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF28AADC)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
        ),
      ),
      routes: {
        loginRoute: (context) => const LoginView(),
        verifyEmailRoute: (context) => const VerifyEmailView(),
        signUpRoute: (context) => const SignUpView(),
        userHomePageRoute: (context) => const UserMainView(),
        // need to change this later
        userFoodNutritionQueryRoute: (context) => const UserFoodNutritionView(),
        userUserIntakeRoute: (context) => UserIntakeView(),
        userDiscoverRecipesRoute: (context) => const UserDiscoverRecipesView(),
        bmiCalculatorRoute: (context) => const BMICalculatorView(),
        userNoUserDetailsRoute: (context) => const UserNoUserDetailsView(),
      },
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService.firebase().initialize(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = AuthService.firebase().currentUser;
            if (user != null) {
              if (user.isEmailVerified) {
                return const UserMainView();
              } else {
                return const VerifyEmailView();
              }
            } else {
              return const LoginView();
            }
          default:
            return const CircularProgressIndicator();
        }
      },
    );
  }
}
