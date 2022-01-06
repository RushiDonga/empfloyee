import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:employee/CommonWidgets/search_employee.dart';
import 'package:employee/Employee/Attendance/ManuallyFillAttendanceCEO.dart';
import 'package:employee/Employee/Attendance/TodayAttendance.dart';
import 'package:employee/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../CommonWidgets/show_weather.dart';
import '../../CommonWidgets/text_heading.dart';
import '../../CommonWidgets/two_in_rows_text_icon_button.dart';
import '../Todo_And_Reminder/add_todo.dart';
import 'package:toast/toast.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../../Work/EmployeeList_to_assign_work.dart';
import '../../Globals.dart' as globals;
import '../../Leave/viewLeaveCEO.dart';

const apiKey = "98023c6decac06308ed4c5c21fa56eae";
Firestore _fireStore = Firestore.instance;

class TodoPage extends StatefulWidget {
  @override
  _TodoPageState createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {

  List<GestureDetector> todoList = [];

  _getTodos(){
    String date = DateTime.now().day.toString() + "-" + DateTime.now().month.toString() + "-" + DateTime.now().year.toString();
    _fireStore.collection(globals.companyName).document("CEO TODOs").collection("Todo").where("TodoDate", isEqualTo: date).getDocuments().then((value){
      value.documents.forEach((element) {
        _displayDeadLineList(element.data["tag"], element.data["Description"]);
      });
    }).catchError((onError){});
  }

  _displayDeadLineList(String todo, String description){
    setState(() {
      todoList.add(
        GestureDetector(
          onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => Todo(
              tag: todo,
              state: "HISTORY",
            )));
          },
          child: Card(
            margin: EdgeInsets.symmetric(vertical: 2.0, horizontal: 10.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 7.0, horizontal: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ClipOval(
                    child: Material(
                      color: kLightBlue,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.5, horizontal: 14.0),
                        child: Icon(
                          Icons.format_list_numbered,
                          color: Colors.white,
                        ),
                      )
                    ),
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "TODO",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 15.0
                        ),
                      ),
                      SizedBox(
                        height: 3.0,
                      ),
                      Text(
                        "Tag: $todo",
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 13.5
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        )
      );
    });
  }

  _checkIfAttendanceTaken() async {
    await _fireStore.collection(globals.companyName).document("Attendance").get().then((value){

      if(value.data["TodayAttendance"] == true){
        Alert(
            context: context,
            title: "Hey ${globals.companyName}",
            desc: "You have Already taken the Attendance..!",
            buttons: [
              DialogButton(
                color: kLightBlue,
                onPressed: (){
                  Navigator.pop(context);
                },
                child: Text(
                  "OKAY",
                  style: TextStyle(
                      color: Colors.white
                  ),
                ),
              ),
            ]
        ).show();
      }else{
        Alert(
            context: context,
            title: "Are You Sure ?",
            desc: "Once you start the Attendance, you will not be able to stop it for Today",
            buttons: [
              DialogButton(
                color: kLightBlue,
                onPressed: () async {
                  String _date = DateTime.now().day.toString() + "-" + DateTime.now().month.toString() + "-" + DateTime.now().year.toString();
                  String _dateTime = DateTime.now().toString();
                  await _fireStore.collection(globals.companyName).document("Attendance").updateData({
                    "Date": _date,
                    "TodayAttendance": true,
                    "DocumentName": _dateTime,
                  }).then((value) async {

                    // Get the Name of all Employees
                    List<dynamic> employeeNames = [];
                    await _fireStore.collection(globals.companyName).document("Employee").get().then((value){
                      employeeNames = value.data["EmployeeList"];
                    }).then((value) async {
                      // Adding a document to every employee name
                      print("ADDING DOCUMENT");
                      for(int i=0; i<employeeNames.length; i++){
                        await _fireStore.collection(globals.companyName).document("Attendance").collection("Attendance").document(employeeNames[i])
                            .collection(employeeNames[i]).document(_dateTime).setData({
                          "Date": _date,
                          "Status": "Absent",
                          "Time": "",
                          "filled": false,
                        });
                      }
                      Navigator.pop(context);
                    });
                  }).catchError((onError){
                    Toast.show("Error starting the Attendance", context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                    Navigator.pop(context);
                  });
                },
                child: Text(
                  "YESS",
                  style: TextStyle(
                      color: Colors.white
                  ),
                ),
              ),
              DialogButton(
                color: kLightBlue,
                onPressed: (){
                  Navigator.pop(context);
                },
                child: Text(
                  "NO",
                  style: TextStyle(
                      color: Colors.white
                  ),
                ),
              )
            ]
        ).show();
      }
    });
  }

  _getAttendanceType(){
    String _attendanceType = "";
    _fireStore.collection(globals.companyName).document("Attendance").get().then((value){
      _attendanceType = value.data["Type"];
    }).then((value){
      if(_attendanceType == "AllowEmployee"){
        _checkIfAttendanceTaken();
      }else if(_attendanceType == "ManuallyFill"){
        Navigator.push(context, MaterialPageRoute(builder: (context) => ManuallyFillAttendance()));
      }else{

      }
    }).catchError((onError){

    });
  }



  @override
  void initState() {
    super.initState();

    _getTodos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              DisplayWeather(),
              SearchToday(),
              TextHeading(text: "Attendence",),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 17.0),
                child: Row(
                  children: <Widget>[
                    TwoInRowTextIconButton(
                      text: "Take\nAttendance",
                      iconData: Icons.scatter_plot,
                      color: Color(0XFFFAECEE),
                      buttonText: "TAKE",
                      onButtonPressed: (){
                        _getAttendanceType();
                      },
                    ),

                    TwoInRowTextIconButton(
                      text: "View \nAttendance",
                      iconData: Icons.streetview,
                      color: Color(0XFFE2F1FE),
                      buttonText: "VIEW",
                      onButtonPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => TodayAttendance()));
                      },
                    ),
                  ],
                ),
              ),

              TextHeading(text: "Today's Target",),

              Container(
                margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Color(0xFFDEE1F4),
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 7.0),
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(Radius.circular(12.0))
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(left: 7.0, right: 7.0, top: 5.0),
                                  decoration: BoxDecoration(
                                    color: kLightBlue,
                                    borderRadius: BorderRadius.all(Radius.circular(10.0))
                                  ),
                                  child: Column(
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.only(top: 10.0, right: 10.0),
                                        child: Align(
                                          alignment: Alignment.topRight,
                                          child: Icon(
                                            Icons.group_work,
                                            color: Colors.white,
                                            size: 23.0,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(left: 10.0, bottom: 10.0),
                                        child: Align(
                                          alignment: Alignment.bottomLeft,
                                          child: Text(
                                            "Assign Work\nfor Today",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.symmetric(horizontal: 8.0),
                                  width: MediaQuery.of(context).size.width,
                                  child: RaisedButton(
                                    onPressed: (){
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => EmployeeListAssignWork()));
                                    },
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                        side: BorderSide(color: Colors.white)
                                    ),
                                    color: Colors.grey[100],
                                    child: Text(
                                      "ASSIGN",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.0
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 7.0),
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(Radius.circular(12.0))
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.symmetric(horizontal: 8.0),
                                  width: MediaQuery.of(context).size.width,
                                  child: RaisedButton(
                                    onPressed: (){
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => ViewLeavesCEO()));
                                    },
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                        side: BorderSide(color: Colors.white)
                                    ),
                                    color: Colors.grey[100],
                                    child: Text(
                                      "VIEW",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.0
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(left: 7.0, right: 7.0, bottom: 5.0),
                                  decoration: BoxDecoration(
                                      color: kLightBlue,
                                      borderRadius: BorderRadius.all(Radius.circular(10.0))
                                  ),
                                  child: Column(
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.only(top: 10.0, right: 10.0),
                                        child: Align(
                                          alignment: Alignment.topRight,
                                          child: Icon(
                                            Icons.work,
                                            color: Colors.white,
                                            size: 23.0,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(left: 10.0, bottom: 10.0),
                                        child: Align(
                                          alignment: Alignment.bottomLeft,
                                          child: Text(
                                            "View Leave\nApplication",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              TextHeading(text: "Deadline",),

              Column(
                children: todoList,
              ),

            ],
          ),
        ),
      )
    );
  }
}

