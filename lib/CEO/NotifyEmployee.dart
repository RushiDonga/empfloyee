import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:employee/CommonWidgets/CircularLoadingIndicator.dart';
import 'package:employee/CommonWidgets/text_heading.dart';
import 'package:employee/constants.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:employee/Globals.dart' as globals;
import 'package:toast/toast.dart';

Firestore _fireStore = Firestore.instance;

class NotifyEmployee extends StatefulWidget {
  @override
  _NotifyEmployeeState createState() => _NotifyEmployeeState();
}

class _NotifyEmployeeState extends State<NotifyEmployee> {

  List<dynamic> _employeeList = [];
  List<String> _selectedEmployee = [];

  String _title = "";
  String _description = "";

  bool isThereTitle = true;
  bool isThereDescription = true;
  bool isLoading = true;

  _getEmployeeList(){
    _fireStore.collection(globals.companyName).document("Employee").get().then((value){
      setState(() {
        _employeeList = value.data["EmployeeList"];
      });
    }).then((value){
      setState(() {
        isLoading = false;
      });
    }).catchError((onError){
      setState(() {
        isLoading = false;
        Toast.show("Error Getting the Employee List...:(", context, gravity: Toast.BOTTOM, duration: Toast.LENGTH_LONG);
      });
    });
  }

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
              "Notify Employee",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0
              ),
            ),
            SizedBox(
              width: 20.0,
            )
          ],
        ),
      ),
    );
  }

  Widget _body(){
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: Card(
            child: TextField(
              onChanged: (value){
                setState(() {
                  _title = value;
                });
              },
              style: TextStyle(
                  color: Colors.black
              ),
              decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.mode_edit,
                    color: Colors.black,
                    size: 25.0,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide.none
                  ),
                  hintText: isThereTitle ? "Title" : "Title Required*",
                  hintStyle: TextStyle(
                    color: isThereTitle ? Colors.grey[700] : Colors.red,
                  )
              ),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: Card(
            child: TextField(
              onChanged: (value){
                setState(() {
                  _description = value;
                });
              },
              style: TextStyle(
                  color: Colors.black
              ),
              decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.description,
                    color: Colors.black,
                    size: 25.0,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide.none
                  ),
                  hintText: isThereDescription ? "Description" : "Description Required*",
                  hintStyle: TextStyle(
                    color: isThereDescription ? Colors.grey[700] : Colors.red,
                  )
              ),
            ),
          ),
        ),

        TextHeading(text: "Select Employee",),

        SizedBox(
          height: MediaQuery.of(context).size.width,
          child: ListView.builder(
              physics: ClampingScrollPhysics(),
              shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemCount: _employeeList.length,
              itemBuilder: (context, index){
                return Card(
                  elevation: 0.5,
                  margin: EdgeInsets.symmetric(vertical: 1.0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 10.0,
                            ),
                            Container(
                                height: 38.0,
                                width: 38.0,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    borderRadius:
                                    BorderRadius.all(const Radius.circular(100.0)),
                                    color: kLightBlue
                                ),
                                child: Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 20,
                                )
                            ),
                            SizedBox(
                              width: 15.0,
                            ),
                            Text(
                              _employeeList[index],
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16.0,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),

                        Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: Container(
                            height: 30.0,
                            child: RaisedButton(
                              onPressed: (){
                                setState(() {
                                  if(_selectedEmployee.contains(_employeeList[index])){
                                    _selectedEmployee.removeAt(_selectedEmployee.indexOf(_employeeList[index]));
                                  }else{
                                    _selectedEmployee.add(_employeeList[index]);
                                  }
                                });
                              },
                              color: kLightBlue,
                              child: Text(
                                _selectedEmployee.contains(_employeeList[index]) ? "REMOVE" : "ADD",
                                style: TextStyle(
                                  color: Colors.white,
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
    );
  }

  Widget _bottomBar(){
    return Align(
      alignment: Alignment.bottomCenter,
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: 25.0,
                color: Colors.transparent,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 60.0,
                color: kLightBlue,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width - 200,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20.0, right: 90.0, left: 10.0),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _selectedEmployee.length,
                        itemBuilder: (context, index){
                      return Text(
                        _selectedEmployee[index] + ", ",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0
                        ),
                      );
                    }),
                  ),
                )
              ),
            ],
          ),
          Positioned(
            right: 20.0,
            bottom: 20.0,
            child: GestureDetector(
              onTap: (){
                _checkFields();
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(100.0)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Icon(
                    Icons.send,
                    color: Colors.black,
                  )
                )
              ),
            ),
          )
        ],
      ),
    );
  }

  _checkFields(){
    if(_title != "" && _description != "" && _selectedEmployee.isEmpty != true){
      _uploadData();
    }else{
      setState(() {
        _title == "" ? isThereTitle = false : isThereTitle = true;
        _description == "" ? isThereDescription = false : isThereDescription = true;
      });
      if(_selectedEmployee.isEmpty){
        Toast.show("Employee...?", context, gravity: Toast.BOTTOM, duration: Toast.LENGTH_LONG);
      }
    }
  }

  _uploadData(){
    setState(() {
      isLoading = true;
    });
    for(int i=0; i< _selectedEmployee.length; i++){
      String document = DateTime.now().toString();
      _fireStore.collection(globals.companyName).document("Employee").collection("employee").document(_selectedEmployee[i])
          .collection("Notifications").document(document).setData({
        "Date": DateTime.now().day.toString() + "-" + DateTime.now().month.toString() + "-" + DateTime.now().year.toString(),
        "DocumentName": document,
        "Search": DateTime.now().month.toString() + "-" + DateTime.now().year.toString(),
        "Seen": false,
        "Time": DateTime.now().hour.toString() + ":" + DateTime.now().minute.toString(),
        "Type": "ManagerNotification",
        "Title": _title.trim(),
        "Description": _description.trim(),
      }).then((value){
        setState(() {
          isLoading = false;
        });
        Toast.show("Notifications Sent", context, gravity: Toast.BOTTOM, duration: Toast.LENGTH_LONG);
      }).catchError((onError){
        setState(() {
          isLoading = false;
        });
        Toast.show("Error Sending Notifications", context, gravity: Toast.BOTTOM, duration: Toast.LENGTH_LONG);
        Navigator.pop(context);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getEmployeeList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? circularProgress()
          : SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  _appBar(),
                  _body(),
                ],
              ),
            ),
            _bottomBar(),
          ],
        ),
      ),
    );
  }
}
