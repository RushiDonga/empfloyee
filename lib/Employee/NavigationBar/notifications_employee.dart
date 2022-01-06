import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:employee/CommonWidgets/CircularLoadingIndicator.dart';
import 'package:employee/CommonWidgets/text_heading.dart';
import 'package:employee/Employee/Attendance/EmployeeViewSingleAttendance.dart';
import 'package:employee/Employee/NotifyManager.dart';
import 'package:employee/Leave/ViewSingleLeave.dart';
import 'package:employee/Teams/info_page.dart';
import 'package:employee/Work/ViewSingleWork.dart';
import 'package:flutter/material.dart';
import 'package:employee/Globals.dart' as globals;
import 'package:rflutter_alert/rflutter_alert.dart';
import '../../constants.dart';
import '../../CommonWidgets/NotificationCard.dart';

Firestore _fireStore = Firestore.instance;


class NotificationsEmployee extends StatefulWidget {
  @override
  _NotificationsEmployeeState createState() => _NotificationsEmployeeState();
}

class _NotificationsEmployeeState extends State<NotificationsEmployee> {

  // ManagerNotification
  // Work
  // LeaveStatus
  // TeamWork
  // ManuallyFilledAttendance
  // UpdateSalary
  // UpdateGST

  int searchMonth;
  int searchYear;

  String trackSearch = "";
  String end;

  bool isLoading = true;
  bool isHistoryNotificationLoading = false;
  bool showLoadMore = true;
  bool isThereNoData = false;

  List<NotificationData> _notifications = [];
  List<NotificationData> _notificationToReverse = [];

