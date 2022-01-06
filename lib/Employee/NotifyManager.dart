import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:employee/CommonWidgets/CircularLoadingIndicator.dart';
import 'package:employee/CommonWidgets/text_heading.dart';
import 'package:employee/constants.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:employee/Globals.dart' as globals;
import 'package:toast/toast.dart';

Firestore _fireStore = Firestore.instance;

class NotifyManager extends StatefulWidget {
  @override
  _NotifyManagerState createState() => _NotifyManagerState();
  NotifyManager({this.title, this.description, this.identity, this.employeeName});
  final String title;
  final String description;
  final String identity;
  final String employeeName;
}

class _NotifyManagerState extends State<NotifyManager> {

  String _title = "";
  String _description = "";

  bool _isThereTitle = true;
  bool _isThereDescription = true;
  bool isLoading = false;

  TextEditingController _titleController;
  TextEditingController _descriptionController;

  _textController(){
    _titleController = TextEditingController.fromValue(TextEditingValue(text: widget.title));
    _descriptionController = TextEditingController.fromValue(TextEditingValue(text: widget.description));
  }

  _checkFields(){
    setState(() {
      isLoading = true;
    });
    if(_title.trim() != "" && _description.trim() != ""){
      _uploadNotification();
    }else{
      _showError();
    }
  }

  _showError(){
    setState(() {
      isLoading = false;
      _title == "" ? _isThereTitle = false : _isThereTitle = true;
      _description == "" ? _isThereDescription = false : _isThereDescription = true;
    });
  }

  _uploadNotification(){
    DateTime nowDate = DateTime.now();
    _fireStore.collection(globals.companyName).document("CEO Notifications").collection("Notifications").document(nowDate.toString()).setData({
      "Title": _title,
      "Description": _description,
      "Date": nowDate.day.toString() + "-" + nowDate.month.toString() + "-" + nowDate.year.toString(),
      "Time": nowDate.hour.toString() + ":" + nowDate.minute.toString(),
      "Search": nowDate.month.toString() + "-" + nowDate.year.toString(),
      "Type": "Employee Notification",
      "EmployeeName": globals.userName,
      "Seen": false,
    }).then((value){
      setState(() {
        isLoading = false;
        Toast.show("Notification Sent", context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        Navigator.pop(context);
      });
    }).catchError((onError){
      setState(() {
        isLoading = false;
        Toast.show("Error Sending Notification..!", context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      });
    });
  }

  @override
  void initState() {
    super.initState();

    widget.identity == "CEO" || widget.identity == "Employee"? _textController() : print(widget.identity);
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
                          icon: FaIcon(FontAwesomeIcons.arrowLeft),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          color: Colors.black,
                          iconSize: 22.0,
                        ),
                        Text(
                          widget.identity == "CEO"
                              ? "Employee Notification"
                              : widget.identity == "Employee" ? "Company Notification" : "Notify Manager",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0
                          ),
                        ),
                        SizedBox(
                          width: 20.0,
                        )
                      ],
                    ),
                  ),
                ),

                widget.identity == "CEO"
                ? TextHeading(text: "${widget.employeeName}",)
                : SizedBox(),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: Card(
                            child: TextField(
                              onChanged: (value){
                                setState(() {
                                  _title = value;
                                });
                              },
                              controller: _titleController,
                              enabled: widget.identity != "Employee" ? true : false,
                              style: TextStyle(
                                  color: Colors.black
                              ),
                              decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.mode_edit,
                                    color: Colors.black,
                                    size: 25.0,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide.none
                                  ),
                                  hintText: _isThereTitle ? "Title" : "Title Required*",
                                  hintStyle: TextStyle(
                                    color: _isThereTitle ? Colors.grey[700] : Colors.red,
                                  )
                              ),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: Card(
                            elevation: 0.5,
                            child: TextField(
                              minLines: 1,
                              maxLines: 100,
                              onChanged: (value){
                                _description = value;
                              },
                              style: TextStyle(
                                  color: Colors.black
                              ),
                              controller: _descriptionController,
                              enabled: widget.identity != "Employee" ? true : false,
                              decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.description,
                                    color: Colors.black,
                                    size: 25.0,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide.none
                                  ),
                                  hintText: _isThereDescription ? "Description" : "Description Required*",
                                  hintStyle: TextStyle(
                                    color: _isThereDescription ? Colors.grey[700] : Colors.red,
                                  )
                              ),
                            ),
                          ),
                        ),

                        SizedBox(
                          height: 60.0,
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),

            widget.identity != "Employee"
            ?  Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Colors.white,
                width: MediaQuery.of(context).size.width,
                height: 50.0,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 110.0),
                  child: RaisedButton(
                    onPressed: (){
                      _checkFields();
                    },
                    color: kLightBlue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(7.0)),
                        side: BorderSide(width: 1.0, color: Colors.white, style: BorderStyle.solid)
                    ),
                    child: Text(
                      "NOTIFY",
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
