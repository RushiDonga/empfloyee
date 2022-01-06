import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'confirm_pay.dart';
import 'display_all_details_of_salary.dart';

final Firestore fireStore = Firestore.instance;

class SortEmployeeSalaryDetails extends StatefulWidget {
  @override
  _SortEmployeeSalaryDetailsState createState() => _SortEmployeeSalaryDetailsState();

  SortEmployeeSalaryDetails({this.companyName });
  final String companyName;

}

class _SortEmployeeSalaryDetailsState extends State<SortEmployeeSalaryDetails> {

  List<String> months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
  String selectedMonth;
  String selectedYear = DateTime.now().year.toString();

  List<Card> _sortedSalaryDetails = [];

  _getEmployeeList() {
    _sortedSalaryDetails.clear();
    final fireStoreData = fireStore.collection(widget.companyName).document("Employee").collection("employee").orderBy("Name");
    fireStoreData.getDocuments().then((value){
      value.documents.forEach((element) {
        _getSalaryDetails(element.data["Name"]);
      });
    });
  }

  _getSalaryDetails(String employeeName){
    final fireStoreData = fireStore.collection(widget.companyName).document("Salary Details").collection(employeeName).orderBy("Name");
    fireStoreData.getDocuments().then((value){
      value.documents.forEach((element) {

        int month = months.indexOf(selectedMonth) + 1;

        String searchDate;
        month < 10 ? searchDate = selectedYear + "-0" + month.toString() : searchDate = selectedYear + "-" + month.toString();

        if((element.data["Document Name"]).contains(searchDate)){
          _displaySalaryDetails(element.data["Name"], element.data["Salary"], element.data["Status"], element.data["Paid"], element.data["Pay Date"], element.data["Document Name"], element.data["Date Paid"], element.data["GST"]);
        }
      });
    });
  }

