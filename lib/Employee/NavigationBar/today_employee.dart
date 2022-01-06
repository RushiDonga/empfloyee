import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:employee/CommonWidgets/CircularLoadingIndicator.dart';
import 'package:employee/CommonWidgets/show_weather.dart';
import 'package:employee/CommonWidgets/text_heading.dart';
import 'package:employee/CommonWidgets/two_in_row_text_button.dart';
import 'package:employee/CommonWidgets/two_in_rows_text_icon_button.dart';
import 'package:employee/Teams/view_teams_ceo.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../../CommonWidgets/search_employee.dart';
import '../../constants.dart';
import '../Attendance/TodayAttendance.dart';
import '../../Globals.dart' as globals;
import '../../Work/EmployeeViewWork.dart';

Firestore _fireStore = Firestore.instance;

class TodayEmployee extends StatefulWidget {
  @override
  _TodayEmployeeState createState() => _TodayEmployeeState();
}

class _TodayEmployeeState extends State<TodayEmployee> {
  String todayDate = DateTime.now().day.toString() + "-" + DateTime.now().month.toString() + "-" + DateTime.now().year.toString();
  bool filled = false;
  bool isLoading = false;
  
  _checkIfAttendanceStarted() async {
    setState(() {
      isLoading = true;
    });
    await _fireStore.collection(globals.companyName).document("Attendance").get().then((value){
      if(value.data["TodayAttendance"] == true && value.data["Date"] == todayDate){ // Attendance has been Started
        _checkIfAttendanceFilled();
      }else{
        setState(() {
          isLoading = false;
        });
        _showDialogWithSingleButton(
            "Hey ${globals.userName}",
            "Attendance has not yet Started",
            "OKAY",
            (){
              Navigator.pop(context);
            },
        );
      }
    });
  }

  _checkIfAttendanceFilled() async {
    String documentName;
    await _fireStore.collection(globals.companyName).document("Attendance").get().then((value){
      setState(() {
        documentName = value.data["DocumentName"];
      });
    }).then((value) async{
      setState(() {
        isLoading = false;
      });
      bool filled;
      await _fireStore.collection(globals.companyName).document("Attendance").collection("Attendance").document(globals.userName)
          .collection(globals.userName).document(documentName).get().then((value){
        filled = value.data["filled"];
      }).then((value){
        if(filled == true){
          _showDialogWithSingleButton(
              "Hey ${globals.userName}",
              "Your Attendance is Already taken !",
              "OKAY",
                  (){
                Navigator.pop(context);
              }
          );
        }else{
          _fillAttendance();
        }
      }).catchError((onError){
        setState(() {
          isLoading = false;
        });
        print(onError);
      });
    });
  }

  _fillAttendance() {
    // If the Attendance is not filled
    _showDialogWithTwoButtons(
        "Hey ${globals.userName}",
        "What's your Status for Today ?",
        "PRESENT",
        "ABSENT",
            () async { // For PRESENT
              _attendanceLogic("Present");
              Navigator.pop(context);
           },

            () async { // For ABSENT
              _attendanceLogic("Absent");
          Navigator.pop(context);
        }
    );
  }

  // Registering the Attendance in the Database
  _attendanceLogic(String fill) async {
    String documentName;
    await _fireStore.collection(globals.companyName).document("Attendance").get().then((value){
      documentName = value.data["DocumentName"];
    }).then((value) async{
      await _fireStore.collection(globals.companyName).document("Attendance").collection("Attendance")
          .document(globals.userName).collection(globals.userName).document(documentName).updateData({
        "Status": fill,
        "Time": DateTime.now().hour.toString() + "-" + DateTime.now().minute.toString(),
        "Date": todayDate,
        "filled": true,
      }).then((value){
        setState(() {
          isLoading = false;
        });
      });
    });
  }

  _showDialogWithSingleButton(String title, String description, String buttonText,dynamic onPressed){
    Alert(
        context: context,
        title: title,
        desc: description,
        buttons: [
          DialogButton(
            color: kLightBlue,
            onPressed: (){
              onPressed();
            },
            child: Text(
              buttonText,
              style: TextStyle(
                  color: Colors.white
              ),
            ),
          ),
        ]
    ).show();
  }

  _showDialogWithTwoButtons(String title, String description, String buttonOneText, String buttonTextTwo, dynamic onPressedOne, dynamic onPressedTwo){
    Alert(
        context: context,
        title: title,
        desc: description,
        buttons: [
          DialogButton(
            color: kLightBlue,
            onPressed: (){
              onPressedOne();
            },
            child: Text(
              buttonOneText,
              style: TextStyle(
                  color: Colors.white
              ),
            ),
          ),
          DialogButton(
            color: kLightBlue,
            onPressed: (){
              onPressedTwo();
            },
            child: Text(
              buttonTextTwo,
              style: TextStyle(
                  color: Colors.white
              ),
            ),
          ),
        ]
    ).show();
  }

  _getAttendanceType(){
    setState(() {
      isLoading = true;
    });
    String _attendanceType = "";
    _fireStore.collection(globals.companyName).document("Attendance").get().then((value){
      _attendanceType = value.data["Type"];
    }).then((value){
      setState(() {
        isLoading = false;
      });
      if(_attendanceType == "AllowEmployee"){
        _checkIfAttendanceStarted();
      }else{
        _showDialogWithSingleButton(
          "Hey ${globals.userName}",
          "You do not have the Permission to fill the Attendance",
          "OKAY",
              (){
            Navigator.pop(context);
          },
        );
      }
    }).catchError((onError){
      print(onError);
      print("ERROR FETCHING THE ATTENDANCE TYPE");
      setState(() {
        isLoading = true;
      });
    });
  }
  
  @override
  void initState() {
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
        ? circularProgress()
          : SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              DisplayWeather(),
              SearchToday(),

              TextHeading(text: "Attendance",),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 11.0),
                child: Row(
                  children: [
                    TwoInRowTextIconButton(
                      buttonText: filled ? "FILLED": "FILL",
                      color: Colors.cyan[50],
                      iconData: Icons.format_color_fill,
                      text: "Fill \nAttendance",
                      onButtonPressed: (){
                        _getAttendanceType();
                      },
                    ),
                    TwoInRowTextIconButton(
                      buttonText: "VIEW",
                      color: Colors.teal[50],
                      iconData: Icons.rate_review,
                      text: "Today's \nAttendance",
                      onButtonPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => TodayAttendance()));
                      },
                    )
                  ],
                ),
              ),
              TextHeading(text: "Teams & Work",),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 11.0),
                child: Row(
                  children: [
                    TwoInRowTextButton(
                      buttonText: "VIEW",
                      color: Colors.indigo[50],
                      onButtonPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => EmployeeViewWork()));
                      },
                      text: "Work",
                    ),
                    TwoInRowTextButton(
                      buttonText: "VIEW",
                      color: Colors.purple[50],
                      onButtonPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ViewTeamsCEO()));
                      },
                      text: "Teams",
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
