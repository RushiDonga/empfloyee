import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:employee/CommonWidgets/CircularLoadingIndicator.dart';
import 'package:employee/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:employee/Globals.dart' as globals;
import 'package:toast/toast.dart';

Firestore _fireStore = Firestore.instance;

class UpdateAttendanceCEO extends StatefulWidget {
  @override
  _UpdateAttendanceCEOState createState() => _UpdateAttendanceCEOState();

  UpdateAttendanceCEO({this.employeeName, this.status, this.documentName});
  final String employeeName;
  final String status;
  final String documentName;
}

class _UpdateAttendanceCEOState extends State<UpdateAttendanceCEO> {

  String documentName = DateTime.now().toString();

  bool isLoading = true;
  bool updated = true;

  _checkIfUpdated(){
    print(widget.documentName);
    _fireStore.collection(globals.companyName).document("CEO Notifications").collection("Notifications").document(widget.documentName).get().then((value){
      setState(() {
        updated = value.data["Updated"];
      });
    }).then((value){
      setState(() {
        isLoading = false;
      });
    }).catchError((onError){
      setState(() {
        isLoading = false;
        Toast.show("Error Fetching Attendance", context, gravity: Toast.BOTTOM, duration: Toast.LENGTH_LONG);
        Navigator.pop(context);
        print(onError);
      });
    });
  }
  
  _updateAttendance(){
    setState(() {
      isLoading = true;
    });
    _fireStore.collection(globals.companyName).document("Attendance").collection("Attendance").document(widget.employeeName)
        .collection(widget.employeeName).document(widget.documentName).updateData({
      "Status": widget.status.toLowerCase() == "present" ? "Absent" : "Present",
    }).then((value){
      _fireStore.collection(globals.companyName).document("CEO Notifications").collection("Notifications").document(widget.documentName).updateData({
        "Updated": true,
      }).then((value){
        _fireStore.collection(globals.companyName).document("Employee").collection("employee").document(widget.employeeName)
            .collection("Notifications").document(documentName).setData({
          "Date": DateTime.now().day.toString() + "-" + DateTime.now().month.toString() + "-" + DateTime.now().year.toString(),
          "Search": DateTime.now().month.toString() + "-" + DateTime.now().year.toString(),
          "Seen": false,
          "Time": DateTime.now().hour.toString() + ":" + DateTime.now().minute.toString(),
          "Type": "UpdatedAttendance",
          "DocumentName": widget.documentName,
          "Status": "Updated",
        }).then((value){
          setState(() {
            isLoading = false;
            Toast.show("Request Updated", context, gravity: Toast.BOTTOM, duration: Toast.LENGTH_LONG);
            Navigator.pop(context);
          });
        }).catchError((onError){
          setState(() {
            isLoading = false;
            Toast.show("Error Updating Attendance", context, gravity: Toast.BOTTOM, duration: Toast.LENGTH_LONG);
          });
        });
      });
    });
  }

  _denyAttendance(){
    _fireStore.collection(globals.companyName).document("CEO Notifications").collection("Notifications").document(widget.documentName).updateData({
      "Updated": true,
    }).then((value){
      _fireStore.collection(globals.companyName).document("Employee").collection("employee").document(widget.employeeName)
          .collection("Notifications").document(documentName).setData({
        "Date": DateTime.now().day.toString() + "-" + DateTime.now().month.toString() + "-" + DateTime.now().year.toString(),
        "Search": DateTime.now().month.toString() + "-" + DateTime.now().year.toString(),
        "Seen": false,
        "Time": DateTime.now().hour.toString() + ":" + DateTime.now().minute.toString(),
        "Type": "UpdatedAttendance",
        "DocumentName": widget.documentName,
        "Status": "Denied",
      }).then((value){
        setState(() {
          isLoading = false;
          Toast.show("Request Denied", context, gravity: Toast.BOTTOM, duration: Toast.LENGTH_LONG);
          Navigator.pop(context);
        });
      }).catchError((onError){
        setState(() {
          isLoading = false;
          Toast.show("Error Denying Attendance", context, gravity: Toast.BOTTOM, duration: Toast.LENGTH_LONG);
        });
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _checkIfUpdated();
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
                "Update Attendance",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0
                ),
              ),
              GestureDetector(
                onTap: (){

                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Icon(
                      Icons.assignment_turned_in
                  ),
                ),
              )
            ],
          ),
        ),
      );
    }

    Widget _mainBody(){
      return Container(
        child: Column(
          children: [
            SizedBox(height: 10.0,),
            Text(
              widget.employeeName,
              style: TextStyle(
                color: Colors.grey[900],
                letterSpacing: 1.0,
                fontSize: 22.0,
                fontFamily: "Dark"
              ),
            ),
            SizedBox(height: 8.0,),
            Text(
              "has requested to update his Attendance \nsince it was marked Wrong as",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                letterSpacing: 0.5,
                fontSize: 15.0
              ),
            ),
            SizedBox(height: 5.0,),
            Text(
              widget.status,
              style: TextStyle(
                color: Colors.black,
                fontSize: 16.5,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 50.0),
              child: Divider(
                height: 1.0,
                color: Colors.grey[700],
              ),
            ),

            updated
            ? Column(
              children: [
                SizedBox(height: 10.0,),
                Text(
                  "Already took an Action!",
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 16.0,
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.bold
                  ),
                )
              ],
            )
                : Column(
              children: [Text(
                "Mark it as ${widget.status == "Present" ? "ABSENT" : "PRESENT"}? ",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  fontSize: 16.0,
                ),
              ),

                SizedBox(height: 10.0,),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      RaisedButton(
                        onPressed: (){
                          _updateAttendance();
                        },
                        color: kLightBlue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(7.0)),
                            side: BorderSide(width: 1.0, color: Colors.white)
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text(
                            "UPDATE",
                            style: TextStyle(
                                color: Colors.white,
                                letterSpacing: 1.0
                            ),
                          ),
                        ),
                      ),

                      RaisedButton(
                        onPressed: (){
                          _denyAttendance();
                        },
                        color: kLightBlue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(7.0)),
                            side: BorderSide(width: 1.0, color: Colors.white)
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: Text(
                            "DENY",
                            style: TextStyle(
                                color: Colors.white,
                                letterSpacing: 1.0
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )],
            )
          ],
        ),
      );
    }

    return Scaffold(
      body: isLoading
          ? circularProgress()
          : SafeArea(
        child: Column(
          children: [
            _appBar(),
            _mainBody(),
          ],
        ),
      ),
    );
  }
}
