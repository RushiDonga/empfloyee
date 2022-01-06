import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:employee/constants.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../CommonMethods//go_to_url.dart';
import '../Add_Employee/generate_qr_code.dart';
import 'package:employee/Globals.dart' as globals;

final Firestore fireStore = Firestore.instance;

class EmployeeProfileCEO extends StatefulWidget {
  @override
  _EmployeeProfileCEOState createState() => _EmployeeProfileCEOState();

  EmployeeProfileCEO({this.name});
  final String name;
}

class _EmployeeProfileCEOState extends State<EmployeeProfileCEO> {

  PageController _pageController = PageController(initialPage: 0);
  int _pageChanged = 0;

  CommonMethods _commonMethods = new CommonMethods();

  String _name = "";
  String _proficiency = "";
  String _facebook = "";
  String _instagram = "";
  String _twitter = "";
  String _phoneNumber = "";
  String _email = "";
  String _salary = "";
  String _gst = "";
  String _code = "";
  String _joinDate = "";

  bool _isEditingSalary = false;
  bool _isEditingGST = false;

  bool _isThereSalary = true;
  bool _isThereGST = true;

  String _newSalary = "";
  String _newGst = "";

  _getEmployeeDetails(){
    fireStore.collection(globals.companyName).document("Employee").collection("employee").document(widget.name).get().then((value){
      setState(() {
        _name = value.data["Name"];
        _proficiency = value.data["Proficiency"] == null ? "" : value.data["Proficiency"];
        _facebook = value.data["Facebook"];
        _instagram = value.data["Instagram"];
        _twitter = value.data["Twitter"];
        _phoneNumber = value.data["PhoneNumber"];
        _email = value.data["Email"];
        _salary = value.data["Salary"];
        _code = value.data["Code"];
        _gst = value.data["GST"];
        _joinDate = value.data["Start Date"];
      });
    });
  }
  
  _updateSalary(){
    setState(() {
      _salary = _newSalary;
    });
    fireStore.collection(globals.companyName).document("Employee").collection("employee").document(_name).updateData({
      "Salary": _newSalary,
    }).then((value){
      String documentName = DateTime.now().toString();
      fireStore.collection(globals.companyName).document("Employee").collection("employee").document(_name)
          .collection("Notifications").document(documentName).setData({
        "Date": DateTime.now().day.toString() + "-" + DateTime.now().month.toString() + "-" + DateTime.now().year.toString(),
        "DocumentName": documentName,
        "Search": DateTime.now().month.toString() + "-" + DateTime.now().year.toString(),
        "Seen": false,
        "Time": DateTime.now().hour.toString() + ":" + DateTime.now().minute.toString(),
        "Type": "UpdateSalary",
        "NewSalary": _newSalary,
      });
    });
  }

