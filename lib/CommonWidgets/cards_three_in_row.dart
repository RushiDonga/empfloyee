import 'package:flutter/material.dart';

class ProfileThreeInRow extends StatelessWidget {

  ProfileThreeInRow({@required this.iconData, @required this.text, @required this.color});
  final Widget iconData;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            child: Align(
              alignment: Alignment.topRight,
              child: iconData
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                text,
                style: TextStyle(
                    color: Colors.black.withOpacity(0.8),
                    fontWeight: FontWeight.bold
                ),
              ),
            ),
          ),
          SizedBox(
            height: 5.0,
          )
        ],
      ),
    );
  }
}