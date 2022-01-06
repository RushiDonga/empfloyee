import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:employee/CommonWidgets/CircularLoadingIndicator.dart';
import 'package:employee/CommonWidgets/text_heading.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:employee/Globals.dart' as globals;
import 'package:toast/toast.dart';

Firestore _fireStore = Firestore.instance;

class ViewReport extends StatefulWidget {
  @override
  _ViewReportState createState() => _ViewReportState();

  ViewReport({this.date, this.employeeName});
  final String date;
  final String employeeName;
}

class _ViewReportState extends State<ViewReport> {

  List<ReportData> _reportData = [];

  bool _isLoading = true;
  
  _getReport(){

    _fireStore.collection(globals.companyName).document("Employee").collection("employee").document(widget.employeeName)
        .collection("Report").where("Date", isEqualTo: widget.date).getDocuments().then((value){
      value.documents.forEach((element) {
        setState(() {
          _reportData.add(
            ReportData(
              element.data["Date"],
              element.data["Report"],
            ),
          );
        });
      });
    }).then((value){
      setState(() {
        _isLoading = false;
      });
    }).catchError((onError){
      Toast.show("Error Fetching Report", context);
      Navigator.pop(context);
    });
  }

  @override
  void initState() {
    super.initState();
    _getReport();
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
                widget.employeeName,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0
                ),
              ),
              SizedBox(width: 20.0,)
            ],
          ),
        ),
      );
    }
    
    Widget _displayReport(){
      return Container(
        margin: EdgeInsets.only(top: 55.0),
        width: MediaQuery.of(context).size.width,
        child: ListView.builder(
          itemCount: _reportData.length,
          itemBuilder: (BuildContext context, int index) {
            return Card(
              child: Column(
                children: [
                  SizedBox(height: 5.0,),
                  Text(
                    "Date: ${_reportData[index].date}",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  SizedBox(height: 10.0,),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        _reportData[index].reportContent,
                        style: TextStyle(
                          fontSize: 15.0
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.0,)
                ],
              ),
            );
          },

        )
      );
    }

    return Scaffold(
      body: _isLoading
          ? circularProgress()
          : SafeArea(
        child: Container(
          child: Stack(
            children: [
              _appBar(),
              _displayReport(),
            ],
          ),
        ),
      ),
    );
  }
}






class ReportData{
  final String date;
  final String reportContent;

  ReportData(this.date, this.reportContent);
}
