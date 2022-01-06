import 'package:employee/CommonWidgets/CircularLoadingIndicator.dart';
import 'package:employee/LoginOrSignUp/VerifyEmailPage.dart';
import 'package:employee/constants.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'package:toast/toast.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {

  String email = "";
  String password = "";
  String errorMessage = "";
  String selected = "null";

  bool isLoading = false;
  bool isThereEmail = true;
  bool isTherePassword = true;

  // firebase auth Variable
  final _auth = FirebaseAuth.instance;
  String userID = "";

  _checkField(){
    if(email != "" && password != ""){
      _registerUser();
    }else{
      setState(() {
        email == "" ? isThereEmail = false : isThereEmail = true;
        password == "" ? isTherePassword = false : isTherePassword = true;
      });
    }
  }

  _registerUser() async {
    setState(() {
      isLoading = true;
    });

    SharedPreferences _prefs = await SharedPreferences.getInstance();

    _auth.createUserWithEmailAndPassword(email: email.trim(), password: password.trim()).then((value){
      if(value != null){
        _prefs.setString('email', email.trim());
        _prefs.setString('password', password);
        _prefs.setString('where', 'VerifyEmailPage').then((value){
          print("==================");
          print(_prefs.getString('where'));

          Navigator.push(context, MaterialPageRoute(builder: (context) => VerifyEmailPage()));
        });
      }
    }).catchError((onError){
      setState(() {
        isLoading = false;
      });
      if(onError.code == "ERROR_EMAIL_ALREADY_IN_USE"){
        Toast.show("Email Already Exists!", context, duration: Toast.LENGTH_LONG);
      }else if(onError.code == "ERROR_WEAK_PASSWORD"){
        Toast.show("Enter a Strong Password!", context, duration: Toast.LENGTH_LONG);
      }else if(onError == "ERROR_INVALID_EMAIL"){
        Toast.show("Invalid E-mail", context, gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
      }else{
        print(onError.code);
        Toast.show("Error registering an E-mail!", context, duration: Toast.LENGTH_LONG);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                colorFilter: ColorFilter.mode(Colors.white, BlendMode.color),
                child: Image(
                  image: AssetImage("assets/signUpPage.jpg"),
                  fit: BoxFit.cover,
                  height: double.infinity,
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
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
                              email = value;
                            });
                          },
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
                              hintText:isThereEmail ? "E-mail" : "E-mail Required*",
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
                              password = value;
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
                      height: 8.0,
                    ),

                    GestureDetector(
                      onTap: (){
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
                              "SIGN UP",
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
                          "Have an Account?",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(
                          width: 5.0,
                        ),
                        GestureDetector(
                          onTap: (){
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
                          },
                          child: Text(
                            "Login",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),

              ],
            )
          ],
        ),
      ),
    );
  }
}
