import 'package:employee/CEO/Add_Employee/add_employee.dart';
import 'package:employee/CEO/Todo_And_Reminder/Employee_Review_Page.dart';
import 'package:employee/Report/SelectReport.dart';
import '../../Leave/ceo_manageLeaves.dart';
import 'package:employee/CEO/NotifyEmployee.dart';
import 'package:employee/CEO/Salary/EmployeeListForSalary.dart';
import 'package:employee/CommonWidgets/text_heading.dart';
import 'package:employee/LoginOrSignUp/login_or_signup_page.dart';
import 'package:employee/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../GetDetails/user_id.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../ChangePasswordEmail.dart';
import '../../Employee/Attendance/ManageAttendance.dart';
import '../edit_ceo_details.dart';
import '../Todo_And_Reminder/add_todo.dart';
import '../Todo_And_Reminder/todo_list.dart';
import '../My_Employee/employee_list.dart';
import '../../CommonWidgets/cards_three_in_row.dart';
import '../CommonMethods//go_to_url.dart';
import '../../CommonWidgets/two_in_row_text_button.dart';
import '../../CommonWidgets/two_in_rows_text_icon_button.dart';
import '../../Teams/create_teams.dart';
import '../../Teams/view_teams_ceo.dart';
import '../../Globals.dart' as globals;
import '../../Employee/Attendance/ViewAttendanceEmployee.dart';