  _updateGST(){
    setState(() {
      _gst = _newGst;
    });
    fireStore.collection(globals.companyName).document("Employee").collection("employee").document(_name).updateData({
      "GST": _newGst,
    }).then((value){
      String documentName = DateTime.now().toString();
      fireStore.collection(globals.companyName).document("Employee").collection("employee").document(_name)
          .collection("Notifications").document(documentName).setData({
        "Date": DateTime.now().day.toString() + "-" + DateTime.now().month.toString() + "-" + DateTime.now().year.toString(),
        "DocumentName": documentName,
        "Search": DateTime.now().month.toString() + "-" + DateTime.now().year.toString(),
        "Seen": false,
        "Time": DateTime.now().hour.toString() + ":" + DateTime.now().minute.toString(),
        "Type": "UpdateGST",
        "NewGST": _newGst,
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _getEmployeeDetails();
  }

  @override
  Widget build(BuildContext context) {

    Widget _mainProfile(){
      return SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 50.0,),
              Align(
                alignment: Alignment.center,
                child: Image(
                  height: 100,
                  image: AssetImage("assets/profile.png"),
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              Text(
                _name,
                style: TextStyle(
                    color: Colors.white,
                    letterSpacing: 2.0,
                    fontSize: 30.0,
                    fontFamily: "Dark"
                ),
              ),
              SizedBox(
                height: 5.0,
              ),
              Text(
                _proficiency,
                style: TextStyle(
                    color: Colors.white54,
                    letterSpacing: 1.0,
                    fontSize: 17.0
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    IconButton(
                      onPressed: (){
                        _commonMethods.launchURL(_facebook);
                      },
                      icon: FaIcon(FontAwesomeIcons.facebook),
                      color: Colors.white,
                      iconSize: 27.0,
                    ),
                    IconButton(
                      onPressed: (){
                        _commonMethods.launchURL(_instagram);
                      },
                      icon: FaIcon(FontAwesomeIcons.instagram),
                      color: Colors.white,
                      iconSize: 27.0,
                    ),
                    IconButton(
                      onPressed: (){
                        _commonMethods.launchURL(_twitter);
                      },
                      icon: FaIcon(FontAwesomeIcons.twitter),
                      color: Colors.white,
                      iconSize: 27.0,
                    ),
                    IconButton(
                      onPressed: (){
                        _commonMethods.makePhoneCall(_phoneNumber);
                      },
                      icon: FaIcon(FontAwesomeIcons.phoneSquare),
                      color: Colors.white,
                      iconSize: 27.0,
                    ),
                    IconButton(
                      onPressed: (){
                        _commonMethods.sendEmail(_email);
                      },
                      icon: FaIcon(FontAwesomeIcons.mailBulk),
                      color: Colors.white,
                      iconSize: 27.0,
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 15.0,
              ),
              Container(
                height: 36.0,
                width: 150.0,
                child: RaisedButton(
                  onPressed: (){},
                  color: kLightBlue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(7.0)),
                      side: BorderSide(width: 1.5, color: Colors.white54)
                  ),
                  child: Text(
                    "NOTIFY",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.0,
                        letterSpacing: 2.0,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 50.0,
              ),
              Divider(
                thickness: 1.0,
                color: Color(0xFF9A9A9A),
                indent: 30.0,
                endIndent: 30.0,
              ),
              SizedBox(
                height: 12.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      IconButton(
                        onPressed: (){},
                        icon: FaIcon(FontAwesomeIcons.rupeeSign),
                        color: Colors.white,
                        iconSize: 35.0,
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      Text(
                        _salary ,
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 17.0
                        ),
                      ),
                      Text(
                        "Salary",
                        style: TextStyle(
                            color: Colors.white54,
                            letterSpacing: 1.0,
                            fontSize: 20.0
                        ),
                      )
                    ],
                  ),

                  Column(
                    children: <Widget>[
                      IconButton(
                        onPressed: (){},
                        icon: FaIcon(FontAwesomeIcons.airbnb),
                        color: Colors.white,
                        iconSize: 35.0,
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      Text(
                        _gst + " %",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 17.0
                        ),
                      ),
                      Text(
                        "GST",
                        style: TextStyle(
                            color: Colors.white54,
                            letterSpacing: 1.0,
                            fontSize: 20.0
                        ),
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

    Widget _editProfilePage(){
      return SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              SizedBox(height: 10.0,),
              Container(
                margin: EdgeInsets.symmetric(vertical: 2.0, horizontal: 10.0),
                child: Row(
                  children: [
                    IconButton(
                        icon: FaIcon(FontAwesomeIcons.mailBulk),
                        color: Colors.white,
                        onPressed: (){

                        }
                    ),
                    SizedBox(width: 10.0,),
                    Text(
                      _email,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0
                      ),
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 2.0, horizontal: 10.0),
                child: Row(
                  children: [
                    IconButton(
                        icon: FaIcon(FontAwesomeIcons.phone),
                        color: Colors.white,
                        onPressed: (){

                        }
                    ),
                    SizedBox(width: 10.0,),
                    Text(
                      _phoneNumber,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0
                      ),
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 2.0, horizontal: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                            icon: FaIcon(FontAwesomeIcons.rupeeSign),
                            color: Colors.white,
                            onPressed: (){}
                        ),
                        SizedBox(width: 10.0,),

                        _isEditingSalary
                            ? Container(
                          width: MediaQuery.of(context).size.width - 130,
                              child: TextField(
                                onChanged: (value){
                                  setState(() {
                                    _newSalary = value;
                                  });
                                },
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.0
                                ),
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            suffixIcon: GestureDetector(
                              onTap: (){
                                setState(() {
                                  _isEditingSalary = false;
                                });
                              },
                              child: Icon(
                                Icons.cancel,
                                color: Colors.white,
                              ),
                            ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide.none
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide.none
                              ),
                            hintText: _isThereSalary ? "New Salary" : "Required*",
                            hintStyle: TextStyle(
                              color: Colors.white54,
                              fontSize: 18.0
                            )
                          ),
                        ),
                            )
                            : Text(
                          "Salary: " + _salary,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0
                          ),
                        )

                      ],
                    ),

                    _isEditingSalary
                        ? GestureDetector(
                      onTap: (){
                        setState(() {
                          _isEditingSalary = false;
                        });
                        if(_newSalary != ""){
                           _updateSalary();
                        }else{
                          setState(() {
                            _isThereSalary = false;
                          });
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Icon(
                          Icons.save,
                          color: Colors.white,
                          size: 25.0,
                        ),
                      ),
                    )
                        : GestureDetector(
                      onTap: (){
                        setState(() {
                          _isEditingSalary = true;
                          _isEditingGST = false;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 25.0,
                        ),
                      ),
                    )
                  ],
                ),
              ),

              Container(
                margin: EdgeInsets.symmetric(vertical: 2.0, horizontal: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                            icon: FaIcon(FontAwesomeIcons.airbnb),
                            color: Colors.white,
                            onPressed: (){}
                        ),
                        SizedBox(width: 10.0,),

                        _isEditingGST
                            ? Container(
                          width: MediaQuery.of(context).size.width - 130,
                          child: TextField(
                            onChanged: (value){
                              setState(() {
                                _newGst = value;
                              });
                            },
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.0
                            ),
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                                suffixIcon: GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      _isEditingGST = false;
                                    });
                                  },
                                  child: Icon(
                                    Icons.cancel,
                                    color: Colors.white,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide.none
                                ),
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide.none
                                ),
                                hintText: _isThereGST ? "New GST" : "New GST Required*",
                                hintStyle: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 18.0
                                )
                            ),
                          ),
                        )
                            : Text(
                          "GST : " + _gst,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0
                          ),
                        )

                      ],
                    ),

