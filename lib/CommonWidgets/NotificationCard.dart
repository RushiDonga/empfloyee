import 'package:flutter/material.dart';

import '../constants.dart';

class NotificationCard extends StatelessWidget {

  NotificationCard({@required this.icon, @required this.time, @required this.description, @required this.date, @required this.title, @required this.onClick, @required this.seen});
  final IconData icon;
  final String title;
  final String description;
  final String date;
  final String time;
  final bool seen;
  final dynamic onClick;


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClick,
      child: Card(
        elevation: 0.5,
        margin: EdgeInsets.symmetric(vertical: 1.5, horizontal: 3.0),
        color: seen == true? Colors.white : Colors.indigo[50],
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  ClipOval(
                    child: Material(
                      color: kLightBlue,
                      child: InkWell(
                        child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 11.0),
                            child: Icon(
                              icon,
                              color: Colors.white,
                            )
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 15.0
                        ),
                      ),
                      SizedBox(
                        height: 6.0,
                      ),
                      Row(
                        children: [
                          Text(
                            description.length > 20 ? description.substring(0, 20) + "..." : description,
                            style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13.0
                            ),
                          ),
                          SizedBox(
                            width: 5.0,
                          ),
                          Icon(
                            Icons.arrow_right,
                            color: Colors.black,
                            size: 20.0,
                          ),
                          Text(
                            date,
                            style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 11.0
                            ),
                          ),
                          SizedBox(
                            width: 5.0,
                          ),
                          Text(
                            "@ " + time,
                            style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 11.0
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}