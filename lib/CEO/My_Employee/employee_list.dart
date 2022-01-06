import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:employee/CEO/Add_Employee/add_employee.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../../constants.dart';
import 'employee_profile.dart';
import '../../Globals.dart' as globals;
import 'package:toast/toast.dart';

Firestore _fireStore = Firestore.instance;

class EmployeeList extends StatefulWidget {
  @override
  _EmployeeListState createState() => _EmployeeListState();
}

class _EmployeeListState extends State<EmployeeList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[

            Padding(
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
                        "Employee List",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                            letterSpacing: 1.0
                        ),
                      ),
                      GestureDetector(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => AddEmployee()));
                        },
                        child: Icon(
                          Icons.add_box,
                          color: Colors.black,
                          size: 25.0,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),

            EmployeeStream()
          ],
        ),
      ),
    );
  }
}

class EmployeeStream extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _fireStore.collection(globals.companyName).document("Employee").collection("employee").snapshots(),
      builder: (context, snapshots){
        if(snapshots.hasData){
          final employees = snapshots.data.documents;
          List<DisplayEmployee> displayEmployee = [];
          for(var employee in employees){
            final name = employee.data["Name"];
            final email = employee.data["Email"];

            final displayEmployeeWidget = DisplayEmployee(
              name: name,
              email: email,
            );
            displayEmployee.add(displayEmployeeWidget);
          }
          return Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(vertical: 5.0),
              children: displayEmployee,
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

class DisplayEmployee extends StatelessWidget {

  DisplayEmployee({this.name, this.email});

  final String name;
  final String email;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 20.0, top: 5.0, bottom: 5.0),
      child: Card(
        margin: EdgeInsets.all(0.0),
        color: kLightBlue,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(topRight: Radius.circular(15.0), bottomRight: Radius.circular(15.0))
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 6,
              child: GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => EmployeeProfileCEO(
                    name: name,
                  )));
                },
                child: Card(
                  elevation: 0.2,
                  margin: EdgeInsets.all(0.0),
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(topRight: Radius.circular(15.0), bottomRight: Radius.circular(15.0)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                    child: Row(
                      children: <Widget>[
                        SizedBox(
                          width: 10.0,
                        ),
                        ClipOval(
                          child: Material(
                            color: kLightBlue,
                            child: InkWell(
                              child: SizedBox(
                                width: 45,
                                height: 45,
                                child: Center(
                                  child: Text(
                                    name[0],
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20.0
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 15.0,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              name,
                              style: TextStyle(
                                  color: kLightBlue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17.0
                              ),
                            ),
                            SizedBox(
                              height: 3.0,
                            ),
                            Text(
                              email.length > 30 ? email.substring(0, 30) : email,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.grey[900],
                                fontSize: 15.0,
                                letterSpacing: 0.5
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                  child:GestureDetector(
                    onTap: (){
                      Alert(
                        context: context,
                        title: "Are you Sure?",
                        desc: "Want to remove $name",
                        buttons: [
                          DialogButton(
                            child: Text(
                              "YES",
                              style: TextStyle(color: Colors.white, fontSize: 15),
                            ),
                            onPressed: (){

                              List<dynamic> _employeeList = [];
                              Navigator.pop(context);

                              _fireStore.collection(globals.companyName).document("Employee").collection("employee").document(name).delete()
                              .then((value){
                                _fireStore.collection(globals.companyName).document("Employee").get().then((value){
                                  _employeeList.addAll(value.data["EmployeeList"]);
                                }).then((value){
                                  _employeeList.remove(name);
                                  _fireStore.collection(globals.companyName).document("Employee").updateData({
                                    "EmployeeList": _employeeList,
                                  }).then((value){})
                                      .catchError((onError){});
                                });
                              }).catchError((onError){
                                Toast.show("Error Removing the Employee", context);
                              });
                            },
                          ),
                          DialogButton(
                            child: Text(
                              "NO",
                              style: TextStyle(color: Colors.white, fontSize: 15),
                            ),
                            onPressed: (){
                              Navigator.pop(context);
                            },
                          )
                        ],
                      ).show();
                    },
                    child: Icon(
                      Icons.delete_forever,
                      color: Colors.white,
                      size: 30.0,
                    )
                  )
              ),
            )
          ],
        ),
      ),
    );
  }
}


