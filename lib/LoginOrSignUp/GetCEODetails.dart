import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:employee/CEO/NavigationPages/navigation_bar_ceo.dart';
import 'package:employee/CommonWidgets/CircularLoadingIndicator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import '../constants.dart';

Firestore _fireStore = Firestore.instance;

class GetCEODetails extends StatefulWidget {
  @override
  _GetCEODetailsState createState() => _GetCEODetailsState();

  GetCEODetails({this.phoneNumber});
  final String phoneNumber;
}

class _GetCEODetailsState extends State<GetCEODetails> {

  bool isLoading = false;

  bool isThereUserName = true;
  bool isThereCompanyName = true;

  String _userName = "";
  String _companyName = "";

  _checkFields(){
    if(_userName.trim() != "" && _companyName.trim() != ""){
      _registerData();
      print(_userName);
      print(_companyName);
    }else{
      setState(() {
        _userName == "" ? isThereUserName = false : isThereUserName = true;
        _companyName == "" ? isThereCompanyName = false : isThereCompanyName = true;
      });
    }
  }

  _registerData() async {
    setState(() {
      isLoading = true;
    });

    SharedPreferences _prefs = await SharedPreferences.getInstance();

    DatabaseReference storeID = FirebaseDatabase.instance.reference().child("AllUsers").child(_prefs.getString('emailUID'));
    storeID.child("CompanyName").set(_companyName);
    storeID.child("IamA").set("CEO");
    storeID.child("ceoName").set(_userName);

    await _fireStore.collection(_companyName).document("CompanyDetails").setData({
      "CEOName  ":_userName,
      "PhoneNumber": widget.phoneNumber,
      "CompanyName": _companyName,
      "Email": _prefs.getString('email'),
      "Description": "",
      "CompanyWebsite": "",
      "facebook": "",
      "Instagram": "",
      "Twitter": "",
      "Join Month": DateTime.now().month.toString(),
      "Join Year": DateTime.now().year.toString(),
    }).then((value) async {

      print("COMPANY DETAILS ADDED");
      await _fireStore.collection(_companyName).document("Employee").setData({
        "TotalEmployee": 0,
        "EmployeeList": [],
        "LeaveList": [],
      });

      print("SUCCESS IN EMPLOYEE");

      await _fireStore.collection(_companyName).document("Attendance").setData({
        "TodayAttendance": false,
        "Date": DateTime.now().day.toString() + "-" + DateTime.now().month.toString() + "-" + DateTime.now().year.toString(),
        "DocumentName": "",
        "filled": false,
        "Type": "AllowEmployee",
      }).then((value) async {
        print("SUCCESS IN ATTENDANCE");
        SharedPreferences _prefs = await SharedPreferences.getInstance();
        _prefs.setString('where', 'COMPLETED');
        _prefs.setBool('LoggedIn', true);
        _prefs.setString('Identity', 'CEO');


        FirebaseAuth _auth = FirebaseAuth.instance;
        _auth.signInWithEmailAndPassword(
          email: _prefs.getString('email'),
          password: _prefs.getString('password'),
        ).then((value){
          _prefs.setString('password', '');
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CEONavigationBar()));
        }).catchError((onError){
          _prefs.setBool('LoggedIn', true);
          _prefs.setString('Identity', '');
          Toast.show("Error Signing In", context, gravity: Toast.BOTTOM, duration: Toast.LENGTH_LONG);
        });
        isLoading = false;
      }).catchError((onError){
        print("ERROR IN ATTENDANCE");
        print(onError);
      });
    }).catchError((onError){
      print("ERROR IN COMPANY DETAILS");
      print(onError);
    });
  }

  Widget _mainBody(){
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width-20,
        height: 300.0,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(0.0)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey[300],
                blurRadius: 25.0,
                spreadRadius: 5.0,
              )
            ]
        ),
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width-20,
              height: 60.0,
              child: Card(
                color: kLightBlue,
                margin: EdgeInsets.symmetric(vertical: 0.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(0.0)),
                ),
                child: Center(
                  child: Text(
                    "Emp-Floyee",
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: "Dark",
                        fontSize: 25.0,
                        letterSpacing: 1.0
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 15.0,
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: Card(
                child: TextField(
                  keyboardType: TextInputType.text,
                  onChanged: (value){
                    setState(() {
                      _userName = value;
                    });
                  },
                  style: TextStyle(
                      color: Colors.black
                  ),
                  decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.phone_android,
                        color: kLightBlue,
                        size: 25.0,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide.none
                      ),
                      hintText: isThereUserName ? "User Name" : "User Name Required*",
                    hintStyle: TextStyle(
                      color: isThereUserName ? Colors.grey[700] : Colors.red,
                    )
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: Card(
                child: TextField(
                  keyboardType: TextInputType.text,
                  onChanged: (value){
                    setState(() {
                      _companyName = value;
                    });
                  },
                  style: TextStyle(
                      color: Colors.black
                  ),
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.confirmation_number_sharp,
                      color: kLightBlue,
                      size: 25.0,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide.none
                    ),
                    hintText: isThereCompanyName ? "Company Name" : "Company Name Required*",
                    hintStyle: TextStyle(
                      color: isThereCompanyName ? Colors.grey[700] : Colors.red,
                    )
                  ),
                ),
              ),
            ),

            SizedBox(
              height: 10.0,
            ),

            RaisedButton(
              onPressed: (){
                _checkFields();
              },
              color: kLightBlue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  side: BorderSide(width: 1.0, color: Colors.white, style: BorderStyle.solid)
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  "REGISTER",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),

            SizedBox(
              height: 10.0,
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? circularProgress()
          : _mainBody()
    );
  }
}
