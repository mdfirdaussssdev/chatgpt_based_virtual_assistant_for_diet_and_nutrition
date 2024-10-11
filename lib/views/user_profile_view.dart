import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UserProfileView extends StatefulWidget {
  const UserProfileView({super.key});

  @override
  State<UserProfileView> createState() => _UserProfileViewState();
}

class _UserProfileViewState extends State<UserProfileView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            itemProfile('Email', 'test@gmail.com', CupertinoIcons.mail),
            const SizedBox(height: 10),
            itemProfile('Date of Birth', '21/12/1999', CupertinoIcons.calendar),
            const SizedBox(height: 10),
            itemProfile('Weight', '60 kg', CupertinoIcons.gauge),
            const SizedBox(height: 10),
            itemProfile('Height', '160 cm', CupertinoIcons.person),
            const SizedBox(height: 10),
            itemProfile('Diseases', 'not applicable', CupertinoIcons.bandage),
            const SizedBox(height: 10),
            itemProfile('Gender', 'Male', CupertinoIcons.person_2),
            const SizedBox(height: 10),
            itemProfile('Goal', 'Lose Weight', CupertinoIcons.hand_thumbsup),
            const SizedBox(height: 10),
            itemProfile(
                'Activity Level', 'Active', CupertinoIcons.graph_circle),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {},
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
            )
          ],
        ),
      ),
    );
  }

  itemProfile(String title, String subtitle, IconData iconData) {
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
        trailing: Icon(Icons.arrow_forward, color: Colors.grey.shade400),
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
