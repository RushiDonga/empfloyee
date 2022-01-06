import 'package:flutter/material.dart';

class SenderSideAnnouncements extends StatelessWidget {
  const SenderSideAnnouncements({
    @required this.message,
    @required this.sender,
    @required this.time,
  });

  final String message;
  final String sender;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Card(
          margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0),
          color: Colors.red[50],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(topRight: Radius.circular(25.0), topLeft: Radius.circular(20.0), bottomRight: Radius.circular(20.0), bottomLeft: Radius.circular(5.0)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Icon(
                      Icons.announcement,
                      color: Colors.black,
                      size: 15.0,
                    ),
                    SizedBox(
                      width: 5.0,
                    ),
                    Text(
                      "Announcement",
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 11.5,
                          letterSpacing: 1.0
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 8.0,
                ),
                Text(
                  message,
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold
                  ),
                ),
                SizedBox(
                  height: 5.0,
                ),
                Row(
                  children: <Widget>[
                    Text(
                      "@ $sender",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 12.0
                      ),
                    ),
                    Icon(
                      Icons.arrow_right,
                      color: Colors.black,
                      size: 15.0,
                    ),
                    Text(
                      "$time",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 12.0
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}