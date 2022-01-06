import 'package:employee/CEO/Search_CEO.dart';
import 'package:employee/Employee/SearchEmployee.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:employee/Globals.dart' as globals;
import '../constants.dart';

class SearchToday extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        if(globals.position == "CEO"){
          Navigator.push(context, MaterialPageRoute(builder: (context) => SearchManager()));
        }else{
          Navigator.push(context, MaterialPageRoute(builder: (context) => SearchEmployee()));
        }
      },
      child: Hero(
        tag: "search",
        child: Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0))
            ),
            margin: EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.0),
            child: Row(
              children: <Widget>[
                IconButton(
                  onPressed: (){},
                  icon: FaIcon(FontAwesomeIcons.search),
                  color: kLightBlue,
                ),
                Text(
                  "Search",
                  style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 18.0
                  ),
                )
              ],
            )
        ),
      ),
    );
  }
}