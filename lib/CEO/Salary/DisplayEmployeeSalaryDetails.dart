import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_util/date_util.dart';
import 'package:employee/CommonWidgets/CircularLoadingIndicator.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:employee/Globals.dart' as globals;
import 'package:toast/toast.dart';
import '../../constants.dart';

Firestore _fireStore = Firestore.instance;

class DisplayEmployeeSalaryDetails extends StatefulWidget {
  @override
  _DisplayEmployeeSalaryDetailsState createState() => _DisplayEmployeeSalaryDetailsState();

  DisplayEmployeeSalaryDetails({this.employeeName});
  final String employeeName;
}

class _DisplayEmployeeSalaryDetailsState extends State<DisplayEmployeeSalaryDetails> {

  bool isLoading = false;
  bool searched = false;

  String joinDate = "";
  String _employeeSalary = "";
  String _employeeGST = "";

  int _totalAbsent = 0;
  int _totalLeaves = 0;
  int _totalPresent = 0;
  int _perDaySalary = 0;
  int _totalSalary = 0;

  List<dynamic> _employeeLeavesType = [];
  List<dynamic> _companyLeaveType = [];
  List<String> _companyLeavesWithOutTotalNumber = [];
  List<dynamic> _leaveCount = [];

  static var month = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];

  // DropDown menu for Month
  String selectedMonth;
  List<DropdownMenuItem<String>> _dropDownMenuForMonths;
  static var menuItemsForMonths =<String>[];

  // Drop Down Menu for Year
  String selectedYear = DateTime.now().year.toString();
  List<DropdownMenuItem<String>> _dropDownMenuForYear;

  static var menuItemsOfYear = <String>[];

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

  _getJoinDate() async {
    setState(() {
      _dropDownMenuForMonths = [];
    });
    await _fireStore.collection(globals.companyName).document("Employee").collection("employee").document(widget.employeeName).get().then((value){
      setState(() {
        joinDate = value.data["Start Date"];
        print(value.data["Start Date"]);
      });
    } ).then((value){
      _getDisplayMonths();
      _getDisplayYear();
    }).catchError((onError){
      print("-------------");
      print(onError);
    });
  }

  _getSalaryDetails(){
    _fireStore.collection(globals.companyName).document("Employee").collection("employee").document(widget.employeeName).get().then((value){
      setState(() {
        _employeeGST = value.data["GST"];
        _employeeSalary = value.data["Salary"];
      });
    });
  }

  _getSalaryReceipt(String month, String year){
    setState(() {
      isLoading = true;
    });
    String date = month + "-" + year;
    _fireStore.collection(globals.companyName).document("Salary Details").collection(widget.employeeName)
        .where("Search", isEqualTo: date).getDocuments().then((value){
      if(value.documents.isNotEmpty){

        value.documents.forEach((element) {
          setState(() {
            _companyLeaveType = element.data["CompanyLeavesType"];
            _employeeLeavesType = element.data["EmployeeLeaveType"];
            _employeeSalary = element.data["EmployeeSalary"];
            _employeeGST = element.data["GST"];
            _leaveCount = element.data["LeaveCount"];
            _totalAbsent = element.data["TotalAbsent"];
            _totalLeaves = element.data["TotalLeave"];
            _totalPresent = element.data["TotalPresent"];
            _totalSalary = element.data["TotalSalary"];
            _perDaySalary = element.data["PerDaySalary"];
            isLoading = false;
          });
        });
      }else{
        // If the Receipt is Not Generated
        _getSalaryDetails();
        _getCompanyLeaveTypes(month, year);
      }
    }).then((value){})
    .catchError((onError){});
  }

  _calculateLeaveNumber(){
    print(_companyLeaveType);
    for(int i=0; i<_employeeLeavesType.length; i++){
      _leaveCount[_companyLeavesWithOutTotalNumber.indexOf(_employeeLeavesType[i])] = _leaveCount[_companyLeavesWithOutTotalNumber.indexOf(_employeeLeavesType[i])] + 1;
    }

    for(int i=0; i<_companyLeaveType.length; i++){
      if(int.parse(_companyLeaveType[i].toString().split("------>")[1]) < _leaveCount[i]){
        _totalLeaves++;
      }
    }
    _calculateTotalSalary();
  }
  
  _getEmployeeAbsenceAndPresence(String month, String year){

    String date = month + "-" + year;
    _fireStore.collection(globals.companyName).document("Attendance").collection("Attendance").document(widget.employeeName)
        .collection(widget.employeeName).where("Search", isEqualTo: date).getDocuments().then((value){
      value.documents.forEach((element) {
        setState(() {
          if(element.data["Status"] == "Present"){
            _totalPresent++;
          }else if(element.data["Status"] == "Absent"){
            _totalAbsent++;
          }else if(element.data["Status"] == "Leave"){
            _employeeLeavesType.add(element.data["Type"]);
          }
        });
      });
    }).then((value){
      print(_totalPresent);
      print(_totalLeaves);
      print(_totalAbsent);
      print(_employeeLeavesType);
      setState(() {
        _perDaySalary = int.parse(_employeeSalary)~/(DateUtil().daysInMonth(int.parse(month), int.parse(year)));
      });
      _calculateLeaveNumber();
    }).catchError((onError){
      print(onError);
      print("------------");
    });
  }

  _getCompanyLeaveTypes(String month, String year){
    _fireStore.collection(globals.companyName).document("Employee").get().then((value){
      setState(() {
        _companyLeaveType.addAll(value.data["LeaveList"]);
      });
    }).then((value){
      for(int i=0; i<_companyLeaveType.length; i++){
        _leaveCount.add(0);
        _companyLeavesWithOutTotalNumber.add(_companyLeaveType[i].toString().split("------>")[0]);
      }
      _getEmployeeAbsenceAndPresence(month, year);
    });
  }

  _calculateTotalSalary(){
    int gst = int.parse(_employeeGST) * int.parse(_employeeSalary) ~/ 100;
    int subtractAbsent = _totalAbsent * _perDaySalary;
    int subtractLeaves = _totalLeaves * _perDaySalary;
    _totalSalary = int.parse(_employeeSalary) - gst - subtractAbsent - subtractLeaves;
   _uploadSalaryReceipt();
  }

  _uploadSalaryReceipt(){
    _fireStore.collection(globals.companyName).document("Salary Details").collection(widget.employeeName).document(DateTime.now().toString()).setData({
      "EmployeeSalary": _employeeSalary,
      "GST": _employeeGST,
      "TotalPresent": _totalPresent,
      "TotalAbsent": _totalAbsent,
      "TotalLeave": _totalLeaves,
      "TotalSalary": _totalSalary,
      "CompanyLeavesType": _companyLeaveType,
      "EmployeeLeaveType": _employeeLeavesType,
      "LeaveCount": _leaveCount,
      "Search": (month.indexOf(selectedMonth)+1).toString() +  "-" + selectedYear,
      "PerDaySalary": _perDaySalary,
    }).then((value){
      setState(() {
        isLoading = false;
      });
    }).catchError((onError){
      print("ERROR UPLOADING");
    });
  }

  _reInitializeData(){
     _employeeSalary = "";
     _employeeGST = "";

    _totalAbsent = 0;
    _totalLeaves = 0;
    _totalPresent = 0;
    _perDaySalary = 0;
    _totalSalary = 0;

    _employeeLeavesType = [];
    _companyLeaveType = [];
    _companyLeavesWithOutTotalNumber = [];
    _leaveCount = [];
  }

  @override
  void initState() {
    super.initState();
    _getJoinDate();
  }

  @override
  Widget build(BuildContext context) {

    Widget _appBar(){
      return Hero(
        tag: "appBar",
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
          child: Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0))
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
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
                      size: 25.0,
                    ),
                  ),
                  Text(
                    "${widget.employeeName}",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                        letterSpacing: 1.0
                    ),
                  ),
                  SizedBox(width: 10.0,)
                ],
              ),
            ),
          ),
        ),
      );
    }

    Widget _dropDown(){
      return Padding(
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
                  icon: FaIcon(FontAwesomeIcons.search),
                  color: Colors.white,
                  iconSize: 18.0,
                  onPressed: (){
                    if((month.indexOf(selectedMonth) + 1) == DateTime.now().month && int.parse(selectedYear) == DateTime.now().year){
                      Toast.show("Not available for Current Month", context);
                    }else{
                      setState(() {
                        searched = true;
                        isLoading = true;
                      });
                      print(month.indexOf(selectedMonth));
                      _reInitializeData();
                      _getSalaryReceipt((month.indexOf(selectedMonth)+1).toString(), selectedYear);
                    }
                  }

              ),
            )
          ],
        ),
      );
    }

    Widget _demoSalaryReceipt(){
      return Card(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(height: 20.0,),

                      Text(
                        "Salary",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 15.0
                        ),
                      ),

                      SizedBox(height: 5.0,),

                      Text(
                        "GST",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 15.0
                        ),
                      ),

                      SizedBox(height: 5.0,),

                      Text(
                        "Absence",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 15.0
                        ),
                      ),

                      SizedBox(height: 5.0,),

                      Text(
                        "Leaves",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 15.0
                        ),
                      ),

                      SizedBox(height: 10.0,),
                    ],
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10.0,),

                      Text(
                        _employeeSalary,
                        style: TextStyle(
                            color: Colors.grey[900],
                            fontSize: 15.0
                        ),
                      ),

                      SizedBox(height: 5.0,),

                      Text(
                        _employeeGST,
                        style: TextStyle(
                            color: Colors.grey[900],
                            fontSize: 15.0
                        ),
                      ),

                      SizedBox(height: 5.0,),

                      Text(
                        "$_totalAbsent * $_perDaySalary",
                        style: TextStyle(
                            color: Colors.grey[900],
                            fontSize: 15.0
                        ),
                      ),

                      SizedBox(height: 5.0,),

                      Text(
                        "$_totalLeaves * $_perDaySalary",
                        style: TextStyle(
                            color: Colors.grey[900],
                            fontSize: 15.0
                        ),
                      ),

                      SizedBox(height: 10.0,),
                    ],
                  )

                ],
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Divider(
                  height: 1.0,
                  color: Colors.grey[500],
                ),
              ),

              SizedBox(height: 10.0,),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Total   ",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                                fontSize: 15.0
                            ),
                          ),
                        ],
                      ),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "$_totalSalary   ",
                            style: TextStyle(
                                color: Colors.grey[900],
                                fontSize: 15.0
                            ),
                          ),
                        ],
                      )

                    ],
                  )
                ],
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 7.0, horizontal: 25.0),
                child: Divider(
                  height: 1.0,
                  color: Colors.grey[500],
                ),
              ),

              SizedBox(height: 30.0,),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Present",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 15.0
                        ),
                      ),

                      SizedBox(height: 5.0,),

                      Text(
                        "Absent",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 15.0
                        ),
                      ),

                      SizedBox(height: 5.0,),

                      Text(
                        "Leave",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 15.0
                        ),
                      ),

                      SizedBox(height: 5.0,),
                    ],
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "$_totalPresent      ",
                        style: TextStyle(
                            color: Colors.grey[900],
                            fontSize: 15.0
                        ),
                      ),

                      SizedBox(height: 5.0,),

                      Text(
                        "$_totalAbsent     ",
                        style: TextStyle(
                            color: Colors.grey[900],
                            fontSize: 15.0
                        ),
                      ),

                      SizedBox(height: 5.0,),

                      Text(
                        "${_employeeLeavesType.length}     ",
                        style: TextStyle(
                            color: Colors.grey[900],
                            fontSize: 15.0
                        ),
                      ),

                      SizedBox(height: 5.0,),

                    ],
                  )
                ],
              ),

              SizedBox(
                height: 10.0,
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 7.0, horizontal: 25.0),
                child: Divider(
                  height: 1.0,
                  color: Colors.grey[500],
                ),
              ),

              SizedBox(height: 10.0,),

              Center(
                child: Column(
                  children: [
                    Text(
                      "Leave Details",
                      style: TextStyle(
                        color: Colors.grey[900],
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5
                      ),
                    ),

                    SizedBox(height: 10.0,),

                    ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: _companyLeaveType.length,
                        itemBuilder: (context, index){
                        return Container(
                          margin: EdgeInsets.symmetric(horizontal: 50.0),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 1.5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _companyLeaveType[index].toString().split("------>")[0],
                                      style: TextStyle(
                                        color: Colors.grey[800],
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1.0
                                      ),
                                    ),
                                  ],
                                ),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${_leaveCount[index]}  -->  ${_companyLeaveType[index].split("------>")[1]}",
                                      style: TextStyle(
                                        color: Colors.grey[800],
                                        fontSize: 15.0
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                        }
                    )
                  ],
                ),
              ),

              SizedBox(height: 20.0,),
            ],
          ),
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
            _dropDown(),
            searched
                ? _demoSalaryReceipt()
                : SizedBox(),
          ],
        ),
      ),
    );
  }
}
