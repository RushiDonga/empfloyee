import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'DisplayEmployeeSalaryDetails.dart';
import '../../constants.dart';
import 'sort_employee_salary_details.dart';
import '../../Globals.dart' as globals;

final Firestore fireStore = Firestore.instance;

class EmployeeSalaryList extends StatefulWidget {
  @override
  _EmployeeSalaryListState createState() => _EmployeeSalaryListState();
}

class _EmployeeSalaryListState extends State<EmployeeSalaryList> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[

            Hero(
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
                          "View Salary Of",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                              letterSpacing: 1.0
                          ),
                        ),
                        GestureDetector(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => SortEmployeeSalaryDetails(
                              companyName: globals.companyName,
                            )));
                          },
                          child: Icon(
                            Icons.sort,
                            color: Colors.black,
                            size: 25.0,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),

            EmployeeListStream(
              companyName: globals.companyName,
            )
          ],
        ),
      ),
    );
  }
}

class EmployeeListStream extends StatelessWidget {

  EmployeeListStream({this.companyName});

  final String companyName;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: fireStore.collection(companyName).document("Employee").collection("employee").snapshots(),
      builder: (context, snapshots){
        if(snapshots.hasData){
          final employees = snapshots.data.documents;
          List<EmployeeDisplayList> displaySearchResult = [];
          for(var employee in employees){
            String name = employee.data["Name"];

            final employeeName = EmployeeDisplayList(
              display: name,
              companyName: companyName,
            );

            displaySearchResult.add(employeeName);
          }
          return Expanded(
            child: ListView(
              children: displaySearchResult,
            ),
          );
        }else{
          return Center(
            child: Text(""),
          );
        }
      },
    );
  }
}

class EmployeeDisplayList extends StatelessWidget {

  EmployeeDisplayList({this.display, this.companyName});

  final String display;
  final String companyName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7.0),
      child: GestureDetector(
        onTap: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) => DisplayEmployeeSalaryDetails(
            employeeName: display,
          )));
        },
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0), bottomLeft: Radius.circular(10.0))
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Container(
                    decoration: BoxDecoration(
                      color: kLightBlue,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0), bottomLeft: Radius.circular(10.0)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: IconButton(
                        onPressed: (){},
                        icon: FaIcon(FontAwesomeIcons.dollarSign),
                        iconSize: 20.0,
                        color: Colors.white,
                      )
                    )
                ),
              ),
              Expanded(
                  flex: 5,
                  child: Container(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0, top: 20.0, bottom: 20.0),
                      child: Text(
                        display,
                        style:
                        TextStyle(
                            color: Colors.grey[800],
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  )
              )
            ],
          ),
        ),
      ),
    );
  }
}


