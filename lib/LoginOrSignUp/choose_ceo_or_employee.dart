import 'file:///D:/FlutterRealWorldProjects/employee/lib/CommonWidgets/iconPlusText.dart';
import 'package:employee/LoginOrSignUp/scan_qr_code.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import 'VerifyPhoneNumber.dart';

class ChooseCEOorEmployee extends StatefulWidget {
  @override
  _ChooseCEOorEmployeeState createState() => _ChooseCEOorEmployeeState();
}

class _ChooseCEOorEmployeeState extends State<ChooseCEOorEmployee> {

  String selected = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "NOTE: ",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0
              ),
            ),
            Text(
              "Once you Click on proceed \nyou will not be able to change it later!",
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.0
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(
              height: 10.0,
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: GestureDetector(
                        onTap: (){
                          setState(() {
                            selected = "CEO";
                          });
                        },
                        child: IconPlusText(
                          selected: selected,
                          text: "CEO",
                          icon: Icons.stars,
                        )
                    ),
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  Expanded(
                    child: GestureDetector(
                        onTap: (){
                          setState(() {
                            selected = "EMPLOYEE";
                          });
                        },
                        child: IconPlusText(
                          selected: selected,
                          text: "EMPLOYEE",
                          icon: Icons.perm_contact_calendar,
                        )
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            RaisedButton(
              onPressed: () async {
                SharedPreferences _prefs = await SharedPreferences.getInstance();

                FirebaseAuth _auth = FirebaseAuth.instance;
                FirebaseUser _user = await _auth.currentUser();

                if(selected == "CEO"){
                  _prefs.setString('where', 'VerifyPhoneNumber');
                  _prefs.setString('emailUID', _user.uid);
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => VerifyPhoneNumber(
                    editPhoneNumber: false,
                  )));
                }else if(selected == "EMPLOYEE"){
                  _prefs.setString('where', 'SCANQRCode');
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ScanQRCode()));
                }
              },
              color: kBlueColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  "GO ;)",
                  style: TextStyle(
                      color: Colors.white
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
