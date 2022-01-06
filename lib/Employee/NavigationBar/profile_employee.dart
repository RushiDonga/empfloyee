import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:employee/CEO/ChangePasswordEmail.dart';
import 'package:employee/CEO/CommonMethods/GenerateTodayDate.dart';
import 'package:employee/CEO/Salary/DisplayEmployeeSalaryDetails.dart';
import 'package:employee/CEO/Todo_And_Reminder/Employee_Review_Page.dart';
import 'package:employee/CommonWidgets/cards_three_in_row.dart';
import 'package:employee/CommonWidgets/two_in_rows_text_icon_button.dart';
import 'package:employee/Employee/NotifyManager.dart';
import 'package:employee/Report/addReport.dart';
import 'package:employee/SplashScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../CommonWidgets/text_heading.dart';
import '../../constants.dart';
import '../edit_employee_details.dart';
import '../../GetDetails/user_id.dart';
import '../../CEO/CommonMethods/go_to_url.dart';
import '../../CommonWidgets/social_media_icons.dart';
import '../../Globals.dart' as globals;
import '../../Employee/Attendance/ViewAttendanceEmployee.dart';
import '../../Leave/demandLeave.dart';
import 'package:toast/toast.dart';

Firestore _fireStore = Firestore.instance;

class ProfilePageEmployee extends StatefulWidget {
  @override
  _ProfilePageEmployeeState createState() => _ProfilePageEmployeeState();
}

class _ProfilePageEmployeeState extends State<ProfilePageEmployee> with SingleTickerProviderStateMixin {

  final double maxSlide = 225.0;

  GeneralInfo _info = GeneralInfo();

  AnimationController _animationController;

  CommonMethods commonMethods = new CommonMethods();
  FirebaseAuth _auth = FirebaseAuth.instance;

  GetUserID getUserId = new GetUserID();
  String _proficiency = "";
  String _bio = "";
  String _facebook = "";
  String _linkedIn = "";
  String _twitter = "";
  String _website = "";

  bool isLoading = false;
  bool isTodayStatusLoading = false;

  _getEmployeeInfo() {
    _fireStore.collection (globals.companyName).document("Employee").collection ("employee").document(globals.userName).get().then ((value) {
      setState (() {
        globals.companyName = value.data["Company Name"];
        globals.userName = value.data["Name"];
        _proficiency = value.data["Proficiency"];
        _bio = value.data["Bio"];
        _facebook = value.data["Facebook"];
        _linkedIn = value.data["LinkedIn"];
        _twitter = value.data["Twitter"];
        _website = value.data["Website"];
      });
    });
  }

  _getAttendanceType(){
    setState(() {
      isTodayStatusLoading = true;
    });
    String _attendanceType = "";
    String _documentName = "";
    _fireStore.collection(globals.companyName).document("Attendance").get().then((value){
      _attendanceType = value.data["Type"];
      _documentName = value.data["DocumentName"];
    }).then((value){
      if(_attendanceType == "ManuallyFill"){

        // Get the Attendance of Today
        if(_documentName.contains(_info.getTodayDateYMD())){
          _fireStore.collection(globals.companyName).document("Attendance").collection("Attendance").document(globals.userName)
              .collection(globals.userName).document(_documentName).get().then((value){
            _showAlertWithOneButton(
                "Hey ${globals.userName}",
                "You Attendance has been Marked as ${value.data["Status"]} for today",
                "OKAY",
                    (){
                  Navigator.pop(context);
                }
            );
          }).then((value){
            setState(() {
              isTodayStatusLoading = false;
            });
          });
        }else{
          _showAlertWithOneButton(
              "Hey ${globals.userName}",
              "Your Attendance for Toady has Not been filled" ,
              "OKAY",
                  (){
                Navigator.pop(context);
              }
          );
          setState(() {
            isTodayStatusLoading = false;
          });
        }
      }else{
        _getTodayStatus();
      }
    });
  }

