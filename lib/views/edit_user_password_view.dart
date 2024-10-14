import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditUserPasswordView extends StatefulWidget {
  const EditUserPasswordView({super.key});

  @override
  State<EditUserPasswordView> createState() => _EditUserPasswordViewState();
}

class _EditUserPasswordViewState extends State<EditUserPasswordView> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _updatePassword() async {
    if (_formKey.currentState!.validate()) {
      String oldPassword = _oldPasswordController.text;
      String newPassword = _newPasswordController.text;
      User? user = _auth.currentUser;

      try {
        // Re-authenticate the user with the old password
        AuthCredential credential = EmailAuthProvider.credential(
          email: user!.email!,
          password: oldPassword,
        );

        await user.reauthenticateWithCredential(credential);

        // Update the password
        await user.updatePassword(newPassword);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password updated successfully!')),
          );
        }

        // Clear the fields after update
        _oldPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      } on FirebaseAuthException catch (e) {
        String message;
        if (e.code == 'wrong-password') {
          message = 'The old password is incorrect.';
        } else {
          message = 'Failed to update password. Please try again.';
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _oldPasswordPart(),
              const SizedBox(
                height: 10,
              ),
              _newPasswordPart(),
              const SizedBox(
                height: 10,
              ),
              _confirmNewPaswordPart(),
              const SizedBox(height: 10),
              _changePasswordButton(),
            ],
          ),
        ),
      ),
    );
  }

  SizedBox _changePasswordButton() {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: _updatePassword,
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

  TextFormField _confirmNewPaswordPart() {
    return TextFormField(
      controller: _confirmPasswordController,
      decoration: const InputDecoration(labelText: 'Confirm New Password'),
      obscureText: true,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please confirm your new password';
        }
        if (value != _newPasswordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
    );
  }

  TextFormField _newPasswordPart() {
    return TextFormField(
      controller: _newPasswordController,
      decoration: const InputDecoration(labelText: 'New Password'),
      obscureText: true,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a new password';
        }
        if (value.length < 6) {
          return 'Password must be at least 6 characters long';
        }
        return null;
      },
    );
  }

  TextFormField _oldPasswordPart() {
    return TextFormField(
      controller: _oldPasswordController,
      decoration: const InputDecoration(labelText: 'Old Password'),
      obscureText: true,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your old password';
        }
        return null;
      },
    );
  }

  AppBar appbar() {
    return AppBar(
      title: const Text(
        'Edit Password',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      centerTitle: true,
    );
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
