import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:employee/CommonWidgets/CircularLoadingIndicator.dart';
import 'package:employee/CommonWidgets/text_heading.dart';
import 'package:flutter/material.dart';
import 'package:employee/Globals.dart' as globals;
import 'package:toast/toast.dart';

import '../constants.dart';
import 'AssignWork.dart';

Firestore _fireStore = Firestore.instance;

class ViewSingleWork extends StatefulWidget {
  @override
  _ViewSingleWorkState createState() => _ViewSingleWorkState();

  ViewSingleWork({this.documentName,this.employeeName});
  final String documentName;
  final String employeeName;
}

class _ViewSingleWorkState extends State<ViewSingleWork> {

  String _fromDate = "";
  String _toDate = "";
  String _description = "";
  String _priority = "";
  String _document = "";
  bool _status = false;

  bool isLoading = true;

  _getWorkDetails(){
    _fireStore.collection(globals.companyName).document("Works").collection("Employee").document(widget.employeeName).collection(widget.employeeName)
        .document(widget.documentName).get().then((value){
          setState(() {
            _fromDate = value.data["Start Date"];
            _toDate = value.data["End Date"];
            _description = value.data["Description"];
            _document = value.data["Document"];
            _status = value.data["Status"];
            _priority = value.data["Priority"];
          });
    }).then((value){
      setState(() {
        isLoading = false;
      });
    });
  }

  _updateWorkStatus(){
    setState(() {
      isLoading = true;
    });
    _fireStore.collection(globals.companyName).document("Works").collection("Employee").document(globals.userName).collection(globals.userName)
        .document(widget.documentName).updateData({
      "Status": true,
    }).then((value){
      setState(() {
        Toast.show("Marked as Done :)", context, gravity: Toast.BOTTOM, duration: Toast.LENGTH_LONG);
        _getWorkDetails();
      });
    }).catchError((onError){
      setState(() {
        isLoading = false;
      });
      Navigator.pop(context);
      Toast.show("Error Marking as Done :(", context, gravity: Toast.BOTTOM, duration: Toast.LENGTH_LONG);
    });
  }

  Widget _mainBody(){
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
              child: Container(
                height: 60.0,
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0))
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        GestureDetector(
                          onTap: (){
                            Navigator.pop(context);
                          },
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.black,
                            size: 25.0,
                          ),
                        ),
                        Text(
                          "New Work",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                              letterSpacing: 1.0
                          ),
                        ),
                        SizedBox()
                      ],
                    ),
                  ),
                ),
              ),
            ),

            Card(
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
                      TextHeading(text: "Start Date:  ",),
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
                      TextHeading(text: "End Date:    ",),
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
                      TextHeading(text: "Priority:      ",),
                      Text(
                        _priority,
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
                      TextHeading(text: "Status:        ",),
                      Text(
                        _status == true ? "Completed" : "Not Yet Completed",
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

                  _status
                      ? globals.position == "CEO"
                  ? Center(
                    child: RaisedButton(
                      onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => AssignWork(
                          name: widget.employeeName,
                          newWork: true,
                        )));
                      },
                      color: kLightBlue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(7.0)),
                          side: BorderSide(width: 1.0, color: Colors.white, style: BorderStyle.solid)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18.0),
                        child: Text(
                          "Assign Work ?",
                          style: TextStyle(
                              color: Colors.white
                          ),
                        ),
                      ),
                    ),
                  )
                  : SizedBox()
                      : Center(
                    child: RaisedButton(
                      onPressed: (){
                        _updateWorkStatus();
                      },
                      color: kLightBlue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(7.0)),
                          side: BorderSide(width: 1.0, color: Colors.white, style: BorderStyle.solid)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18.0),
                        child: Text(
                          "Mark as Done ?",
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

          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    print(widget.documentName);
    _getWorkDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? circularProgress()
          : _mainBody()
    );
  }
}