  var months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];

  String _getPrintDate(String date){
    var data = date.split("-");
    print(date);
    print(data);
    return months[int.parse(data[0])-1] + " " + data[1];
  }

  _getEmployeeNotification(String search) async {

    setState(() {
      _notificationToReverse.clear();
    });

    await _fireStore.collection(globals.companyName).document("Employee").collection("employee").document(globals.userName)
        .collection("Notifications").where("Search", isEqualTo: search).getDocuments().then((value){
      value.documents.forEach((element) {

        switch (element.data["Type"]){

        case "ManagerNotification":{
          setState(() {
            _notificationToReverse.add(
                NotificationData(
                  date: element.data["Date"],
                  description: element.data["Description"],
                  documentName: element.data["DocumentName"],
                  search: element.data["Search"],
                  seen: element.data["Seen"],
                  title: element.data["Title"],
                  time: element.data["Time"],
                  type: element.data["Type"],
                )
            );
          });
          break;
        }

        case "WORK":{
          setState(() {
            print("WORK");
            _notificationToReverse.add(
                NotificationData(
                  date: element.data["Date"],
                  description: element.data["Description"],
                  documentName: element.data["DocumentName"],
                  endDate: element.data["End Date"],
                  priority: element.data["Priority"],
                  search: element.data["Search"],
                  seen: element.data["Seen"],
                  startDate: element.data["Start Date"],
                  boolStatus: element.data["Status"],
                  time: element.data["Time"],
                  type: element.data["Type"],
                )
            );
          });
          break;
        }

        case "LeaveStatus":{
          setState(() {
            print("LeaveStatus");
            _notificationToReverse.add(
                NotificationData(
                  date: element.data["Date"],
                  documentName: element.data["DocumentName"],
                  fromDate: element.data["FromDate"],
                  search: element.data["Search"],
                  seen: element.data["Seen"],
                  time: element.data["Time"],
                  type: element.data["Type"],
                  strStatus: element.data["Status"],
                )
            );
          });
          break;
        }

          case "TeamWork":{
            setState(() {
              _notificationToReverse.add(
                NotificationData(
                  date: element.data["Date"],
                  documentName: element.data["DocumentName"],
                  search: element.data["Search"],
                  seen: element.data["Seen"],
                  time: element.data["Time"],
                  type: element.data["Type"],
                  teamTag: element.data["TeamTag"],
                )
              );
            });
            break;
          }

          case "ManuallyFilledAttendance":{
            _notificationToReverse.add(
              NotificationData(
                date: element.data["Date"],
                documentName: element.data["DocumentName"],
                search: element.data["Search"],
                seen: element.data["Seen"],
                type: element.data["Type"],
                time: element.data["Time"],
                strStatus: element.data["Status"],
              )
            );
            break;
          }

          case "UpdatedAttendance":{
            _notificationToReverse.add(
              NotificationData(
                date: element.data["Date"],
                documentName: element.data["DocumentName"],
                search: element.data["Search"],
                seen: element.data["Seen"],
                strStatus: element.data["Status"],
                time: element.data["Time"],
                type: element.data["Type"],
              )
            );
            break;
          }

          case "UpdateSalary":{
            _notificationToReverse.add(
                NotificationData(
                  date: element.data["Date"],
                  documentName: element.data["DocumentName"],
                  search: element.data["Search"],
                  seen: element.data["Seen"],
                  time: element.data["Time"],
                  type: element.data["Type"],
                  strStatus: element.data["NewSalary"],
                )
            );
            break;
          }

          case "UpdateGST":{
            _notificationToReverse.add(
                NotificationData(
                  date: element.data["Date"],
                  documentName: element.data["DocumentName"],
                  search: element.data["Search"],
                  seen: element.data["Seen"],
                  time: element.data["Time"],
                  type: element.data["Type"],
                  strStatus: element.data["NewSalary"],
                )
            );
            break;
          }
      }
      });

      setState(() {
        _notifications.addAll(_notificationToReverse.reversed.toList());
      });
    }).then((value){
      setState(() {

        if(_notifications.isEmpty){
          isThereNoData = true;
        }

        isLoading = false;
        isHistoryNotificationLoading = false;
      });
    }).catchError((onError){
      print("ERROR IN NOTIFICATIONS");
      print(onError);
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
            _getEmployeeNotification(_getPreviousMonth());
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
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
        itemCount: _notifications.length,
        itemBuilder: (context, index){
          return Column(
            children: [
              _displayDate(_notifications[index].search),

              Container(
                child: _notifications[index].type == "ManagerNotification"
                    ? NotificationCard(
                  icon: Icons.compare,
                  time: _notifications[index].time,
                  description: _notifications[index].title.length > 15 ? _notifications[index].title.substring(0, 15) + "..." : _notifications[index].title,
                  date: _notifications[index].date,
                  title: globals.companyName,
                  seen: _notifications[index].seen,
                  onClick: (){

                    Navigator.push(context, MaterialPageRoute(builder: (context) => NotifyManager(
                      title: _notifications[index].title,
                      description: _notifications[index].description,
                      identity: "Employee",
                      employeeName: globals.userName,
                    )));

                    _fireStore.collection(globals.companyName).document("Employee").collection("employee").document(globals.userName)
                        .collection("Notifications").document(_notifications[index].documentName).updateData({
                      "Seen": true,
                    }).then((value){
                      setState(() {
                        _notifications[index].seen = true;
                      });
                    });
                  },
                )
                    : _notifications[index].type == "LeaveStatus"
                    ? NotificationCard(
                  icon: Icons.time_to_leave,
                  time: _notifications[index].time,
                  description: _notifications[index].fromDate,
                  date: _notifications[index].date,
                  title: "Leave ",
                  seen: _notifications[index].seen,
                  onClick: (){

                    Navigator.push(context, MaterialPageRoute(builder: (context) => ViewSingleLeave(
                      employeeName: globals.userName,
                      documentName: _notifications[index].documentName,
                    )));

                    _fireStore.collection(globals.companyName).document("Employee").collection("employee").document(globals.userName)
                        .collection("Notifications").document(_notifications[index].documentName).updateData({
                      "Seen": true,
                    }).then((value){
                      setState(() {
                        _notifications[index].seen = true;
                      });
                    });
                  },
                )
                    : _notifications[index].type == "WORK"
                    ? NotificationCard(
                        icon: Icons.work,
                        time: _notifications[index].time,
                        description: _notifications[index].description,
                        date: _notifications[index].date,
                        title: "New Work ",
                        seen: _notifications[index].seen,
                        onClick: (){

                          _fireStore.collection(globals.companyName).document("Employee").collection("employee").document(globals.userName)
                              .collection("Notifications").document(_notifications[index].documentName).updateData({
                            "Seen": true,
                          }).then((value){
                            setState(() {
                              _notifications[index].seen = true;
                            });
                          });

                          Navigator.push(context, MaterialPageRoute(builder: (context) => ViewSingleWork(
                            documentName: _notifications[index].documentName,
                            employeeName: globals.userName,
                          )));
                        },
                )
                    : _notifications[index].type == "TeamWork"
                    ? NotificationCard(
                        icon: Icons.group,
                        time: _notifications[index].time,
                        description: _notifications[index].teamTag,
                        date: _notifications[index].date,
                        title: "New Team",
                        seen: _notifications[index].seen,
                        onClick: (){
                          _fireStore.collection(globals.companyName).document("Employee").collection("employee").document(globals.userName)
                              .collection("Notifications").document(_notifications[index].documentName).updateData({
                            "Seen": true,
                          }).then((value){
                            setState(() {
                              _notifications[index].seen = true;
                            });
                          });

                          Navigator.push(context, MaterialPageRoute(builder: (context) => InfoPageOfTeams(
                            teamTag: _notifications[index].teamTag,
                            selectedEmployee: [],
                          )));
                        },
                      )
                    : _notifications[index].type == "ManuallyFilledAttendance"
                      ? NotificationCard(
                        icon: Icons.how_to_vote_sharp,
                        time: _notifications[index].time,
                        description: _notifications[index].strStatus,
                        date: _notifications[index].date,
                        title: "Attendance",
                        seen: _notifications[index].seen,
                        onClick: (){

                          _fireStore.collection(globals.companyName).document("Employee").collection("employee").document(globals.userName)
                              .collection("Notifications").document(_notifications[index].documentName).updateData({
                            "Seen": true,
                          }).then((value){
                            setState(() {
                              _notifications[index].seen = true;
                            });
                          });

                          Navigator.push(context, MaterialPageRoute(builder: (context) => EmployeeViewSingleAttendance(
                            date: _notifications[index].date,
                            status: _notifications[index].strStatus,
                            documentName: _notifications[index].documentName,
                          )));
                        },
                ): _notifications[index].type == "UpdatedAttendance"
                    ? NotificationCard(
                  icon: Icons.update_sharp,
                  time: _notifications[index].time,
                  description: _notifications[index].strStatus,
                  date: _notifications[index].date,
                  title: "Updated Attendance",
                  seen: _notifications[index].seen,
                  onClick: (){
                    _fireStore.collection(globals.companyName).document("Employee").collection("employee").document(globals.userName)
                        .collection("Notifications").document(_notifications[index].documentName).updateData({
                      "Seen": true,
                    }).then((value){
                      setState(() {
                        _notifications[index].seen = true;
                      });
                    });
                  },
                )
                    : _notifications[index].type == "UpdateSalary"
                    ? NotificationCard(
                  icon: Icons.money,
                  time: _notifications[index].time,
                  description: _notifications[index].strStatus,
                  date: _notifications[index].date,
                  title: "Updated Salary",
                  seen: _notifications[index].seen,
                  onClick: (){

                    _fireStore.collection(globals.companyName).document("Employee").collection("employee").document(globals.userName)
                        .collection("Notifications").document(_notifications[index].documentName).updateData({
                      "Seen": true,
                    }).then((value){
                      setState(() {
                        _notifications[index].seen = true;
                      });
                    });

                    Alert(
                      context: context,
                      title: "Hey ${globals.userName}",
                      desc: "${globals.companyName} updated your salary to ${_notifications[index].strStatus}",
                      buttons: [
                        DialogButton(
                          child: Text(
                            "OKAY",
                            style: TextStyle(color: Colors.white, fontSize: 17),
                          ),
                          onPressed: () => Navigator.pop(context),
                          width: 120,
                        )
                      ],
                    ).show();
                  },
                )
                    : _notifications[index].type == "UpdateGST"
                    ? NotificationCard(
                  icon: Icons.money,
                  time: _notifications[index].time,
                  description: "",
                  date: _notifications[index].date,
                  title: "Updated GST",
                  seen: _notifications[index].seen,
                  onClick: (){

                    _fireStore.collection(globals.companyName).document("Employee").collection("employee").document(globals.userName)
                        .collection("Notifications").document(_notifications[index].documentName).updateData({
                      "Seen": true,
                    }).then((value){
                      setState(() {
                        _notifications[index].seen = true;
                      });
                    });

                    Alert(
                      context: context,
                      title: "Hey ${globals.userName}",
                      desc: "${globals.companyName} updated the GST on your to ${_notifications[index].strStatus}",
                      buttons: [
                        DialogButton(
                          child: Text(
                            "OKAY",
                            style: TextStyle(color: Colors.white, fontSize: 17),
                          ),
                          onPressed: () => Navigator.pop(context),
                          width: 120,
                        )
                      ],
                    ).show();
                  },
                )
                    : SizedBox()
              )
            ],
          );
        }
    );
  }

  Widget _loadMoreButton(){
    return showLoadMore
        ? isHistoryNotificationLoading
            ? Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.grey[600]),
                ),
            )
            : Column(
                children: [
                  SizedBox(
                    height: 10.0,
                  ),
                  GestureDetector(
                    onTap: (){
                      setState(() {
                        isHistoryNotificationLoading = true;
                        String date = _getPreviousMonth();
                        _getEmployeeNotification(date);

                        if(end.contains(date)){
                          showLoadMore = false;
                        }else{
                          if(int.parse(end.split("-")[1]) == int.parse(date.split("-")[1])){
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
                  ),
                ],
              )
        : SizedBox();
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
    var date;

    _fireStore.collection(globals.companyName).document("Employee").collection("employee").document(globals.userName).get().then((value){
      date = value.data["Start Date"].toString().split("-");
      end = date[1].toString() + "-" + date[2].toString();
    });
  }

  @override
  void initState() {
    super.initState();

    searchMonth = DateTime.now().month;
    searchYear = DateTime.now().year;
    _getJoinDate();

    _getEmployeeNotification(DateTime.now().month.toString() + "-" + DateTime.now().year.toString());
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
      : isThereNoData
        ? _noData()
          : SingleChildScrollView(
            child: Column(
                children: [
                  _widgetSelector(),
                  _loadMoreButton(),
                ],
              ),
          ),
    );
  }
}








class NotificationData{
  String date;
  String documentName;
  String search;
  bool seen;
  String time;
  String type;

  String fromDate;
  String strStatus;

  String description;
  String title;

  String endDate;
  String priority;
  String startDate;
  bool boolStatus;

  String teamTag;

  NotificationData({this.date, this.documentName, this.search, this.seen, this.time, this.type, this.fromDate,
    this.description, this.title, this.endDate, this.priority, this.boolStatus, this.startDate, this.strStatus, this.teamTag,
  });
}
