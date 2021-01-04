import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:barter/services/navigation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(BarterApp());
}

class BarterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Barter",
      onGenerateRoute: Router.generateRoute,
      initialRoute: '/splash',
      theme: ThemeData(
        primaryColor: Color.fromRGBO(0, 165, 79, 1),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          color: Colors.white,
          shadowColor: Colors.green[100],
        ),
        textTheme: TextTheme(
          headline6: TextStyle(fontSize: 22, height: 1),
          bodyText1: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            height: 1.2,
          ),
          subtitle1:
              TextStyle(fontSize: 14, color: Colors.grey, letterSpacing: 0.4),
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Color.fromRGBO(0, 165, 79, 1),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
      ),
    );
  }
}
