import 'package:flutter/material.dart';

class TextHeading extends StatelessWidget {

  TextHeading({@required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(
          text,
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
              letterSpacing: 1.5
          ),
        ),
      ),
    );
  }
}