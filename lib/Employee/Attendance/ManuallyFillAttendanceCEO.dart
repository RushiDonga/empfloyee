import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:employee/CommonWidgets/CircularLoadingIndicator.dart';
import 'package:employee/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:employee/Globals.dart' as globals;
import 'package:toast/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

Firestore _fireStore = Firestore.instance;

class ManuallyFillAttendance extends StatefulWidget {
  @override
  _ManuallyFillAttendanceState createState() => _ManuallyFillAttendanceState();
}

class _ManuallyFillAttendanceState extends State<ManuallyFillAttendance> {

  List<dynamic> _employeeList = [];
  List<String> _status = [];

  bool isLoading = true;

  String _date = DateTime.now().day.toString() + "-" + DateTime.now().month.toString() + "-" + DateTime.now().year.toString();
  String documentName = "";

  _getEmployeeOnLeave() async {
    print("CALLED");

    SharedPreferences _prefs = await SharedPreferences.getInstance();

    for(int i=0; i<_employeeList.length; i++){
      await _fireStore.collection(globals.companyName).document("Attendance").collection("Attendance").document(_employeeList[i])
          .collection(_employeeList[i]).where("Date", isEqualTo: _date).getDocuments().then((value){

        if(value.documents.isNotEmpty){
          value.documents.forEach((element) {

            setState(() {
              _status[_employeeList.indexOf(_employeeList[i])] = element.data["Status"];
              documentName = element.data["DocumentName"];
              _prefs.setString('DocumentName', documentName);
            });
            print(documentName);
          });
        }else{
          print("IS EMPTY");
        }
      }).then((value){
        print("GOT LEAVES SUCCESSFULLY");
        setState(() {
          isLoading = false;
        });
        _updateDocumentName();
      }).catchError((onError){
        print("--------");
        print(onError);
        Navigator.pop(context);
      });
    }
  }

  _updateDocumentName(){
    _fireStore.collection(globals.companyName).document("Attendance").updateData({
      "DocumentName": documentName
    }).then((value){})
        .catchError((onError){});
  }

  _checkDate() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();