final fireStore = Firestore.instance;

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {

  final double maxSlide = 225.0;

  AnimationController _animationController;

  CommonMethods _commonMethods = new CommonMethods();
  String _description = "";
  String _facebook = "";
  String _instagram = "";
  String _twitter = "";
  String _website = "";
  String totalEmployee = "";
  GetUserID getUserID = new GetUserID();

  int _todoNumber = 0;

  FirebaseAuth _auth = FirebaseAuth.instance;

  _signOut() async {
    await _auth.signOut().then((value) async {
      var prefs = await SharedPreferences.getInstance();
      prefs.setBool('LoggedIn', false);
      prefs.setString('Identity', '');
      prefs.setString('userId', '');
      prefs.setString('emailUID', '');
      prefs.setString('password', '');
      prefs.setString('email', '');

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginOrSignUpPage()));
    }).catchError((onError){
      Toast.show("Error Signing Out", context);
    });
  }

  void toggle(){
    _animationController.isDismissed
        ? _animationController.forward()
        : _animationController.reverse();
  }

  _getTotalEmployee()async {
    await fireStore.collection(globals.companyName).document("Employee").get().then((value){
      setState(() {
        totalEmployee = value.data["TotalEmployee"].toString();
      });
    });
  }

  _getNumber(){
    // Get Todos Number
    fireStore.collection(globals.companyName).document("CEO TODOs").collection("Todo").getDocuments().then((value){
      setState(() {
        _todoNumber = value.documents.length;
      });
    });
  }

  _getCompanyDetails() {
    fireStore.collection(globals.companyName).document("CompanyDetails").get().then((value){
      setState(() {
        globals.companyName = value.data["CompanyName"];
        _description = value.data["Description"];
        _facebook = value.data["facebook"];
        _instagram = value.data["Instagram"];
        _twitter = value.data["Twitter"];
        _website = value.data["CompanyWebsite"];
      });
    });
  }

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 250)
    );

    _getNumber();
    _getTotalEmployee();
    _getCompanyDetails();
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

    Widget _mainBody(){
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
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                            flex: 1,
                            child: GestureDetector(
                              onTap: (){
                                toggle();
                              },
                              child: Icon(
                                Icons.settings,
                                color: kLightBlue,
                                size: 30.0,
                              ),
                            )
                        ),
                        Expanded(
                          flex: 4,
                          child: Text(
                            "${globals.companyName}",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 20.0,
                                letterSpacing: 1.5
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: IconButton(
                            onPressed: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => EditCEODetails()));
                            },
                            icon: FaIcon(FontAwesomeIcons.edit),
                            color: kLightBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Card(
                      color: Color(0XFFF7F2F9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          SizedBox(
                            height: 10.0,
                          ),
                          Stack(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(top: 45.0, left: 10.0, right: 10.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: kLightBlue,
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Column(
                                    children: <Widget>[
                                      SizedBox(
                                        height: 60.0,
                                      ),
                                      Center(
                                        child: Text(
                                          "${globals.userName}",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20.0
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 8.0,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                                        child: Text(
                                          _description,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18.0
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: <Widget>[
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(30.0),
                                              ),
                                              child: IconButton(
                                                onPressed: (){
                                                  _commonMethods.launchURL(_facebook);
                                                },
                                                icon: FaIcon(FontAwesomeIcons.facebook),
                                                color: kLightBlue,
                                              ),
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(30.0),
                                              ),
                                              child: IconButton(
                                                onPressed: (){
                                                  _commonMethods.launchURL(_instagram);
                                                },
                                                icon: FaIcon(FontAwesomeIcons.instagram),
                                                color: kLightBlue,
                                              ),
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(30.0),
                                              ),
                                              child: IconButton(
                                                onPressed: (){
                                                  _commonMethods.launchURL(_twitter);
                                                },
                                                icon: FaIcon(FontAwesomeIcons.twitter),
                                                color: kLightBlue,
                                              ),
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(30.0),
                                              ),
                                              child: IconButton(
                                                onPressed: (){
                                                  _commonMethods.launchURL(_website);
                                                },
                                                icon: FaIcon(FontAwesomeIcons.link),
                                                color: kLightBlue,
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: Image(
                                  height: 100.0,
                                  image: AssetImage("assets/profile.png"),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10.0,
                          )
                        ],
                      ),
                    ),
                  ),
                  TextHeading(text: "Employee & Salary",),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: GestureDetector(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => EmployeeList()));
                            },
                            child: ProfileThreeInRow(
                              iconData: Icon(
                                Icons.account_circle,
                                color: Colors.black.withOpacity(0.7),
                                size: 28.0,
                              ),
                              text: "my \nemployee",
                              color: Color(0XFFFAECEE),
                            ),
                          ),
                        ),

                        Expanded(
                          child: GestureDetector(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => AddEmployee()));
                            },
                            child: ProfileThreeInRow(
                              iconData: Icon(
                                Icons.add_comment,
                                color: Colors.black.withOpacity(0.7),
                                size: 28.0,
                              ),
                              text: "add \nemployee",
                              color: Color(0XFFE2F1FE),
                            ),
                          ),
                        ),

                        Expanded(
                          child: GestureDetector(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => EmployeeSalaryList()));
                            },
                            child: ProfileThreeInRow(
                              iconData: Icon(
                                Icons.monetization_on,
                                color: Colors.black.withOpacity(0.7),
                                size: 28.0,
                              ) ,
                              text: "salary \ndetails's",
                              color: Color(0XFFE2F1FE),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextHeading(text: "Manage Teams",),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      children: <Widget>[
                        TwoInRowTextButton(
                          text: "Create Team",
                          buttonText: "MAKE",
                          color: Colors.indigo[50],
                          onButtonPressed: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => CreateTeam(
                              enable: true,
                              showMoreOptions: true,
                            )));
                          },
                        ),
                        TwoInRowTextButton(
                          text: "View Teams",
                          buttonText: "VIEW",
                          color: Colors.cyan[50],
                          onButtonPressed: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ViewTeamsCEO()));
                          },
                        )
                      ],
                    ),
                  ),
                  TextHeading(text: "Attendance",),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      children: <Widget>[
                        TwoInRowTextIconButton(
                          text: "View \nAttendance",
                          buttonText: "VIEW",
                          onButtonPressed: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ViewAttendanceEmployee(
                              ceo: true,
                            )));
                          },
                          color: Colors.teal[50],
                          iconData: Icons.attach_file,
                        ),
                        TwoInRowTextIconButton(
                          text: "Notify \nEmployee",
                          buttonText: "NOTIFY",
                          onButtonPressed: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => NotifyEmployee()));
                          },
                          color: Colors.blue[50],
                          iconData: Icons.notifications_active,
                        )
                      ],
                    ),
                  ),

                  TextHeading(text: "Others",),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Card(
                            color: Color(0XFFA4AAEE),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(
                                    "TODO's",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17.0
                                    ),
                                  ),
                                ),
                                Card(
                                  color: Colors.white,
                                  margin: EdgeInsets.all(0.0),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0)
                                  ),
                                  child: Column(
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: <Widget>[
                                          Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
                                            child: Text(
                                              "$_todoNumber todo \navailable",
                                              style: TextStyle(
                                                  color: Color(0XFFA4AAEE),
                                                  fontSize: 15.0,
                                                  fontWeight: FontWeight.bold
                                              ),
                                            ),
                                          ),
                                          Padding(
                                              padding: EdgeInsets.symmetric(vertical: 5.0),
                                              child: IconButton(
                                                onPressed: (){
                                                  Navigator.push(context, MaterialPageRoute(builder: (context) => TodoList()));
                                                },
                                                icon: FaIcon(FontAwesomeIcons.tasks),
                                                color: kLightBlue,
                                              )
                                          )
                                        ],
                                      ),
                                      RaisedButton(
                                        onPressed: (){
                                          Navigator.push(context, MaterialPageRoute(builder: (context) =>Todo(
                                            state: "NEW",
                                          )));
                                        },
                                        color: Color(0XFFA4AAEE),
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10.0),
                                            side: BorderSide(color: Colors.white, width: 1.0)
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 30.0),
                                          child: Text(
                                            "ADD",
                                            style: TextStyle(
                                                color: Colors.white
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Card(
                            color: kLightBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(
                                    "REVIEW",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17.0
                                    ),
                                  ),
                                ),
                                Card(
                                  color: Colors.white,
                                  margin: EdgeInsets.all(0.0),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0)
                                  ),
                                  child: Column(
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: <Widget>[
                                          Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
                                            child: Text(
                                              "Help us\nImprove",
                                              style: TextStyle(
                                                  color: kLightBlue,
                                                  fontSize: 15.0,
                                                  fontWeight: FontWeight.bold
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(vertical: 10.0),
                                            child: Icon(
                                              Icons.help_outline,
                                              color: kLightBlue,
                                              size: 35.0,
                                            ),
                                          )
                                        ],
                                      ),
                                      RaisedButton(
                                        onPressed: (){
                                          Navigator.push(context, MaterialPageRoute(builder: (context) => EmployeeReviewPage()));
                                        },
                                        color: kLightBlue,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10.0),
                                            side: BorderSide(color: Colors.white, width: 1.0)
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 30.0),
                                          child: Text(
                                            "HELP",
                                            style: TextStyle(
                                                color: Colors.white
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  )
                ],
              ),
            ),
          ),
        )
      );
    }

    Widget _sideDrawer(){
      return SafeArea(
        child: Stack(
          children: [
            Container(
              color: kLightBlue,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width-90,
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 15.0,),
                          Row(
                            children: [
                              Image(
                                image: AssetImage("assets/profile.png"),
                                height: 40.0,
                              ),
                              SizedBox(width: 15.0,),
                              Text(
                                "SCUPE",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w100,
                                  letterSpacing: 1.5,
                                  fontFamily: "Dark",
                                  fontSize: 27.0
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10.0,),
                          Text(
                            "Total Employee: $totalEmployee",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.5,
                              letterSpacing: 0.5
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Divider(
                              height: 1.5,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SingleChildScrollView(
                      child: Column(
                        children: [

                          ListTile(
                              leading: Container(
                                  height: 38.0,
                                  width: 38.0,
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                      borderRadius:
                                      BorderRadius.all(const Radius.circular(100.0)),
                                      color: Colors.white
                                  ),
                                  child: Icon(
                                    Icons.how_to_vote,
                                    color: kLightBlue,
                                    size: 20,
                                  )),
                              title: Text(
                                'Attendance',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context) => ManageAttendance()));
                                toggle();
                              }
                          ),

                          ListTile(
                              leading: Container(
                                  height: 38.0,
                                  width: 38.0,
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                      borderRadius:
                                      BorderRadius.all(const Radius.circular(100.0)),
                                      color: Colors.white
                                  ),
                                  child: Icon(
                                    Icons.star,
                                    color: kLightBlue,
                                    size: 20,
                                  )),
                              title: Text(
                                'Change Password',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              onTap: () async {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => ChangePassword()));
                                toggle();
                              }
                          ),

                          ListTile(
                              leading: Container(
                                  height: 38.0,
                                  width: 38.0,
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                      borderRadius:
                                      BorderRadius.all(const Radius.circular(100.0)),
                                      color: Colors.white
                                  ),
                                  child: Icon(
                                    Icons.phone_android,
                                    color: kLightBlue,
                                    size: 20,
                                  )),
                              title: Text(
                                'Contact Us',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              onTap: () async {
                                String url = "";
                                if(await canLaunch(url)){
                                  await launch(url);
                                }
                                toggle();
                              }
                          ),

                          ListTile(
                              leading: Container(
                                  height: 38.0,
                                  width: 38.0,
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                      borderRadius:
                                      BorderRadius.all(const Radius.circular(100.0)),
                                      color: Colors.white
                                  ),
                                  child: Icon(
                                    Icons.leave_bags_at_home,
                                    color: kLightBlue,
                                    size: 20,
                                  )),
                              title: Text(
                                'Manage Leaves',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context) => CEOManageLeaves()));
                                toggle();
                              }
                          ),

                          ListTile(
                              leading: Container(
                                  height: 38.0,
                                  width: 38.0,
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                      borderRadius:
                                      BorderRadius.all(const Radius.circular(100.0)),
                                      color: Colors.white
                                  ),
                                  child: Icon(
                                    Icons.report_gmailerrorred_sharp,
                                    color: kLightBlue,
                                    size: 20,
                                  )),
                              title: Text(
                                'Report',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => SelectReport()));
                                toggle();
                              }
                          ),

                          ListTile(
                              leading: Container(
                                  height: 38.0,
                                  width: 38.0,
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                      borderRadius:
                                      BorderRadius.all(const Radius.circular(100.0)),
                                      color: Colors.white
                                  ),
                                  child: Icon(
                                    Icons.power_settings_new,
                                    color: kLightBlue,
                                    size: 20,
                                  )),
                              title: Text(
                                'Sign Out',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              onTap: ()async {
                                await _signOut();
                                toggle();
                              }
                          ),

                        ],
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 14.0, left: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 110.0),
                        child: Divider(
                          height: 1.5,
                          color: Colors.white,
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          String url = "https://rushidonga.github.io/RushiDonga/";
                          if(await canLaunch(url)){
                            await launch(url);
                          }
                        },
                        child: Row(
                          children: [
                            Text(
                              "With ♥ by: ",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.0
                              ),
                            ),
                            Text(
                              "Rushi Donga",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                )

              ],
            ),
          ],
        ),
      );
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, _){
        double slide = maxSlide * _animationController.value;
        double scale = 1 - (_animationController.value*0.1);
        return Stack(
          children: [
            _sideDrawer(),

            Transform(
              transform: Matrix4.identity()
                ..translate(slide)
                ..scale(scale),
              alignment: Alignment.centerRight,
              child: _mainBody(),
            )
          ],
        );
      },
    );
  }
}
