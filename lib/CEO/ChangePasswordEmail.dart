import 'package:employee/CommonWidgets/CircularLoadingIndicator.dart';
import 'package:employee/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:employee/Globals.dart' as globals;
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class ChangePassword extends StatefulWidget {
  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {

  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser _user;

  bool isLoading = false;
  bool isThereNewPassword = true;
  bool isThereCurrentPassword = true;
  bool isThereConfirmPassword = true;

  String _currentPassword = "";
  String _newPassword = "";
  String _confirmPassword = "";

  _forgottenPassword() async {
    _user = await _auth.currentUser();
    await _auth.sendPasswordResetEmail(email: globals.email).then((value){
      setState(() {
        print("EMAIL LINK SENT");

        Alert(
          context: context,
          title: "Hey ${globals.userName}",
          desc: "We have sent a Password Reset link on ${globals.email}",
          buttons: [
            DialogButton(
              height: 30.0,
              child: Text(
                "OKAY",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              onPressed: () => Navigator.pop(context),
              width: 120,
            )
          ],
        ).show();
      });
    }).catchError((onError){
      print("ERROR UPDATING PASSWORD");
      print(onError);
      setState(() {
        isLoading = false;
      });
    });
  }

   _updatePassword() async {

    setState(() {
      isLoading = true;
    });
    _user = await _auth.currentUser();

    var credential = EmailAuthProvider.getCredential(
      email: _user.email,
      password: _currentPassword,
    );

    _user.reauthenticateWithCredential(credential).then((value){
      print("GOT PERMISSION");
      setState(() {
        isLoading = false;
      });
      _user.updatePassword(_confirmPassword).then((value){
        Toast.show("Password Updated", context, gravity: Toast.BOTTOM, duration: Toast.LENGTH_LONG);
        Navigator.pop(context);
      }).catchError((onError){
        Toast.show("Error Updating the Password", context, gravity: Toast.BOTTOM, duration: Toast.LENGTH_LONG);
      });
    }).catchError((onError){
      setState(() {
        isLoading = false;
      });
      if(onError.code == "ERROR_WRONG_PASSWORD"){
        Toast.show("Incorrect Current Password", context, gravity: Toast.BOTTOM, duration: Toast.LENGTH_LONG);
      }
    });
  }

  _checkFields() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();

    if(_currentPassword != "" && _newPassword != "" && _confirmPassword != ""){
      if(_currentPassword == _prefs.getString('password')){
        if(_newPassword == _confirmPassword){
          _updatePassword();
        }else{
          Toast.show("Password Miss-match", context, gravity: Toast.BOTTOM, duration: Toast.LENGTH_LONG);
        }
      }else{
        Toast.show("Incorrect Current Password", context, gravity: Toast.BOTTOM, duration: Toast.LENGTH_LONG);
      }
    }else{
      setState(() {
        _currentPassword == "" ? isThereCurrentPassword = false : isThereCurrentPassword = true;
        _newPassword == "" ? isThereNewPassword = false : isThereNewPassword = true;
        _confirmPassword == "" ? isThereConfirmPassword = false : isThereConfirmPassword = true;
      });
    }
  }

  Widget _mainBody(){
    return SafeArea(
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
                    "Change Password",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0
                    ),
                  ),
                  GestureDetector(
                    onTap: (){
                      _checkFields();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Icon(
                        Icons.assignment_turned_in
                      ),
                    ),
                  )
                ],
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
                    _currentPassword = value;
                  });
                },
                style: TextStyle(
                    color: Colors.black
                ),
                decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.star,
                      color: kLightBlue,
                      size: 25.0,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide.none
                    ),
                    hintText: isThereCurrentPassword ? "Current Password" : "Current Password Required*",
                    hintStyle: TextStyle(
                      color: isThereCurrentPassword ? Colors.grey[700] : Colors.red,
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
                    _newPassword= value;
                  });
                },
                style: TextStyle(
                    color: Colors.black
                ),
                decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.stars,
                      color: kLightBlue,
                      size: 25.0,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide.none
                    ),
                    hintText: isThereNewPassword ? "New Password" : "New Password Required*",
                    hintStyle: TextStyle(
                      color: isThereNewPassword ? Colors.grey[700] : Colors.red,
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
                    _confirmPassword = value;
                  });
                },
                style: TextStyle(
                    color: Colors.black
                ),
                decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.stars,
                      color: kLightBlue,
                      size: 25.0,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide.none
                    ),
                    hintText: isThereConfirmPassword ? "Confirm Password" : "Confirm Password Required*",
                    hintStyle: TextStyle(
                      color: isThereConfirmPassword ? Colors.grey[700] : Colors.red,
                    )
                ),
              ),
            ),
          ),

          SizedBox(
            height: 5.0,
          ),

          Align(
            alignment: Alignment.topLeft,
            child: GestureDetector(
              onTap: (){
                _forgottenPassword();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  "Forgotten Password?",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 13.0,
                    letterSpacing: 1.0
                  ),
                ),
              ),
            ),
          )

        ],
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
