import 'package:employee/CommonWidgets/CircularLoadingIndicator.dart';
import 'package:employee/CommonWidgets/text_heading.dart';
import 'package:employee/LoginOrSignUp/VerifyPhoneNumber.dart';
import 'package:employee/constants.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toast/toast.dart';
import '../Globals.dart' as globals;

final fireStore = Firestore.instance;

class EditCEODetails extends StatefulWidget {
  @override
  _EditCEODetailsState createState() => _EditCEODetailsState();
}

class _EditCEODetailsState extends State<EditCEODetails> {

  static String _phoneNumber = "";
  static String _description = "";
  static String _website = "";
  static String _facebook = "";
  static String _instagram = "";
  static String _twitter = "";
  static String _email = "";

  bool _phNum = false;
  bool _isLoading = true;

  // textControllers
  TextEditingController _companyNameTextController;
  TextEditingController _ceoNameTextController;
  TextEditingController _phoneNumberTextController;
  TextEditingController _descriptionTextController;
  TextEditingController _websiteTextController;
  TextEditingController _facebookTextController;
  TextEditingController _instagramTextController;
  TextEditingController _twitterTextController;

  _getCEOData(){
    fireStore.collection(globals.companyName).document("CompanyDetails").get().then((value){
      setState(() {
        _phoneNumber = value.data["PhoneNumber"];
        _description = value.data["Description"];
        _website = value.data["CompanyWebsite"];
        _facebook = value.data["facebook"];
        _instagram = value.data["Instagram"];
        _twitter = value.data["Twitter"];
        _email = value.data["Email"];
      });
    }).then((value){
      _textControllers();
    });
  }

  _textControllers(){
    setState(() {
      _companyNameTextController = TextEditingController.fromValue(TextEditingValue(text: globals.companyName));
      _ceoNameTextController = TextEditingController.fromValue(TextEditingValue(text: globals.userName));
      _phoneNumberTextController = TextEditingController.fromValue(TextEditingValue(text: _phoneNumber));
      _descriptionTextController = TextEditingController.fromValue(TextEditingValue(text: _description));
      _websiteTextController = TextEditingController.fromValue(TextEditingValue(text: _website));
      _facebookTextController = TextEditingController.fromValue(TextEditingValue(text: _facebook));
      _instagramTextController = TextEditingController.fromValue(TextEditingValue(text: _instagram));
      _twitterTextController = TextEditingController.fromValue(TextEditingValue(text: _twitter));

      _isLoading = false;
    });
  }

  _checkFields(){

    _phoneNumber == "" || _phoneNumber == null ? setState((){_phNum = false;}) : setState((){_phNum = true;});

    if(globals.companyName != "" && globals.userName != "" && _phoneNumber != ""){
      _updateData();
    }
  }

  _updateData(){
    fireStore.collection(globals.companyName).document("CompanyDetails").updateData({
      "Description": _description,
      "CompanyWebsite": _website,
      "facebook" : _facebook,
      "Twitter": _twitter,
      "Instagram" : _instagram,
    }).then((value){
      setState(() {
        _isLoading = false;
      });
      Toast.show("Updated Successfully..!", context, gravity: Toast.BOTTOM, duration: Toast.LENGTH_LONG);
    }).catchError((onError){
      setState(() {
        _isLoading = false;
      });
      Toast.show("Could not Update Data..!", context, gravity: Toast.BOTTOM, duration: Toast.LENGTH_LONG);
    });
  }

  @override
  void initState() {
    super.initState();
    _getCEOData();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
        ? circularProgress()
          : SafeArea(
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
                decoration: BoxDecoration(
                    color: kLightBlue,
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    gradient: LinearGradient(
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                      colors: [
                        kLightBlue,
                        kLightBlue,
                        kLightBlue,
                        kLightBlue,
                      ],

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
                                  globals.userName,
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
                                  _description.length > 30 ? _description.substring(0, 16) + "..." : _description,
                                  maxLines: 1,
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
                              _isLoading = true;
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
                    children: [
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
                                  Icons.business,
                                  color: kLightBlue,
                                  size: 25.0,
                                ),
                                SizedBox(width: 10.0,),
                                Text(
                                  _companyNameTextController.text,
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
                                  Icons.verified_user,
                                  color: kLightBlue,
                                  size: 25.0,
                                ),
                                SizedBox(width: 10.0,),
                                Text(
                                  _ceoNameTextController.text,
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
                            controller: _descriptionTextController,
                            onChanged: (value){
                              setState(() {
                                _description = value;
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
                                hintText: "Description"
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
                            controller: _websiteTextController,
                            onChanged: (value){
                              setState(() {
                                _website = value;
                              });
                            },
                            style: TextStyle(
                                color: Colors.black
                            ),
                            decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.code,
                                  color: kLightBlue,
                                  size: 25.0,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide.none
                                ),
                                hintText: "Company Website"
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
                            controller: _facebookTextController,
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
                                  icon: FaIcon(
                                    FontAwesomeIcons.facebook,
                                    color: kLightBlue,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide.none
                                ),
                                hintText: "Facebook"
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
                            controller: _instagramTextController,
                            onChanged: (value){
                              setState(() {
                                _instagram = value;
                              });
                            },
                            style: TextStyle(
                                color: Colors.black
                            ),
                            decoration: InputDecoration(
                                prefixIcon: IconButton(
                                  onPressed: (){},
                                  icon: FaIcon(
                                    FontAwesomeIcons.instagram,
                                    color: kLightBlue,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide.none
                                ),
                                hintText: "Instagram Link"
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
                            controller: _websiteTextController,
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
                                  icon: FaIcon(
                                    FontAwesomeIcons.twitter,
                                    color: kLightBlue,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide.none
                                ),
                                hintText: "Company Website"
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
