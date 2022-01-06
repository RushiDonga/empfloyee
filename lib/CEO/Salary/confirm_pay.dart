import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

final fireStore = Firestore.instance;

class ConformPay extends StatefulWidget {
  @override
  _ConformPayState createState() => _ConformPayState();

  ConformPay({this.month, this.companyName, this.name, this.documentID});
  final String month;
  final String companyName;
  final String name;
  final String documentID;
}

class _ConformPayState extends State<ConformPay> {

  @override
  void initState() {
    super.initState();

    print(widget.month);
    print(widget.companyName);
    print(widget.name);
    print(widget.documentID);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
          child: Column(
            children: <Widget>[
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Are you sure, wanna mark the Salary for \n" + widget.month  + " as Paid...?",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 30.0,
                    width: 90.0,
                    child: RaisedButton(
                      color: Colors.green,
                      onPressed: (){
                        fireStore.collection(widget.companyName).document("Salary Details").collection(widget.name).document(widget.documentID).updateData({
                          "Status": "Paid",
                          "Date Paid": DateTime.now().day.toString() + "/" + DateTime.now().month.toString() + "/" + DateTime.now().year.toString(),
                        }).then((value){
                          Toast.show("Marked as Paid", context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                          Navigator.pop(context);
                        }).catchError((onError){
                          print(onError);
                          Toast.show("Error Registering", context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                        });
                      },
                      child: Text(
                        "Yes",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  SizedBox(
                    width: 90.0,
                    height: 30.0,
                    child: RaisedButton(
                      color: Colors.red,
                      onPressed: (){
                        Navigator.pop(context);
                      },
                      child: Text(
                        "No",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 10.0,
              ),
              Text(
                "NOTE : Once it has been marked as Paid You won't be able to change it later"
              )
            ],
          ),
        ),
      ),
    );
  }
}
