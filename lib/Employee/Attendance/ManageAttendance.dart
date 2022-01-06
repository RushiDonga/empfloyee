import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:employee/CommonWidgets/CircularLoadingIndicator.dart';
import 'package:employee/constants.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:employee/Globals.dart' as globals;
import 'package:toast/toast.dart';

Firestore _fireStore = Firestore.instance;

class ManageAttendance extends StatefulWidget {
  @override
  _ManageAttendanceState createState() => _ManageAttendanceState();
}

class _ManageAttendanceState extends State<ManageAttendance> {

  String selected = "";

  bool isLoading = true;
  
  _getSelected(){
    _fireStore.collection(globals.companyName).document("Attendance").get().then((value){
      setState(() {
        selected = value.data["Type"];
      });
    }).then((value){
      print("SUCCESS IN GETTING ATTENDANCE TYPE");
    }).catchError((onError){
      print("ERROR IN GETTING ATTENDANCE TYPE");
    });
    setState(() {
      isLoading = false;
    });
  }

  _updateAttendanceType(){
    setState(() {
      isLoading = true;
    });
    _fireStore.collection(globals.companyName).document("Attendance").updateData({
      "Type": selected,
    }).then((value){
      print("UPDATED");
      Toast.show("Updated", context, gravity: Toast.BOTTOM, duration: Toast.LENGTH_LONG);
      Navigator.pop(context);
    }).catchError((onError){
      print("ERROR UPDATING");
      print(onError);
      Toast.show("Error Updating", context, gravity: Toast.BOTTOM, duration: Toast.LENGTH_LONG);
    });
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _getSelected();
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
                "Manage Attendance",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0
                ),
              ),
              GestureDetector(
                onTap: (){
                  _updateAttendanceType();
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

    Widget _content(){
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 5.0,
          ),
          Text(
            "Emp-Floyee",
            style: TextStyle(
              color: Colors.black,
              fontSize: 22.0,
              letterSpacing: 1.0,
              fontFamily: "Dark"
            ),
          ),
          SizedBox(
            height: 6.0,
          ),
          Text(
            "supports the following three ways \nfor taking the Attendance\n of the Employee",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              letterSpacing: 0.5,
              fontSize: 16.0
            ),
          ),
          SizedBox(
            height: 10.0,
          ),

          SingleChildScrollView(
            child: Column(
              children: [
                GestureDetector(
                  onTap: (){
                    setState(() {
                      selected = "ManuallyFill";
                    });
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.symmetric(horizontal: 5.0),
                    child: Card(
                      color: selected == "ManuallyFill" ? kLightBlue.withOpacity(0.2) : Colors.white,
                      elevation: 0.5,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.how_to_vote,
                                  color: Colors.black,
                                    size: 30.0,
                                ),
                                SizedBox(
                                  width: 10.0,
                                ),
                                Text(
                                  "Manually Fill the Attendance",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15.0
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 35.0, right: 10.0),
                              child: Divider(
                                color: Colors.grey[700],
                              ),
                            ),
                            Text(
                              "The Manager of the Company needs to Manually fill the Attendance of all the Employee",
                              style: TextStyle(
                                color: Colors.grey[800],
                                letterSpacing: 0.3
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                GestureDetector(
                  onTap: (){
                    setState(() {
                      selected = "AllowEmployee";
                    });
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.symmetric(horizontal: 5.0),
                    child: Card(
                      elevation: 0.5,
                      color: selected == "AllowEmployee" ? kLightBlue.withOpacity(0.2) : Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.how_to_vote,
                                  color: Colors.black,
                                  size: 30.0,
                                ),
                                SizedBox(
                                  width: 10.0,
                                ),
                                Text(
                                  "Allow Employee to fill the Attendance",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15.0
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 35.0, right: 10.0),
                              child: Divider(
                                color: Colors.grey[700],
                              ),
                            ),
                            Text(
                              "The Manager of the Company needs to \nTURN-ON each day Attendance, then and only then the Employee can fill the Attendance for the same day",
                              style: TextStyle(
                                  color: Colors.grey[800],
                                  letterSpacing: 0.3
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.symmetric(horizontal: 5.0),
                  child: Card(
                    elevation: 0.5,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.how_to_vote,
                                color: Colors.black,
                                size: 30.0,
                              ),
                              SizedBox(
                                width: 10.0,
                              ),
                              Text(
                                "Scan Cards",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15.0
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 35.0, right: 10.0),
                            child: Divider(
                              color: Colors.grey[700],
                            ),
                          ),
                          Text(
                            "Scan Cards to fill the Attendance of the Employee by installing a Card Scanner Machine",
                            style: TextStyle(
                                color: Colors.grey[800],
                                letterSpacing: 0.3
                            ),
                          ),
                          SizedBox(
                            height: 7.0,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width-10,
                            height: 32.0,
                            child: RaisedButton(
                                onPressed:  (){},
                              color: Colors.grey[900],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(7.0)),
                                side: BorderSide(width: 1.0, color: Colors.white, style: BorderStyle.solid)
                              ),
                              child: Text(
                                "CONTACT US",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 1.0
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      );
    }

    Widget _mainBody(){
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              _appBar(),
              isLoading
              ? circularProgress()
                  : _content(),
            ],
          ),
        ),
      );
    }

    return _mainBody();
  }
}