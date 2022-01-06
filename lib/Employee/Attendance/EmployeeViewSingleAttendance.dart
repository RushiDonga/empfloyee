import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:employee/CommonWidgets/CircularLoadingIndicator.dart';
import 'package:employee/constants.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:employee/Globals.dart' as globals;
import 'package:toast/toast.dart';

Firestore _fireStore = Firestore.instance;

class EmployeeViewSingleAttendance extends StatefulWidget {
  @override
  _EmployeeViewSingleAttendanceState createState() => _EmployeeViewSingleAttendanceState();

  EmployeeViewSingleAttendance({this.date, this.status, this.documentName});
  final String date;
  final String status;
  final String documentName;
}

class _EmployeeViewSingleAttendanceState extends State<EmployeeViewSingleAttendance> {

  bool isLoading = true;

  bool requested = false;

  _checkIfRequested(){

    _fireStore.collection(globals.companyName).document("Employee").collection("employee").document(globals.userName)
        .collection("Notifications").document(widget.documentName).get().then((value){

      setState(() {
        requested =value.data["Requested"];
      });
    }).then((value){
      setState(() {
        isLoading = false;
      });
    }).catchError((onError){
      setState(() {
        Toast.show("Error Fetching Attendance", context, gravity: Toast.BOTTOM, duration: Toast.LENGTH_LONG);
        Navigator.pop(context);
      });
    });
  }
  
  _updateAttendanceRequest(){
    setState(() {
      isLoading = true;
    });
    _fireStore.collection(globals.companyName).document("CEO Notifications").collection("Notifications").document(widget.documentName).setData({
       "Date": DateTime.now().day.toString() + "-" + DateTime.now().month.toString() + "-" + DateTime.now().year.toString(),
      "DocumentName": widget.documentName,
      "EmployeeName": globals.userName,
      "Search": DateTime.now().month.toString() + "-" + DateTime.now().year.toString(),
      "Seen": false,
      "Time": DateTime.now().hour.toString() + ":" + DateTime.now().minute.toString(),
      "Type": "UpdateAttendance",
      "Status": widget.status,
      "Updated": false,
    }).then((value){

    _fireStore.collection(globals.companyName).document("Employee").collection("employee").document(globals.userName)
        .collection("Notifications").document(widget.documentName).updateData({
      "Requested": true,
    }).then((value){
      setState(() {
        isLoading = false;
        Navigator.pop(context);
      });
    });

    }).catchError((onError){
      setState(() {
        isLoading = false;
        Toast.show("Error Requesting the Manager", context, gravity: Toast.BOTTOM, duration: Toast.LENGTH_LONG);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _checkIfRequested();
  }
  
  @override
  Widget build(BuildContext context) {

    Widget _appBar(){
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                icon: FaIcon(FontAwesomeIcons.arrowLeft),
                onPressed: () {
                  Navigator.pop(context);
                },
                color: Colors.black,
                iconSize: 22.0,
              ),
              Text(
                "Attendance",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0
                ),
              ),
              SizedBox(
                width: 20.0,
              )
            ],
          ),
        ),
      );
    }

    Widget _mainBody(){
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            "${globals.userName}",
            style: TextStyle(
              color: Colors.grey[900],
              letterSpacing: 1.0,
              fontSize: 20.0,
              fontFamily: "Dark"
            ),
          ),

          SizedBox(
            height: 10.0,
          ),

          Text(
            "Your Attendance for ${widget.date} \nis marked as ${widget.status}",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 15.0,
              letterSpacing: 0.5
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 7.5, horizontal: 30.0),
            child: Divider(
              color: Colors.grey[700],
            ),
          ),

          Text(
            "In-case if you think it is wrong,\nyou may Request Manager \nto Update It",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[900],
              fontSize: 14.0,
              letterSpacing: 0.5
            ),
          ),

          SizedBox(height: 7.0,),

          RaisedButton(
            onPressed: (){
              if(!requested){
                _updateAttendanceRequest();
              }
            },
            color: kLightBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(7.0)),
              side: BorderSide(width: 1.0, color: Colors.white)
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(
                requested ? "REQUESTED" : "REQUEST",
                style: TextStyle(
                  color: Colors.white,
                  letterSpacing: 0.7,
                ),
              ),
            ),
          )
        ],
      );
    }

    return Scaffold(
      body: isLoading
          ? circularProgress()
          : SafeArea(
        child: Column(
          children: [
            _appBar(),
            _mainBody()
          ],
        ),
      ),
    );
  }
}
