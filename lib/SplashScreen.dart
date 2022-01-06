import 'package:employee/CEO/NavigationPages/navigation_bar_ceo.dart';
import 'package:employee/Employee/NavigationBar/navigationbar_employee.dart';
import 'package:employee/LoginOrSignUp/choose_ceo_or_employee.dart';
import 'package:employee/LoginOrSignUp/login_or_signup_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'LoginOrSignUp/GetCEODetails.dart';
import 'LoginOrSignUp/VerifyEmailPage.dart';
import 'LoginOrSignUp/VerifyPhoneNumber.dart';
import 'LoginOrSignUp/scan_qr_code.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {

  AnimationController _logoController;
  AnimationController _textController;

  String identity;
  bool isLoading = true;
  bool isLoggedIn =  false;
  bool isCEO = false;
  bool isEmployee = false;

  _identifyUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn = prefs.getBool('LoggedIn');
      print(prefs.getBool('LoggedIn'));
      print("-------------");


      switch (isLoggedIn){
        case true:{
          identity = prefs.getString('Identity');
          print(identity);
          if(identity == "CEO"){
            isCEO = true;
            isEmployee = false;
          }else if(identity == "Employee"){
            isEmployee = true;
            isCEO = false;
          }else{
            isEmployee = false;
            isCEO = false;
          }
          isLoading = false;
          break;
        }

        case false:{
          isLoading = false;
          break;
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();

    _identifyUser();

    _logoController = AnimationController(
      duration:Duration(seconds: 1),
      vsync:  this,
      upperBound: 110.0,
    );
    _logoController.forward();
    _logoController.addListener(() {
      setState(() {});
    });

    _textController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
      lowerBound: 23.0,
      upperBound: 70.0
    );
    _textController.reverse();
    _textController.addListener(() {
      setState(() {});
    });

    Future.delayed(
      Duration(seconds: 3),
        (){
          if(isLoggedIn == true){
            if(isCEO){
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CEONavigationBar()));
            }else if(isEmployee){
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => EmployeeNavigationBar()));
            }else{
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginOrSignUpPage()));
            }
          }else if(isLoggedIn == false){
            _goWhereLeft();
          }else{
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginOrSignUpPage()));
          }
        }
    );
  }

  _goWhereLeft() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String left = _prefs.getString('where');
    print(left);
    print("************");

    switch (left.toString()){
      case "VerifyPhoneNumber":{
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => VerifyPhoneNumber(
          editPhoneNumber: false,
        )));
        break;
      }

      case "SCANQRCode":{
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ScanQRCode()));
        break;
      }

      case "GetCEODetails":{
        _getPhoneNumber();
        break;
      }

      case "COMPLETED":{
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginOrSignUpPage()));
        break;
      }

      case "ChooseCEOorEmployee":{
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ChooseCEOorEmployee()));
        break;
      }

      case "SCANQRCode":{
        Navigator.push(context, MaterialPageRoute(builder: (context) => ScanQRCode()));
        break;
      }

      case "VerifyEmailPage":{
        Navigator.push(context, MaterialPageRoute(builder: (context) => VerifyEmailPage()));
        break;
      }

      case "null":{
        Navigator.push(context, MaterialPageRoute(builder: (context) => LoginOrSignUpPage()));
      }
    }
  }

  _getPhoneNumber() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => GetCEODetails(
      phoneNumber: _prefs.getString('phoneNumber'),
    )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            flex: 7,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  height: _logoController.value,
                  child: Image(
                    image: AssetImage("assets/logo.png"),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 80.0, vertical: 10.0),
                  child: Divider(
                    height: 2.0,
                    color: Colors.grey[800],
                  ),
                ),
                Text(
                  "Emp-Floyee",
                  style: TextStyle(
                      color: Colors.grey[800],
                      fontFamily: "Dark",
                      fontSize: _textController.value,
                      letterSpacing: 1.0,
                  ),
                )
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  // "With ❤ by",
                  "",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontWeight: FontWeight.bold,
                    fontSize: 15.0,
                    letterSpacing: 1.0
                  ),
                ),
                Text(
                  // "RUSHI DONGA",
                  "",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontWeight: FontWeight.bold,
                    fontSize: 15.0,
                    letterSpacing: 2.5,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
