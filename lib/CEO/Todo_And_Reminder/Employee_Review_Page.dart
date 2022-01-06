import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:employee/CommonWidgets/CircularLoadingIndicator.dart';
import 'package:employee/constants.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:employee/Globals.dart' as globals;

Firestore _fireStore = Firestore.instance;

class EmployeeReviewPage extends StatefulWidget {
  @override
  _EmployeeReviewPageState createState() => _EmployeeReviewPageState();
}

class _EmployeeReviewPageState extends State<EmployeeReviewPage> {

  String _moreFunctionality = "";
  String _improveFunctionality = "";
  String _others = "";
  String _designs = "";

  bool isLoading = false;
  
  _uploadImproveUs(){
    setState(() {
      isLoading = true;
    });

    _fireStore.collection("AapunLogKaFeedBackHeYeBhidu").document(DateTime.now().toString()).setData({
      "MoreFunctionality": _moreFunctionality,
      "ImproveFunctionality": _improveFunctionality,
      "Design": _designs,
      "Others": _others,
      "UserName": globals.userName,
      "CompanyName": globals.companyName,
      "Position": globals.position,
    }).then((value){
      setState(() {
        isLoading = false;
      });
      Navigator.pop(context);
    }).catchError((onError){
      setState(() {
        isLoading = false;
      });
      Navigator.pop(context);
    });
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
                "Help us Improve",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0
                ),
              ),
              GestureDetector(
                onTap: (){
                  _uploadImproveUs();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Icon(
                    Icons.upload_file,
                    color: Colors.black,
                  ),
                ),
              )
            ],
          ),
        ),
      );
    }

    Widget _mainBody(){
      return Expanded(
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              children: [

                Card(
                  margin: EdgeInsets.all(0.0),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Hero(
                          tag: "review",
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 5.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(10.0)),
                              color: kLightBlue,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.functions_rounded,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 3.0,),
                                Text(
                                    "More Functionality to be Added",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17.0,
                                    letterSpacing: 1.0
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        TextField(
                          minLines: 1,
                          maxLines: 5,
                          onChanged: (value){
                            setState(() {
                              _moreFunctionality = value;
                            });
                          },
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                            hintText  : "Your Response"
                          ),
                        )
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 10.0,),

                Card(
                  margin: EdgeInsets.all(0.0),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 5.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            color: kLightBlue,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.functions_rounded,
                                color: Colors.white,
                              ),
                              SizedBox(width: 3.0,),
                              Text(
                                "Functionality to be Improved",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17.0,
                                    letterSpacing: 1.0
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextField(
                          minLines: 1,
                          maxLines: 5,
                          onChanged: (value){
                            setState(() {
                              _improveFunctionality = value;
                            });
                          },
                          decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              hintText  : "Your Response"
                          ),
                        )
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 10.0,),

                Card(
                  margin: EdgeInsets.all(0.0),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 5.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            color: kLightBlue,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.functions_rounded,
                                color: Colors.white,
                              ),
                              SizedBox(width: 3.0,),
                              Text(
                                "Design to be Improved",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17.0,
                                    letterSpacing: 1.0
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextField(
                          minLines: 1,
                          maxLines: 5,
                          onChanged: (value){
                            setState(() {
                              _designs = value;
                            });
                          },
                          decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              hintText  : "Your Response"
                          ),
                        )
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 10.0,),

                Card(
                  margin: EdgeInsets.all(0.0),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 5.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            color: kLightBlue,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.functions_rounded,
                                color: Colors.white,
                              ),
                              SizedBox(width: 3.0,),
                              Text(
                                "Others ",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17.0,
                                    letterSpacing: 1.0
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextField(
                          minLines: 1,
                          maxLines: 5,
                          onChanged: (value){
                            setState(() {
                              _others = value;
                            });
                          },
                          decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              hintText  : "Your Response"
                          ),
                        )
                      ],
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: isLoading
          ? circularProgress()
          : SafeArea(
        child: Container(
          child: Column(
            children: [
              _appBar(),
              _mainBody(),
            ],
          ),
        ),
      ),
    );
  }
}
