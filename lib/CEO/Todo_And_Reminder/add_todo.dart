import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:employee/CommonWidgets/CircularLoadingIndicator.dart';
import 'package:employee/constants.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../Globals.dart' as globals;

final fireStore = Firestore.instance;

class Todo extends StatefulWidget {
  @override
  _TodoState createState() => _TodoState();

  Todo({this.state, this.tag});

  final String state;
  final String tag;
}

class _TodoState extends State<Todo> {

  String _tag = "";
  String _description = "";
  DateTime _tillDate;

  bool isLoading = false;

  TextEditingController _tagController;
  TextEditingController _descriptionController;
  TextEditingController _dateTimeController;

  _checkFields(){
    _tag == "" ? Toast.show("Cannot set an Empty Todo..!", context, gravity: Toast.BOTTOM, duration: Toast.LENGTH_LONG) : _storeData();
  }

  _storeData(){
    setState(() {
      isLoading = true;
    });
    fireStore.collection(globals.companyName).document("CEO TODOs").collection("Todo").document(_tag).setData({
      "tag": _tag,
      "Description": _description,
      "tillDate": _tillDate.toString(),
      "TodoDate": _tillDate.day.toString() + "-" + _tillDate.month.toString() + "-" + _tillDate.year.toString(),
    }).then((value){
      if(widget.state == "NEW"){
        String document = DateTime.now().toString();
        fireStore.collection(globals.companyName).document("CEO Notifications").collection("Notifications").document(document).setData({
          "Description": _description,
          "TodoDate": _tillDate.day.toString() + "-" + _tillDate.month.toString() + "-" + _tillDate.year.toString(),
          "tag": _tag,
          "tillDate": _tillDate,
          "Type": "TODO",
          "Seen": false,
          "Search": _tillDate.month.toString() + "-" + _tillDate.year.toString(),
          "DocumentName": document,
        }).then((value){
          Toast.show("Todo Added", context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
          setState(() {
            isLoading = false;
          });
        }).catchError((onError){
          setState(() {
            isLoading = false;
            Toast.show("Error Uploading TODO", context, gravity: Toast.BOTTOM, duration: Toast.LENGTH_LONG);
          });
        });
      }
    });
  }
  
  _getTodo(){
    fireStore.collection(globals.companyName).document("CEO TODOs").collection("Todo").document(widget.tag).get().then((value){
      setState(() {
        isLoading = true;
        _tag = value.data["tag"];
        _description = value.data["Description"];
        _tillDate = DateTime.parse(value.data["tillDate"]);

        _textController();
      });
    });
  }

  _textController(){
    setState(() {
      _tagController = TextEditingController.fromValue(TextEditingValue(text: _tag));
      _descriptionController = TextEditingController.fromValue(TextEditingValue(text: _description));
      _dateTimeController = TextEditingController.fromValue(TextEditingValue(text: _tillDate.toString()));
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();

    if(widget.state == "HISTORY"){
      _getTodo();
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: isLoading
        ? circularProgress()
          : SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: <Widget>[

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
                child: Container(
                  height: 60.0,
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0))
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
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
                          Text(
                            "TODO's",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 20.0,
                                letterSpacing: 1.0
                            ),
                          ),
                          IconButton(
                            onPressed: (){
                              _checkFields();
                            },
                            icon: FaIcon(FontAwesomeIcons.upload),
                            color: Colors.black,
                            iconSize: 18.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                child: Column(
                  children: <Widget>[
                    Card(
                      color: Color(0XFFA4AAEE),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: IconButton(
                                    onPressed: (){
                                      showDatePicker(
                                          context: context,
                                          initialDate: _tillDate == null ? DateTime.now() : _tillDate,
                                          firstDate: DateTime(2000),
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
                                      ).then((date){
                                        setState(() {
                                          _tillDate = date;
                                        });
                                      });
                                    },
                                    icon: FaIcon(FontAwesomeIcons.calendarPlus),
                                    color: Colors.white,
                                    iconSize: 19.0,
                                  ),
                                ),
                                Expanded(
                                  flex: 12,
                                  child: TextField(
                                    controller: _tagController,
                                    maxLines: 1,
                                    textAlign: TextAlign.center,
                                    onChanged: (value){
                                      setState(() {
                                        _tag = value;
                                      });
                                    },
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold
                                    ),
                                    decoration: InputDecoration(
                                      filled: false,
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide.none
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                      ),
                                      hintText: "Give a Tag",
                                      hintStyle: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Card(
                            elevation: 0.5,
                            color: Colors.white,
                            margin: EdgeInsets.all(0.0),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0)
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15.0),
                              child: TextField(
                                controller: _descriptionController,
                                onChanged: (value){
                                  setState(() {
                                    _description = value;
                                  });
                                },
                                maxLines: 100,
                                minLines: 2,
                                expands: false,
                                style: TextStyle(
                                    height: 1.9
                                ),
                                decoration: InputDecoration(
                                    hintText: ("Here goes the Description..!"),
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide.none
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide.none
                                    )
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
