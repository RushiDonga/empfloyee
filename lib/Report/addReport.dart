import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:employee/CommonWidgets/CircularLoadingIndicator.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:employee/Globals.dart' as globals;
import 'package:toast/toast.dart';

Firestore _fireStore = Firestore.instance;

class AddReport extends StatefulWidget {
  @override
  _AddReportState createState() => _AddReportState();
}

class _AddReportState extends State<AddReport> {

  final _reportController = TextEditingController();

  bool isThereReport = true;
  bool _isLoading = false;

  _uploadReport(){
    setState(() {
      _isLoading = true;
    });

    String _documentName = DateTime.now().toString();

    if(_reportController.text != ""){
      _fireStore.collection(globals.companyName).document("Employee").collection("employee").document(globals.userName).collection("Report").document(_documentName).setData({
        "DocumentName": _documentName,
        "EmployeeName": globals.userName,
        "Date": DateTime.now().day.toString() + "-" + DateTime.now().month.toString() + "-" + DateTime.now().year.toString(),
        "Time": DateTime.now().minute.toString() + ":" + DateTime.now().year.toString(),
        "Report": _reportController.text,
      }).then((value){

        _fireStore.collection(globals.companyName).document("CEO Notifications").collection("Notifications").document(_documentName).setData({
          "Date": DateTime.now().day.toString() + "-" + DateTime.now().month.toString() + "-" + DateTime.now().year.toString(),
          "DocumentName": _documentName,
          "EmployeeName": globals.userName,
          "Search": DateTime.now().month.toString() + "-" + DateTime.now().year.toString(),
          "Seen": false,
          "Time": DateTime.now().day.toString() + ":" + DateTime.now().hour.toString(),
          "Type": "Report",
        }).then((value){
          Toast.show("Report Sent", context);
          Navigator.pop(context);
          setState(() {
            _isLoading = false;
          });
        }).catchError((onError){});
      }).catchError((onError){
        setState(() {
          _isLoading = false;
        });
        Toast.show("Error sending the Report", context);
        Navigator.pop(context);
      });
    }else{
      setState(() {
        _reportController.text == "" ? isThereReport = false : isThereReport = true;
      });
    }
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
                "Add Report",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0
                ),
              ),
              GestureDetector(
                onTap: (){
                  _uploadReport();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Icon(
                    Icons.upload_file,
                    color: Colors.black,
                  ),
                ),
              )
            ],
          ),
        ),
      );
    }

    Widget _enterReport(){
      return Container(
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: TextField(
                minLines: 1,
                maxLines: 1000,
                controller: _reportController,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide.none
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide.none
                  ),
                  hintText: isThereReport ? "The Report goes Here" : "Enter Report *",
                  hintStyle: TextStyle(
                    color: isThereReport ? Colors.grey[600] : Colors.red
                  )
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: _isLoading
          ? circularProgress()
          : SafeArea(
        child: Container(
          child: Column(
            children: [
              _appBar(),
              _enterReport(),
            ],
          ),
        ),
      ),
    );
  }
}
