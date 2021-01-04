import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:barter/services/auth.dart';
import 'package:barter/widgets/custom_snackbar.dart';

class LoginScreen extends StatelessWidget {
  void _signInWithGoogle(BuildContext context) async {
    try {
      final User user = await authService.signInWithGoogle();
      if (user != null) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } catch (e) {
      print("Login failed!");
      Scaffold.of(context).showSnackBar(CustomSnackbar(
        content: Text(
          "Login failed!",
          style: TextStyle(fontSize: 18),
        ),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Builder(
        builder: (context) => Center(
          child: RaisedButton(
            onPressed: () => _signInWithGoogle(context),
            child: Text(
              "Signin with Google",
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
