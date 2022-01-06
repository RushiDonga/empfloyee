import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:employee/CommonWidgets/text_heading.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../constants.dart';
import '../Globals.dart' as globals;
import 'package:toast/toast.dart';
import '../CommonWidgets/CircularLoadingIndicator.dart';

Firestore _fireStore = Firestore.instance;

class AssignWork extends StatefulWidget {
  @override
  _AssignWorkState createState() => _AssignWorkState();
  AssignWork({@required this.name, @required this.newWork, this.description, this.startDate, this.endDate, this.priority, this.document});
  final String name;
  final bool newWork;
  final String description;
  final String startDate;
  final String endDate;
  final String priority;
  final String document;
}

class _AssignWorkState extends State<AssignWork> {

  String _selectedPriority;
  String _description;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

  bool _descriptionIsNull = false;
  bool _priorityIsNull = false;
  bool isLoading = false;

  TextEditingController _startDateController;
  TextEditingController _endDateController;
  TextEditingController _descriptionController;

  _updatePreviousWork() async {
    await _fireStore.collection(globals.companyName).document("Works").collection("Employee").document(widget.name)
        .collection(widget.name).document(widget.document).updateData({
      "Description": _descriptionController.value.text,
      "Start Date": _startDate.day.toString() + "-" + _startDate.month.toString() + "-" + _startDate.year.toString(),
      "End Date": _endDate.day.toString() + "-" + _endDate.month.toString() + "-" + _endDate.year.toString(),
      "Priority": _selectedPriority,
    }).then((value){
      isLoading = false;
      Navigator.pop(context);
    }).catchError((onError){
      setState(() {
        isLoading = false;
      });
      Toast.show("Error Updating Work", context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    });
  }

  _deleteWork() async {
    await _fireStore.collection(globals.companyName).document("Works").collection("Employee")
        .document(widget.name).collection(widget.name).document(widget.document).delete()
        .then((value){
          isLoading = false;
          Navigator.pop(context);
    }).catchError((onError){
      setState(() {
        isLoading = false;
      });
      Toast.show("Error Deleting Work", context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    });
  }

  _dateController(){
    setState(() {
      _startDateController = TextEditingController.fromValue(TextEditingValue(text: DateTime.now().day.toString() + "-" + DateTime.now().month.toString() + "-" + DateTime.now().year.toString()));
      _endDateController = TextEditingController.fromValue(TextEditingValue(text: DateTime.now().day.toString() + "-" + DateTime.now().month.toString() + "-" + DateTime.now().year.toString()));
    });
  }

  _controllerOfPreviousWork(){
    setState(() {
      _description = widget.description;
      _descriptionController = TextEditingController.fromValue(TextEditingValue(text: widget.description));
      _startDateController = TextEditingController.fromValue(TextEditingValue(text: widget.startDate));
      _endDateController = TextEditingController.fromValue(TextEditingValue(text: widget.endDate));
      _selectedPriority = widget.priority;
    });
  }

  _checkFields(){
    if(_description != null && _selectedPriority != null){
      widget.newWork ? _updateWorkInDatabase() : _updatePreviousWork();
    }else{
      setState(() {
        isLoading = false;
        if(_description == null){
          _descriptionIsNull = true;
        }else{
          _descriptionIsNull = false;
        }

        if(_selectedPriority == null){
          _priorityIsNull = true;
        }else{
          _priorityIsNull = false;
        }
      });
    }
  }

  _updateWorkInDatabase(){
    String document = DateTime.now().toString();
    _fireStore.collection(globals.companyName).document("Works").collection("Employee").document(widget.name)
        .collection(widget.name).document(document).setData({
      "Date": DateTime.now().day.toString() + "-" + DateTime.now().month.toString() + "-" + DateTime.now().year.toString(),
      "Description": _description,
      "End Date": _endDate.day.toString() + "-" + _endDate.month.toString() + "-" + _endDate.year.toString(),
      "Priority": _selectedPriority,
      "Start Date": _startDate.day.toString() + "-" + _startDate.month.toString() + "-" + _startDate.year.toString(),
      "Status": false,
      "Document": document,
    }).then((value){

    _fireStore.collection(globals.companyName).document("Employee").collection("employee").document(widget.name)
        .collection("Notifications").document(document).setData({
      "Date": DateTime.now().day.toString() + "-" + DateTime.now().month.toString() + "-" + DateTime.now().year.toString(),
      "DocumentName": document,
      "Search": DateTime.now().month.toString() + "-" + DateTime.now().year.toString(),
      "Seen": false,
      "Time" : DateTime.now().hour.toString() + ":" + DateTime.now().minute.toString(),
      "Type": "WORK",
      "Description": _description,
    }).then((value){
      isLoading = false;
      Navigator.pop(context);
    });
    }).catchError((onError){
      setState(() {
        isLoading = false;
      });
      Toast.show("Error Assigning Work", context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    });
  }

  // Drop down menu
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

  @override
  void initState() {
    super.initState();

    widget.newWork
    ? _dateController()
    : _controllerOfPreviousWork();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? circularProgress()
        : Scaffold(
            body: SafeArea(
              child: Container(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
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
                              Text(
                                widget.newWork ? "Assign Work" : "Assigned Work",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0
                                ),
                              ),
                              SizedBox(
                                width: 30.0,
                              )
                            ],
                          ),
                        ),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextHeading(
                            text: widget.newWork ? "Assigning work to ${widget.name}" : "Work Assigned to ${widget.name}",
                          ),
                        ],
                      ),

                      Card(
                        margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.5),
                        child: TextField(
                          minLines: 1,
                          maxLines: 4,
                          controller: _descriptionController,
                          onChanged: (value){
                            setState(() {
                              _description = value;
                            });
                          },
                          decoration: InputDecoration(
                              prefixIcon: IconButton(
                                onPressed: (){},
                                icon: FaIcon(FontAwesomeIcons.folder),
                                color: kLightBlue,
                              ),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide.none
                              ),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide.none
                              ),
                              hintText: _descriptionIsNull ? "Work Description required*" : "Work Description",
                              hintStyle: TextStyle(
                                color: _descriptionIsNull ? Colors.red : Colors.grey[800],
                              )
                          ),
                        ),
                      ),

                      GestureDetector(
                        onTap: (){
                          showDatePicker(
                              context: context,
                              initialDate: _startDate == null ? DateTime.now() : _startDate,
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
                              _startDate = value;
                              _startDateController = TextEditingController.fromValue(TextEditingValue(text: _startDate.day.toString() + "-" + _startDate.month.toString() + "-" + _startDate.year.toString()));
                            });
                          });
                        },
                        child: Card(
                          margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.5),
                          child: TextField(
                            minLines: 1,
                            maxLines: 4,
                            enabled: false,
                            controller: _startDateController,
                            onChanged: (value){},
                            decoration: InputDecoration(
                                prefixIcon: IconButton(
                                  onPressed: (){},
                                  icon: FaIcon(FontAwesomeIcons.calendarAlt),
                                  color: kLightBlue,
                                ),
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide.none
                                ),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide.none
                                ),
                                hintText: "Start Date",
                                hintStyle: TextStyle(
                                  color: Colors.grey[800],
                                )
                            ),
                          ),
                        ),
                      ),

                      GestureDetector(
                        onTap: (){
                          showDatePicker(
                              context: context,
                              initialDate: _endDate == null ? DateTime.now() : _endDate,
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
                              _endDate = value;
                              _endDateController = TextEditingController.fromValue(TextEditingValue(text: _endDate.day.toString() + "-" + _endDate.month.toString() + "-" + _endDate.year.toString()));
                            });
                          });
                        },
                        child: Card(
                          margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.5),
                          child: TextField(
                            minLines: 1,
                            maxLines: 4,
                            controller: _endDateController,
                            enabled: false,
                            onChanged: (value){},
                            decoration: InputDecoration(
                                prefixIcon: IconButton(
                                  onPressed: (){},
                                  icon: FaIcon(FontAwesomeIcons.calendarCheck),
                                  color: kLightBlue,
                                ),
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide.none
                                ),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide.none
                                ),
                                hintText: "End Date",
                                hintStyle: TextStyle(
                                  color: Colors.grey[800],
                                )
                            ),
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
                                        _selectedPriority = value;
                                      });
                                    },
                                    isExpanded: true,
                                    underline: Container(),
                                    hint: Text(
                                      _priorityIsNull ? "Priority required*" : "Priority",
                                      style: TextStyle(
                                          color: _priorityIsNull ? Colors.red : Colors.grey[700]
                                      ),
                                    ),
                                    value: _selectedPriority,
                                    items: _dropDownMenuItems,
                                  ),
                                ),
                              ],
                            ),
                          )
                      ),

                      widget.newWork
                          ? RaisedButton(
                        onPressed: (){
                          setState(() {
                            isLoading = true;
                          });
                          _checkFields();
                        },
                        color: kLightBlue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(6.0)),
                            side: BorderSide(width: 1.0, color: Colors.white, style: BorderStyle.solid)
                        ),
                        child: Text(
                          "ASSIGN",
                          style: TextStyle(
                              color: Colors.white
                          ),
                        ),
                      )
                          : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RaisedButton(
                            onPressed: (){
                              setState(() {
                                isLoading = true;
                              });
                              _checkFields();
                            },
                            color: kLightBlue,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(6.0)),
                                side: BorderSide(width: 1.0, color: Colors.white, style: BorderStyle.solid)
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15.0),
                              child: Text(
                                "UPDATE",
                                style: TextStyle(
                                    color: Colors.white
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 20.0,
                          ),
                          RaisedButton(
                            onPressed: (){
                              setState(() {
                                isLoading = true;
                              });
                              _deleteWork();
                            },
                            color: kLightBlue,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(6.0)),
                                side: BorderSide(width: 1.0, color: Colors.white, style: BorderStyle.solid)
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15.0),
                              child: Text(
                                "DELETE",
                                style: TextStyle(
                                    color: Colors.white
                                ),
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
