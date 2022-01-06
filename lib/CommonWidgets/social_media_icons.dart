import 'package:flutter/material.dart';

class SocialMediaIcons extends StatelessWidget {

  SocialMediaIcons({@required this.icon});
  final IconButton icon;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: icon
    );
  }
}