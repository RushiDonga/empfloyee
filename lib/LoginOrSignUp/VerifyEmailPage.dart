import 'package:employee/CommonWidgets/CircularLoadingIndicator.dart';
import 'package:employee/LoginOrSignUp/choose_ceo_or_employee.dart';
import 'package:employee/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class VerifyEmailPage extends StatefulWidget {
  @override
  _VerifyEmailPageState createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {

  FirebaseAuth _auth = FirebaseAuth.instance;
  AuthResult _result;

  bool isLoading = false;

  String _email = "";
  String _password = "";

  _checkIfVerified() async {
    setState(() {
      isLoading = true;
    });

    try{
      _result = await _auth.signInWithEmailAndPassword(email: _email, password: _password);
    }catch(e){
      print("EXCEPTION OCCURED");
      print(e);
    }finally{
      if(_result.user.isEmailVerified){

        SharedPreferences _prefs = await SharedPreferences.getInstance();
        _prefs.setString('where', 'ChooseCEOorEmployee');
        _prefs.setBool('LoggedIn', false);

        print("===================");
        print(_result.user.uid);

        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ChooseCEOorEmployee()));
      }else{
        Toast.show("E-mail is not yet Verified", context, gravity: Toast.BOTTOM, duration: Toast.LENGTH_LONG);
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _mainBody(){
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Hey There!",
                style: TextStyle(
                    color: Colors.black,
                    fontFamily: "Dark",
                    fontSize: 24.0,
                    letterSpacing: 1.0
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 5.0,
              ),
              Text(
                "We need to verify the E-mail \nbefore you proceed",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 17.0,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 10.0,
              ),
              Text(
                "We have sent you an E-mail \nverification link on",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.0
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 15.0,
              ),
              Text(
                _email,
                style: TextStyle(
                    color: Colors.grey[900],
                    fontWeight: FontWeight.w600
                ),
              ),
              SizedBox(
                height: 5.0,
              ),
              RaisedButton(
                color: kLightBlue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    side: BorderSide(width: 1.0, color: Colors.white, style: BorderStyle.solid)
                ),
                onPressed: (){
                  _checkIfVerified();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text(
                    "PROCEED",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.0,
                        letterSpacing: 0.6
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 5.0,
              ),
              Image(
                image: AssetImage("assets/up-arrow.png"),
                width: 50.0,
              ),
              SizedBox(
                height: 10.0,
              ),
              Text(
                "Press Once \nthe E-mail is Verified",
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600
                ),
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),
      ),
    );
  }

  _verifyEmail() async {

    SharedPreferences _prefs = await SharedPreferences.getInstance();
    setState(() {
      _email = _prefs.getString('email');
      _password = _prefs.getString('password');
    });

    FirebaseUser _user = await _auth.currentUser();
    _user.sendEmailVerification().then((value){
      setState(() {
        isLoading = false;
      });

      print("EMAIL SENT");
    }).catchError((onError){
      setState(() {
        isLoading = false;
      });
      Toast.show("Unable to Send E-mail", context, gravity: Toast.BOTTOM, duration: Toast.LENGTH_LONG);
      print("UNABLE TO SEND EMAIL");
      print(onError);
    });
  }

  @override
  void initState() {
    super.initState();
    _verifyEmail();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? circularProgress()
        : _mainBody();
  }
}
