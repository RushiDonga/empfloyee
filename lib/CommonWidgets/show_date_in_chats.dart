import 'package:flutter/material.dart';

class ShowDateInChats extends StatelessWidget {

  ShowDateInChats({this.date});
  final String date;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.teal[50],
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 7.0),
        child: Text(
          date,
          style: TextStyle(
              color: Colors.black
          ),
        ),
      ),
    );
  }
}