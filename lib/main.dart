import 'package:employee/SplashScreen.dart';
import 'package:employee/constants.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(

        accentColor: kLightBlue,
        fontFamily: "General"
      ),
      home: SplashScreen(),
    );
  }
}
