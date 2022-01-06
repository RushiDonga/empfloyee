import 'package:employee/CEO/ChangePasswordEmail.dart';
import 'package:employee/CEO/Salary/DisplayEmployeeSalaryDetails.dart';
import 'package:employee/Leave/demandLeave.dart';
import 'package:employee/LoginOrSignUp/login_or_signup_page.dart';
import 'package:employee/Teams/view_teams_ceo.dart';
import 'package:employee/Work/EmployeeViewWork.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:employee/Globals.dart' as globals;
import 'Attendance/TodayAttendance.dart';
import 'Attendance/ViewAttendanceEmployee.dart';
import 'NotifyManager.dart';
import 'edit_employee_details.dart';

class SearchEmployee extends StatefulWidget {
  @override
  _SearchEmployeeState createState() => _SearchEmployeeState();
}

class _SearchEmployeeState extends State<SearchEmployee> {

  TextEditingController _controller = TextEditingController();

  FirebaseAuth _auth = FirebaseAuth.instance;

  bool _displaySearchHistory = true;

  List<String> _searchedList = [];
  List<String> _history = [];

  List<String> _searchThing = [
    'Fill Attendance',
    'Today Attendance',
    'View Work',
    'View Attendance',
    'Salary Details',
    'Send Notification',
    'Leave Section',
    'Work',
    'Teams',
    'Change Password',
    'Contact Us',
    'Sign Out',
    'Profile',
  ];

  _navigate(String data){
    if(data == "Fill Attendance"){
      Navigator.pop(context);
    }else if(data == "Today Attendance"){
      Navigator.push(context, MaterialPageRoute(builder: (context) => TodayAttendance()));
    }else if(data == "View Work"){
      Navigator.push(context, MaterialPageRoute(builder: (context) => EmployeeViewWork()));
    }else if(data == "View Attendance"){
      Navigator.push (context , MaterialPageRoute (builder: (context) => ViewAttendanceEmployee (
        ceo: false ,
      )));
    }else if(data == "Salary Details"){
      Navigator.push(context, MaterialPageRoute(builder: (context) => DisplayEmployeeSalaryDetails(
        employeeName: globals.userName,
      )));
    }else if(data == "Send Notification"){
      Navigator.push (context , MaterialPageRoute (builder: (context) => NotifyManager (
        identity: "Hello" ,
      )));
    }else if(data == "Leave Section"){
      Navigator.push (context , MaterialPageRoute (builder: (context) => DemandLeave ()));
    }else if(data == "Work"){
      Navigator.push (context , MaterialPageRoute (builder: (context) => EmployeeViewWork ()));
    }else if(data == "Teams"){
      Navigator.push (context , MaterialPageRoute (builder: (context) => ViewTeamsCEO ()));
    }else if(data == "Change Password"){
      Navigator.push (context , MaterialPageRoute (builder: (context) => ChangePassword ()));
    }else if(data == "Contact Us"){

    }else if(data == "Sign Out"){
      _signOut();
    }else if(data == "Profile"){
      Navigator.push (context , MaterialPageRoute (builder: (context) => EditEmployeeDetailsForEmployee ()));
    }
  }

  _signOut() async {
    await _auth.signOut ().then ((value) async {
      var prefs = await SharedPreferences.getInstance ();
      prefs.setBool ('LoggedIn' , false);
      prefs.setString ('Identity' , '');
      prefs.setString ('userId' , '');
      prefs.setString ('emailUID' , '');
      prefs.setString ('password' , '');
      prefs.setString ('email' , '');

      Navigator.pushReplacement (context ,
          MaterialPageRoute (builder: (context) => LoginOrSignUpPage ()));
    }).catchError ((onError) {
      Toast.show ("Error Signing Out" , context);
    });
  }

