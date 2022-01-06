import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:employee/CommonWidgets/CircularLoadingIndicator.dart';
import 'package:employee/CommonWidgets/text_heading.dart';
import 'package:employee/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:employee/Globals.dart' as globals;

Firestore _fireStore = Firestore.instance;

class DemandLeave extends StatefulWidget {
  @override
  _DemandLeaveState createState() => _DemandLeaveState();
}

class _DemandLeaveState extends State<DemandLeave> with SingleTickerProviderStateMixin {

  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now();

  String _description;
  String joinDate;
  int maxLeaves = 0;

  bool isLoadingViewLeaves = true;
  bool isLoadingLeaveApplication = true;
  bool isYearSelected = true;
  bool isMonthSelected = true;
  bool isLeaveTypeSelected = true;

  ListView listCriteria;
  List<LeaveDetails> _employeeListDetails = List<LeaveDetails>();

  static var month = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];

  // DropDown menu for Month
  String selectedMonth;
  List<DropdownMenuItem<String>> _dropDownMenuForMonths;
  static var menuItemsForMonths =<String>[];

  // Drop Down Menu for Year
  String selectedYear = DateTime.now().year.toString();
  List<DropdownMenuItem<String>> _dropDownMenuForYear;

  static var menuItemsOfYear = <String>[];

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

  // Drop down menu
  String selectedLeaveType;
  static var menuItems = <String>[];

  List<DropdownMenuItem<String>> _dropDownMenuItems = menuItems.map(
        (String value) => DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        ),
  ).toList();

  _getLeaveType(){
    List<dynamic> _leaveType = [];
    menuItems.clear();
    _dropDownMenuItems = [];
    _fireStore.collection(globals.companyName).document("Employee").get().then((value){
      _leaveType.addAll(value.data["LeaveList"]);
    }).then((value){

      for(int i = 0; i<_leaveType.length; i++){
        menuItems.add(_leaveType[i].toString().split("------>")[0]);
      }

      setState(() {
        isLoadingLeaveApplication = false;
        _dropDownMenuItems = menuItems.map(
              (String value) => DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              ),
        ).toList();
      });
    }).catchError((onError){
      print("ERROR IN GETTING LEAVES TYPE");
      print(onError);
      Navigator.pop(context);
      Toast.show("Error Fetching the Leave Type", context, gravity: Toast.BOTTOM, duration: Toast.LENGTH_LONG);
    });
  }

  _checkFields(){
    if(selectedLeaveType != null){
      _checkDates();
    }else{
      setState(() {
        selectedLeaveType == null ? isLeaveTypeSelected = false : isLeaveTypeSelected = true;
      });
    }
  }

  _checkIfTheRequestSent() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    var fromDate = _prefs.getString('fromDate');
    String status = "";

    _fireStore.collection(globals.companyName).document("Employee").collection("employee").document(globals.userName)
        .collection("Leaves").where("From Date", isEqualTo: fromDate).getDocuments().then((value){
          value.documents.forEach((element) {
            status = element.data["Status"];
          });
    }).then((value){
      if(status == "Sent"){
        _showDialogueWithSingleButton();
      }else{
        _uploadLeave();
      }
    });
  }

  _showDialogueWithSingleButton(){
    return Alert(
      context: context,
      type: AlertType.none,
      title: "Hey ${globals.userName}",
      desc: "You can only apply for the Another Leave if the action is taken on the Last you sent!",
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
  }

  // Check if the from date is not less then to date
  _checkDates(){

    if(_toDate.isAfter(_fromDate)){
      if(_toDate.difference(_fromDate).inDays <= (maxLeaves-2)){
        _checkIfTheRequestSent();
      }else{
        Toast.show("You can have Max $maxLeaves Leaves in continuous", context, gravity: Toast.BOTTOM, duration: Toast.LENGTH_LONG);
      }
    }else{
      Toast.show("Invalid Dates!", context, gravity: Toast.BOTTOM, duration: Toast.LENGTH_LONG);
    }
  }

  _getMaxLeaves(){
    _fireStore.collection(globals.companyName).document("Attendance").get().then((value){
      maxLeaves = value.data["MaxLeave"];
    });
  }

  _uploadLeave() async {
    setState(() {
      isLoadingLeaveApplication = true;
    });

    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _prefs.setString('fromDate', _fromDate.day.toString() + "-" + _fromDate.month.toString() + "-" + _fromDate.year.toString());
    _prefs.setString('endDate', _toDate.day.toString() + "-" + _toDate.month.toString() + "-" + _toDate.year.toString());

    String document = DateTime.now().toString();
    await _fireStore.collection(globals.companyName).document("Employee").collection("employee").document(globals.userName)
        .collection("Leaves").document(document).setData({
      "From Date": _fromDate.day.toString() + "-" + _fromDate.month.toString() + "-" + _fromDate.year.toString(),
      "To Date": _toDate.day.toString() + "-" + _toDate.month.toString() + "-" + _toDate.year.toString(),
      "Description": _description == null ? "" : _description.trim(),
      "Leave Type": selectedLeaveType,
      "DocumentName": document,
      "Status": "Sent",
      "Search": _fromDate.month.toString() + "-" + _fromDate.year.toString()
     }).then((value){

       _fireStore.collection(globals.companyName).document("CEO Notifications").collection("Notifications").document(document).setData({
         "Date": DateTime.now().day.toString() + "-" + DateTime.now().month.toString() + "-" + DateTime.now().year.toString(),
         "DocumentName": document,
         "EmployeeName": globals.userName,
         "Search": DateTime.now().month.toString() + "-" + DateTime.now().year.toString(),
         "Seen": false,
         "Time": DateTime.now().hour.toString() + ":" + DateTime.now().minute.toString(),
//         "Type": "Leave Notification",
//         "From Date": _fromDate.day.toString() + "-" + _fromDate.month.toString() + "-" + _fromDate.year.toString(),
//         "To Date": _toDate.day.toString() + "-" + _toDate.month.toString() + "-" + _toDate.year.toString(),
         "Description": _description == null ? "" : _description.trim(),
         "Leave Type": selectedLeaveType,
       }).then((value){
         setState(() {isLoadingLeaveApplication = false;});
         Toast.show("Application Sent", context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
         Navigator.pop(context);
       });
    }).catchError((onError){
      setState(() {isLoadingLeaveApplication = false;});
      Toast.show("Error sending the leave Application", context, gravity: Toast.BOTTOM, duration: Toast.LENGTH_LONG);
    });
  }

  TabController _controller;

  final List<Tab> _allTabs = <Tab>[
    Tab(
      text: "Leave Application",
    ),
    Tab(
      text: "View Leaves",
    )
  ];

  _getLeaveDetails(String month, String year) async {
    setState(() {
      _employeeListDetails.clear();
    });
    String searchString  = month + "-" + year;
    print(searchString);
    await _fireStore.collection(globals.companyName).document("Employee").collection("employee").document(globals.userName)
        .collection("Leaves").where("Search", isEqualTo: searchString).getDocuments().then((value){
      value.documents.forEach((element) {
        _populateListView(
          element.data["From Date"],
          element.data["To Date"],
          element.data["Leave Type"],
          element.data["Description"],
          element.data["Status"],
        );
      });
    }).then((value){
      setState(() {
        isLoadingViewLeaves = false;
      });
    }).catchError((onError){
      setState(() {
        isLoadingViewLeaves = false;
      });
    });
  }

  _populateListView(String fromDate, String toDate, String leaveType, String description, String status){
    setState(() {
      _employeeListDetails.add(
          LeaveDetails(
            isExpanded: false,
            leaveType: leaveType,
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
                      description,
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
                      status == "Sent" ? Icons.assignment_turned_in : status == "Approved" ? Icons.thumb_up : Icons.thumb_down,
                      color: Colors.white,
                    )
                ),
              ),
            ),
          )
      );
    });
  }

  Widget tabs(){
    return TabBarView(
      controller: _controller,
      children: <Widget>[
        applyLeave(),
        viewLeaves(),
      ]
    );
  }

  Widget applyLeave(){
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: 10.0,
          ),
          Card(
              margin: EdgeInsets.symmetric(horizontal: 10.0),
              color: Colors.indigo[100],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 30.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Card(
                              color: Colors.grey[100],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(7.0)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
                                child: Text(
                                  _fromDate.day.toString() + "-" + _fromDate.month.toString() + "-" + _fromDate.year.toString(),
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15.0
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 5.0,
                          ),
                          RaisedButton(
                            onPressed: (){
                              showDatePicker(
                                  context: context,
                                  initialDate: _fromDate == null ? DateTime.now() : _fromDate,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2050),
                                  builder: (BuildContext context, Widget child){
                                    return Theme(
                                      data: ThemeData(
                                        primarySwatch: kMaterialColor,
                                        primaryColor: Color(0XFFC41A3B),
                                        accentColor: Color(0XFFC41A3B),
                                      ),
                                      child: child,
                                    );
                                  }
                              ).then((date){
                                setState(() {
                                  date == null ? _fromDate = _fromDate : _fromDate = date;
                                });
                              });
                            },
                            color: Colors.grey[100],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(7.0)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 15.0),
                              child: Text(
                                "FROM...",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13.0,
                                    letterSpacing: 0.5
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [

                          RaisedButton(
                            onPressed: (){
                              showDatePicker(
                                  context: context,
                                  initialDate: _toDate == null ? DateTime.now() : _toDate,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2050),
                                  builder: (BuildContext context, Widget child){
                                    return Theme(
                                      data: ThemeData(
                                        primarySwatch: kMaterialColor,
                                        primaryColor: Color(0XFFC41A3B),
                                        accentColor: Color(0XFFC41A3B),
                                      ),
                                      child: child,
                                    );
                                  }
                              ).then((date){
                                setState(() {
                                  date == null ? _toDate = _toDate : _toDate = date;
                                });
                              });
                            },
                            color: Colors.grey[100],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(7.0)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 15.0),
                              child: Text(
                                "TO...",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13.0,
                                    letterSpacing: 0.5
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 5.0,
                          ),
                          Expanded(
                            child: Card(
                              color: Colors.grey[100],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(7.0)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      _toDate.day.toString() + "-" + _toDate.month.toString() + "-" + _toDate.year.toString(),
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 15.0
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 13.0),
                      child: Card(
                        color: Colors.grey[100],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(7.0)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: DropdownButton(
                            onChanged: (value){
                              setState(() {
                                selectedLeaveType = value;
                                print(value);
                                print(selectedLeaveType);
                              });
                            },
                            isExpanded: true,
                            underline: Container(),
                            hint: Text(
                              isLeaveTypeSelected ? "Leave Type" : "Leave Type Required*",
                              style: TextStyle(
                                  color: isLeaveTypeSelected ? Colors.grey[800] : Colors.red
                              ),
                            ),
                            value: selectedLeaveType,
                            style: TextStyle(
                                color: Colors.grey[800],
                                letterSpacing: 1.5,
                                fontSize: 15.0
                            ),
                            items: _dropDownMenuItems,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              )
          ),
          Card(
            margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
            color: Colors.grey[200],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(7.0)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: TextField(
                  minLines: 1,
                  maxLines: 100,
                  onChanged: (value){
                    setState(() {
                      _description = value;
                    });
                  },
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.5
                  ),
                  decoration: InputDecoration(
                      hintText: "Here goes the Explanation...!",
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide.none
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide.none
                      )
                  )
              ),
            ),
          ),
          RaisedButton(
            color: kLightBlue,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))
            ),
            onPressed: (){
              setState(() {
                isLoadingLeaveApplication = true;
              });
              _checkFields();
            },
            child: Text(
              "SEND APPLICATION",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget viewLeaves(){

    listCriteria = ListView(
      physics: BouncingScrollPhysics(),
      children: [
        Padding(
          padding: EdgeInsets.all(10.0),
          child: ExpansionPanelList(
            expansionCallback: (int index, bool isExpanded){
              setState(() {
                _employeeListDetails[index].isExpanded = !_employeeListDetails[index].isExpanded;
              });
            },
            children: _employeeListDetails.map((LeaveDetails item){
              return ExpansionPanel(
                headerBuilder: (BuildContext context, bool isExpanded){
                  return Padding(
                    padding: const EdgeInsets.only(top: 6.5),
                    child: ListTile(
                      leading: item.circle,
                      title: Text(
                        item.leaveType,
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


    return Container(
      child: isLoadingViewLeaves
          ? circularProgress()
          : Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 3.0),
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
                        _getLeaveDetails((month.indexOf(selectedMonth)+1).toString(), selectedYear);
                        setState(() {
                          isMonthSelected = true;
                          isYearSelected = true;
                          isLoadingViewLeaves = true;
                        });
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
            child: listCriteria,
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _controller = TabController(vsync: this, length: _allTabs.length);
    _getJoinDate(globals.userName);
    _getLeaveType();
    _getMaxLeaves();
    _getLeaveDetails(DateTime.now().month.toString(), DateTime.now().year.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kLightBlue,
        title: Text(
          "Leaves Section",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0
          ),
        ),
        bottom: TabBar(
          controller: _controller,
          tabs: _allTabs,
          indicatorColor: Colors.white,
        ),
      ),
      body: tabs(),
    );
  }
}



class LeaveDetails{
  bool isExpanded;
  final String leaveType;
  final String fromDate;
  final Widget body;
  final Widget circle;

  LeaveDetails({this.isExpanded, this.leaveType, this.fromDate, this.body, this.circle});
}
