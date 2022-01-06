import 'package:employee/CommonWidgets/CircularLoadingIndicator.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:employee/Globals.dart' as globals;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:toast/toast.dart';
import '../../constants.dart';
import '../../CEO/CommonMethods/GenerateTodayDate.dart';

Firestore _fireStore = Firestore.instance;

class ViewAttendanceEmployee extends StatefulWidget {
  @override
  _ViewAttendanceEmployeeState createState() => _ViewAttendanceEmployeeState();
  ViewAttendanceEmployee({@required this.ceo});
  final bool ceo;
}

class _ViewAttendanceEmployeeState extends State<ViewAttendanceEmployee> {

  GeneralInfo _info = new GeneralInfo();

  List<EmployeeAttendanceList> attendanceList = [];
  String joinDate;
  String leaveType = "";

  int totalPresent = 0;
  int totalAbsent = 0;
  int totalLeave = 0;

  bool isLoading = true;

  static var month = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];

  // DropDown menu for Employee
  String selectedEmployee;
  List<DropdownMenuItem<String>> _dropDownMenuForEmployee = [];

  static var menuItemsForEmployees =<String>[];

  _getEmployeeList() async {
    List<dynamic> employeeList = [];
    setState(() {
      menuItemsForEmployees.clear() ;
      _dropDownMenuForEmployee = [];
    });
    await _fireStore.collection(globals.companyName).document("Employee").get().then((value){
      employeeList.addAll(value.data["EmployeeList"]);
      print(employeeList);
    }).then((value){
      for(int i=0; i<employeeList.length; i++){
        setState(() {
          menuItemsForEmployees.add(employeeList[i].toString());
        });
        print(menuItemsForEmployees);
      }
      setState(() {
        isLoading = false;
        _dropDownMenuForEmployee = menuItemsForEmployees
            .map((String value) => DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        )
        ).toList();
      });
    });
  }

  // Drop Down Menu for Year
  String selectedYear = DateTime.now().year.toString();
  List<DropdownMenuItem<String>> _dropDownMenuForYear;

  static var menuItemsOfYear = <String>[];

  // DropDown menu for Month
  String selectedMonth;
  List<DropdownMenuItem<String>> _dropDownMenuForMonths;
  static var menuItemsForMonths =<String>[];

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
      _dropDownMenuForMonths = menuItemsForMonths
          .map((String value) => DropdownMenuItem<String>(
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

  _getJoinDate(String userName) async {
    setState(() {
      isLoading = true;
      _dropDownMenuForMonths = [];
    });
    await _fireStore.collection(globals.companyName).document("Employee").collection("employee").document(userName).get().then((value){
      setState(() {
        joinDate = value.data["Start Date"];
      });
    }).then((value){
      isLoading = false;
      _getDisplayMonths();
      _getDisplayYear();
    });
  }

  _getLeaveType(){
    _fireStore.collection(globals.companyName).document("Attendance").get().then((value){
      setState(() {
        leaveType = value.data["Type"];
      });
    }).then((value){
      widget.ceo ? print("CEO") : _getJoinDate(globals.userName);
      widget.ceo ? print("CEO") : _getEmployeeAttendance(DateTime.now().month-1, DateTime.now().year, globals.userName);
      widget.ceo ? _getEmployeeList() : print("Employee");
    }).catchError((onError){
      Navigator.pop(context);
      Toast.show("Error", context);
    });
  }

  _getEmployeeAttendance(int selectedMonth, int selectedYear, String userName) async { // the month is actually the index of an array and year is int selected year
    setState(() {
      isLoading = true;
      attendanceList.clear();
      totalAbsent = 0;
      totalPresent = 0;
      totalLeave = 0;
    });
    if(_info.checkIfLeap(selectedYear)){ // year is a leap year
      var days = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

      for(int i=1; i<=days[selectedMonth]; i++){
        String generateDate = i.toString() + "-" + (selectedMonth+1).toString() + "-" + selectedYear.toString(); // Generating the date to be searched

        // Searching the date in fireStore
        await _fireStore.collection(globals.companyName).document("Attendance").collection("Attendance").document(userName)
            .collection(userName).where("Date", isEqualTo: generateDate).getDocuments().then((value){
              for(var actualData in value.documents){
                setState(() {

                  String strDate = i.toString() + " " + month[selectedMonth] + " " + selectedYear.toString();
                  // Do not show the Result to Today
                  if(leaveType == "ManuallyFill"){
                    attendanceList.add(EmployeeAttendanceList(
                        date: strDate,
                        status: actualData.data["Status"]
                    ));
                    if(actualData.data["Status"] == "Present"){
                      totalPresent++;
                    }else if(actualData.data["Status"] == "Absent"){
                      totalAbsent++;
                    }else if(actualData.data["Status"] == "Leave"){
                      totalLeave++;
                    }
                  }else{
                    if(generateDate != (DateTime.now().day.toString() + "-" + DateTime.now().month.toString() + "-" + DateTime.now().year.toString())){
                      attendanceList.add(EmployeeAttendanceList(
                          date: strDate,
                          status: actualData.data["Status"]
                      ));
                      if(actualData.data["Status"] == "Present"){
                        totalPresent++;
                      }else if(actualData.data["Status"] == "Absent"){
                        totalAbsent++;
                      }else if(actualData.data["Status"] == "Leave"){
                        totalLeave++;
                      }
                    }
                  }
                });
              }
        });
      }
    }else{ // year is not a leap year
      var days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

      for(int i=1; i<=days[selectedMonth]; i++){
        String generateDate = i.toString() + "-" + (selectedMonth+1).toString() + "-" + selectedYear.toString(); // Generating the date to be searched

        // Searching the date in fireStore
        await _fireStore.collection(globals.companyName).document("Attendance").collection("Attendance").document(userName)
            .collection(userName).where("Date", isEqualTo: generateDate).getDocuments().then((value){
          for(var actualData in value.documents){
            setState(() {
              String strDate = i.toString() + " " + month[selectedMonth] + " " + selectedYear.toString();
              // Do not show the Result to Today
              if(leaveType == "ManuallyFil"){
                attendanceList.add(EmployeeAttendanceList(
                    date: strDate,
                    status: actualData.data["Status"]
                ));
              }else{
                if(generateDate != (DateTime.now().day.toString() + "-" + DateTime.now().month.toString() + "-" + DateTime.now().year.toString())){
                  attendanceList.add(EmployeeAttendanceList(
                      date: strDate,
                      status: actualData.data["Status"]
                  ));
                }
              }
              if(actualData.data["Status"] == "Present"){
                totalPresent++;
              }else if(actualData.data["Status"] == "Absent"){
                totalAbsent++;
              }else if(actualData.data["Status"] == "Leave"){
                totalLeave++;
              }
            });
          }
        });
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();

    _getLeaveType();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? circularProgress()
          : SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
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
                              ),
                            ),
                            Text(
                              "Attendance ",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0
                              ),
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.thumb_up,
                                  color: Colors.green[100],
                                ),
                                SizedBox(
                                  width: 3.0,
                                ),
                                Text(
                                  totalPresent.toString(),
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.0
                                  ),
                                ),
                                SizedBox(
                                  width: 6.0,
                                ),
                                Icon(
                                  Icons.thumb_down,
                                  color: Colors.red[100],
                                ),
                                SizedBox(
                                  width: 3.0,
                                ),
                                Text(
                                  totalAbsent.toString(),
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.0
                                  ),
                                ),
                                SizedBox(
                                  width: 6.0,
                                ),
                                Icon(
                                  Icons.home,
                                  color: Colors.grey[300],
                                ),
                                SizedBox(
                                  width: 3.0,
                                ),
                                Text(
                                  totalLeave.toString(),
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.0
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Display the Widget only if the user is CEO
                  widget.ceo
                      ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Card(
                      color: Colors.grey[200],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0))
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: DropdownButton(
                          underline: Container(),
                          hint: Text("Select Employee"),
                          isExpanded: true,
                          value: selectedEmployee,
                          items: _dropDownMenuForEmployee,
                          onChanged: (value){
                            setState(() {
                              selectedEmployee = value;
                              _getJoinDate(value);
                            });
                          },
                        ),
                      ),
                    ),
                  )
                      : SizedBox(),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
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
                                hint: Text("Month"),
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
                              padding: const EdgeInsets.symmetric(horizontal: 10.0),
                              child: DropdownButton(
                                underline: Container(),
                                hint: Text("Year"),
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
                              if(selectedYear != null && selectedMonth != null){

                                if(widget.ceo){
                                  _getEmployeeAttendance(month.indexOf(selectedMonth), int.parse(selectedYear), selectedEmployee);
                                }else{
                                  _getEmployeeAttendance(month.indexOf(selectedMonth), int.parse(selectedYear), globals.userName);
                                }
                              }else{
                                if(selectedYear == null && selectedMonth == null){
                                  Toast.show("Incomplete Details...!", context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                                }else if(selectedMonth == null){
                                  Toast.show("Month...?", context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                                }else if(selectedYear == null){
                                  Toast.show("Year...?", context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                                }
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
                ],
              ),
              Padding(
                padding: widget.ceo
                    ? EdgeInsets.only(top: 180.0)  // If the User is CEO
                    : EdgeInsets.only(top: 120.0), // if the User is Employee
                child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                    itemCount: attendanceList.length,
                    itemBuilder: (context, index){
                      return Card(
                        elevation: 0.5,
                        margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 1.0),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 5.0),
                                child: Text(
                                  attendanceList[index].date,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                              ),
                              Container(
                                height: 33.5,
                                child: Card(
                                  margin: EdgeInsets.only(right: 10.0),
                                  color: attendanceList[index].status == "Present"
                                      ? Colors.green[100]
                                      : attendanceList[index].status == "Absent"
                                          ? Colors.red[100]
                                          : Colors.grey[200],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                                    child: Text(
                                      attendanceList[index].status == "Leave"
                                        ? "   ${attendanceList[index].status}  "
                                        : attendanceList[index].status,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.bold
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    }
                ),
              )
            ],
          )
      ),
    );
  }
}

class EmployeeAttendanceList{
  String date;
  String status;

  EmployeeAttendanceList({String date, String status}){
    this.date = date;
    this.status = status;
  }
}
