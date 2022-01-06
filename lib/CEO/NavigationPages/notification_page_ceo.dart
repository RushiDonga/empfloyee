import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:employee/CEO/My_Employee/employee_profile.dart';
import 'package:employee/CEO/Todo_And_Reminder/add_todo.dart';
import 'package:employee/CommonWidgets/CircularLoadingIndicator.dart';
import 'package:employee/CommonWidgets/NotificationCard.dart';
import 'package:employee/CommonWidgets/text_heading.dart';
import 'package:employee/Employee/Attendance/UpdateAttendanceCEO.dart';
import 'package:employee/Employee/NotifyManager.dart';
import 'package:employee/Leave/ViewSingleLeave.dart';
import 'package:employee/Report/ViewReport.dart';
import 'package:employee/Work/ViewSingleWork.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:employee/Globals.dart' as globals;
import '../../constants.dart';
import 'package:toast/toast.dart';

// TYPES OF NOTIFICATIONS

// Employee Notification
// Announcements
// Leave Notification
// TODO  <-- This is the type to notification
// EmployeeUpdateData
// WorkUpdateStatus
// UpdateAttendance
// Report

Firestore _fireStore = Firestore.instance;

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {

  List<NotificationData> _allNotifications = [];
  List<NotificationData> _notificationToReverse = [];

  int searchMonth;
  int searchYear;

  bool isLoading = true;
  bool isHistoryNotificationLoading = false;
  bool isThereNoData = false;
  bool isEnd = false;
  bool showLoadMore = true;

  String trackSearch;
  String end;

  var months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];

  String _getPrintDate(String date){
    var data = date.split("-");
    print(date);
    print(data);
    return months[int.parse(data[0])-1] + data[1];
  }

  _getNotification(String search){
    setState(() {
      _notificationToReverse.clear();
    });

    _fireStore.collection(globals.companyName).document("CEO Notifications").collection("Notifications")
        .where("Search", isEqualTo: search).getDocuments().then((value){
      value.documents.forEach((element) {

        switch (element.data["Type"]){

          case "Employee Notification":{
            _notificationToReverse.add(
                NotificationData(
                  date: element.data["Date"],
                  description: element.data["Description"],
                  documentName: element.data["DocumentName"],
                  employeeName: element.data["EmployeeName"],
                  search: element.data["Search"],
                  seen: element.data["Seen"],
                  time: element.data["Time"],
                  title: element.data["Title"],
                  type: element.data["Type"],
                )
            );
            break;
          }

          case "Leave Notification":{
            _notificationToReverse.add(
                NotificationData(
                  date: element.data["Date"],
                  description: element.data["Description"],
                  documentName: element.data["DocumentName"],
                  employeeName: element.data["EmployeeName"],
                  leaveType: element.data["Leave Type"],
                  search: element.data["Search"],
                  seen: element.data["Seen"],
                  time: element.data["Time"],
                )
            );
            break;
          }

          case "TODO ":{
            _notificationToReverse.add(
                NotificationData(
                  description: element.data["Description"],
                  search: element.data["Search"],
                  seen: element.data["Seen"],
                  todoDate: element.data["TodoDate"],
                  type: element.data["Type"],
                  tag: element.data["tag"],
                  tillDate: element.data["tillDate"],
                )
            );
            break;
          }

          case "EmployeeUpdateData":{
            _notificationToReverse.add(
                NotificationData(
                  date: element.data["Date"],
                  documentName: element.data["DocumentName"],
                  employeeName: element.data["EmployeeName"],
                  search: element.data["Search"],
                  seen: element.data["Seen"],
                  type: element.data["Type"],
                  time: element.data["Time"],
                )
            );
            break;
          }

          case "WorkUpdateStatus":{
            _allNotifications.add(
                NotificationData(
                  date: element.data["Date"],
                  documentName: element.data["DocumentName"],
                  employeeName: element.data["EmployeeName"],
                  search: element.data["Search"],
                  seen: element.data["Seen"],
                  time: element.data["Time"],
                  type: element.data["Type"],
                )
            );
            break;
          }

          case "EmployeeLoggedIn":{
            _notificationToReverse.add(
                NotificationData(
                  date: element.data["Date"],
                  documentName: element.data["DocumentName"],
                  employeeName: element.data["EmployeeName"],
                  search: element.data["Search"],
                  seen: element.data["Seen"],
                  time: element.data["Time"],
                  type: element.data["Type"],
                )
            );
            break;
          }

          case "EmployeeLogOut":{
            setState(() {
              _notificationToReverse.add(
                NotificationData(
                  date: element.data["Date"],
                  documentName: element.data["DocumentName"],
                  employeeName: element.data["EmployeeName"],
                  search: element.data["Search"],
                  seen: element.data["Seen"],
                  time: element.data["Time"],
                  type: element.data["Type"],
                )
              );
            });
            break;
          }

          case "UpdateAttendance":{
            setState(() {
              _notificationToReverse.add(
                NotificationData(
                  date: element.data["Date"],
                  documentName: element.data["DocumentName"],
                  employeeName: element.data["EmployeeName"],
                  search: element.data["Search"],
                  seen: element.data["Seen"],
                  status: element.data["Status"],
                  time: element.data["Time"],
                  type: element.data["Type"],
                )
              );
            });
            break;
          }

          case "Report":{
            setState(() {
              _notificationToReverse.add(
                  NotificationData(
                    date: element.data["Date"],
                    documentName: element.data["DocumentName"],
                    employeeName: element.data["EmployeeName"],
                    search: element.data["Search"],
                    seen: element.data["Seen"],
                    time: element.data["Time"],
                    type: element.data["Type"],
                  )
              );
            });
          }
        }
      });

      setState(() {
        _allNotifications.addAll(_notificationToReverse.reversed.toList());
      });

    }).then((value){
      setState(() {

        if(_allNotifications.isEmpty){
          isThereNoData = true;
        }else{
          isThereNoData = false;
        }

        isLoading = false;
        isHistoryNotificationLoading = false;
      });
    }).catchError((onError){
      setState(() {
        isLoading = false;
        isHistoryNotificationLoading = false;
        print(onError);
        Toast.show("Error Loading...!", context, gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
      });
    });
  }

  Widget _displayDate(String date){
    bool printDate;

    if(trackSearch != date){
      printDate = true;
      trackSearch = date;
    }else{
      printDate = false;
    }

    return printDate
        ? TextHeading(text: _getPrintDate(date),)
        : SizedBox();
  }

  Widget _noData(){
    return  Column(
      children: [
        Center(
          child: Image(
            image: AssetImage("assets/no-notifications.png"),
            fit: BoxFit.cover,
          ),
        ),
        RaisedButton(
          color: kLightBlue,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(7.0)),
              side: BorderSide(width: 1.0, color: Colors.white, style: BorderStyle.solid)
          ),
          onPressed: (){
            setState(() {
              isLoading = true;
              isThereNoData = false;
            });
            _getNotification(_getPreviousMonth());
          },
          child: Text(
            "Load Previous",
            style: TextStyle(
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        )
      ],
    );
  }

  Widget _widgetSelector(){
    return ListView.builder(
        shrinkWrap: true,
        physics: ScrollPhysics(),
        itemCount: _allNotifications.length,
        itemBuilder: (context, index){
          return Column(
            children: [
              _displayDate(_allNotifications[index].search),

              Container(
                  child: _allNotifications[index].type == "Employee Notification"
                      ? NotificationCard(
                    icon: Icons.compare,
                    time: _allNotifications[index].time,
                    description: "Employee Notification",
                    date: _allNotifications[index].date,
                    title: _allNotifications[index].employeeName,
                    seen: _allNotifications[index].seen,
                    onClick: (){
                      print(_allNotifications[index].documentName);
                      _fireStore.collection(globals.companyName).document("CEO Notifications").collection("Notifications").document(_allNotifications[index].documentName).updateData({
                        "Seen": true,
                      });

                      Navigator.push(context, MaterialPageRoute(builder: (context) => NotifyManager(
                        title: _allNotifications[index].title,
                        description: _allNotifications[index].description,
                        identity: "CEO",
                        employeeName: _allNotifications[index].employeeName,
                      )));
                    },
                  )
                      : _allNotifications[index].type == "Leave Notification"
                      ? NotificationCard(
                    icon: Icons.time_to_leave,
                    time: _allNotifications[index].time,
                    description: "Leave",
                    date: _allNotifications[index].date,
                    title: _allNotifications[index].employeeName,
                    seen: _allNotifications[index].seen,
                    onClick: (){

                      _fireStore.collection(globals.companyName).document("CEO Notifications").collection("Notifications").document(_allNotifications[index].documentName).updateData({
                        "Seen": true,
                      }).then((value){
                        setState(() {
                          _allNotifications[index].seen = true;
                        });
                      });

                      Navigator.push(context, MaterialPageRoute(builder: (context) => ViewSingleLeave(
                        employeeName: _allNotifications[index].employeeName,
                        documentName: _allNotifications[index].documentName,
                      )));
                    },
                  )
                      : _allNotifications[index].type == "TODO"
                      ? NotificationCard(
                    icon: Icons.timer,
                    time: _allNotifications[index].time,
                    description: "TODO",
                    date: _allNotifications[index].date,
                    title: _allNotifications[index].tag,
                    seen: _allNotifications[index].seen,
                    onClick: (){
                      _fireStore.collection(globals.companyName).document("CEO Notifications").collection("Notifications").document(_allNotifications[index].documentName).updateData({
                        "Seen": true,
                      });

                      Navigator.push(context, MaterialPageRoute(builder: (context) => Todo(
                        state: "HISTORY",
                        tag: _allNotifications[index].tag,
                      )));
                    },
                  )
                      : _allNotifications[index].type == "EmployeeUpdateData"
                      ? NotificationCard(
                    icon: Icons.update,
                    time: _allNotifications[index].time,
                    description: _allNotifications[index].employeeName,
                    date: _allNotifications[index].date,
                    title: "Updated Profile",
                    seen: _allNotifications[index].seen,
                    onClick: (){
                      _fireStore.collection(globals.companyName).document("CEO Notifications").collection("Notifications")
                          .document(_allNotifications[index].documentName).updateData({
                        "Seen": true,
                      }).then((value){
                        setState(() {
                          _allNotifications[index].seen = true;
                        });
                      });

                      Navigator.push(context, MaterialPageRoute(builder: (context) => EmployeeProfileCEO(
                        name: _allNotifications[index].employeeName,
                      )));
                    },
                  )
                      : _allNotifications[index].type == "WorkUpdateStatus"
                      ? NotificationCard(
                    icon: Icons.work,
                    time: _allNotifications[index].time,
                    description: "Work Updated",
                    date: _allNotifications[index].date,
                    title: _allNotifications[index].employeeName,
                    seen: _allNotifications[index].seen,
                    onClick: (){

                      _fireStore.collection(globals.companyName).document("CEO Notifications").collection("Notifications")
                          .document(_allNotifications[index].documentName).updateData({
                        "Seen": true,
                      }).then((value){
                        setState(() {
                          _allNotifications[index].seen = true;
                        });
                      });

                      Navigator.push(context, MaterialPageRoute(builder: (context) => ViewSingleWork(
                        documentName: _allNotifications[index].documentName,
                        employeeName: _allNotifications[index].employeeName,
                      )));
                    },
                  )
                      : _allNotifications[index].type == "EmployeeLoggedIn"
                      ? NotificationCard(
                    icon: Icons.lock,
                    time: _allNotifications[index].time,
                    description: _allNotifications[index].employeeName,
                    date: _allNotifications[index].date,
                    title: "Logged In",
                    seen: _allNotifications[index].seen,
                    onClick: (){

                      print(_allNotifications[index].seen);

                      _fireStore.collection(globals.companyName).document("CEO Notifications").collection("Notifications").document(_allNotifications[index].documentName).updateData({
                        "Seen": true,
                      }).then((value){
                        print("UPDATED");
                        setState(() {
                          _allNotifications[index].seen = true;
                        });
                      });
                    },
                  )
                      : _allNotifications[index].type == "UpdateAttendance"
                        ? NotificationCard(
                          icon: Icons.where_to_vote_outlined,
                          time: _allNotifications[index].time,
                          description: _allNotifications[index].employeeName,
                          date: _allNotifications[index].date,
                          title: "Update Attendance",
                          seen: _allNotifications[index].seen,
                          onClick: (){
                            _fireStore.collection(globals.companyName).document("CEO Notifications").collection("Notifications").document(_allNotifications[index].documentName).updateData({
                              "Seen": true,
                            }).then((value){
                              setState(() {
                                _allNotifications[index].seen = true;
                              });
                            });

                            Navigator.push(context, MaterialPageRoute(builder: (context) => UpdateAttendanceCEO(
                              employeeName: _allNotifications[index].employeeName,
                              status: _allNotifications[index].status,
                              documentName: _allNotifications[index].documentName,
                            )));
                          },
                        )
                        : _allNotifications[index].type == "EmployeeLogOut"
                      ? NotificationCard(
                    icon: Icons.lock_open,
                    time: _allNotifications[index].time,
                    description: _allNotifications[index].employeeName,
                    date: _allNotifications[index].date,
                    title: "Logged Out",
                    seen: _allNotifications[index].seen,
                    onClick: (){
                      _fireStore.collection(globals.companyName).document("CEO Notifications").collection("Notifications").document(_allNotifications[index].documentName).updateData({
                        "Seen": true,
                      }).then((value){
                        setState(() {
                          _allNotifications[index].seen = true;
                        });
                      });
                    },
                  )
                      : _allNotifications[index].type == "Report"
                        ? NotificationCard(
                    icon: Icons.repeat_one,
                    time: _allNotifications[index].time,
                    description: _allNotifications[index].employeeName,
                    date: _allNotifications[index].date,
                    title: "Report",
                    seen: _allNotifications[index].seen,
                    onClick: (){

                      _fireStore.collection(globals.companyName).document("CEO Notifications").collection("Notifications").document(_allNotifications[index].documentName).updateData({
                        "Seen": true,
                      }).then((value){
                        setState(() {
                          _allNotifications[index].seen = true;
                        });
                      });

                      Navigator.push(context, MaterialPageRoute(builder: (context) => ViewReport(
                        date: _allNotifications[index].date,
                        employeeName: _allNotifications[index].employeeName,
                      )));
                    },
                  ) : SizedBox()
              ),
            ],
          );
        }
    );
  }

  String _getPreviousMonth(){
    if(searchMonth == 1){
     setState(() {
       searchYear = searchYear-1;
       searchMonth = 12;
     });
    }else{
      setState(() {
        searchMonth = searchMonth-1;
      });
    }
    return searchMonth.toString() + "-" + searchYear.toString();
  }

  _getJoinDate(){
    _fireStore.collection(globals.companyName).document("CompanyDetails").get().then((value){
      end = value.data["Join Month"] + "-" + value.data["Join Year"];
    });
  }

  @override
  void initState() {
    super.initState();

    searchMonth = DateTime.now().month;
    searchYear = DateTime.now().year;
    _getJoinDate();
    _getNotification(searchMonth.toString() + "-" + searchYear.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: kLightBlue,
          leading: Icon(
            Icons.notification_important,
            color: Colors.white,
            size: 30.0,
          ),
          centerTitle: true,
          title: Title(
            color: Colors.white,
            child: Text(
              "Notifications",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                  letterSpacing: 1.0
              ),
            ),
          ),
        ),
      body: isLoading
        ? circularProgress()
          : Container(
          child: SingleChildScrollView(
            child: Column(
              children: [
                isThereNoData
                ? _noData()
                : _widgetSelector(),

                SizedBox(
                  height: 10.0,
                ),

                isThereNoData
                    ? SizedBox()
                      : isHistoryNotificationLoading
                    ? CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.grey[600]),
                )
                    : showLoadMore
                ? GestureDetector(
                  onTap: (){
                    setState(() {
                      isHistoryNotificationLoading = true;
                      String date = _getPreviousMonth();
                      _getNotification(date);
                      print(date);
                      print(end);
                      if(date == end){
                        showLoadMore = false;
                      }else{
                        if(end.split("-")[1] == date.split("-")[1]){
                          if(int.parse(date.split("-")[0]) < int.parse(end.split("-")[0])){
                            showLoadMore = false;
                          }
                        }
                      }
                    });
                  },
                  child: ClipOval(
                    child: Container(
                      color: kLightBlue.withOpacity(0.4),
                      height: 50.0,
                      width: 50.0,
                      child: Center(
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                          )
                      ),
                    ),
                  ),
                )
                : SizedBox(),

                SizedBox(
                  height: 10.0,
                )
              ],
            ),
          )
      )
    );
  }
}






class NotificationData{
  String date;
  String time;
  bool seen;
  String search;
  String documentName;
  String type;

  String description;
  String employeeName;
  String title;  // Employee Notification

  String fromDate;
  String leaveType;
  String status;
  String toDate;  // Leave Notification

  String todoDate;
  String tag;
  String tillDate;  // Todo

  // Logged In Logged Out isIncluded in Above

  NotificationData({this.date, this.time, this.seen, this.search, this.documentName, this.type, this.description, this.employeeName, this.title,
    this.fromDate, this.leaveType, this.todoDate, this.toDate, this.tag, this.tillDate, this.status
  });
}

