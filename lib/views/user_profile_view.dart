import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/constants/routes.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/auth/auth_service.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/cloud/cloud_storage_exceptions.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/cloud/cloud_user_details.dart';
import 'package:chatgpt_based_virtual_assistant_for_diet_and_nutrition/services/cloud/firebase_cloud_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UserProfileView extends StatefulWidget {
  const UserProfileView({super.key});

  @override
  State<UserProfileView> createState() => _UserProfileViewState();
}

class _UserProfileViewState extends State<UserProfileView> {
  late final FirebaseCloudStorage _userDetailsService;
  CloudUserDetails? userDetails;
  @override
  void initState() {
    super.initState();
    _userDetailsService = FirebaseCloudStorage();
    _fetchUserDetails();
  }

  String activityLevel = '';
  String email = '';
  String gender = '';
  String goal = '';
  int height = 0;
  int weight = 0;
  List<String> userDiseases = [];

  // Parse the UTC date string and convert it to local time
  DateTime dateOfBirth = DateTime.parse('1999-12-21T08:00:00Z').toLocal();

  Future<void> _fetchUserDetails() async {
    try {
      final userId = AuthService.firebase().currentUser?.id;
      if (userId == null) {
        throw Exception("User ID is null");
      }

      // Fetch user details excluding email
      final CloudUserDetails userDetails =
          await _userDetailsService.getUserDetails(ownerUserId: userId);

      // Get the current user from FirebaseAuth to retrieve the email
      // final currentUser = AuthService.firebase().currentUser;

      setState(
        () {
          activityLevel = userDetails.userActivityLevel;
          dateOfBirth = userDetails.userDateOfBirth;
          userDiseases = userDetails.userDiseases;
          gender = userDetails.userGender;
          goal = userDetails.userGoal;
          height = userDetails.userHeight;
          weight = userDetails.userWeight;
          // email = currentUser!
          //     .email; // Retrieve the email directly from the current user
        },
      );
    } catch (e) {
      throw CouldNotGetUserDetailsException();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      body: StreamBuilder<CloudUserDetails>(
        stream: FirebaseCloudStorage().getUserDetailsStream(
          ownerUserId: AuthService.firebase().currentUser!.id,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            ); // Display a loading spinner while waiting for the data
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            ); // Display error if any occurs
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text('No user data available'),
            ); // Display message if there's no data
          } else {
            final CloudUserDetails userDetails = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  itemProfile(
                    'Date of Birth',
                    DateFormat('dd/MM/yyyy')
                        .format(userDetails.userDateOfBirth),
                    CupertinoIcons.calendar,
                    context,
                    () {
                      Navigator.pushNamed(
                        context,
                        editUserProfileRoute,
                        arguments: {'dateOfBirth': userDetails.userDateOfBirth},
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  itemProfile(
                    'Weight',
                    '${userDetails.userWeight} kg',
                    CupertinoIcons.gauge,
                    context,
                    () {
                      Navigator.pushNamed(
                        context,
                        editUserProfileRoute,
                        arguments: {'weight': userDetails.userWeight},
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  itemProfile(
                    'Height',
                    '${userDetails.userHeight} cm',
                    CupertinoIcons.person,
                    context,
                    () {
                      Navigator.pushNamed(
                        context,
                        editUserProfileRoute,
                        arguments: {'height': userDetails.userHeight},
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  itemProfile(
                    'Diseases',
                    userDetails.userDiseases.isNotEmpty
                        ? userDetails.userDiseases.join(', ')
                        : 'Not applicable',
                    CupertinoIcons.bandage,
                    context,
                    () {
                      Navigator.pushNamed(
                        context,
                        editUserProfileRoute,
                        arguments: {'userDiseases': userDetails.userDiseases},
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  itemProfile(
                    'Gender',
                    userDetails.userGender,
                    CupertinoIcons.person_2,
                    context,
                    () {
                      Navigator.pushNamed(
                        context,
                        editUserProfileRoute,
                        arguments: {'gender': userDetails.userGender},
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  itemProfile(
                    'Goal',
                    userDetails.userGoal,
                    CupertinoIcons.hand_thumbsup,
                    context,
                    () {
                      Navigator.pushNamed(
                        context,
                        editUserProfileRoute,
                        arguments: {'goal': userDetails.userGoal},
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  itemProfile(
                    'Activity Level',
                    userDetails.userActivityLevel,
                    CupertinoIcons.graph_circle,
                    context,
                    () {
                      Navigator.pushNamed(
                        context,
                        editUserProfileRoute,
                        arguments: {
                          'activityLevel': userDetails.userActivityLevel
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  _changePasswordButton(context),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  SizedBox _changePasswordButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () {
          Navigator.pushNamed(context, editUserPasswordRoute);
        },
        style: TextButton.styleFrom(
          backgroundColor: Colors.blue.shade300,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
        ),
        child: const Text(
          'Change Password',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  itemProfile(String title, String subtitle, IconData iconData,
      BuildContext context, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                offset: const Offset(0, 5),
                color: Colors.blue.withOpacity(.2),
                spreadRadius: 2,
                blurRadius: 10)
          ]),
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        leading: Icon(iconData),
        trailing: GestureDetector(
          onTap: onTap, // Call the function when tapped
          child: Icon(Icons.arrow_forward, color: Colors.grey.shade400),
        ),
        tileColor: Colors.white,
      ),
    );
  }

  AppBar appBar(BuildContext context) {
    return AppBar(
      title: const Text(
        'Your Profile',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      centerTitle: true,
    );
  }
}