  _getTodayStatus() async {
    String document;
    await _fireStore.collection (globals.companyName).document ("Attendance").get ().then ((value) {
      document = value.data["DocumentName"];
      String date = DateTime.now ().day.toString () + "-" + DateTime.now ().month.toString () + "-" + DateTime.now ().year.toString ();
      if (value.data["TodayAttendance"] == true && value.data["Date"] ==
          date) { // Check if the Attendance has been Started

        _fireStore.collection (globals.companyName).document ("Attendance").collection ("Attendance").document (globals.userName).collection (globals.userName).document (value.data["DocumentName"]).get ().then ((value) {
          if (value.data["filled"] == true) {
            setState (() {
              isLoading = false;
            });
            _showAlertWithOneButton (
                "Hey ${globals.userName}" ,
                "Your Attendance has been marked as ${value.data["Status"]}" ,
                "OKAY" ,
                    () {
                  Navigator.pop (context);
                }
            );
          } else if (value.data["filled"] == false) {
            setState (() {
              isLoading = false;
            });
            _showAlertWithTwoButtons (
                "Hey ${globals.userName}" ,
                "You haven't filled your Attendance yet" ,
                "OKAY" ,
                "FILL ?" ,
                    () { // On OKAY pressed
                  Navigator.pop (context);
                } ,
                    () { // on Fill Pressed
                  Navigator.pop (context);
                  _showAlertWithTwoButtons (
                      "Hey ${globals.userName}" ,
                      "Wanna mark your Attendance for Today as...?" ,
                      "PRESENT" ,
                      "ABSENT" ,
                          () { // if the Present is Marked
                        _fillAttendance ("Present" , document);
                      } ,
                          () { // if the Absent is Marked
                        _fillAttendance ("Absent" , value.data["DocumentName"]);
                      }
                  );
                }
            );
          }
          setState(() {
            isTodayStatusLoading = false;
          });
        });
      } else {
        setState (() {
          isLoading = false;
          isTodayStatusLoading = false;
        });
        _showAlertWithOneButton (
            "Hey ${globals.userName}" ,
            "Attendance has not yet Started" ,
            "OKAY" ,
                () {
              Navigator.pop (context);
            }
        );
      }
    }).then ((value) {});
  }

  _fillAttendance(String status , String documentName) {
    setState (() {
      isLoading = true;
    });
    _fireStore.collection (globals.companyName).document ("Attendance").collection ("Attendance").document (globals.userName).collection (globals.userName).document (documentName).updateData ({
      "Status": status ,
      "filled": true ,
      "Time": DateTime.now ().hour.toString () + "-" + DateTime.now ().minute.toString () ,
    }).then ((value) {
      setState (() {
        isLoading = false;
      });
      Navigator.pop (context);
    });
  }

  _showAlertWithTwoButtons(String title , String description ,
      String btnTextOne , String btnTextTwo , dynamic btnPressedOne ,
      dynamic btnPressedTwo) {
    Alert (
        context: context ,
        title: title ,
        desc: description ,
        buttons: [
          DialogButton (
            color: kLightBlue ,
            onPressed: btnPressedOne ,
            child: Text (
              btnTextOne ,
              style: TextStyle (
                  color: Colors.white
              ) ,
            ) ,
          ) ,
          DialogButton (
            color: kLightBlue ,
            onPressed: btnPressedTwo ,
            child: Text (
              btnTextTwo ,
              style: TextStyle (
                  color: Colors.white
              ) ,
            ) ,
          ) ,
        ]
    ).show ();
  }

  _showAlertWithOneButton(String title , String description , String btnText ,
      dynamic btnPressed) {
    Alert (
        context: context ,
        title: title ,
        desc: description ,
        buttons: [
          DialogButton (
            color: kLightBlue ,
            onPressed: btnPressed ,
            child: Text (
              btnText ,
              style: TextStyle (
                  color: Colors.white
              ) ,
            ) ,
          ) ,
        ]
    ).show ();
  }