  _displaySalaryDetails(String name, String salary, String status, String paidAmount, String payDate, String documentID, String paymentDate, String gst){
    setState(() {
      _sortedSalaryDetails.add(
          Card(
            margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            elevation: 3.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 12.0, left: 15.0),
                  child: Text(
                    "$name",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 19.0
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(
                              height: 10.0,
                            ),
                            Text(
                              "Salary :- $salary",
                              style: TextStyle(
                                  fontSize: 17.0
                              ),
                            ),
                            SizedBox(
                              height: 5.0,
                            ),
                            Row(
                              children: <Widget>[
                                Text(
                                  "Status :- ",
                                  style: TextStyle(
                                      fontSize: 17.0
                                  ),
                                ),
                                Text(
                                  "$status",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17.0,
                                      color: status == "Paid" ? Colors.green : Colors.red
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 15.0, right: 5.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            SizedBox(
                              width: 80.0,
                              height: 30.0,
                              child: RaisedButton(
                                color: status == "Paid" ? Colors.green[200]  : Colors.green,
                                onPressed: (){
                                  if(status == "UnPaid"){
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => ConformPay(
                                      month: payDate,
                                      companyName: widget.companyName,
                                      name: name,
                                      documentID: documentID,
                                    )));
                                  }
                                },
                                child: Text(
                                  status == "Paid" ? "Paid" : "Pay ?",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 5.0,
                            ),
                            SizedBox(
                              width: 80.0,
                              height: 30.0,
                              child: RaisedButton(
                                color: Colors.red ,
                                onPressed: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => DisplayAllDetailsOfSalary(
                                    name: name,
                                    companyName: widget.companyName,
                                    salary: salary,
                                    month: payDate,
                                    paymentDate: paymentDate,
                                    paidAmount: paidAmount,
                                    gst: gst,
                                  )));
                                },
                                child: Text(
                                  "Details",
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
                    )
                  ],
                ),
                SizedBox(
                  height: 10.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Amount to be Paid :- ",
                      style: TextStyle(
                          fontSize: 15.0
                      ),
                    ),
                    Text(
                      "$paidAmount",
                      style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10.0,
                )
              ],
            ),
          ),
      );
    });
  }

  _showBottomSheetForMonth(context){
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context){
          return Container(
            height: 700,
            decoration: BoxDecoration(
              color: Colors.black54,
            ),
            child: Container(
              height: 550.0,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0))
              ),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Text(
                      "Select the Month \nyou wanna View the Salary for...!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15.0,
                      ),
                    ),
                  ),
                  Divider(
                    thickness: 1.0,
                    indent: 20.0,
                    endIndent: 20.0,
                    color: Colors.black,
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      GestureDetector(
                        onTap: (){
                          setState(() {
                            selectedMonth = "January";
                            _getEmployeeList();
                            Navigator.pop(context);
                          });
                        },
                        child: Icon_plus_text(
                          text: "January",
                          selected: selectedMonth,
                        ),
                      ),
                      GestureDetector(
                        onTap: (){
                          setState(() {
                            selectedMonth = "February";
                            _getEmployeeList();
                            Navigator.pop(context);
                          });
                        },
                        child: Icon_plus_text(
                          text: "February",
                          selected: selectedMonth,
                        ),
                      ),
                      GestureDetector(
                        onTap: (){
                          setState(() {
                            selectedMonth = "March";
                            _getEmployeeList();
                            Navigator.pop(context);
                          });
                        },
                        child: Icon_plus_text(
                          text: "March",
                          selected: selectedMonth,
                        ),
                      ),
                      GestureDetector(
                        onTap: (){
                          setState(() {
                            selectedMonth = "April";
                            _getEmployeeList();
                            Navigator.pop(context);
                          });
                        },
                        child: Icon_plus_text(
                          text: "April",
                          selected: selectedMonth,
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      GestureDetector(
                        onTap: (){
                          setState(() {
                            selectedMonth = "May";
                            _getEmployeeList();
                            Navigator.pop(context);
                          });
                        },
                        child: Icon_plus_text(
                          text: "May",
                          selected: selectedMonth,
                        ),
                      ),
                      GestureDetector(
                        onTap: (){
                          setState(() {
                            selectedMonth = "June";
                            _getEmployeeList();
                            Navigator.pop(context);
                          });
                        },
                        child: Icon_plus_text(
                          text: "June",
                          selected: selectedMonth,
                        ),
                      ),
                      GestureDetector(
                        onTap: (){
                          setState(() {
                            selectedMonth = "July";
                            _getEmployeeList();
                            Navigator.pop(context);
                          });
                        },
                        child: Icon_plus_text(
                          text: "July",
                          selected: selectedMonth,
                        ),
                      ),
                      GestureDetector(
                        onTap: (){
                          setState(() {
                            selectedMonth = "August";
                            _getEmployeeList();
                            Navigator.pop(context);
                          });
                        },
                        child: Icon_plus_text(
                          text: "August",
                          selected: selectedMonth,
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      GestureDetector(
                        onTap: (){
                          setState(() {
                            selectedMonth = "September";
                            _getEmployeeList();
                            Navigator.pop(context);
                          });
                        },
                        child: Icon_plus_text(
                          text: "September",
                          selected: selectedMonth,
                        ),
                      ),
                      GestureDetector(
                        onTap: (){
                          setState(() {
                            selectedMonth = "October";
                            _getEmployeeList();
                            Navigator.pop(context);
                          });
                        },
                        child: Icon_plus_text(
                          text: "October",
                          selected: selectedMonth,
                        ),
                      ),
                      GestureDetector(
                        onTap: (){
                          setState(() {
                            selectedMonth = "November";
                            _getEmployeeList();
                            Navigator.pop(context);
                          });
                        },
                        child: Icon_plus_text(
                          text: "November",
                          selected: selectedMonth,
                        ),
                      ),
                      GestureDetector(
                        onTap: (){
                          setState(() {
                            selectedMonth = "December";
                            _getEmployeeList();
                            Navigator.pop(context);
                          });
                        },
                        child: Icon_plus_text(
                          text: "December",
                          selected: selectedMonth,
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          );
        }
    );
  }

  @override
  void initState() {
    super.initState();

    setState(() {
      selectedMonth = months[DateTime.now().month - 1];
    });

    _getEmployeeList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                decoration: BoxDecoration(
                    color: Colors.indigo[400],
                    borderRadius: BorderRadius.circular(10.0)
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    IconButton(
                      onPressed: (){
                        Navigator.pop(context);
                      },
                      icon: FaIcon(FontAwesomeIcons.backward),
                      color: Colors.white,
                    ),
                    GestureDetector(
                      onTap: (){
                        _showBottomSheetForMonth(context);
                      },
                      child: Text(
                        selectedMonth,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                            letterSpacing: 1.5
                        ),
                      ),
                    ),
                    Text(
                      DateTime.now().year.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                          letterSpacing: 1.5
                      ),
                    ),
                    IconButton(
                      onPressed: (){},
                      icon: FaIcon(FontAwesomeIcons.swatchbook),
                      color: Colors.white,
                    ),
                  ],
                ),
              ),

              Column(
                children: _sortedSalaryDetails,
              )
            ],
          ),
        ),
      ),
    );
  }
}

// ignore: camel_case_types
class Icon_plus_text extends StatelessWidget {

  Icon_plus_text({this.text, this.selected});
  final String text;
  final String selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80.0,
      height:65.0,
      decoration: BoxDecoration(
        color: selected == text ? Colors.indigo[400] : Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
        child: Column (
          children: <Widget>[
            Icon(
              Icons.calendar_today,
              color: selected == text ? Colors.white : Colors.grey[800],
              size: 30.0,
            ),
            SizedBox(
              height: 5.0,
            ),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected == text ? Colors.white : Colors.grey[800],
                fontWeight: FontWeight.bold
              ),
            ),
          ],
        ),
      ),
    );
  }
}

