import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../Employee/NavigationBar/navigationbar_employee.dart';
import 'package:toast/toast.dart';

Firestore _fireStore = Firestore.instance;

class ScanQRCode extends StatefulWidget {
  @override
  _ScanQRCodeState createState() => _ScanQRCodeState();
}

class _ScanQRCodeState extends State<ScanQRCode> {

  DatabaseReference _registerEmployeeDetails = FirebaseDatabase.instance.reference();

  _scanQRCode() async {
    var scanning = await BarcodeScanner.scan();
    String _code = scanning.rawContent.toString();

    print(_code.split("^()&*"));
    print(_code.split("^()&*")[1]);
    print(_code.split("^()&*")[2]);
    print(_code.split("^()&*")[3]);

    if(_code.split("^()&*").length == 5){
      FirebaseAuth _auth = FirebaseAuth.instance;
      FirebaseUser _user = await _auth.currentUser();
      _registerEmployeeDetails.child("AllUsers").child(_user.uid).child("CompanyName").set(_code.split("^()&*")[2]);
      _registerEmployeeDetails.child("AllUsers").child(_user.uid).child("IamA").set("Employee");
      _registerEmployeeDetails.child("AllUsers").child(_user.uid).child("Name").set(_code.split("^()&*")[3]);

      SharedPreferences _prefs = await SharedPreferences.getInstance();
      _prefs.setString('where', 'COMPLETED');
      _prefs.setBool('LoggedIn', true);
      _prefs.setString('Identity', 'Employee');

      _fireStore.collection(_code.split("^()&*")[2]).document("Employee").collection("employee").document(_code.split("^()&*")[3]).updateData({
        "Email": _prefs.getString('email'),
      }).then((value){
        print(_prefs.getString('email'));
         Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => EmployeeNavigationBar()));
      });
    }else{
      Toast.show(_code, context, gravity: Toast.BOTTOM, duration: Toast.LENGTH_LONG);
    }
  }

  Widget _mainBody(){
    return Center(
      child: RaisedButton(
        onPressed: (){
          _scanQRCode();
        },
        color: kLightBlue,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            side: BorderSide(width: 1.0, color: Colors.white, style: BorderStyle.solid)
        ),
        child: Text(
          "SCAN AGAIN",
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.0
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _scanQRCode();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: kWhiteColor,
        body: _mainBody()
    );
  }
}
