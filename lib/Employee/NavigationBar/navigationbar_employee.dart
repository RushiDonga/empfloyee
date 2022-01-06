import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
import 'package:employee/CEO/Add_Employee/add_employee.dart';
import 'package:employee/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'today_employee.dart';
import 'notifications_employee.dart';
import 'profile_employee.dart';
import '../../Globals.dart' as globals;

class EmployeeNavigationBar extends StatefulWidget {
  @override
  _EmployeeNavigationBarState createState() => _EmployeeNavigationBarState();

  EmployeeNavigationBar({this.status});
  final String status;
}

class _EmployeeNavigationBarState extends State<EmployeeNavigationBar> {

  int _currentIndex = 0;

  _getUserDetails() async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    FirebaseUser _user = await _auth.currentUser();
    globals.userId = _user.uid.toString();

    DatabaseReference _getCompanyDetails = FirebaseDatabase.instance.reference().child("AllUsers").child(globals.userId);
    _getCompanyDetails.child("CompanyName").once().then((value){  // Get the Company Name
      setState(() {
        globals.companyName = value.value;
      });
    }).then((value){

      _getCompanyDetails.child("Name").once().then((value){  // Get the Company Name
        setState(() {
          globals.userName = value.value;
        });
      }).then((value){
         // Get the Position of the User
        DatabaseReference _database = FirebaseDatabase.instance.reference().child("AllUsers").child(globals.userId);
        _database.child("IamA").once().then((value){
          globals.position = value.value;
        }).then((value) async {

          // Todo add all the new methods from here

          SharedPreferences _prefs = await SharedPreferences.getInstance();
          globals.email = _prefs.getString('email');

          if(widget.status == "loggedIn"){
            _addLoggedInNotification();
          }
        });
      });
    });
  }

  _addLoggedInNotification(){
    String document = DateTime.now().toString();
    fireStore.collection(globals.companyName).document("CEO Notifications").collection("Notifications").document(document).setData({
      "Search": DateTime.now().month.toString() + "-" + DateTime.now().year.toString(),
      "Type": "EmployeeLoggedIn",
      "Date": DateTime.now().day.toString() + "-" + DateTime.now().month.toString() + "-" + DateTime.now().year.toString(),
      "DocumentName": document,
      "EmployeeName": globals.userName,
      "Seen": false,
      "Time": DateTime.now().hour.toString() + ":" + DateTime.now().month.toString(),
    });
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
              print(index);
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
            ? TodayEmployee()
            : _currentIndex == 1
              ? NotificationsEmployee()
              : _currentIndex == 2
                ? ProfilePageEmployee()
                : TodayEmployee(),
    );
  }
}
