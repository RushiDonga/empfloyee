import 'package:employee/CommonWidgets/CircularLoadingIndicator.dart';
import 'package:employee/LoginOrSignUp/VerifyEmailPage.dart';
import 'package:employee/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'signup_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../CEO/NavigationPages/navigation_bar_ceo.dart';
import '../Employee/NavigationBar/navigationbar_employee.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  FirebaseAuth _auth = FirebaseAuth.instance;
  DatabaseReference _getCurrentPosition = FirebaseDatabase.instance.reference();

  String _email = "";
  String _password = "";
  String _forgotPasswordEmail = "";

  bool isLoading = false;
  bool isThereEmail = true;
  bool isTherePassword = true;

  _sendPasswordResetLink(){
    FirebaseAuth _auth = FirebaseAuth.instance;
    _auth.sendPasswordResetEmail(email: _forgotPasswordEmail.trim()).then((value){
      Toast.show("E-mail Sent", context, gravity: Toast.BOTTOM, duration: Toast.LENGTH_LONG);
      print("--------------------");
    }).catchError((onError){
      print(onError.code);
      if(onError.code == "ERROR_USER_NOT_FOUND"){
        Toast.show("E-mail is not Registered", context, gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
      }
    });
  }

  _forgottenPassword(){
    Alert(
        context: context,
        title: "Forgotten Password",
        content: Column(
          children: <Widget>[
            Text(
              "We will send You the Password Reset Link on the entered E-mail",
              style: TextStyle(
                color: Colors.grey[800],
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
                fontSize: 13.5
              ),
              textAlign: TextAlign.center,
            ),
            TextField(
              onChanged: (value){
                setState(() {
                  _forgotPasswordEmail = value;
                });
              },
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                icon: Icon(
                    Icons.email,
                  color: kLightBlue,
                ),
                hintText: "E-mail",
                hintStyle: TextStyle(
                  color: Colors.grey[500]
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide.none
                )
              ),
            ),
          ],
        ),
        buttons: [
          DialogButton(
            onPressed: (){
              if(_forgotPasswordEmail != null){
                _sendPasswordResetLink();
                Navigator.pop(context);
              }
            },
            child: Text(
              "SEND",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
  }

  _checkField(){
    if(_email != "" && _password != ""){
      _userSignIn();
    }else{
      setState(() {
        isLoading = false;
        _email == "" ? isThereEmail = false : isThereEmail = true;
        _password == "" ? isTherePassword = false : isTherePassword = true;
      });
    }
  }

  _userSignIn() async {
    _auth.signInWithEmailAndPassword(
        email: _email.trim(),
        password: _password.trim()
    ).then((value){

      if(value.user.isEmailVerified){
        print("SIGNED INN");
        _checkPositionOfUser();
      }else{
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => VerifyEmailPage()));
      }
    }).catchError((onError){
      print(onError.code);
      print("*************");
      setState(() {
        if(onError.code == "ERROR_WRONG_PASSWORD"){
          isLoading = false;
          Toast.show("Incorrect Password", context, gravity: Toast.BOTTOM, textColor: Colors.white, backgroundColor: Colors.grey[900]);
        }else if(onError.code == "ERROR_INVALID_EMAIL"){
          isLoading = false;
          Toast.show("Invalid E-mail", context, gravity: Toast.CENTER, textColor: Colors.white, backgroundColor: Colors.grey[900]);
        }else if(onError.code == "ERROR_USER_NOT_FOUND"){
          isLoading = false;
          Toast.show("No User Found!", context, gravity: Toast.CENTER, textColor: Colors.white, backgroundColor: Colors.grey[900]);
        }else{
          isLoading = false;
          Toast.show("Error Logging In", context, gravity: Toast.CENTER, textColor: Colors.white, backgroundColor: Colors.grey[900]);
        }
      });
    });
  }

  _checkPositionOfUser() async {

    FirebaseUser _user = await _auth.currentUser();

    _getCurrentPosition.child("AllUsers").child(_user.uid).child("IamA").once().then((value) async {
      setState(() {
        isLoading = true;
      });

      FirebaseUser _user = await _auth.currentUser();

      final prefs = await SharedPreferences.getInstance();
      prefs.setBool('LoggedIn', true);
      prefs.setString('Identity', value.value);
      prefs.setString('userId', _user.uid.toString());
      prefs.setString('emailUID', _user.uid);
      prefs.setString('email', _email);

      if(value.value == "CEO"){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CEONavigationBar()));
      }else if(value.value == "Employee"){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => EmployeeNavigationBar(
          status: "loggedIn",
        )));
      }
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.black,
      body: isLoading
        ? circularProgress()
          : SafeArea(
        child: Stack(
          children: <Widget>[
            Positioned(
              top: 0.0,
              bottom: 0.0,
              left: 0.0,
              right: 0.0,
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(Colors.black, BlendMode.color),
                child: Image(
                  image: AssetImage("assets/111.jpg"),
                  fit: BoxFit.cover,
                  height: double.infinity,
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Center(
                  child: Text(
                    "Emp-Floyee",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: "Dark",
                      fontSize: 25.0,
                      letterSpacing: 2.5
                    ),
                  )
                ),
                Column(
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20.0),
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(50.0)),
                        color: Colors.grey[900].withOpacity(0.7)
                      ),
                      child: TextField(
                          onChanged: (value){
                            setState(() {
                              _email = value;
                            });
                          },
                          keyboardType: TextInputType.emailAddress,
                        style: TextStyle(
                          color: Colors.white
                        ),
                        decoration: InputDecoration(
                            prefixIcon:Icon(
                              Icons.mail,
                              color: Colors.white,
                              size: 27.0,
                            ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide.none
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide.none
                          ),
                            hintText:isThereEmail ? "E mail" : "E mail Required*",
                            hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 17.0
                            )
                        )
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20.0),
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(50.0)),
                          color: Colors.grey[900].withOpacity(0.7)
                      ),
                      child: TextField(
                          obscureText: true,
                          onChanged: (value){
                            setState(() {
                              _password = value;
                            });
                          },
                          style: TextStyle(
                              color: Colors.white
                          ),
                          decoration: InputDecoration(
                              prefixIcon:Icon(
                                Icons.lock_outline,
                                color: Colors.white,
                                size: 27.0,
                              ),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide.none
                              ),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide.none
                              ),
                              hintText: isTherePassword ? "Password" : "Password Required*",
                              hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 17.0
                              )
                          )
                      ),
                    ),

                    SizedBox(
                      height: 10.0,
                    ),

                    GestureDetector(
                      onTap: (){
                        setState(() {
                          isLoading = true;
                        });
                        _checkField();
                      },
                      child: Container(
                        width: double.infinity,
                        margin: EdgeInsets.symmetric(horizontal: 20.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(50.0)),
                            color: kLightBlue
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 13.0),
                          child: Center(
                            child: Text(
                              "LOGIN",
                              style: TextStyle(
                                color: Colors.white,
                                  fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "New To Emp-Foyee",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(
                          width: 5.0,
                        ),
                        GestureDetector(
                          onTap: (){
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignUpPage()));
                          },
                          child: Text(
                            "Create Account",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0
                            ),
                          ),
                        )
                      ],
                    ),
                    
                    SizedBox(
                      height: 10.0,
                    ),
                    
                    GestureDetector(
                      onTap: (){
                        _forgottenPassword();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(50.0)),
                          border: Border.all(color: Colors.grey[500]),
                          color: Colors.grey[900].withOpacity(0.7)
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                          child: Text(
                            "Forgot Password?",
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1.0
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
