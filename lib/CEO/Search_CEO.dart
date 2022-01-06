import 'package:employee/Employee/Attendance/ManageAttendance.dart';
import 'package:employee/Employee/Attendance/TodayAttendance.dart';
import 'package:employee/Employee/Attendance/ViewAttendanceEmployee.dart';
import 'package:employee/Leave/ceo_manageLeaves.dart';
import 'package:employee/Leave/viewLeaveCEO.dart';
import 'package:employee/LoginOrSignUp/login_or_signup_page.dart';
import 'package:employee/Teams/create_teams.dart';
import 'package:employee/Teams/view_teams_ceo.dart';
import 'package:employee/Work/EmployeeList_to_assign_work.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'Add_Employee/add_employee.dart';
import 'ChangePasswordEmail.dart';
import 'My_Employee/employee_list.dart';
import 'NotifyEmployee.dart';
import 'Salary/EmployeeListForSalary.dart';
import 'Todo_And_Reminder/add_todo.dart';
import 'Todo_And_Reminder/todo_list.dart';
import 'edit_ceo_details.dart';

class SearchManager extends StatefulWidget {
  @override
  _SearchManagerState createState() => _SearchManagerState();
}

class _SearchManagerState extends State<SearchManager> {

  TextEditingController _controller = TextEditingController();

  FirebaseAuth _auth = FirebaseAuth.instance;

  bool _displaySearchHistory = true;

  List<String> _searchedList = [];
  List<String> _history = [];

  List<String> _searchThing = [
    'Take Attendance',
    'Today Attendance',
    'Assign Work',
    'Leave Applications',
    'Employees',
    'Add Employees',
    'Salary Details',
    'Create Teams',
    'View Teams',
    'View Attendance',
    'Notify Employee',
    'Add Todo',
    'View Todo'
    'Change Password',
    'Contact Us',
    'Manage Attendance',
    'Manage Leaves',
    'Sign Out',
    'Profile',
  ];

  _navigate(String data){

    if(data == "Take Attendance"){
      Navigator.pop(context);
    }else if(data == "Today Attendance"){
      Navigator.push(context, MaterialPageRoute(builder: (context) => TodayAttendance()));
    }else if(data == "Assign Work"){
      Navigator.push(context, MaterialPageRoute(builder: (context) => EmployeeListAssignWork()));
    }else if(data == "Leave Applications"){
      Navigator.push(context, MaterialPageRoute(builder: (context) => ViewLeavesCEO()));
    }else if(data == "Employees"){
      Navigator.push(context, MaterialPageRoute(builder: (context) => EmployeeList()));
    }else if(data == "Add Employees"){
      Navigator.push(context, MaterialPageRoute(builder: (context) => AddEmployee()));
    }else if(data == "Salary Details"){
      Navigator.push(context, MaterialPageRoute(builder: (context) => EmployeeSalaryList()));
    }else if(data == "Create Teams"){
      Navigator.push(context, MaterialPageRoute(builder: (context) => CreateTeam(
        enable: true,
        showMoreOptions: true,
      )));
    }else if(data == "View Teams"){
      Navigator.push(context, MaterialPageRoute(builder: (context) => ViewTeamsCEO()));
    }else if(data == "Notify Employee"){
      Navigator.push(context, MaterialPageRoute(builder: (context) => NotifyEmployee()));
    }else if(data == "View Attendance"){
      Navigator.push(context, MaterialPageRoute(builder: (context) => ViewAttendanceEmployee(
        ceo: true,
      )));
    }else if(data == "Add Todo"){
      Navigator.push(context, MaterialPageRoute(builder: (context) =>Todo(
        state: "NEW",
      )));
    }else if(data == "View Todo"){
      Navigator.push(context, MaterialPageRoute(builder: (context) => TodoList()));
    }else if(data == "Change Password"){
      Navigator.push(context, MaterialPageRoute(builder: (context) => ChangePassword()));
    }else if(data == "Manage Attendance"){
      Navigator.push(context, MaterialPageRoute(builder: (context) => ManageAttendance()));
    }else if(data == "Manage Leaves"){
      Navigator.push(context, MaterialPageRoute(builder: (context) => CEOManageLeaves()));
    }else if(data == "Sign Out"){
      _signOut();
    }else if(data == "Profile"){
      Navigator.push(context, MaterialPageRoute(builder: (context) => EditCEODetails()));
    }
  }

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

    _history = _prefs.getStringList('searchHistory');
    if(!_history.contains(data)){
      _history.add(data);
      await _prefs.setStringList('searchHistory', _history);
    }
  }

  _getSearchHistory() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    if(_prefs.getStringList('searchHistory') == null){
      await _prefs.setStringList('searchHistory', []);
    }else{
      setState(() {
        _history.addAll(_prefs.getStringList('searchHistory').reversed.toList());
      });
    }
    print(_history);
  }

  _deleteHistory(String data) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    setState(() {
      _history.remove(data);
      _prefs.setStringList('searchHistory', _history);
    });
  }

  @override
  void initState() {
    super.initState();
    _getSearchHistory();

    _controller.addListener(() { });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
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
                return Container(
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
      )
    );
  }
}
