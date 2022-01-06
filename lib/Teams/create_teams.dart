import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:employee/CommonWidgets/CircularLoadingIndicator.dart';
import 'package:employee/Teams/info_page.dart';
import 'package:employee/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:toast/toast.dart';
import '../Globals.dart' as globals;

Firestore _fireStore = Firestore.instance;

class CreateTeam extends StatefulWidget {
  @override
  _CreateTeamState createState() => _CreateTeamState();

  CreateTeam({this.selectedMembers, @required this.enable, this.teamTag,@required this.showMoreOptions});
  final List<dynamic> selectedMembers;
  final String teamTag;
  final bool enable;
  final bool showMoreOptions;
}

class _CreateTeamState extends State<CreateTeam> {

  List<Card> _displaySelectedEmployeeNameWidget = [];
  List<Padding> _displayEmployeeNameWidget = [];
  List<dynamic> _selectedEmployeeList = [];
  List<String> _totalEmployeeList = [];

  String _tag = "";
  String _description = "";
  bool isThereTag = true;
  bool showMoreDetails = false;
  bool isLoading = true;

  DateTime startDate;
  DateTime endDate;

  TextEditingController _teamTagEditingController;

  // Drop down menu
  String selectedPriority;
  static const menuItems = <String>[
    'Low',
    'Medium',
    'High',
  ];

  final List<DropdownMenuItem<String>> _dropDownMenuItems = menuItems.map(
        (String value) => DropdownMenuItem<String>(
          value: value,
          child: Text(value),
    ),
  ).toList();



  _getEmployeeName(){
    final fireStoreData =  _fireStore.collection(globals.companyName).document("Employee").collection("employee").orderBy("Name");
    fireStoreData.getDocuments().then((value){
      value.documents.forEach((element) {
        _totalEmployeeList.add(element.data["Name"]);
        _displayEmployeeName(element.data["Name"]);
      });
    }).then((value){
      setState(() {
        isLoading = false;
      });
    });
  }