    if(_prefs.getString('Date') == _date){
      setState(() {
        documentName = _prefs.getString('DocumentName');
      });
    }else{
      setState(() {
        documentName = DateTime.now().toString();
      });

      _prefs.setStringList('filledAttendance', []);
      _prefs.setStringList('filledAttendanceStatus', []);
      _prefs.setString('Date', _date);
      _prefs.setString('DocumentName', documentName);
    }
    _getEmployeeList();
  }

  _employeeFilledAttendance(String _employeeName, String status) async {

    SharedPreferences _prefs = await SharedPreferences.getInstance();

    List<String> _attendance = _prefs.getStringList('filledAttendance');
    List<String> _attendanceStatus = _prefs.getStringList('filledAttendanceStatus');

    _attendance.add(_employeeName);
    _attendanceStatus.add(status);

    _prefs.setStringList('filledAttendance', _attendance);
    _prefs.setStringList('filledAttendanceStatus', _attendanceStatus);
    _prefs.setString('Date', _date);
  }

  _getEmployeeList() async {

    SharedPreferences _prefs = await SharedPreferences.getInstance();

    _fireStore.collection(globals.companyName).document("Employee").get().then((value){
      setState(() {
        _employeeList.addAll(value.data["EmployeeList"]);
      });
    }).then((value){

      for(int i=0; i< _employeeList.length; i++){
        if(_prefs.getStringList('filledAttendance').contains(_employeeList[i])){
          _status.add(_prefs.getStringList('filledAttendanceStatus')[_prefs.getStringList('filledAttendance').indexOf(_employeeList[i])]);
        }else{
          _status.add("NotFilled");
        }
        print(_status);
      }

      _getEmployeeOnLeave();
    }).catchError((onError){
      setState(() {
        Toast.show("Error Fetching Employees", context, gravity: Toast.BOTTOM, duration: Toast.LENGTH_LONG);
      });
    });
  }

  _uploadSingleEmployeeAttendance(String employeeName, String status, int index){

    setState(() {
      _status[index] = "Filling";
    });
    _fireStore.collection(globals.companyName).document("Attendance").collection("Attendance").document(employeeName)
        .collection(employeeName).document(documentName).setData({
      "Date": DateTime.now().day.toString() + "-" + DateTime.now().month.toString() + "-" + DateTime.now().year.toString(),
      "Status": status,
      "Time": DateTime.now().hour.toString() + ":" + DateTime.now().minute.toString(),
      "filled": true,
      "DocumentName": documentName,
      "Search": DateTime.now().month.toString() + "-" + DateTime.now().year.toString(),
    }).then((value){

      // Uploading in the Notifications
      _fireStore.collection(globals.companyName).document("Employee").collection("employee").document(employeeName)
          .collection("Notifications").document(documentName).setData({
        "Date": DateTime.now().day.toString() + "-" + DateTime.now().month.toString() + "-" + DateTime.now().year.toString(),
        "DocumentName": documentName,
        "Search": DateTime.now().month.toString() + "-" + DateTime.now().year.toString(),
        "Seen": false,
        "Type": "ManuallyFilledAttendance",
        "Status": status,
        "Time": DateTime.now().hour.toString() + ":" + DateTime.now().minute.toString(),
        "Requested": false,
      }).then((value){
        setState(() {
          _status[index] = status;
          _employeeFilledAttendance(employeeName, status);
        });
      });
    }).catchError((onError){

    });
  }

  @override
  void initState() {
    super.initState();

    _checkDate();
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
                "Fill Attendance",
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

    Widget _progress(){
      return Padding(
        padding: const EdgeInsets.only(right: 30.0),
        child: Container(
            height: 25.0,
            width: 25.0,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.grey[800]),
              strokeWidth: 2.0,
            )
        ),
      );
    }

    Widget _showStatus(String status){
      return Container(
        child: Card(
          color: status == "Present"
              ? Colors.green[200]
              : status == "Absent"
                  ? Colors.red[100]
                  : Colors.grey[200],
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(7.0)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
            child: Text(
              status == "Leave" ? "  Leave " : status,
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5
              ),
            ),
          ),
        ),
      );
    }

    Widget _showThumbs(int index){
      return Container(
        child: Row(
          children: [
            GestureDetector(
              onTap: (){
                _uploadSingleEmployeeAttendance(
                    _employeeList[index],
                    "Present",
                    index
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 7.0),
                child: Icon(
                  Icons.thumb_up,
                  color: Colors.green.withOpacity(0.7),
                  size: 28.0,
                ),
              ),
            ),
            GestureDetector(
              onTap: (){
                _uploadSingleEmployeeAttendance(
                    _employeeList[index],
                    "Absent",
                    index
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 7.0),
                child: Icon(
                  Icons.thumb_down,
                  color: Colors.red.withOpacity(0.6),
                  size: 28.0,
                ),
              ),
            )
          ],
        ),
      );
    }

    Widget _mainBody(){
      return Container(
        child: ListView.builder(
            itemCount: _employeeList.length,
            physics: BouncingScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index){
              return Container(
                child: Card(
                  elevation: 0.5,
                  margin: EdgeInsets.symmetric(horizontal: 9.0, vertical: 0.6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 7.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.person,
                              color: kLightBlue,
                            ),
                            SizedBox(
                              width: 5.0,
                            ),
                            Text(
                              _employeeList[index],
                              style: TextStyle(
                                  color: Colors.grey[800],
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16.0
                              ),
                            ),
                          ],
                        ),

                        _status[index] == "NotFilled"
                            ? _showThumbs(index)
                            : _status[index] == "Filling"
                              ? _progress()
                              : _showStatus(_status[index])
                      ],
                    ),
                  ),
                ),
              );
            }
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
