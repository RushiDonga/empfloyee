import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:employee/CommonWidgets/CircularLoadingIndicator.dart';
import 'package:employee/CommonWidgets/text_heading.dart';
import 'package:employee/constants.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:toast/toast.dart';
import 'create_teams.dart';
import '../Globals.dart' as globals;

Firestore  _fireStore = Firestore.instance;

class InfoPageOfTeams extends StatefulWidget {
  @override
  _InfoPageOfTeamsState createState() => _InfoPageOfTeamsState();

  InfoPageOfTeams({@required this.teamTag, this.selectedEmployee});
  final String teamTag;
  final List<dynamic> selectedEmployee;
}

class _InfoPageOfTeamsState extends State<InfoPageOfTeams> {

  List<Padding> _membersList = [];
  List<dynamic> _members = [];

  bool isLoading = true;
  bool markAsDone = false;

  String _teamTag = "";
  String _teamDescription = "";

  DateTime startDate;
  DateTime endDate;

  String strStartDate = "";
  String strEndDate = "";


  TextEditingController _teamTagEditingController;
  TextEditingController _descriptionEditingController;
  TextEditingController _priorityEditingController;

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

  _displayMembers(String name){
    setState(() {
      _membersList.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 11.0, horizontal: 14.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          color: kLightBlue,
                        ),
                        SizedBox(
                          width: 8.0,
                        ),
                        Text(
                            name
                        ),
                      ],
                    ),

