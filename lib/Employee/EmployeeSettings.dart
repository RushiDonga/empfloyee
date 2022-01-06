import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:employee/CEO/ChangePasswordEmail.dart';
import 'package:employee/LoginOrSignUp/login_or_signup_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:employee/Globals.dart' as globals;
import '../constants.dart';

Firestore _fireStore = Firestore.instance;

class EmployeeSettings extends StatefulWidget {
  @override
  _EmployeeSettingsState createState() => _EmployeeSettingsState();
}

class _EmployeeSettingsState extends State<EmployeeSettings> {

  bool isLoading = false;

  FirebaseAuth _auth = FirebaseAuth.instance;

  _signOut(){
    setState(() {
      isLoading = true;
    });
    _auth.signOut().then((value) async {
      var prefs = await SharedPreferences.getInstance();
      prefs.setBool('LoggedIn', false);
      prefs.setString('userId', '');
      prefs.setString('Identity', '');

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginOrSignUpPage()));
    }).catchError((onError){
      setState(() {
        isLoading = false;
      });
      Toast.show("Error Signing Out", context, gravity: Toast.BOTTOM, duration: Toast.LENGTH_LONG);
    });
  }

  _notifyCEO(){
    setState(() {
      isLoading = true;
    });
    String document = DateTime.now().toString();
    _fireStore.collection(globals.companyName).document("CEO Notifications").collection("Notifications").document(document).setData({
      "Date": DateTime.now().day.toString() + "-" + DateTime.now().month.toString() + "-" + DateTime.now().year.toString(),
      "Time": DateTime.now().hour.toString() + ":" + DateTime.now().minute.toString(),
      "Search": DateTime.now().month.toString() + "-" + DateTime.now().year.toString(),
      "EmployeeName": globals.userName,
      "Seen": false,
      "Type": "EmployeeLogOut",
      "DocumentName": document,
    }).then((value){
      _signOut();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [

              Padding(
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
                        "Settings",
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
              ),

              ListTile(
                  leading: Container(
                      height: 38.0,
                      width: 38.0,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          borderRadius:
                          BorderRadius.all(const Radius.circular(100.0)),
                          color: kLightBlue
                      ),
                      child: Icon(
                        Icons.star,
                        color: Colors.white,
                        size: 20,
                      )),
                  title: Text(
                    'Change Password',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18.0,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.0,
                    ),
                  ),
                  onTap: () async {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ChangePassword()));
                  }
              ),

              ListTile(
                  leading: Container(
                      height: 38.0,
                      width: 38.0,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          borderRadius:
                          BorderRadius.all(const Radius.circular(100.0)),
                          color: kLightBlue
                      ),
                      child: Icon(
                        Icons.phone_android,
                        color: Colors.white,
                        size: 20,
                      )),
                  title: Text(
                    'Contact Us',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18.0,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.0,
                    ),
                  ),
                  onTap: () async {
                    String url = "";
                    if(await canLaunch(url)){
                      await launch(url);
                    }
                  }
              ),

              ListTile(
                  leading: Container(
                      height: 38.0,
                      width: 38.0,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          borderRadius:
                          BorderRadius.all(const Radius.circular(100.0)),
                          color: kLightBlue
                      ),
                      child: Icon(
                        Icons.power_settings_new,
                        color: Colors.white,
                        size: 20,
                      )),
                  title: Text(
                    'Sign Out',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18.0,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.0,
                    ),
                  ),
                  onTap: (){
                    _notifyCEO();
                  }
              ),
            ],
          ),
        ),
      ),
    );
  }
}