  _addSearchItem(String search){
    setState(() {
      _searchedList.clear();
      print(search);
    });
    for(int i=0; i<_searchThing.length; i++){
      if(_searchThing[i].toLowerCase().contains(search.toLowerCase())){
        setState(() {
          _searchedList.add(_searchThing[i]);
        });
      }
    }
    print(_searchedList);
  }

  _saveHistory(String data) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();

    _history = _prefs.getStringList('employeeSearch');
    if(_history.contains(data)){
      _history.remove(data);
      _history.add(data);
      await _prefs.setStringList('employeeSearch', _history);
    }else{
      _history.add(data);
      await _prefs.setStringList('employeeSearch', _history);
    }
  }

  _getSearchHistory() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    if(_prefs.getStringList('employeeSearch') == null){
      await _prefs.setStringList('employeeSearch', []);
    }else{
      setState(() {
        _history.addAll(_prefs.getStringList('employeeSearch').reversed.toList());
      });
    }
    print(_history);
  }

  _deleteHistory(String data) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    setState(() {
      _history.remove(data);
      _prefs.setStringList('searchHiemployeeSearchstory', _history);
    });
  }

  @override
  void initState() {
    super.initState();
    _getSearchHistory();
  }

  @override
  Widget build(BuildContext context) {

    Widget _appBar(){
      return Hero(
        tag: "search",
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
          child: Container(
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0))
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    GestureDetector(
                      onTap: (){
                        Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                        size: 25.0,
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width-90.0,
                      child: TextField(
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        controller: _controller,
                        onChanged: (value){
                          setState(() {
                            if(value == ""){
                              setState(() {
                                _displaySearchHistory = true;
                              });
                            }else{
                              setState(() {
                                _displaySearchHistory = false;
                              });
                            }
                            _addSearchItem(value);
                          });
                        },
                        decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide.none
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide.none
                            ),
                            hintText: "Search here",
                            hintStyle: TextStyle(
                                color: Colors.grey[700]
                            )
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: (){
                        setState(() {
                          _controller.clear();
                          _displaySearchHistory = true;
                        });
                      },
                      child: Icon(
                        Icons.cancel,
                        color: Colors.grey[900],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    Widget _displaySearchItem(){
      return Expanded(
        child: ListView.builder(
            physics: AlwaysScrollableScrollPhysics(),
            itemCount: _searchedList.length,
            itemBuilder: (context, index){
              return GestureDetector(
                onTap: (){
                  _saveHistory(_searchedList[index]);
                  _navigate(_searchedList[index]);
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 7.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.search,
                            size: 30.0,
                          ),
                          SizedBox(width: 15.0,),
                          Text(
                            _searchedList[index],
                            style: TextStyle(
                                color: Colors.grey[900],
                                fontSize: 16.0
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 40.0, top: 5.0),
                        child: Divider(
                          height: 1.0,
                          color: Colors.grey[300],
                        ),
                      )
                    ],
                  ),
                ),
              );
            }
        ),
      );
    }

    Widget _displayHistory(){
      return Expanded(
          child: ListView.builder(
              physics: AlwaysScrollableScrollPhysics(),
              itemCount: _history.length,
              itemBuilder: (context, index){
                return GestureDetector(
                  onTap: (){
                    _navigate(_history[index]);
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 7.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.search,
                                  size: 30.0,
                                ),
                                SizedBox(width: 15.0,),
                                Text(
                                  _history[index],
                                  style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 16.0
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: (){
                                _deleteHistory(_history[index]);
                              },
                              child: Icon(
                                Icons.delete_outline,
                                color: Colors.grey[900],
                                size: 25.0,
                              ),
                            )
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 40.0, top: 5.0),
                          child: Divider(
                            height: 1.0,
                            color: Colors.grey[300],
                          ),
                        )
                      ],
                    ),
                  ),
                );
              }
          )
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _appBar(),

            _displaySearchHistory
                ? _displayHistory()
                : _displaySearchItem(),
          ],
        ),
      ),
    );
  }
}
