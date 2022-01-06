import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:employee/CommonWidgets/CircularLoadingIndicator.dart';
import 'package:employee/CommonWidgets/text_heading.dart';
import 'package:employee/LoginOrSignUp/VerifyPhoneNumber.dart';
import 'package:employee/constants.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:toast/toast.dart';
import '../Globals.dart' as globals;

Firestore _firestore = Firestore.instance;

class EditEmployeeDetailsForEmployee extends StatefulWidget {
  @override
  _EditEmployeeDetailsForEmployeeState createState() => _EditEmployeeDetailsForEmployeeState();

}

class _EditEmployeeDetailsForEmployeeState extends State<EditEmployeeDetailsForEmployee> {

  String _name = "";
  String _proficiency = "";
  String _bio = "";
  String _phoneNumber = "";
  String _email = "";
  String _facebook = "";
  String _linkedin = "";
  String _twitter = "";
  String _website = "";
  String _salary = "";
  String _gst = "";
  String _date = "";

  bool _isThereName = true;
  bool _isTherePhoneNumber = true;
  bool _isThereEmail = true;
  bool isLoading = true;

  TextEditingController _nameEditingController;
  TextEditingController _proficiencyTextController;
  TextEditingController _bioEditingController;
  TextEditingController _phoneNumberEditingController;
  TextEditingController _emailEditingController;
  TextEditingController _facebookEditingController;
  TextEditingController _linkedInEditingController;
  TextEditingController _twitterEditingController;
  TextEditingController _websiteEditingController;

  _getDetails(){
    _firestore.collection(globals.companyName).document("Employee").collection("employee").document(globals.userName).get().then((value){
      setState(() {
        _name = value.data["Name"];
        _proficiency = value.data["Proficiency"];
        _bio = value.data["Bio"];
        _phoneNumber = value.data["PhoneNumber"];
        _email = value.data["Email"];
        _facebook = value.data["Facebook"];
        _linkedin = value.data["LinkedIn"];
        _twitter = value.data["Twitter"];
        _website = value.data["Website"];
        _salary = value.data["Salary"];
        _gst = value.data["GST"];
        _date = value.data["Start Date"];

        _textController();
      });
    }).then((value){
      setState(() {
        isLoading = false;
      });
    });
  }

  _textController(){
    setState(() {
      _nameEditingController = TextEditingController.fromValue(TextEditingValue(text: _name));
      _bioEditingController = TextEditingController.fromValue(TextEditingValue(text: _bio));
      _proficiencyTextController = TextEditingController.fromValue(TextEditingValue(text: _proficiency));
      _phoneNumberEditingController = TextEditingController.fromValue(TextEditingValue(text: _phoneNumber));
      _emailEditingController = TextEditingController.fromValue(TextEditingValue(text: _email));
      _facebookEditingController = TextEditingController.fromValue(TextEditingValue(text: _facebook));
      _linkedInEditingController = TextEditingController.fromValue(TextEditingValue(text: _linkedin));
      _twitterEditingController = TextEditingController.fromValue(TextEditingValue(text: _twitter));
      _websiteEditingController = TextEditingController.fromValue(TextEditingValue(text: _website));
    });
  }

  _checkFields(){
    setState(() {
      isLoading = true;
    });
    _name != "" ? setState((){_isThereName = true;}) : setState((){_isThereName = false;});
    _phoneNumber != "" ? setState((){_isTherePhoneNumber = true;}) : setState((){_isTherePhoneNumber = false;});
    _email != "" ? setState((){_isThereEmail = true;}) : setState((){_isThereEmail = false;});

    if(_name != "" && _phoneNumber != "" && _email != ""){
      _updateData();
    }
  }