                    _isEditingGST
                      ? GestureDetector(
                      onTap: (){
                        setState(() {
                          _isEditingGST = false;
                        });
                        if(_newGst != ""){
                          _updateGST();
                        }else{
                          setState(() {
                            _isThereGST = false;
                          });
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Icon(
                          Icons.save,
                          color: Colors.white,
                          size: 25.0,
                        ),
                      ),
                    )
                        : GestureDetector(
                      onTap: (){
                        setState(() {
                          _isEditingGST = true;
                          _isEditingSalary = false;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 25.0,
                        ),
                      ),
                    )
                  ],
                ),
              ),

              Container(
                margin: EdgeInsets.symmetric(vertical: 2.0, horizontal: 10.0),
                child: Row(
                  children: [
                    IconButton(
                        icon: FaIcon(FontAwesomeIcons.calendar),
                        color: Colors.white,
                        onPressed: (){

                        }
                    ),
                    SizedBox(width: 10.0,),
                    Text(
                      "Join Date: $_joinDate",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF2E324F),
        centerTitle: true,
        title: Title(
          color: Colors.white,
          child: Text(
            globals.companyName,
            style: TextStyle(
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
        ),
        actions: <Widget>[

          _pageChanged == 0
              ? IconButton(
            onPressed: (){
              _pageController.animateToPage(1, duration: Duration(milliseconds: 300), curve: Curves.bounceInOut);
            },
            icon: FaIcon(FontAwesomeIcons.edit),
            color: Colors.white,
            iconSize: 21.0,
          )
            : IconButton(
            onPressed: (){
              _pageController.animateToPage(0, duration: Duration(milliseconds: 300), curve: Curves.bounceInOut);
            },
            icon: FaIcon(FontAwesomeIcons.angleLeft),
            color: Colors.white,
            iconSize: 24.0,
          ),

          IconButton(
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => DisplayQRCode(
                code: _code,
              )));
            },
            icon: FaIcon(FontAwesomeIcons.qrcode),
            color: Colors.white,
          )
        ],
      ),
      backgroundColor: Color(0xFF2E324F),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index){
          setState(() {
            _pageChanged = index;
          });
        },
        children: [
          _mainProfile(),
          _editProfilePage(),
        ],
      )
    );
  }
}