  void toggle() {
    _animationController.isDismissed
        ? _animationController.forward ()
        : _animationController.reverse ();
  }

  _signOut() async {
    setState(() {
      isLoading = true;
    });
    String documentName = DateTime.now().toString();
    _fireStore.collection(globals.companyName).document("CEO Notifications").collection("Notifications").document(documentName).setData({
      "Date": DateTime.now().day.toString() + "-" + DateTime.now().month.toString() + "-" + DateTime.now().year.toString(),
      "DocumentName": documentName,
      "EmployeeName": globals.userName,
      "Search": DateTime.now().month.toString() + "-" + DateTime.now().year.toString(),
      "Seen": false,
      "Time": DateTime.now().hour.toString() + ":" + DateTime.now().minute.toString(),
      "Type": "EmployeeLogOut",
    }).then((value) async {

      await _auth.signOut ().then ((value) async {
        var prefs = await SharedPreferences.getInstance ();
        prefs.setBool ('LoggedIn' , false);
        prefs.setString ('Identity' , '');
        prefs.setString ('userId' , '');
        prefs.setString ('emailUID' , '');
        prefs.setString ('password' , '');
        prefs.setString ('email' , '');
        prefs.setString('where', 'COMPLETED');
      }).then((value){
        setState(() {
          isLoading = false;
        });
        Navigator.pushReplacement (context , MaterialPageRoute (builder: (context) => SplashScreen ()));
      }).catchError ((onError) {
        setState(() {
          isLoading = false;
        });
        print(onError);
        Toast.show ("Error Signing Out" , context);
      });
    }).catchError((onError){
      setState(() {
        isLoading = false;
      });
      print("***********");
      print(onError);
    });
  }

  @override
  void initState() {
    super.initState ();

    _animationController = AnimationController (
        vsync: this ,
        duration: Duration (milliseconds: 250)
    );

    _getEmployeeInfo ();
  }