  _updateData(){
    _firestore.collection(globals.companyName).document("Employee").collection("employee").document(globals.userName).updateData({
      // "Name": _name,
      "Proficiency": _proficiency,
      "Bio": _bio,
      "PhoneNumber": _phoneNumber,
      "Email": _email,
      "Facebook": _facebook,
      "LinkedIn": _linkedin,
      "Twitter": _twitter,
      "Website": _website,
    }).then((value){

      String document = DateTime.now().toString();
      _firestore.collection(globals.companyName).document("CEO Notifications").collection("Notifications").document(document).setData({
        "Date": DateTime.now().day.toString() + "-" + DateTime.now().month.toString() + "-" + DateTime.now().year.toString(),
        "DocumentName": document,
        "Search": DateTime.now().month.toString() + "-" + DateTime.now().year.toString(),
        "Seen": false,
        "Type": "EmployeeUpdateData",
        "EmployeeName": globals.userName,
        "Time": DateTime.now().hour.toString() + ":" + DateTime.now().minute.toString(),
      }).then((value){
        setState(() {
          isLoading = false;
        });
        Toast.show("Updated Successfully..!", context, gravity: Toast.BOTTOM, duration: Toast.LENGTH_LONG);
      });
    }).catchError((onError){
      setState(() {
        isLoading = false;
      });
      Toast.show("Cannot Update Data", context, gravity: Toast.BOTTOM, duration: Toast.LENGTH_LONG);
    });
  }

