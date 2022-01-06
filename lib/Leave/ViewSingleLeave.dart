import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:employee/CommonWidgets/CircularLoadingIndicator.dart';
import 'package:employee/CommonWidgets/text_heading.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:toast/toast.dart';
import 'package:employee/Globals.dart' as globals;
import '../constants.dart';

Firestore _fireStore  = Firestore.instance;

class ViewSingleLeave extends StatefulWidget {
  @override
  _ViewSingleLeaveState createState() => _ViewSingleLeaveState();

  ViewSingleLeave({this.employeeName, this.documentName});
  final String employeeName;
  final String documentName;
}

class _ViewSingleLeaveState extends State<ViewSingleLeave> {

  bool isLoading = true;
  String _name = "";
  String _fromDate = "";
  String _toDate = "";
  String _leaveType = "";
  String _description = "";
  String _status = "";

  _updateLeaveStatus(String status, String employeeName, String documentName){
    setState(() {
      isLoading = true;
    });
    _fireStore.collection(globals.companyName).document("Employee").collection("employee").document(employeeName).collection("Leaves")
        .document(documentName).updateData({
      "Status": status,
    }).then((value){
      setState(() {
        isLoading = false;
        Navigator.pop(context);
      });
      Toast.show("Leave $status Successfully..!", context, gravity: Toast.BOTTOM, duration: Toast.LENGTH_LONG);
    }).catchError((onError){
      setState(() {
        isLoading = false;
      });
      Toast.show("Error updating leave Status", context, gravity: Toast.BOTTOM, duration: Toast.LENGTH_LONG);
    });
  }

  _getActualLeave(){
    _fireStore.collection(globals.companyName).document("Employee").collection("employee").document(widget.employeeName)
        .collection("Leaves").document(widget.documentName).get().then((value){
      setState(() {
        _name = widget.employeeName;
        _fromDate = value.data["From Date"];
        _toDate = value.data["To Date"];
        _leaveType = value.data["Leave Type"];
        _description = value.data["Description"];
        _status = value.data["Status"];
      });
    }).then((value){
      setState(() {
        isLoading = false;
      });
    }).catchError((onError){
      print("ERROR");
      print(onError);
    });
  }

  @override
  void initState() {
    super.initState();

    _getActualLeave();
    print(widget.documentName);
    print(widget.employeeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
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
                      "View Leave",
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
            ),

            isLoading
            ? Container(
              width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height - 150,
                child: circularProgress()
            )
                : SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: Card(
                  elevation: 1.0,
                  margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0))
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          TextHeading(text: "Name:          ",),
                          Text(
                            _name,
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                                fontSize: 16.0
                            ),
                          )
                        ],
                      ),

                      Row(
                        children: [
                          TextHeading(text: "From Date:  ",),
                          Text(
                            _fromDate,
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                                fontSize: 16.0
                            ),
                          )
                        ],
                      ),

                      Row(
                        children: [
                          TextHeading(text: "To Date:      ",),
                          Text(
                            _toDate,
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                                fontSize: 16.0
                            ),
                          )
                        ],
                      ),

                      Row(
                        children: [
                          TextHeading(text: "Leave Type:",),
                          Text(
                            _leaveType,
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                                fontSize: 16.0
                            ),
                          )
                        ],
                      ),

                      TextHeading(text: "Description:",),
                      Padding(
                        padding: const EdgeInsets.only(left: 19.0),
                        child: Text(
                          _description,
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                              fontSize: 16.0
                          ),
                        ),
                      ),

                      SizedBox(
                        height: 10.0,
                      ),

                      _status == "Sent"
                          ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          RaisedButton(
                            onPressed: (){
                              _updateLeaveStatus("Approved", widget.employeeName, widget.documentName);
                            },
                            color: kLightBlue,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(7.0)),
                                side: BorderSide(width: 1.0, color: Colors.white, style: BorderStyle.solid)
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 18.0),
                              child: Text(
                                "Approve",
                                style: TextStyle(
                                    color: Colors.white
                                ),
                              ),
                            ),
                          ),

                          RaisedButton(
                            onPressed: (){
                              _updateLeaveStatus("Declined", widget.employeeName, widget.documentName);
                            },
                            color: kLightBlue,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(7.0)),
                                side: BorderSide(width: 1.0, color: Colors.white, style: BorderStyle.solid)
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 18.0),
                              child: Text(
                                "Decline",
                                style: TextStyle(
                                    color: Colors.white
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                          : Center(
                        child: RaisedButton(
                          onPressed: (){},
                          color: kLightBlue,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(7.0)),
                              side: BorderSide(width: 1.0, color: Colors.white, style: BorderStyle.solid)
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18.0),
                            child: Text(
                              _status,
                              style: TextStyle(
                                  color: Colors.white
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(
                        height: 10.0,
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
