import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    final User _user = FirebaseAuth.instance.currentUser;
    if (_user == null) {
      Future.delayed(
        Duration.zero,
        () => Navigator.of(context).pushReplacementNamed('/login'),
      );
    } else {
      Future.delayed(
        Duration.zero,
        () => Navigator.of(context).pushReplacementNamed('/'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            child: Center(
              child: Icon(Icons.compare_arrows, color: Colors.white, size: 48),
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 24),
            child: CircularProgressIndicator(),
          )
        ],
      ),
    );
  }
}
