import 'package:employee/CommonWidgets/CircularLoadingIndicator.dart';
import 'package:flutter/material.dart';
import '../../Globals.dart' as globals;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../CEO/CommonMethods/GenerateTodayDate.dart';
import '../../constants.dart';

Firestore _fireStore = Firestore.instance;

class TodayAttendance extends StatefulWidget {
  @override
  _TodayAttendanceState createState() => _TodayAttendanceState();
}

class _TodayAttendanceState extends State<TodayAttendance> {
  GeneralInfo _todayDate = GeneralInfo();

  List<Padding> todayPresentList = [];

  int totalPresent = 0;
  int totalAbsent = 0;
  int notFilled = 0;
  int totalLeave = 0;

  bool fillAttendance;
  bool isLoading = true;

  // DropDown menu
  String selected;
  final List<DropdownMenuItem<String>> __dropDownMenuItems =menuItems.map(
      (String value) =>DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      )
  ).toList();

  static const menuItems =<String>[
    "All",
    "Absent",
    "Present",
    "Leave"
  ];

  _getTodayAttendance(String searchBy) async {
    setState(() {
      isLoading = true;
    });
    todayPresentList.clear();
    List<dynamic> employeeList = [];
    await _fireStore.collection(globals.companyName).document("Employee").get().then((value){   // Get the List of Employees
      employeeList = value.data["EmployeeList"];
    }).then((value) async {
      String documentName;
      await _fireStore.collection(globals.companyName).document("Attendance").get().then((value){  // Get the Name of the Document
        documentName = value.data["DocumentName"];
      }).then((value) async {

        if(searchBy == "All"){
          totalAbsent = 0;
          totalPresent = 0;
        }
        if(documentName.contains(_todayDate.getTodayDateYMD())){
          setState(() {fillAttendance = true;});
          for(int i=0; i<employeeList.length; i++){  // To Filter the Presence for today
            await _fireStore.collection(globals.companyName).document("Attendance").collection("Attendance").document(employeeList[i])
                .collection(employeeList[i]).document(documentName).get().then((value){

                  if(searchBy == "All"){ // Filter Result for ALL
                    if(value.data["filled"] == true){
                      value.data["Status"] == "Present"
                          ? totalPresent++
                          : value.data["Status"] == "Absent"
                              ? totalAbsent++
                              : totalLeave++;
                      print("===============");
                      print(totalLeave);
                      _displayTodayPresence(employeeList[i], value.data["Status"]);
                    }else{
                      print(value.data["filled"]);
                      _displayTodayPresence(employeeList[i], "    NA     ");
                    }
                  }else if(searchBy == "Present"){  // Filter Result for PRESENT
                    if(value.data["filled"] == true){
                      if(value.data["Status"] == "Present"){
                        _displayTodayPresence(employeeList[i], value.data["Status"]);
                      }
                    }
                  }else if(searchBy == "Absent"){ // Filter Result for ABSENT
                    if(value.data["filled"] == true){
                      if(value.data["Status"] == "Absent"){
                        _displayTodayPresence(employeeList[i], value.data["Status"]);
                      }
                    }
                  }else if(searchBy == "Leave"){ // Filter Result for NOT FILLED
                    if(value.data["Status"] == "Leave"){
                      _displayTodayPresence(employeeList[i], "  Leave   ");
                    }
                  }else{ // Search Result by DEFAULT IS ALL
                    if(value.data["filled"] == true){
                      value.data["Status"] == "Present"
                          ? totalPresent++
                          : value.data["Status"] == "Absent"
                              ? totalAbsent++
                              : totalLeave++;
                      _displayTodayPresence(employeeList[i], value.data["Status"]);
                    }else{
                      print(value.data["filled"]);
                      _displayTodayPresence(employeeList[i], "    NA     ");
                    }
                  }
            });
          }
        }else{
          setState(() {
            print(documentName);
            print(_todayDate.getTodayDateYMD());
            fillAttendance = false;
          });
        }
        setState(() {
          isLoading = false;
        });
      }).catchError((onError){print(onError);isLoading = false;});
    }).catchError((onError){print(onError);isLoading = false;});
  }

  _displayTodayPresence(String name, String status){
    setState(() {
      todayPresentList.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 11.0, horizontal: 14.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          Icons.person,
                          color: kLightBlue,
                        ),
                        SizedBox(
                          width: 8.0,
                        ),
                        Text(
                            name,
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    ),
                    Card(
                      margin: EdgeInsets.only(right: 10.0),
                      color: status == "Present" ? Colors.green[100] : status == "Absent" ? Colors.red[100] : Colors.grey[200],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 15.0),
                        child: Text(
                          status,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 12.5,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _getTodayAttendance("All");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? circularProgress()
          : SafeArea(
        child: Column(
          children: <Widget>[
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
                        "Today's Attendance",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0
                        ),
                      ),
                      SizedBox(
                        width: 10.0,
                      )
                    ],
                  ),
                ),
              ),
            ),
            fillAttendance == true
                ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[

//                Card(
//                  color: kLightBlue,
//                  shape: RoundedRectangleBorder(
//                      borderRadius: BorderRadius.all(Radius.circular(5.0))
//                  ),
//                  child: Padding(
//                    padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
//                    child: Text(
//                      "Present: $totalPresent",
//                      style: TextStyle(
//                          color: Colors.white,
//                          fontWeight: FontWeight.bold
//                      ),
//                    ),
//                  ),
//                ),
//                Card(
//                  color: kLightBlue,
//                  shape: RoundedRectangleBorder(
//                      borderRadius: BorderRadius.all(Radius.circular(5.0))
//                  ),
//                  child: Padding(
//                    padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 30.0),
//                    child: Text(
//                      "Absent: $totalAbsent",
//                      style: TextStyle(
//                          color: Colors.white,
//                          fontWeight: FontWeight.bold
//                      ),
//                    ),
//                  ),
//                ),

              Row(
                children: [
                  Icon(
                    Icons.thumb_up,
                    color: Colors.green[200],
                    size: 29.0,
                  ),
                  SizedBox(
                    width: 7.0,
                  ),
                  Text(
                    totalPresent.toString(),
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20.0
                    ),
                  ),
                ],
              ),

                Row(
                  children: [
                    Icon(
                      Icons.thumb_down,
                      color: Colors.red[200],
                      size: 29.0,
                    ),
                    SizedBox(
                      width: 7.0,
                    ),
                    Text(
                      totalAbsent.toString(),
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20.0
                      ),
                    ),
                  ],
                ),

                Row(
                  children: [
                    Icon(
                      Icons.home,
                      color: Colors.grey[400],
                      size: 29.0,
                    ),
                    SizedBox(
                      width: 7.0,
                    ),
                    Text(
                      totalLeave.toString(),
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20.0
                      ),
                    ),
                  ],
                ),

                DropdownButton(
                  underline: Container(),
                  value: selected,
                  hint: Text("Search By"),
                  items: __dropDownMenuItems,
                  onChanged: (value){
                    setState(() {
                      selected = value;
                      _getTodayAttendance(value);
                    });
                  },
                )
              ],
            )
                : SizedBox(),
            fillAttendance == true
                ? Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: todayPresentList,
                ),
              ),
            )
                : Column(
              children: [
                SizedBox(
                  height: 80.0,
                ),
                Image(
                  image: AssetImage("assets/noAttendance.png"),
                  width: 200.0,
                  height: 200.0,
                ),
                Text(
                  "Attendance has not \nyet started",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                      fontSize: 17.0
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

