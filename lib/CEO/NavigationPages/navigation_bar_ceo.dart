import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
import 'package:employee/constants.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile_page_ceo.dart';
import 'notification_page_ceo.dart';
import 'today_page_ceo.dart';
import '../../Globals.dart' as globals;
import '../../CEO/CommonMethods/GenerateTodayDate.dart';

class CEONavigationBar extends StatefulWidget {
  @override
  _CEONavigationBarState createState() => _CEONavigationBarState();
}

class _CEONavigationBarState extends State<CEONavigationBar> {
  GeneralInfo _info = new GeneralInfo();

  var noLeap = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
  var leap = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

  _getUserDetails() async {

    SharedPreferences _prefs = await SharedPreferences.getInstance();
    globals.userId = _prefs.getString('emailUID');

    //globals.userId = _user.uid.toString();

    DatabaseReference _getCompanyDetails = FirebaseDatabase.instance.reference().child("AllUsers").child(globals.userId);
    _getCompanyDetails.child("CompanyName").once().then((value){  // Get the Company Name
      setState(() {
        globals.companyName = value.value;
      });
    }).then((value){

      // Now get the User Name
      _getCompanyDetails.child("ceoName").once().then((value){  // Get the User Name
        setState(() {
          globals.userName = value.value;
          print(globals.userName);
        });
      }).then((value) async {
        // _updateAttendanceEachDay();
        DatabaseReference _database = FirebaseDatabase.instance.reference().child("AllUsers").child(globals.userId);
        _database.child("IamA").once().then((value){
          globals.position = value.value;
        });

        // Get the User Email Address
        SharedPreferences _prefs = await SharedPreferences.getInstance();
        globals.email = _prefs.getString('email');
      });
    });

  }

  //  For Navigating through pages
  int _currentIndex = 0;

  String getYesterdayDate(){
    int day, month, year;
    if(DateTime.now().day == 1 && DateTime.now().month == 1){
      year = DateTime.now().year - 1;
      month = 12;
      day = 31;
    }else{
      year = DateTime.now().year;
      if(DateTime.now().day == 1){
        month = DateTime.now().month - 1;
        if(_info.checkIfLeap(year)){
          day = leap[month-1];
        }else{
          day = noLeap[month-1];
        }
      }else{
        month = DateTime.now().month;
        day = DateTime.now().day-1;
      }
    }
    return day.toString() + "-" + month.toString() + "-" + year.toString();
  }

  @override
  void initState() {
    super.initState();

    _getUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BubbleBottomBar(
        items: <BubbleBottomBarItem>[
          BubbleBottomBarItem(
            backgroundColor: kLightBlue,
              icon: Icon(
                Icons.home,
                color: Colors.black,
              ),
            activeIcon: Icon(
              Icons.home,
              color: Colors.black,
            ),
            title: Text(
              "Home",
              style: TextStyle(
                  color: Colors.black
              ),
            )
          ),

          BubbleBottomBarItem(
              backgroundColor: kLightBlue,
              icon: Icon(
                Icons.add_alert,
                color: Colors.black,
              ),
              activeIcon: Icon(
                Icons.add_alert,
                color: Colors.black,
              ),
              title: Text(
                  "  Notification  ",
                style: TextStyle(
                    color: Colors.black
                ),
              )
          ),

          BubbleBottomBarItem(
              backgroundColor: kLightBlue,
              icon: Icon(
                Icons.dashboard,
                color: Colors.black,
              ),
              activeIcon: Icon(
                Icons.dashboard,
                color: Colors.black,
              ),
              title: Text(
                  "Profile",
                style: TextStyle(
                  color: Colors.black
                ),
              )
          ),
        ],
        onTap: (index){
          setState(() {
            _currentIndex = index;
          });
        },
        opacity: 0.3,
        backgroundColor: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
        currentIndex: _currentIndex,
        hasInk: true,
        inkColor: kLightBlue,
        hasNotch: true,
        fabLocation: BubbleBottomBarFabLocation.end,
      ),
        body: _currentIndex == 0
            ? TodoPage()
            : _currentIndex == 1
              ? NotificationPage()
              : _currentIndex == 2
                ? ProfilePage()
                : TodoPage(),
    );
  }
}
