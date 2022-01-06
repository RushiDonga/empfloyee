import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:employee/CommonWidgets/CircularLoadingIndicator.dart';
import 'package:employee/CommonWidgets/text_heading.dart';
import 'package:employee/constants.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../Globals.dart' as globals;
import 'package:toast/toast.dart';
import 'package:date_util/date_util.dart';

Firestore _fireStore = Firestore.instance;

class ViewLeavesCEO extends StatefulWidget {
  @override
  _ViewLeavesCEOState createState() => _ViewLeavesCEOState();
}

class _ViewLeavesCEOState extends State<ViewLeavesCEO> with SingleTickerProviderStateMixin {

  TabController _controller;
  List<dynamic> _employeeList = [];

  static var month = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];

  String joinDate;

  bool isLoadingApproveLeave = true;
  bool isLoadingLeaveHistory = true;
  bool isOnHistoryTab = false;
  bool isSelectingEmployee = true;
  bool isYearSelected = true;
  bool isMonthSelected = true;

  static var menuItemsForMonths = <String>[];
  static var menuItemsOfYear = <String>[];

  ListView _approvedLeavesCriteria;
  ListView _leavesHistoryCriteria;
  List<ApproveLeaves> _employeeApproveLeaves = List<ApproveLeaves>();
  List<ApproveLeaves> _leaveHistoryDetails =  List<ApproveLeaves>();

  List<DropdownMenuItem<String>> _dropDownMenuForYear;
  List<DropdownMenuItem<String>> _dropDownMenuForMonths;


  String selectedEmployeeName = "";
  String selectedMonth = DateTime.now().month.toString();
  String selectedYear = DateTime.now().year.toString();

  static var employeeDropDownMenu = <String>[];

  _getJoinDate(String userName) async {
    setState(() {
      _dropDownMenuForMonths = [];
    });
    await _fireStore.collection(globals.companyName).document("Employee").collection("employee").document(userName).get().then((value){
      setState(() {
        joinDate = value.data["Start Date"];
      });
    }).then((value){
      _getDisplayMonths();
      _getDisplayYear();
      setState(() {
        isLoadingLeaveHistory = false;
      });
    });
  }

  _getDisplayMonths(){
    setState(() {
      _dropDownMenuForMonths = [];
      menuItemsForMonths.clear();
      selectedMonth = null;
    });
    var splitDate = joinDate.split("-");
    if(selectedYear == splitDate[2]){
      int joinMonth = int.parse(splitDate[1]) - 1;
      int todayMonth = DateTime.now().month - 1;
      for(int i=joinMonth; i<=todayMonth; i++){
        setState(() {
          menuItemsForMonths.add(month[i]);
        });
      }
    }else{
      if(selectedYear == DateTime.now().year.toString()){
        int currentMonth = DateTime.now().month - 1;
        for(int i=0; i<=currentMonth; i++){
          setState(() {
            menuItemsForMonths.add(month[i]);
          });
        }
      }else{
        for(int i=0; i<=11; i++){
          setState(() {
            menuItemsForMonths.add(month[i]);
          });
        }
      }
    }
    setState(() {
      print(menuItemsForMonths);
      _dropDownMenuForMonths = menuItemsForMonths.map((String value) => DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      )
      ).toList();
    });
  }

  _getDisplayYear(){
    int joinYear;
    joinYear = int.parse(joinDate.split("-")[2]);
    setState(() {
      menuItemsOfYear.clear();
      _dropDownMenuForYear = [];
      selectedYear = null;
    });
    int totalLoop = DateTime.now().year - joinYear+1;
    for(int i=0; i<totalLoop; i++){
      setState(() {
        menuItemsOfYear.add(joinYear.toString());
        print(joinYear++);
      });
    }
    print(menuItemsOfYear);
    setState(() {
      _dropDownMenuForYear = menuItemsOfYear.map((String value) => DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      )
      ).toList();
    });
  }


  _getEmployeeList() async {
    await _fireStore.collection(globals.companyName).document("Employee").get().then((value){
      print(value.data["EmployeeList"]);
      _employeeList = value.data["EmployeeList"];
      for(int i=0;i< _employeeList.length; i++){
        setState(() {
          employeeDropDownMenu.add(_employeeList[i].toString());
        });
      }
      print(employeeDropDownMenu);
    }).then((value) => {
      setState((){
        isLoadingLeaveHistory = false;
      }),
      _getNewLeaveApplication(),
    });
  }

  _getNewLeaveApplication() async {
    for(int i=0; i<_employeeList.length; i++){

      await _fireStore.collection(globals.companyName).document("Employee").collection("employee").document(_employeeList[i])
          .collection("Leaves").where("Status", isEqualTo: "Sent").getDocuments().then((value){
        value.documents.forEach((element) {
          print(element.data["Status"]);
          _populateNewLeaveApplication(
              _employeeList[i],
              element.data["From Date"],
              element.data["To Date"],
              element.data["Description"],
              element.data["Leave Type"],
            element.data["DocumentName"]
          );
        });
      });
    }
    setState(() {
      isLoadingApproveLeave = false;
    });
  }

  _getTheLeavesHistory(String employeeName, String month, String year){
    String searchString = month + "-" + year;
    _fireStore.collection(globals.companyName).document("Employee").collection("employee").document(employeeName)
        .collection("Leaves").where("Search", isEqualTo: searchString).getDocuments().then((value){
      value.documents.forEach((element) {
        if(element.data["Status"] != "Sent"){
          _populateTheLeavesHistorySection(
            employeeName,
            element.data["From Date"],
            element.data["Description"],
            element.data["To Date"],
            element.data["Leave Type"],
            element.data["Status"],
          );
        }
      });
    }).then((value){
      setState(() {
        isLoadingLeaveHistory = false;
      });
    }).catchError((onError){
      setState(() {
        isLoadingLeaveHistory = false;
        Toast.show("Error Loading Details...:(", context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      });
    });
  }

  _populateTheLeavesHistorySection(String employeeName, String fromDate, String description, String toDate, String leaveType, String status){
    setState(() {
      _leaveHistoryDetails.add(
          ApproveLeaves(
            isExpanded: false,
            employeeName: employeeName,
            fromDate: fromDate,
            body: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(),
                  TextHeading(text: "Description:",),
                  Padding(
                    padding: const EdgeInsets.only(left: 19.0, bottom: 3.0),
                    child: Text(
                      description != null ? description : "",
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      TextHeading(text: "From Date: ",),
                      Text(
                          "$fromDate"
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      TextHeading(text: "To Date:     ",),
                      Text(
                          "$toDate"
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      TextHeading(text: "Leave Type:",),
                      Text(
                          "$leaveType"
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      TextHeading(text: "Status:       ",),
                      Text(
                          "$status"
                      )
                    ],
                  ),
                ],
              ),
            ),
            circle: ClipOval(
              child: Material(
                color: kLightBlue,
                child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 14.0),
                    child: Icon(
                      status == "Approved" ? Icons.thumb_up : Icons.thumb_down,
                      color: Colors.white,
                    )
                ),
              ),
            ),
          )
      );
    });
  }

  _updateLeaveStatus(String status, String employeeName, String documentName, String fromDate, String toDate, String leaveType){
    _fireStore.collection(globals.companyName).document("Employee").collection("employee").document(employeeName).collection("Leaves")
        .document(documentName).updateData({ // Updating The Laves Section
      "Status": status,
    }).then((value){
      setState(() {

        // Updating the Leave Status
        if(status != "Declined"){
          _getBetweenDates(fromDate, toDate, employeeName, leaveType);
        }

        // Notifying the Employee
        _fireStore.collection(globals.companyName).document("Employee").collection("employee").document(employeeName)
            .collection("Notifications").document(documentName).setData({  // Updating in Notification Section
          "Date": DateTime.now().day.toString() + "-" + DateTime.now().month.toString() + "-" + DateTime.now().year.toString(),
          "DocumentName": documentName,
          "Search": DateTime.now().month.toString() + "-" + DateTime.now().year.toString(),
          "Seen": false,
          "Time": DateTime.now().hour.toString() + ":" + DateTime.now().minute.toString(),
          "Type": "LeaveStatus",
          "FromDate": fromDate,
          "EmployeeName": employeeName,
          "Status": status,
        }).then((value){
        }).catchError((onError){print(onError);});
      });
    }).catchError((onError){
      setState(() {
        isLoadingApproveLeave = false;
      });
      Toast.show("Error updating leave Status", context, gravity: Toast.BOTTOM, duration: Toast.LENGTH_LONG);
    });
  }

  _getBetweenDates(String startDate, String endDate, String employeeName, String leaveType) async {

    var splitStartDate = startDate.split("-");
    var splitEndDate = endDate.split("-");

    int startDateCount = int.parse(splitStartDate[0]);
    int startMonthCount = int.parse(splitStartDate[1]);
    int startYearCount = int.parse(splitStartDate[2]);

    int endDateCount = int.parse(splitEndDate[0]);
    int endMonthCount = int.parse(splitEndDate[1]);
    int endYearCount = int.parse(splitEndDate[2]);

    int difference = DateTime(endYearCount, endMonthCount, endDateCount).difference(DateTime(startYearCount, startMonthCount, startDateCount)).inDays;

    for(int i=0; i<=difference; i++){

      if(startDateCount > 31 && startMonthCount == 12){
        startDateCount = 1;
        startMonthCount = 1;
        startYearCount = startYearCount+1;
      }else if(startDateCount > DateUtil().daysInMonth(startMonthCount, startYearCount)){
        startDateCount = 1;
        startMonthCount = startMonthCount + 1;
      }

      // Uploading Leaves to the Attendance Section
      String documentName = startYearCount.toString() + "-" + startMonthCount.toString() + "-" + startDateCount.toString() + " " + "20" + ":" + "18" + ":" + "00" + "." + "123456";

      await _fireStore.collection(globals.companyName).document("Attendance").collection("Attendance").document(employeeName).collection(employeeName)
          .document(documentName).get().then((value) async {
         if(value.exists || value != null){
           if(value.data["DocumentName"] == documentName){

             // Update the Document if it already Exists
             await _fireStore.collection(globals.companyName).document("Attendance").collection("Attendance").document(employeeName).collection(employeeName)
                 .document(documentName).updateData({
               "Date": startDateCount.toString() + "-" + startMonthCount.toString() + "-" + startYearCount.toString(),
               "Status": "Leave",
               "Time": DateTime.now().hour.toString() + ":" + DateTime.now().minute.toString(),
               "filled": true,
               "DocumentName": documentName,
               "Type": leaveType,
               "Search": startMonthCount.toString() + "-" + startYearCount.toString(),
             }).then((value){})
                 .catchError((onError){});
           }
         }
      }).catchError((onError) async {

        // Create the Document if it does not Exists
        await _fireStore.collection(globals.companyName).document("Attendance").collection("Attendance").document(employeeName).collection(employeeName)
            .document(documentName).setData({
          "Date": startDateCount.toString() + "-" + startMonthCount.toString() + "-" + startYearCount.toString(),
          "Status": "Leave",
          "Time": DateTime.now().hour.toString() + ":" + DateTime.now().minute.toString(),
          "filled": true,
          "DocumentName": documentName,
          "Type": leaveType,
          "Search": startMonthCount.toString() + "-" + startYearCount.toString(),
        }).then((value){})
            .catchError((onError){});
      });

      startDateCount++;
    }

    _employeeApproveLeaves.clear();
    _getNewLeaveApplication();
    Toast.show("Leave Approved Successfully..!", context, gravity: Toast.BOTTOM, duration: Toast.LENGTH_LONG);
  }

  _populateNewLeaveApplication(String employeeName, String fromDate, String toDate, String description, String leaveType, String documentName){
    setState(() {
      _employeeApproveLeaves.add(
        ApproveLeaves(
          isExpanded: false,
          employeeName: employeeName,
          fromDate: fromDate,
          body: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(),
                TextHeading(text: "Description:",),
                Padding(
                  padding: const EdgeInsets.only(left: 19.0, bottom: 3.0),
                  child: Text(
                    description != null ? description : "",
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextHeading(text: "From Date: ",),
                    Text(
                        "$fromDate"
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextHeading(text: "To Date:     ",),
                    Text(
                        "$toDate"
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextHeading(text: "Leave Type:",),
                    Text(
                        "$leaveType"
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    RaisedButton(
                      onPressed: (){
                        setState(() {
                          isLoadingApproveLeave = true;
                        });
                        _updateLeaveStatus("Approved", employeeName, documentName, fromDate, toDate, leaveType);
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
                        setState(() {
                          isLoadingApproveLeave = true;
                        });
                        _updateLeaveStatus("Declined", employeeName, documentName, fromDate, toDate, leaveType);
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
              ],
            ),
          ),
          circle: ClipOval(
            child: Material(
              color: kLightBlue,
              child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 14.0),
                  child: Icon(
                    Icons.account_circle,
                    color: Colors.white,
                  )
              ),
            ),
          ),
        )
      );
    });
  }

  final List<Tab> _allTabs = <Tab>[
    Tab(
      text: "Approve Leaves",
    ),
    Tab(
      text: "Leaves History",
    )
  ];

  Widget _tabs(){
    return TabBarView(
        controller: _controller,
        children: <Widget>[
          isLoadingApproveLeave ? circularProgress() : _approveLeaves(),
          isLoadingLeaveHistory
              ? circularProgress()
              : isSelectingEmployee ? _selectEmployee() : _leavesHistory(),
        ]
    );
  }

  Widget _selectEmployee(){
    return Container(
      color: Colors.black12,
      child: SizedBox(
        height: 50.0,
        child: Card(
          margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            child: ListView.builder(
                itemCount: _employeeList.length,
                itemBuilder: (context, index){
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3.0),
                    child: GestureDetector(
                      onTap: (){
                        setState(() {
                          selectedEmployeeName = _employeeList[index];
                          isSelectingEmployee = false;
                          isLoadingLeaveHistory = true;
                          _leaveHistoryDetails.clear();
                          _getJoinDate(selectedEmployeeName);
                        });
                      },
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.person,
                                color: kLightBlue,
                              ),
                              SizedBox(
                                width: 15.0,
                              ),
                              Text(
                                _employeeList[index],
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 17.0
                                ),
                              ),
                            ],
                          ),
                          Divider(),
                        ],
                      ),
                    ),
                  );
                }
            ),
          ),
        ),
      ),
    );
  }

  Widget _approveLeaves(){

    _approvedLeavesCriteria = ListView(
      physics: BouncingScrollPhysics(),
      children: [
        Padding(
        padding: EdgeInsets.all(10.0),
        child: ExpansionPanelList(
          expansionCallback: (int index, bool isExpanded){
            setState(() {
              _employeeApproveLeaves[index].isExpanded = !_employeeApproveLeaves[index].isExpanded;
            });
          },
          children: _employeeApproveLeaves.map((ApproveLeaves item){
            return ExpansionPanel(
                headerBuilder: (BuildContext context, bool isExpanded){
                  return Padding(
                    padding: const EdgeInsets.only(top: 6.5),
                    child: ListTile(
                      leading: item.circle,
                      title: Text(
                        item.employeeName,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 7.0, bottom: 5.0),
                        child: Text(
                          "From: ${item.fromDate}",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 14.0,
                          ),
                        ),
                      ),
                    ),
                  );
                },
                isExpanded: item.isExpanded,
                body: item.body
            );
          }).toList(),
        ),
      )],
    );

    return _approvedLeavesCriteria;
  }

  Widget _leavesHistory(){

    _leavesHistoryCriteria = ListView(
      physics: BouncingScrollPhysics(),
      children: [
        Padding(
          padding: EdgeInsets.all(10.0),
          child: ExpansionPanelList(
            expansionCallback: (int index, bool isExpanded){
              setState(() {
                _leaveHistoryDetails[index].isExpanded = !_leaveHistoryDetails[index].isExpanded;
              });
            },
            children: _leaveHistoryDetails.map((ApproveLeaves item){
              return ExpansionPanel(
                  headerBuilder: (BuildContext context, bool isExpanded){
                    return Padding(
                      padding: const EdgeInsets.only(top: 6.5),
                      child: ListTile(
                        leading: item.circle,
                        title: Text(
                          item.employeeName,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 7.0, bottom: 5.0),
                          child: Text(
                            "From: ${item.fromDate}",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 14.0,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  isExpanded: item.isExpanded,
                  body: item.body
              );
            }).toList(),
          ),
        )
      ],
    );

    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 3.0),
          child: Row(
            children: [
              Expanded(
                child: Card(
                  color: Colors.grey[200],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0))
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: DropdownButton(
                      underline: Container(),
                      hint: Text(
                        isMonthSelected ? "Month" : "Month...!",
                        style: TextStyle(
                          color: isMonthSelected ? Colors.grey[600] : Colors.red,
                        ),
                      ),
                      isExpanded: true,
                      value: selectedMonth,
                      items: _dropDownMenuForMonths,
                      onChanged: (value){
                        setState(() {
                          selectedMonth = value;
                        });
                      },
                    ),
                  ),
                ),
              ),

              Expanded(
                child: Card(
                  color: Colors.grey[200],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0))
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: DropdownButton(
                      underline: Container(),
                      hint: Text(
                        isYearSelected ? "Year" : "Year...!",
                        style: TextStyle(
                          color: isYearSelected ? Colors.grey[600] : Colors.red,
                        ),
                      ),
                      isExpanded: true,
                      value: selectedYear,
                      items: _dropDownMenuForYear,
                      onChanged: (value){
                        setState(() {
                          selectedYear = value;
                          _getDisplayMonths();
                        });
                      },
                    ),
                  ),
                ),
              ),

              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0))
                ),
                color: kLightBlue,
                child: IconButton(
                  onPressed: (){
                    if(selectedMonth != null && selectedYear != null){
                      setState(() {
                        _leaveHistoryDetails.clear();
                        isLoadingLeaveHistory = true;
                        isMonthSelected = true;
                        isYearSelected = true;
                      });
                      _getTheLeavesHistory(selectedEmployeeName, (month.indexOf(selectedMonth)+1).toString(), selectedYear);
                    }else{
                      setState(() {
                        isMonthSelected = false;
                        isYearSelected = false;
                        isMonthSelected = false;
                      });
                    }
                  },
                  icon: FaIcon(FontAwesomeIcons.search),
                  color: Colors.white,
                  iconSize: 18.0,
                ),
              )
            ],
          ),
        ),

        Padding(
          padding: EdgeInsets.only(top: 56.0),
          child: _leavesHistoryCriteria,
        )
      ],
    );
  }

  _listenToController(){
    setState(() {
      if(_controller.index == 0){
        isOnHistoryTab = false;
      }else if(_controller.index == 1){
        isOnHistoryTab = true;
      }
    });
  }

  @override
  void initState() {
    super.initState();

    _controller = TabController(vsync: this, length: _allTabs.length);
    _controller.addListener(_listenToController);

    _getEmployeeList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kLightBlue,
        title: isOnHistoryTab
        ? GestureDetector(
          onTap: (){
            setState(() {
              isSelectingEmployee = true;
            });
          },
          child: Text(
            selectedEmployeeName == "" ? "Select Employee" : selectedEmployeeName,
            style: TextStyle(
                color: Colors.white,
                letterSpacing: 0.5
            ),
          ),
        )
        : Text(
          "Leaves Section",
          style: TextStyle(
              color: Colors.white,
              letterSpacing: 0.5
          ),
        ),
        bottom: TabBar(
          indicatorColor: Colors.white,
          tabs: _allTabs,
          controller: _controller,
        ),
      ),
      body: _tabs(),
    );
  }
}






class ApproveLeaves{
  bool isExpanded;
  String employeeName;
  String fromDate;
  Widget body;
  Widget circle;

  ApproveLeaves({this.isExpanded, this.employeeName, this.fromDate, this.body, this.circle});
}
