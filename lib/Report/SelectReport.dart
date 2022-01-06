import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_util/date_util.dart';
import 'package:employee/Report/ViewReport.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:employee/Globals.dart' as globals;

import '../constants.dart';

Firestore _fireStore = Firestore.instance;

class SelectReport extends StatefulWidget {
  @override
  _SelectReportState createState() => _SelectReportState();
}

class _SelectReportState extends State<SelectReport> {

  bool isLoading = true;

  String joinDate;

  List<String> dates = [];

  static var month = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];

  // DropDown menu for Employee
  String selectedEmployee;
  List<DropdownMenuItem<String>> _dropDownMenuForEmployee = [];

  static var menuItemsForEmployees =<String>[];

  // Drop Down Menu for Year
  String selectedYear = DateTime.now().year.toString();
  List<DropdownMenuItem<String>> _dropDownMenuForYear;

  static var menuItemsOfYear = <String>[];

  // DropDown menu for Month
  String selectedMonth;
  List<DropdownMenuItem<String>> _dropDownMenuForMonths;
  static var menuItemsForMonths =<String>[];

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

  _generateDate(){

    setState(() {
      dates.clear();
    });

    var splitDate = joinDate.split("-");

    var dateUtility = DateUtil();
    var day1 = dateUtility.daysInMonth(month.indexOf(selectedMonth) + 1, int.parse(selectedYear));

    if(selectedYear == splitDate[2]){
      if((month.indexOf(selectedMonth) + 1).toString() == splitDate[1]){
        for(int i= int.parse(splitDate[0]); i<= DateTime.now().day; i++){
          dates.add(i.toString() + " " + selectedMonth.toString() + " " + selectedYear.toString());
        }
      }else{
        for(int i=1; i<=day1; i++){
          dates.add(i.toString() + " " + selectedMonth.toString() + " " + selectedYear.toString());
        }
      }
    }else{
      for(int i=1; i<=day1; i++){
        dates.add(i.toString() + " " + selectedMonth.toString() + " " + selectedYear.toString());
      }
    }

  }

  @override
  void initState() {
    super.initState();

    _getEmployeeList();
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
                "View Report",
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

    Widget _displayDropdown(){
      return Column(
        children: [
          Padding(
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
          ),

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
                          _generateDate();
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
              ],
            ),
          ),
        ],
      );
    }

    Widget _displayDates(){
      return Container(
        margin: EdgeInsets.only(top: 170.0),
        child: ListView.builder(
          physics: BouncingScrollPhysics(),
          itemCount: dates.length,
          itemBuilder: (BuildContext context, int index) {
            return Container(
              child: GestureDetector(
                onTap: (){
                  var date = dates[index].split(" ");

                  Navigator.push(context, MaterialPageRoute(builder: (context) => ViewReport(
                    date: date[0] + "-" + (month.indexOf(date[1]) + 1).toString() + "-" + date[2],
                    employeeName: selectedEmployee,
                  )));
                },
                child: Card(
                  elevation: 0.5,
                  margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 1.0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 13.0),
                    child: Row(
                      children: [
                        SizedBox(width: 5.0,),
                        Icon(
                          Icons.date_range_rounded,
                        ),
                        SizedBox(width: 10.0,),
                        Padding(
                          padding: const EdgeInsets.only(left: 5.0),
                          child: Text(
                            dates[index],
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },

        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              child: Column(
                children: [
                  _appBar(),
                  _displayDropdown(),
                ],
              ),
            ),
            _displayDates(),
          ],
        ),
      ),
    );
  }
}