                    globals.position == "CEO"
                    ? Container(
                      height: 25.0,
                      margin: EdgeInsets.only(right: 10.0),
                      child: RaisedButton(
                        onPressed: (){
                          _members.length >= 2 ? _members.remove(name) : print("Do Nothing");
                          _membersList.clear();
                          print(_members);

                          for(int i=0; i< _members.length; i++){
                            _displayMembers(_members[i]);
                          }
                        },
                        color: kLightBlue,
                        child: Text(
                          "REMOVE",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.0
                          ),
                        ),
                      ),
                    )
                        : SizedBox(),
                  ],
                ),
              ),
            ),
          )
      );
    });
  }

  _getMembersList() async {
    if(widget.selectedEmployee.length == 0){
      await _fireStore.collection(globals.companyName).document("Teams").collection("Teams").document(widget.teamTag).get().then((value){
        _members = value.data["Members"];
      });

      _members.sort();
      for(int i=0; i< _members.length; i++){
        _displayMembers(_members[i]);
      }
    }else{
      setState(() {
        _members = widget.selectedEmployee;
      });
      for(int i=0; i< _members.length; i++){
        _displayMembers(_members[i]);
      }
    }
  }

  _getDetails() async{
    await _fireStore.collection(globals.companyName).document("Teams").collection("Teams").document(widget.teamTag).get().then((value){
      setState(() {
        _teamTag = value.data["Tag"];
        _teamDescription = value.data["Description"];
        selectedPriority = value.data["Priority"];
        strStartDate = value.data["Start Date"].toString();
        strEndDate = value.data["End Date"].toString();
      });
    }).then((value){
      setState(() {
        isLoading = false;
        _teamTagEditingController = TextEditingController.fromValue(TextEditingValue(text: _teamTag));
        _descriptionEditingController = TextEditingController.fromValue(TextEditingValue(text: _teamDescription));
        _priorityEditingController = TextEditingController.fromValue(TextEditingValue(text: selectedPriority));
      });
    });
  }

  _updateData(){
    setState(() {
      isLoading = true;
    });
    if(_members.length >= 2){
      _fireStore.collection(globals.companyName).document("Teams").collection("Teams").document(widget.teamTag).updateData({
        "Tag": _teamTag,
        "Description": _teamDescription,
        "Members": _members,
        "Priority": selectedPriority,
        "Start Date": startDate != null ? startDate.day.toString() + "-" + startDate.month.toString() + "-" + startDate.year.toString() : strStartDate,
        "End Date": endDate != null ? endDate.day.toString() + "-" + endDate.month.toString() + "-" + endDate.year.toString() : strEndDate,
      }).then((value){
        setState(() {
          isLoading = false;
        });
        Toast.show("Data Updated", context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        Navigator.pop(context);
      }).catchError((onError){
        setState(() {
          isLoading = false;
        });
        Toast.show("Error Updating Data", context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      });
    }else if(_members.length == 1){
      setState(() {
        isLoading = false;
      });
      Toast.show("Team can't be of a single Member", context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  @override
  void initState() {
    super.initState();

    _getMembersList();
    _getDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? circularProgress()
          : SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 150.0,
              child: Card(
                margin: EdgeInsets.symmetric(horizontal: 0.0),
                color: kLightBlue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(bottomRight: Radius.circular(30.0), bottomLeft: Radius.circular(30.0))
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 70.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Image(
                                height: 70.0,
                                image: AssetImage("assets/profile.png"),
                              ),
                              SizedBox(
                                width: 15.0,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    globals.companyName,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20.0
                                    ),
                                  ),
                                  SizedBox(
                                    height: 3.0,
                                  ),
                                  Text(
                                    _teamTag.length > 15 ? _teamTag.substring(0, 15) : _teamTag,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 17.0
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                          globals.position == "CEO"
                              ? IconButton(
                            onPressed: () {

                              if(startDate != null && endDate != null){
                                // Check the Start and the End Date { End Date cannot be less than Start Date }
                                if(endDate.year > startDate.year){
                                  _updateData();
                                }else if(endDate.year < startDate.year){
                                  Toast.show("Invalid Dates...!", context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                                }else{
                                  if(endDate.month > startDate.month){
                                    _updateData();
                                  }else if(endDate.month < startDate.month){
                                    Toast.show("Invalid Dates...!", context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                                  }else{
                                    if(endDate.day >= startDate.day){
                                      _updateData();
                                    }else{
                                      Toast.show("Invalid Dates...!", context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                                    }
                                  }
                                }
                              }else if(startDate == null && endDate == null){
                                _updateData();
                              }else{
                                _updateData();
                              }
                            },
                            icon: FaIcon(FontAwesomeIcons.save),
                            color: Colors.white,
                            iconSize: 25.0,
                          )
                              : SizedBox(),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: Card(
                child: TextField(
                  enabled: false,
                  controller: _teamTagEditingController,
                  onChanged: (value){
                    setState(() {
                      _teamTag = value;
                    });
                  },
                  style: TextStyle(
                      color: Colors.black
                  ),
                  decoration: InputDecoration(
                      prefixIcon: IconButton(
                        onPressed: (){},
                        icon: FaIcon(FontAwesomeIcons.steamSquare),
                        color: kLightBlue,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide.none
                      ),
                      hintText: "Team Tag"
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: Card(
                child: TextField(
                  maxLines: 3,
                  minLines: 1,
                  enabled: globals.position == "CEO" ? true : false,
                  controller: _descriptionEditingController,
                  onChanged: (value){
                    setState(() {
                      _teamDescription = value;
                    });
                  },
                  style: TextStyle(
                      color: Colors.black
                  ),
                  decoration: InputDecoration(
                      prefixIcon: IconButton(
                        onPressed: (){},
                        icon: FaIcon(FontAwesomeIcons.fileImport),
                        color: kLightBlue,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide.none
                      ),
                      hintText: "Add a Description"
                  ),
                ),
              ),
            ),

            globals.position == "CEO"
                ? Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.0),
              child: Card(
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
            )
                : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: Card(
                child: TextField(
                  enabled: false,
                  controller: _priorityEditingController,
                  style: TextStyle(
                      color: Colors.black
                  ),
                  decoration: InputDecoration(
                      prefixIcon: IconButton(
                        onPressed: (){},
                        icon: FaIcon(FontAwesomeIcons.highlighter),
                        color: kLightBlue,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide.none
                      ),
                      hintText: "Priority"
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: (){
                        globals.position == "CEO"
                            ? showDatePicker(
                            context: context,
                            initialDate: startDate == null ? DateTime.now() : startDate,
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
                        })
                            : print(globals.position);
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
                                startDate == null ? strStartDate : startDate.day.toString() + "-" + startDate.month.toString() + "-" + startDate.year.toString(),
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
                        globals.position == "CEO"
                            ? showDatePicker(
                            context: context,
                            initialDate: endDate == null ? DateTime.now() : endDate,
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
                        })
                            : print(globals.position);
                      },
                      child: Card(
                        color: kLightBlue,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 7.0),
                          child:  Row(
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
                                endDate == null ? strEndDate : endDate.day.toString() + "-" + endDate.month.toString() + "-" + endDate.year.toString(),
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
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextHeading(text: "Members",),
                globals.position == "CEO"

                    ? IconButton(
                  splashColor: Colors.white,
                  padding: EdgeInsets.only(right: 50.0),
                  onPressed: (){
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CreateTeam(
                      enable: false,
                      teamTag: widget.teamTag,
                      selectedMembers: _members,
                      showMoreOptions: false,
                    )));
                  },
                  icon: FaIcon(FontAwesomeIcons.plusCircle),
                  color: Colors.black,
                  iconSize: 20.0,
                )

                    : SizedBox(),
              ],
            ),

            Column(
              children: _membersList,
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 30.0),
              child: Divider(
                height: 2.0,
                color: Colors.grey[900],
              ),
            ),

            globals.position == "CEO"
            ? GestureDetector(
              onTap: (){
                Alert(
                  context: context,
                  title: "Are you sure?",
                  desc: "Want to mark $_teamTag as done?",
                  buttons: [
                    DialogButton(
                      child: Text(
                        "YES",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      onPressed: (){

                        Navigator.pop(context);
                        setState(() {
                          markAsDone = true;
                        });
                        _fireStore.collection(globals.companyName).document("Teams").collection("Teams").document(_teamTag).updateData({
                          "Done": true,
                        }).then((value){})
                            .catchError((onError){});
                      },
                    ),
                    DialogButton(
                      child: Text(
                        "NO",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ).show();
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.symmetric(horizontal: 10.0),
                decoration: BoxDecoration(
                    color: kLightBlue,
                    borderRadius: BorderRadius.all(Radius.circular(10.0))
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 15.0),
                  child: Center(
                    child: Text(
                      markAsDone
                          ? "Marked as done?"
                          : "Mark as done?",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.0
                      ),
                    ),
                  ),
                ),
              ),
            )
                : SizedBox()
          ],
        ),
      ),
    );
  }
}


