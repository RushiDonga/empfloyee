import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:employee/CommonWidgets/CircularLoadingIndicator.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:employee/Globals.dart' as globals;
import 'package:toast/toast.dart';
import '../constants.dart';

Firestore _fireStore = Firestore.instance;

class CEOManageLeaves extends StatefulWidget {
  @override
  _CEOManageLeavesState createState() => _CEOManageLeavesState();
}

class _CEOManageLeavesState extends State<CEOManageLeaves> {

  List<String> _leavesType = [];
  List<int> _totalLeaves = [];

  String _enteredLeaveType = "";

  bool isThereLeaveType = true;
  bool isLoading = false;

  TextEditingController _leaveController = TextEditingController();

  _connectLeaves(){
    List<String> _uploadLeaves = [];

    for(int i=0; i<_leavesType.length; i++){
      _uploadLeaves.add(_leavesType[i] + "------>" + _totalLeaves[i].toString());
    }
    _updateLeavesInDatabase(_uploadLeaves);
  }

  _updateLeavesInDatabase(List<String> _list){
    setState(() {
      isLoading = true;
    });
    _fireStore.collection(globals.companyName).document("Employee").updateData({
      "LeaveList": _list,
    }).then((value){
      Navigator.pop(context);
    }).catchError((onError){
      Toast.show("Error Updating the Leaves", context, gravity: Toast.BOTTOM, duration: Toast.LENGTH_LONG);
    });
    setState(() {
      isLoading = false;
    });
  }

  _getThePreviousSetLeaves(){
    List<dynamic> _leaveData = [];

    _fireStore.collection(globals.companyName).document("Employee").get().then((value){
      _leaveData = value.data["LeaveList"];
    }).then((value){
      for(int i=0; i<_leaveData.length; i++){
        var splitLeave = _leaveData[i].toString().split("------>");
        setState(() {
          _leavesType.add(splitLeave[0]);
          _totalLeaves.add(int.parse(splitLeave[1]));
        });
      }
    }).catchError((onError){
      print("ERROR IN FETCHING PREVIOUS LEAVE TYPES");
      print( onError);
    });
  }

  @override
  void initState() {
    super.initState();

    _leaveController.addListener(() {});
    _getThePreviousSetLeaves();
  }

  @override
  Widget build(BuildContext context) {

    Widget _appBar(){
      return Padding(
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
                "Manage Leaves",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0
                ),
              ),
              GestureDetector(
                onTap: (){
                  _connectLeaves();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Icon(
                    Icons.assignment_turned_in,
                    color: Colors.black,
                  ),
                ),
              )
            ],
          ),
        ),
      );
    }

    Widget _addLeave(){
      return Container(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: Row(
            children: [
              Expanded(
                child: Card(
                  child: TextField(
                    onChanged: (value){
                      setState(() {
                        _enteredLeaveType = value;
                      });
                    },
                    controller: _leaveController,
                    style: TextStyle(
                        color: Colors.black
                    ),
                    decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.leave_bags_at_home_rounded,
                          color: kLightBlue,
                          size: 25.0,
                        ),

                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide.none
                        ),
                        hintText: isThereLeaveType ? "Leave Type" : "Leave Type Required*",
                        hintStyle: TextStyle(
                          color: isThereLeaveType ? Colors.grey[700] : Colors.red,
                        )
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: (){
                  setState(() {
                    if(_enteredLeaveType.trim() != "" && _enteredLeaveType.trim() != null){
                      _leavesType.add(_enteredLeaveType);
                      _totalLeaves.add(1);
                      isThereLeaveType = true;
                      _enteredLeaveType = "";
                      _leaveController.clear();
                    }else{
                      setState(() {
                        isThereLeaveType = false;
                      });
                    }
                  });
                },
                child: Card(
                  color: kLightBlue,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 11.0, horizontal: 11.0),
                    child: Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 30.0,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      );
    }

    Widget _displayListOfLeaves(){
      return Expanded(
        child: ListView.builder(
            physics: BouncingScrollPhysics(),
            shrinkWrap: true,
            itemCount: _leavesType.length,
            itemBuilder: (context, index){
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 7.0),
                width: MediaQuery.of(context).size.width,
                child: Card(
                  elevation: 0.3,
                  margin: EdgeInsets.symmetric(vertical: 0.5),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.shopping_bag_rounded,
                              color: kLightBlue,
                            ),
                            SizedBox(
                              width: 10.0,
                            ),
                            Text(
                              _leavesType[index],
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5
                              ),
                            ),
                          ],
                        ),

                        Row(
                          children: [
                            Text(
                              _totalLeaves[index].toString(),
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 15.0,
                              ),
                            ),
                            SizedBox(
                              width: 10.0,
                            ),
                            GestureDetector(
                              onTap: (){
                                setState(() {
                                  _totalLeaves[index] = _totalLeaves[index] + 1;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                  color: Colors.grey[700],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                                  child: Text(
                                    "+",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 5.0,
                            ),
                            GestureDetector(
                              onTap: (){
                                setState(() {
                                  if(_totalLeaves[index] > 1){
                                    _totalLeaves[index] = _totalLeaves[index] - 1;
                                  }
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                  color: Colors.grey[700],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
                                  child: Text(
                                    "-",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10.0,
                            ),
                            GestureDetector(
                              onTap: (){
                                setState(() {
                                  _totalLeaves.removeAt(index);
                                  _leavesType.removeAt(index);
                                });
                              },
                              child: Icon(
                                Icons.delete_forever,
                                color: Colors.black,
                                size: 30.0,
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              );
            }
        ),
      );
    }

    return Scaffold(
      body: isLoading
          ? circularProgress()
          : SafeArea(
        child: Column(
          children: [
            _appBar(),
            _addLeave(),
            _displayListOfLeaves()
          ],
        ),
      ),
    );
  }
}