  @override
  Widget build(BuildContext context) {

    bool _canBeDragged = true;

    _onDragStart(DragStartDetails details){
      bool isDragOpenFromLeft = _animationController.isDismissed; //  && details.globalPosition.dx < minDragStartEdge;
      bool isDragCloseFromRight = _animationController.isCompleted; // && details.globalPosition.dx >

      _canBeDragged = isDragCloseFromRight || isDragOpenFromLeft;
    }

    _onDragUpdate(DragUpdateDetails details){
      if(_canBeDragged){
        double delta = details.primaryDelta/maxSlide;
        _animationController.value += delta;
      }
    }

    _onDragEnd(DragEndDetails details){
      if(_animationController.isDismissed || _animationController.isCompleted){
        return;
      }
      if(details.velocity.pixelsPerSecond.dx.abs() >= 365.0){
        double visualVelocity = details.velocity.pixelsPerSecond.dx/MediaQuery.of(context).size.width;

        _animationController.fling(velocity: visualVelocity);
      }else if(_animationController.value < 0.5){
        toggle();

      }else{
        toggle();
      }
    }

    Widget _mainBody() {
      return Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
            color: Colors.white
        ),
        child: GestureDetector(
          onHorizontalDragStart: _onDragStart,
          onHorizontalDragUpdate: _onDragUpdate,
          onHorizontalDragEnd: _onDragEnd,
          child: SafeArea (
            child: SingleChildScrollView (
              child: Column (
                children: <Widget>[
                  Padding (
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0 , vertical: 10.0) ,
                    child: Row (
                      children: <Widget>[
                        Expanded (
                            flex: 1 ,
                            child: GestureDetector(
                              onTap: (){
                                toggle();
                              },
                              child: Icon(
                                Icons.settings,
                                color: kLightBlue,
                                size: 33.0,
                              ),
                            )
                        ) ,
                        Expanded (
                          flex: 4 ,
                          child: Text (
                            globals.companyName ,
                            textAlign: TextAlign.center ,
                            style: TextStyle (
                                color: Colors.black ,
                                fontSize: 20.0 ,
                                letterSpacing: 1.5
                            ) ,
                          ) ,
                        ) ,
                        Expanded (
                          flex: 1 ,
                          child: IconButton (
                            onPressed: () {
                              Navigator.push (context , MaterialPageRoute (builder: (context) => EditEmployeeDetailsForEmployee ()));
                            } ,
                            icon: FaIcon (FontAwesomeIcons.edit) ,
                            color: kLightBlue ,
                          ) ,
                        ) ,
                      ] ,
                    ) ,
                  ) ,

                  Padding (
                    padding: EdgeInsets.symmetric (horizontal: 10.0) ,
                    child: Card (
                      color: Color (0XFFF7F2F9) ,
                      shape: RoundedRectangleBorder (
                        borderRadius: BorderRadius.circular (10.0) ,
                      ) ,
                      child: Column (
                        crossAxisAlignment: CrossAxisAlignment.stretch ,
                        children: <Widget>[
                          SizedBox (
                            height: 10.0 ,
                          ) ,
                          Stack (
                            children: <Widget>[
                              Padding (
                                padding: const EdgeInsets.only(
                                    top: 45.0 , left: 12.0 , right: 12.0) ,
                                child: Container (
                                  decoration: BoxDecoration (
                                    color: kLightBlue ,
                                    borderRadius: BorderRadius.circular (10.0) ,
                                  ) ,
                                  child: Column (
                                    children: <Widget>[
                                      SizedBox (
                                        height: 60.0 ,
                                      ) ,
                                      Center (
                                        child: Text (
                                          globals.userName ,
                                          textAlign: TextAlign.center ,
                                          style: TextStyle (
                                              color: Colors.white ,
                                              fontWeight: FontWeight.bold ,
                                              fontSize: 20.0
                                          ) ,
                                        ) ,
                                      ) ,
                                      SizedBox (
                                        height: 3.0 ,
                                      ) ,
                                      Padding (
                                        padding: EdgeInsets.symmetric (
                                            horizontal: 10.0) ,
                                        child: Text (
                                          _proficiency ,
                                          textAlign: TextAlign.center ,
                                          style: TextStyle (
                                              color: Colors.white ,
                                              fontSize: 13.0 ,
                                              letterSpacing: 1.0
                                          ) ,
                                        ) ,
                                      ) ,
                                      Padding (
                                        padding: EdgeInsets.symmetric (
                                            horizontal: 10.0) ,
                                        child: Text (
                                          _bio ,
                                          textAlign: TextAlign.center ,
                                          style: TextStyle (
                                            color: Colors.white ,
                                            fontSize: 20.0 ,
                                          ) ,
                                        ) ,
                                      ) ,
                                      Padding (
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20.0 , vertical: 10.0) ,
                                        child: Row (
                                          mainAxisAlignment: MainAxisAlignment.spaceAround ,
                                          children: <Widget>[
                                            SocialMediaIcons (
                                              icon: IconButton (
                                                icon: FaIcon (
                                                    FontAwesomeIcons.facebook) ,
                                                color: kLightBlue ,
                                                onPressed: () {
                                                  commonMethods.launchURL (_facebook);
                                                } ,
                                              ) ,
                                            ) ,
                                            SocialMediaIcons (
                                              icon: IconButton (
                                                icon: FaIcon (
                                                    FontAwesomeIcons.linkedin) ,
                                                color: kLightBlue ,
                                                onPressed: () {
                                                  commonMethods.launchURL (_linkedIn);
                                                } ,
                                              ) ,
                                            ) ,
                                            SocialMediaIcons (
                                              icon: IconButton (
                                                icon: FaIcon (
                                                    FontAwesomeIcons.twitter) ,
                                                color: kLightBlue ,
                                                onPressed: () {
                                                  commonMethods.launchURL (
                                                      _twitter);
                                                } ,
                                              ) ,
                                            ) ,
                                            SocialMediaIcons (
                                              icon: IconButton (
                                                icon: FaIcon (
                                                    FontAwesomeIcons.link) ,
                                                color: kLightBlue ,
                                                onPressed: () {
                                                  commonMethods.launchURL (
                                                      _website);
                                                } ,
                                              ) ,
                                            ) ,
                                          ] ,
                                        ) ,
                                      )
                                    ] ,
                                  ) ,
                                ) ,
                              ) ,
                              Align (
                                alignment: Alignment.center ,
                                child: Image (
                                  height: 100.0 ,
                                  image: AssetImage ("assets/profile.png") ,
                                ) ,
                              ) ,
                            ] ,
                          ) ,
                          SizedBox (
                            height: 10.0 ,
                          )
                        ] ,
                      ) ,
                    ) ,
                  ) ,

                  TextHeading (text: "Attendance and Salary" ,) ,

                  Padding (
                    padding: EdgeInsets.symmetric (horizontal: 15.0) ,
                    child: Row (
                      children: <Widget>[
                        Expanded (
                          child: GestureDetector (
                            onTap: () {
                              _getAttendanceType();
                            } ,
                            child: ProfileThreeInRow (
                              iconData: isTodayStatusLoading
                                  ? Padding(
                                padding: const EdgeInsets.symmetric(vertical: 3.0),
                                child: Container(
                                  height: 21.0,
                                  width: 21.0,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation(Colors.black),
                                    strokeWidth: 2.0,
                                  ),
                                ),
                              )
                                  : Icon(
                                Icons.graphic_eq_sharp,
                                color: Colors.black,
                                size: 28.0,
                              ),
                              text: "Today's \nStatus" ,
                              color: Color (0XFFFAECEE) ,
                            ) ,
                          ) ,
                        ) ,

                        Expanded (
                          child: GestureDetector (
                            onTap: () {
                              Navigator.push (context ,
                                  MaterialPageRoute (builder: (context) => ViewAttendanceEmployee (
                                    ceo: false ,
                                  )));
                            } ,
                            child: ProfileThreeInRow (
                              iconData: Icon(
                                Icons.view_compact,
                                color: Colors.black.withOpacity(0.7),
                                size: 28.0,
                              ) ,
                              text: "View \nAttendance" ,
                              color: Color (0XFFE2F1FE) ,
                            ) ,
                          ) ,
                        ) ,

                        Expanded (
                          child: GestureDetector (
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => DisplayEmployeeSalaryDetails(
                                employeeName: globals.userName,
                              )));
                            } ,
                            child: ProfileThreeInRow (
                              iconData: Icon(
                                Icons.monetization_on,
                                color: Colors.black.withOpacity(0.7),
                                size: 28.0,
                              ) ,
                              text: "Salary \nDetails" ,
                              color: Color (0XFFE2F1FE) ,
                            ) ,
                          ) ,
                        ) ,
                      ] ,
                    ) ,
                  ) ,

