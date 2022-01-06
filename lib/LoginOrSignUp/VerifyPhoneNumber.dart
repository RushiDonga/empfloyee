import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:employee/CommonWidgets/CircularLoadingIndicator.dart';
import 'package:employee/LoginOrSignUp/GetCEODetails.dart';
import 'package:employee/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:employee/Globals.dart' as globals;
import 'package:toast/toast.dart';

Firestore _fireStore = Firestore.instance;

class VerifyPhoneNumber extends StatefulWidget {
  @override
  _VerifyPhoneNumberState createState() => _VerifyPhoneNumberState();

  VerifyPhoneNumber({this.editPhoneNumber});
  final bool editPhoneNumber;
}

class _VerifyPhoneNumberState extends State<VerifyPhoneNumber> {

  bool isLoading = false;
  bool isVerifiedPressed = false;
  bool isPhoneVerified = false;

  bool isPhoneNumberInvalid = false;

  String phoneNumber = "";
  String otp = "";

  _editUserPhoneNumber() async {

    if(globals.position == "CEO"){

      _fireStore.collection(globals.companyName).document("CompanyDetails").updateData({
        "PhoneNumber": phoneNumber,
      }).then((value){
        Toast.show("Updated Successfully!", context);
        Navigator.pop(context, phoneNumber);
      });
    }else{

      _fireStore.collection(globals.companyName).document("Employee").collection("employee").document(globals.userName).updateData({
        "PhoneNumber": phoneNumber,
      }).then((value){

        String document = DateTime.now().toString();
        _fireStore.collection(globals.companyName).document("CEO Notifications").collection("Notifications").document(document).setData({
          "Date": DateTime.now().day.toString() + "-" + DateTime.now().month.toString() + "-" + DateTime.now().year.toString(),
          "DocumentName": document,
          "Search": DateTime.now().month.toString() + "-" + DateTime.now().year.toString(),
          "Seen": false,
          "Type": "EmployeeUpdateData",
          "EmployeeName": globals.userName,
          "Time": DateTime.now().hour.toString() + ":" + DateTime.now().minute.toString(),
        }).then((value){
          Toast.show("Updated Successfully!", context);
          Navigator.pop(context, phoneNumber);
        });
      }).catchError((onError){
        Toast.show("Error Updating the Phone Number", context);
        Navigator.pop(context);
      });
    }
  }

  Future<void> _loginUser(BuildContext context) async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    _auth.verifyPhoneNumber(
        phoneNumber: "+91 " + phoneNumber,
        timeout: Duration(seconds: 60),
        verificationCompleted: (AuthCredential credential) async {
          AuthResult result = await _auth.signInWithCredential(credential);

          FirebaseUser _user = result.user;
          if(_user != null){
            if(widget.editPhoneNumber){
              _editUserPhoneNumber();
            }else{
              _goToNewPage();
            }
          }else{
            print("The Phone Number is not Verified Successfully");
          }
        },
        verificationFailed: (AuthException exception){
        },
        codeSent: (String verificationId, [int forceResendingToken]) async {
          final code = otp;
          AuthCredential credential = PhoneAuthProvider.getCredential(verificationId: verificationId, smsCode: code);

          AuthResult result = await _auth.signInWithCredential(credential);
          FirebaseUser user = result.user;
          if(user != null){
            if(widget.editPhoneNumber){
              _editUserPhoneNumber();
            }else{
              _goToNewPage();
            }
          }else{
            print("ERROR VERIFYING USER");
          }
        },
        codeAutoRetrievalTimeout: null
    );
  }

  _goToNewPage() async {

    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _prefs.setString('where', 'GetCEODetails').then((value){
      _prefs.setString('phoneNumber', phoneNumber).then((value){

        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => GetCEODetails(
          phoneNumber: phoneNumber,
        )));
      });
    });
  }

  Widget _mainBody(){
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width-20,
        height: 325.0,
        decoration: BoxDecoration(
            color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
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
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0)),
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

            Text(
              widget.editPhoneNumber
                ? isVerifiedPressed
                    ? "We have sent an OTP on the \nPhone Number below.\nWaiting for it to Detect Automatically"
                    : "Enter New Phone Number\n "

              : isVerifiedPressed
                  ? "We have sent an OTP on the \nPhone Number below.\nWaiting for it to Detect Automatically"
                  : "We need to Verify the Phone Number \nbefore you proceed",
              style: TextStyle(
                color: Colors.grey[900],
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5
              ),
              textAlign: TextAlign.center,
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: Card(
                child: TextField(
                  keyboardType: TextInputType.number,
                  onChanged: (value){
                    setState(() {
                      phoneNumber = value;
                    });
                  },
                  style: TextStyle(
                      color: Colors.black
                  ),
                  enabled: isVerifiedPressed ? false : true,
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
                      hintText: isPhoneNumberInvalid ? "Phone Number Required*" : "Phone Number",
                    hintStyle: TextStyle(
                      color: isPhoneNumberInvalid ? Colors.red : Colors.grey[700]
                    )
                  ),
                ),
              ),
            ),

            isVerifiedPressed
            ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: Card(
                child: TextField(
                  keyboardType: TextInputType.number,
                  onChanged: (value){
                    setState(() {
                      otp = value;
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
                      hintText: "Enter OTP",
                  ),
                ),
              ),
            )
            : SizedBox(),

            SizedBox(
              height: 10.0,
            ),

            RaisedButton(
              onPressed: (){
                if(isVerifiedPressed == false){
                  setState(() {
                    if((phoneNumber.trim()).length == 10){
                      isVerifiedPressed = true;
                      _loginUser(context);
                    }else{
                      isPhoneNumberInvalid = true;
                    }
                  });
                }else{
                  if(widget.editPhoneNumber == true){
                    _loginUser(context);
                  }
                  print("-----------");
                }
              },
              color: kLightBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                side: BorderSide(width: 1.0, color: Colors.white, style: BorderStyle.solid)
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  isVerifiedPressed
                  ? "VERIFY"
                  : "SEND OTP",
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
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
        ? circularProgress()
          : _mainBody()
    );
  }
}
