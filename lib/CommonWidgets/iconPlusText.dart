import 'package:flutter/material.dart';
import 'package:employee/constants.dart';
import 'dart:ui';

class IconPlusText extends StatelessWidget {

  final String selected;
  final String text;
  final IconData icon;

  IconPlusText({this.selected, this.text, this.icon});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        decoration: BoxDecoration(
            color: selected == text ? kBlueColor : Colors.white,
            borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              spreadRadius: 2.0,
              blurRadius: 5.0,
              offset: Offset(0, 3),
            )
          ]
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Column(
            children: <Widget>[
              Icon(
                icon,
                color: selected == text ? Colors.white : kBlueColor,
                size: 60.0,
              ),
              SizedBox(
                height: 5.0,
              ),
              Text(
                text,
                style: TextStyle(
                    color: selected == text ? Colors.white : kBlueColor,
                    fontSize: 17.0,
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.bold
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}