  @override
  void initState() {
    super.initState();

    _getDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? circularProgress()
          : SafeArea(
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
              decoration: BoxDecoration(
                  color: kLightBlue,
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  gradient: LinearGradient(
                    colors: [
                      kLightBlue,
                      kLightBlue,
                      kLightBlue,
                      kLightBlue,
                    ],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                  )
              ),
              child: Padding(
                padding: const EdgeInsets.only(right: 15.0, left: 15.0, top: 40.0, bottom: 10.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Image(
                        height: 78.0,
                        image: AssetImage("assets/profile.png"),
                      ),
                    ),
                    SizedBox(
                      width: 5.0,
                    ),
                    Expanded(
                      flex: 3,
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Align(
                              alignment: Alignment.bottomLeft,
                              child: Text(
                                _name,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22.0
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 8.0,
                            ),
                            Align(
                              alignment: Alignment.bottomLeft,
                              child: Text(
                                _proficiency,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.0,
                                    letterSpacing: 1.0
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                        child: IconButton(
                          onPressed: (){
                            _checkFields();
                          },
                          color: Colors.white,
                          icon: FaIcon(FontAwesomeIcons.save),
                          iconSize: 28.0,
                        )
                    )
                  ],
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    TextHeading(text: "Personal Details",),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Card(
                        elevation: 0.5,
                        margin: EdgeInsets.symmetric(vertical: 0.7),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 17.0, horizontal: 11.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.verified_user,
                                color: kLightBlue,
                                size: 25.0,
                              ),
                              SizedBox(width: 10.0,),
                              Text(
                                _name,
                                style: TextStyle(
                                    color: Colors.black,
                                  fontSize: 16.0
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Card(
                        elevation: 0.5,
                        margin: EdgeInsets.symmetric(vertical: 0.7),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 17.0, horizontal: 11.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.phone_android,
                                    color: kLightBlue,
                                    size: 25.0,
                                  ),
                                  SizedBox(width: 10.0,),
                                  Text(
                                    _phoneNumber,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16.0
                                    ),
                                  )
                                ],
                              ),
                              GestureDetector(
                                onTap: () async {
                                  String data = await Navigator.push(context, MaterialPageRoute(builder: (context) => VerifyPhoneNumber(
                                    editPhoneNumber: true,
                                  )));

                                  if(data != null){
                                    setState(() {
                                      _phoneNumber = data;
                                    });
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                  child: Icon(
                                    Icons.edit,
                                    color: kLightBlue,
                                    size: 25.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Card(
                        elevation: 0.5,
                        margin: EdgeInsets.symmetric(vertical: 0.7),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 17.0, horizontal: 11.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.alternate_email,
                                color: kLightBlue,
                                size: 25.0,
                              ),
                              SizedBox(width: 10.0,),
                              Text(
                                _email,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16.0
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Card(
                        elevation: 0.5,
                        margin: EdgeInsets.symmetric(vertical: 0.7),
                        child: TextField(
                          controller: _proficiencyTextController,
                          onChanged: (value){
                            setState(() {
                              _proficiency = value;
                            });
                          },
                          style: TextStyle(
                              color: Colors.black
                          ),
                          decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.brightness_auto,
                                color: kLightBlue,
                                size: 25.0,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide.none
                              ),
                              hintText: "Proficiency"
                          ),
                        ),
                      ),
                    ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: Card(
                          elevation: 0.5,
                          margin: EdgeInsets.symmetric(vertical: 0.7),
                          child: TextField(
                            controller: _bioEditingController,
                            onChanged: (value){
                              setState(() {
                                _bio = value;
                              });
                            },
                            style: TextStyle(
                                color: Colors.black
                            ),
                            decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.description,
                                  color: kLightBlue,
                                  size: 25.0,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide.none
                                ),
                                hintText: "Bio"
                            ),
                          ),
                        ),
                      ),

                    TextHeading(text: "Social Media",),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Card(
                        elevation: 0.5,
                        margin: EdgeInsets.symmetric(vertical: 0.7),
                        child: TextField(
                          controller: _facebookEditingController,
                          onChanged: (value){
                            setState(() {
                              _facebook = value;
                            });
                          },
                          style: TextStyle(
                              color: Colors.black
                          ),
                          decoration: InputDecoration(
                              prefixIcon: IconButton(
                                onPressed: (){},
                                icon: FaIcon(FontAwesomeIcons.facebook),
                                color: kLightBlue,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide.none
                              ),
                              hintText: "Facebook link"
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Card(
                        elevation: 0.5,
                        margin: EdgeInsets.symmetric(vertical: 0.7),
                        child: TextField(
                          controller: _linkedInEditingController,
                          onChanged: (value){
                            setState(() {
                              _linkedin = value;
                            });
                          },
                          style: TextStyle(
                              color: Colors.black
                          ),
                          decoration: InputDecoration(
                              prefixIcon: IconButton(
                                onPressed: (){},
                                icon: FaIcon(FontAwesomeIcons.instagram),
                                color: kLightBlue,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide.none
                              ),
                              hintText: "LinkedIn link"
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Card(
                        elevation: 0.5,
                        margin: EdgeInsets.symmetric(vertical: 0.7),
                        child: TextField(
                          controller: _twitterEditingController,
                          onChanged: (value){
                            setState(() {
                              _twitter = value;
                            });
                          },
                          style: TextStyle(
                              color: Colors.black
                          ),
                          decoration: InputDecoration(
                              prefixIcon: IconButton(
                                onPressed: (){},
                                icon: FaIcon(FontAwesomeIcons.twitter),
                                color: kLightBlue,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide.none
                              ),
                              hintText: "Twitter"
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Card(
                        elevation: 0.5,
                        margin: EdgeInsets.symmetric(vertical: 0.7),
                        child: TextField(
                          controller: _websiteEditingController,
                          onChanged: (value){
                            setState(() {
                              _website = value;
                            });
                          },
                          style: TextStyle(
                              color: Colors.black
                          ),
                          decoration: InputDecoration(
                              prefixIcon: IconButton(
                                onPressed: (){},
                                icon: FaIcon(FontAwesomeIcons.portrait),
                                color: kLightBlue,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide.none
                              ),
                              hintText: "Portfolio"
                          ),
                        ),
                      ),
                    ),
                    TextHeading(text: "Others",),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Card(
                        elevation: 0.5,
                        margin: EdgeInsets.symmetric(vertical: 0.7),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 17.0, horizontal: 11.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.money,
                                color: kLightBlue,
                                size: 25.0,
                              ),
                              SizedBox(width: 10.0,),
                              Text(
                                "Salary: $_salary",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16.0
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Card(
                        elevation: 0.5,
                        margin: EdgeInsets.symmetric(vertical: 0.7),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 17.0, horizontal: 11.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.tab_rounded,
                                color: kLightBlue,
                                size: 25.0,
                              ),
                              SizedBox(width: 10.0,),
                              Text(
                                "GST: $_gst",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16.0
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Card(
                        elevation: 0.5,
                        margin: EdgeInsets.symmetric(vertical: 0.7),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 17.0, horizontal: 11.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_view_day,
                                color: kLightBlue,
                                size: 25.0,
                              ),
                              SizedBox(width: 10.0,),
                              Text(
                                "Join Date: $_date",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16.0
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