  _displayEmployeeName(String name){
    setState(() {
      _displayEmployeeNameWidget.add(
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 1.0),
            child: Card(
              margin: EdgeInsets.all(0.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.person,
                          color: Colors.grey[800],
                          size: 23.0,
                        ),
                        SizedBox(
                          width: 8.0,
                        ),
                        Text(
                          name,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18.0,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 30.0,
                      child: RaisedButton(
                        onPressed: (){
                          setState(() {
                            if(!_selectedEmployeeList.contains(name)){
                              _displaySelected(name);
                              _selectedEmployeeList.add(name);
                              // rebuilding all widgets
                              _displayEmployeeNameWidget.clear();
                              for(int i=0; i<_totalEmployeeList.length; i++){
                                _displayEmployeeName(_totalEmployeeList[i]);
                              }
                            }else{
                              _selectedEmployeeList.remove(name);
                              // rebuild all widgets
                              _displaySelectedEmployeeNameWidget.clear();
                              for(int i=0; i<_selectedEmployeeList.length; i++){
                                _displaySelected(_selectedEmployeeList[i]);
                              }
                              _displayEmployeeNameWidget.clear();
                              for(int i=0; i<_totalEmployeeList.length; i++){
                                _displayEmployeeName(_totalEmployeeList[i]);
                              }
                            }
                          });
                        },
                        color: kLightBlue,
                        child: Text(
                            _selectedEmployeeList.contains(name) ? "REMOVE" : "ADD",
                          style: TextStyle(
                            color: Colors.white
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
      );
    });
  }

  _displaySelected(String name){
    setState(() {
      _displaySelectedEmployeeNameWidget.add(
          Card(
            margin: EdgeInsets.symmetric(horizontal: 5.0),
            color: kLightBlue,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
              child: Row(
                children: <Widget>[
                  Text(
                    name,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15.0
                    ),
                  ),
                  SizedBox(
                    width: 15.0,
                  ),
                  GestureDetector(
                    onTap: (){
                      setState(() {
                        _selectedEmployeeList.remove(name);
                        // rebuilding all widgets
                        _displaySelectedEmployeeNameWidget.clear();
                        for(int i=0; i<_selectedEmployeeList.length; i++){
                          _displaySelected(_selectedEmployeeList[i]);
                        }
                        _displayEmployeeNameWidget.clear();
                        for(int i=0; i<_totalEmployeeList.length; i++){
                          _displayEmployeeName(_totalEmployeeList[i]);
                        }
                      });
                    },
                    child: Icon(
                      Icons.remove_circle_outline,
                      color: Colors.white,
                    ),
                  )
                ],
              ),
            ),
          ),
      );
    });
  }

  _checkFields(){
    setState(() {
      isLoading = true;
    });

    _tag == "" ? setState((){isThereTag = false;}) : setState((){isThereTag = true;});
    if(_tag != "" && _selectedEmployeeList.length >= 2 && _description != "" && selectedPriority != null && startDate != null && endDate != null){

      // Check the Start and the End Date { End Date cannot be less than Start Date }
      if(endDate.year > startDate.year){
        _createTeam();
      }else if(endDate.year < startDate.year){
        setState(() {
          isLoading = false;
        });
        Toast.show("Invalid Dates...!", context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      }else{
        if(endDate.month > startDate.month){
          _createTeam();
        }else if(endDate.month < startDate.month){
          isLoading = false;
          Toast.show("Invalid Dates...!", context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        }else{
          if(endDate.day >= startDate.day){
            _createTeam();
          }else{
            setState(() {
              isLoading = false;
            });
            Toast.show("Invalid Dates...!", context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
          }
        }
      }
    }else{
      setState(() {
        isLoading = false;
      });
      Toast.show("Incomplete Details...!", context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
    if(_selectedEmployeeList.length == 0){
      setState(() {
        isLoading = false;
      });
      Toast.show("No Members !", context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }else if(_selectedEmployeeList.length == 1){
      isLoading = false;
      Toast.show("Team can't be of a Single member", context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  _createTeam(){
    _selectedEmployeeList.sort();
    _fireStore.collection(globals.companyName).document("Teams").collection("Teams").document(_tag).setData({
      "Tag": _tag,
      "Members": _selectedEmployeeList,
      "Description": _description,
      "Create Date": DateTime.now().day.toString() + "-" + DateTime.now().month.toString() + "-" + DateTime.now().year.toString(),
      "Start Date": startDate.day.toString() + "-" + startDate.month.toString() + "-" + startDate.year.toString(),
      "End Date": endDate.day.toString() + "-" + endDate.month.toString() + "-" + endDate.year.toString(),
      "Priority": selectedPriority,
      "Done": false,
    }).then((value) async {

      String document = DateTime.now().toString();
      for(int i=0; i<_selectedEmployeeList.length; i++){
        await _fireStore.collection(globals.companyName).document("Employee").collection("employee").document(_selectedEmployeeList[i])
            .collection("Notifications").document(document).setData({
          "Date": DateTime.now().day.toString() + "-" + DateTime.now().month.toString() + "-" + DateTime.now().year.toString(),
          "Time": DateTime.now().hour.toString() + ":" + DateTime.now().minute.toString(),
          "Search": DateTime.now().month.toString() + "-" + DateTime.now().year.toString() ,
          "DocumentName": document,
          "Type": "TeamWork",
          "TeamTag": _tag,
        }).then((value){
          print("UPDATED");
        }).catchError((onError){
          print("ERROR");
        });
      }

      Toast.show("Team created Successfully !", context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      setState(() {
        isLoading = false;
      });
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => InfoPageOfTeams(
        teamTag: _tag,
        selectedEmployee: [],
      )));
    }).catchError((onError){
      setState(() {
        isLoading = false;
      });
      Toast.show("Error creating team !", context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    });
  }

  Widget showMoreWidget(){
    return SingleChildScrollView(
      physics: ScrollPhysics(),

      child: Column(
        children: [
          Card(
            margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            child: TextField(
              minLines: 1,
              maxLines: 4,
              onChanged: (value){
                setState(() {
                  _description = value;
                });
              },
              decoration: InputDecoration(
                  prefixIcon: IconButton(
                    onPressed: (){},
                    icon: FaIcon(FontAwesomeIcons.addressBook),
                    color: kLightBlue,
                  ),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide.none
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide.none
                  ),
                  hintText: isThereTag ? "Add a Description" : "Description required *",
                  hintStyle: TextStyle(
                    color: isThereTag ? Colors.grey[800] : Colors.red,
                  )
              ),
            ),
          ),

          Card(
            margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
              child: Row(
                children: [
                  Icon(
                    Icons.priority_high,
                    color: kLightBlue,
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  Expanded(
                    child: DropdownButton(
                      onChanged: (value){
                        setState(() {
                          selectedPriority = value;
                        });
                      },
                      isExpanded: true,
                      underline: Container(),
                      hint: Text(
                        "Priority",
                      ),
                      value: selectedPriority,
                      items: _dropDownMenuItems,
                    ),
                  ),
                ],
              ),
            )
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: (){
                      showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(DateTime.now().year),
                          lastDate: DateTime(2050),
                          builder: (BuildContext context, Widget child){
                            return Theme(
                              data: ThemeData(
                                primarySwatch: kMaterialColor,
                                primaryColor: Color(0XFFC41A3B),
                                accentColor: Color(0XFFC41A3B),
                              ),
                              child: child,
                            );
                          }
                      ).then((value){
                        setState(() {
                          startDate = value;
                        });
                      });
                    },
                    child: Card(
                      color: kLightBlue,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 7.0),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 10.0,
                            ),
                            Icon(
                              Icons.date_range,
                              color: Colors.white,
                            ),
                            SizedBox(
                              width: 10.0,
                            ),
                            Text(
                              startDate == null ? "Start Date" : startDate.day.toString() + "-" + startDate.month.toString() + "-" + startDate.year.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: (){
                      showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(DateTime.now().year),
                          lastDate: DateTime(2050),
                          builder: (BuildContext context, Widget child){
                            return Theme(
                              data: ThemeData(
                                primarySwatch: kMaterialColor,
                                primaryColor: Color(0XFFC41A3B),
                                accentColor: Color(0XFFC41A3B),
                              ),
                              child: child,
                            );
                          }
                      ).then((value){
                        setState(() {
                          endDate = value;
                          print(endDate);
                        });
                      });
                    },
                    child: Card(
                      color: kLightBlue,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 7.0),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 10.0,
                            ),
                            Icon(
                              Icons.date_range,
                              color: Colors.white,
                            ),
                            SizedBox(
                              width: 10.0,
                            ),
                            Text(
                              endDate == null ? "End Date" : endDate.day.toString() + "-" + endDate.month.toString() + "-" + endDate.year.toString(),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _getEmployeeName();

    widget.enable
        ? print(widget.enable)
        : setState((){
          _selectedEmployeeList = widget.selectedMembers.cast().toList();  // converting dynamic list to string type
    });

    widget.enable
        ? _teamTagEditingController = TextEditingController.fromValue(TextEditingValue(text: ""))
        : _teamTagEditingController = TextEditingController.fromValue(TextEditingValue(text: widget.teamTag));

    // Display in horizontal row if the employees are already selected
    if(!widget.enable){
      for(int i=0; i<_selectedEmployeeList.length; i++){
        _displaySelected(_selectedEmployeeList[i]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? circularProgress()
          : SafeArea(
        child: Stack(
          children: [
            Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        IconButton(
                          icon: FaIcon(FontAwesomeIcons.arrowCircleLeft),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          color: Colors.black,
                        ),
                        SizedBox(
                          width: 10.0,
                        ),
                        Text(
                          "Make a Team",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0
                          ),
                        ),
                        Container(
                          height: 30.0,
                          width: 90.0,
                          margin: EdgeInsets.only(right: 15.0),
                          child: RaisedButton(
                            onPressed: (){
                              widget.enable
                                  ? _checkFields()
                                  : Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => InfoPageOfTeams(
                                teamTag: widget.teamTag,
                                selectedEmployee: _selectedEmployeeList,
                              )));
                            },
                            color: Colors.white,
                            child: Text(
                              widget.enable ? "CREATE" : "ADD",
                              style: TextStyle(
                                  color: Colors.black
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 3.0,
                ),
                Card(
                  margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                  child: TextField(
                    enabled: widget.enable,
                    controller: _teamTagEditingController,
                    onChanged: (value){
                      setState(() {
                        _tag = value;
                      });
                    },
                    decoration: InputDecoration(
                        prefixIcon: IconButton(
                          onPressed: (){},
                          icon: FaIcon(FontAwesomeIcons.tag),
                          color: kLightBlue,
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide.none
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide.none
                        ),
                        hintText: isThereTag ? "Team Tag" : "Team Tag required *",
                        hintStyle: TextStyle(
                          color: isThereTag ? Colors.grey[800] : Colors.red,
                        )
                    ),
                  ),
                ),

                showMoreDetails
                    ? SizedBox()
                    : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _displaySelectedEmployeeNameWidget.reversed.toList(),
                  ),
                ),

                showMoreDetails
                    ? SizedBox()
                    : SizedBox(height: 3.0,),

                showMoreDetails
                    ? showMoreWidget()
                    : Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: _displayEmployeeNameWidget,
                    ),
                  ),
                )

              ],
            ),
            widget.showMoreOptions
                ? Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: MediaQuery.of(context).size.width,
                color: Colors.white,
                margin: EdgeInsets.symmetric(vertical: 8.0),
                padding: EdgeInsets.symmetric(horizontal: 90.0),
                child: RaisedButton(
                  elevation: 7.0,
                  color: kLightBlue,
                  onPressed: (){
                    setState(() {
                      showMoreDetails ? showMoreDetails = false : showMoreDetails = true;
                    });
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 13.0),
                    child: Text(
                      showMoreDetails ? "Show less " : "Show More",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15.0,
                          letterSpacing: 1.0
                      ),
                    ),
                  ),
                ),
              ),
            )
                : SizedBox(),
          ],
        ),
      ),
    );
  }
}
