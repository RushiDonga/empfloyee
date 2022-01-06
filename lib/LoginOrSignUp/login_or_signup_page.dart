import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'signup_page.dart';
import 'login_page.dart';

class LoginOrSignUpPage extends StatefulWidget {
  @override
  _LoginOrSignUpPageState createState() => _LoginOrSignUpPageState();
}

class _LoginOrSignUpPageState extends State<LoginOrSignUpPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: <Widget>[
          CarouselSlider(
            options: CarouselOptions(
              height: double.infinity,
              onScrolled: null,
              enlargeCenterPage: true,
              autoPlay: true,
              aspectRatio: 19/2,
              autoPlayCurve: Curves.fastOutSlowIn,
              enableInfiniteScroll: true,
              autoPlayAnimationDuration: Duration(milliseconds: 800),
              viewportFraction: 0.8,
            ),
            items: [
              Container(
                child: Image(
                  image: AssetImage("assets/loginOrSignUp2.jpg"),
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                child: Image(
                  image: AssetImage("assets/loginOrSignUp2.jpg"),
                  height: double.infinity,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
            ],
          ),

          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Center(
                  child: Text(
                    "Emp-Floyee",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 30.0,
                        letterSpacing: 2.0,
                      fontFamily: "Dark"
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 130.0),
                      child: Divider(
                        color: Colors.white,
                        height: 1.0,
                      ),
                    ),
                    SizedBox(
                      height: 17.0,
                    ),
                    Text(
                    "Management becomes Easy",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  children: <Widget>[
                    RaisedButton(
                      color: Colors.transparent,
                      onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpPage()));
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 80.0),
                        child: Text(
                          "Sign Up",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.0
                          ),
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        side: BorderSide(color: Colors.white, width: 1.0),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 130.0, vertical: 10.0),
                      child: Divider(
                        height: 1.0,
                        color: Colors.white,
                      ),
                    ),
                    RaisedButton(
                      color: Colors.transparent,
                      onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 88.0),
                        child: Text(
                          "Login",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0
                          ),
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        side: BorderSide(color: Colors.white, width: 1.0),
                      ),
                    ),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