                  TextHeading (text: "Send Notifications" ,) ,

                  Padding (
                    padding: const EdgeInsets.symmetric(horizontal: 18.0) ,
                    child: Row (
                      children: <Widget>[
                        TwoInRowTextIconButton (
                          text: "Send\nNotification" ,
                          color: Colors.indigo[50] ,
                          iconData: Icons.notifications_paused ,
                          buttonText: "TAKE" ,
                          onButtonPressed: () {
                            Navigator.push (context , MaterialPageRoute (builder: (context) => NotifyManager (
                              identity: "Hello" ,
                            )));
                          } ,
                        ) ,

                        TwoInRowTextIconButton (
                          text: "Leave\nSection" ,
                          color: Colors.teal[50] ,
                          iconData: Icons.free_breakfast ,
                          buttonText: "VIEW" ,
                          onButtonPressed: () {
                            Navigator.push (context , MaterialPageRoute (builder: (context) => DemandLeave ()));
                          } ,
                        ) ,
                      ] ,
                    ) ,
                  ) ,

                  TextHeading (text: "Help us Improve" ,) ,

                  GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => EmployeeReviewPage()));
                    },
                    child: Hero(
                      tag: "review",
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        child: Card(
                          margin: EdgeInsets.symmetric(horizontal: 15.0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10.0)),
                              side: BorderSide(width: 1.0, color: Colors.white, style: BorderStyle.solid)
                          ),
                          color: kLightBlue,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 15.0),
                            child: Text(
                              "Add a Review ?",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                  letterSpacing: 1.0
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),


                  SizedBox (
                    height: 15.0 ,
                  )
                ] ,
              ) ,
            ) ,
          ),
        ),
      );
    }

    Widget _sideDrawer() {
      return SafeArea (
        child: Stack (
          children: [
            Container (
              color: kLightBlue ,
            ) ,
            Column (
              mainAxisAlignment: MainAxisAlignment.spaceBetween ,
              crossAxisAlignment: CrossAxisAlignment.start ,
              children: [
                Column (
                  crossAxisAlignment: CrossAxisAlignment.start ,
                  children: [
                    Container (
                      width: MediaQuery.of (context).size.width - 90 ,
                      padding: EdgeInsets.symmetric (horizontal: 20.0) ,
                      child: Column (
                        crossAxisAlignment: CrossAxisAlignment.start ,
                        children: [
                          SizedBox (height: 15.0 ,) ,
                          Row (
                            children: [
                              Image (
                                image: AssetImage ("assets/profile.png") ,
                                height: 40.0 ,
                              ) ,
                              SizedBox (width: 15.0 ,) ,
                              Text (
                                "SCUPE" ,
                                style: TextStyle (
                                    color: Colors.white ,
                                    fontWeight: FontWeight.w100 ,
                                    letterSpacing: 1.5 ,
                                    fontFamily: "Dark" ,
                                    fontSize: 27.0
                                ) ,
                              ) ,
                            ] ,
                          ) ,
                          SizedBox (height: 10.0 ,) ,
                          Text (
                            "Total Employee: 15.0" ,
                            style: TextStyle (
                                color: Colors.white ,
                                fontSize: 16.5 ,
                                letterSpacing: 0.5
                            ) ,
                          ) ,
                          Padding (
                            padding: const EdgeInsets.symmetric(vertical: 10.0) ,
                            child: Divider (
                              height: 1.5 ,
                              color: Colors.white ,
                            ) ,
                          ) ,
                        ] ,
                      ) ,
                    ) ,

                    SingleChildScrollView (
                      child: Column (
                        children: [

                          ListTile (
                              leading: Container (
                                  height: 38.0 ,
                                  width: 38.0 ,
                                  padding: const EdgeInsets.all(8) ,
                                  decoration: BoxDecoration (
                                      borderRadius:
                                      BorderRadius.all (const Radius.circular(100.0)) ,
                                      color: Colors.white
                                  ) ,
                                  child: Icon (
                                    Icons.star ,
                                    color: kLightBlue ,
                                    size: 20 ,
                                  )) ,
                              title: Text (
                                'Change Password' ,
                                style: TextStyle (
                                  color: Colors.white ,
                                  fontSize: 18.0 ,
                                  fontWeight: FontWeight.w500 ,
                                  letterSpacing: 1.0 ,
                                ) ,
                              ) ,
                              onTap: () async {
                                Navigator.push (context , MaterialPageRoute (builder: (context) => ChangePassword ()));
                                toggle ();
                              }
                          ) ,

                          ListTile (
                              leading: Container (
                                  height: 38.0 ,
                                  width: 38.0 ,
                                  padding: const EdgeInsets.all(8) ,
                                  decoration: BoxDecoration (
                                      borderRadius:
                                      BorderRadius.all (Radius.circular(100.0)) ,
                                      color: Colors.white
                                  ) ,
                                  child: Icon (
                                    Icons.phone_android ,
                                    color: kLightBlue ,
                                    size: 20 ,
                                  )) ,
                              title: Text (
                                'Contact Us' ,
                                style: TextStyle (
                                  color: Colors.white ,
                                  fontSize: 18.0 ,
                                  fontWeight: FontWeight.w500 ,
                                  letterSpacing: 1.0 ,
                                ) ,
                              ) ,
                              onTap: () async {
                                String url = "";
                                if (await canLaunch (url)) {
                                  await launch (url);
                                }
                                toggle ();
                              }
                          ) ,

                          ListTile (
                              leading: Container (
                                  height: 38.0 ,
                                  width: 38.0 ,
                                  padding: const EdgeInsets.all(8) ,
                                  decoration: BoxDecoration (
                                      borderRadius:
                                      BorderRadius.all (Radius.circular(100.0)) ,
                                      color: Colors.white
                                  ) ,
                                  child: Icon (
                                    Icons.work ,
                                    color: kLightBlue ,
                                    size: 20 ,
                                  )) ,
                              title: Text (
                                'Add Report ' ,
                                style: TextStyle (
                                  color: Colors.white ,
                                  fontSize: 18.0 ,
                                  fontWeight: FontWeight.w500 ,
                                  letterSpacing: 1.0 ,
                                ) ,
                              ) ,
                              onTap: () async {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => AddReport()));
                                toggle ();
                              }
                          ) ,

                          ListTile (
                              leading: Container (
                                  height: 38.0 ,
                                  width: 38.0 ,
                                  padding: const EdgeInsets.all(8) ,
                                  decoration: BoxDecoration (
                                      borderRadius:
                                      BorderRadius.all (const Radius.circular(100.0)) ,
                                      color: Colors.white
                                  ) ,
                                  child: Icon (
                                    Icons.power_settings_new ,
                                    color: kLightBlue ,
                                    size: 20 ,
                                  )) ,
                              title: Text (
                                'Sign Out' ,
                                style: TextStyle (
                                  color: Colors.white ,
                                  fontSize: 18.0 ,
                                  fontWeight: FontWeight.w500 ,
                                  letterSpacing: 1.0 ,
                                ) ,
                              ) ,
                              onTap: () async {
                                await _signOut ();
                                toggle ();
                              }
                          ) ,

                        ] ,
                      ) ,
                    ) ,
                  ] ,
                ) ,

                Padding (
                  padding: const EdgeInsets.only(top: 10.0 , bottom: 10.0 , left: 10.0) ,
                  child: Column (
                    crossAxisAlignment: CrossAxisAlignment.start ,
                    children: [
                      Padding (
                        padding: const EdgeInsets.only(right: 110.0) ,
                        child: Divider (
                          height: 1.5 ,
                          color: Colors.white ,
                        ) ,
                      ) ,
                      GestureDetector (
                        onTap: () async {
                          String url = "https://rushidonga.github.io/RushiDonga/";
                          if (await canLaunch (url)) {
                            await launch (url);
                          }
                        } ,
                        child: Row (
                          children: [
                            Text (
                              "With ♥ by: " ,
                              style: TextStyle (
                                  color: Colors.white ,
                                  fontSize: 16.0
                              ) ,
                            ) ,
                            Text (
                              "Rushi Donga" ,
                              style: TextStyle (
                                  color: Colors.white ,
                                  fontSize: 16.0 ,
                                  fontWeight: FontWeight.bold ,
                                  letterSpacing: 1.0
                              ) ,
                            ) ,
                          ] ,
                        ) ,
                      )
                    ] ,
                  ) ,
                )

              ] ,
            ) ,
          ] ,
        ) ,
      );
    }

    return AnimatedBuilder (
        animation: _animationController ,
        builder: (context , _) {
          double slide = maxSlide * _animationController.value;
          double scale = 1 - (_animationController.value * 0.1);
          return Stack (
            children: [
              _sideDrawer () ,

              Transform (
                transform: Matrix4.identity ()
                  ..translate (slide)
                  ..scale (scale) ,
                alignment: Alignment.centerRight ,
                child: _mainBody () ,
              )
            ] ,
          );
        }
    );
  }
}