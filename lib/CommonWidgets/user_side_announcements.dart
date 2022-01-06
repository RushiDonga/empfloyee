import 'package:flutter/material.dart';

class UserSideAnnouncements extends StatelessWidget {
  const UserSideAnnouncements({
    @required this.message,
    @required this.time,
    @required this.totalMembers,
    @required this.membersSeen,
  });

  final String message;
  final String time;
  final int totalMembers;
  final List<dynamic> membersSeen;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Card(
          margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0),
          color: Colors.cyan[50],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(topRight: Radius.circular(15.0), topLeft: Radius.circular(25.0), bottomRight: Radius.circular(5.0), bottomLeft: Radius.circular(15.0)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
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
                      time,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 12.0
                      ),
                    ),
                    SizedBox(
                      width: 5.0,
                    ),
                    Icon(
                      totalMembers == membersSeen.length ? Icons.done_all : Icons.done,
                      color: Colors.black,
                      size: 13.0,
                    )
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