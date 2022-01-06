import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:employee/CommonWidgets/text_heading.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:toast/toast.dart';
import '../Globals.dart' as globals;
import '../constants.dart';
import '../CommonWidgets/CircularLoadingIndicator.dart';

Firestore _fireStore = Firestore.instance;

class EmployeeViewWork extends StatefulWidget {
  @override
  _EmployeeViewWorkState createState() => _EmployeeViewWorkState();
}

class _EmployeeViewWorkState extends State<EmployeeViewWork> {

  ListView listCriteria;
  List<EmployeeWork> _employeeDetailedWork = List<EmployeeWork>();

  bool isLoading = true;

  _updateTheWorkStatus(String documentName){
    _fireStore.collection(globals.companyName).document("Works").collection("Employee").document(globals.userName)
        .collection(globals.userName).document(documentName).updateData({
      "Status": true,
    }).then((value){

    _fireStore.collection(globals.companyName).document("CEO Notifications").collection("Notifications").document(documentName).setData({
      "Date": DateTime.now().day.toString() + "-" + DateTime.now().month.toString() + "-" + DateTime.now().year.toString(),
      "DocumentName": documentName,
      "EmployeeName": globals.userName,
      "Search": DateTime.now().month.toString() + "-" + DateTime.now().year.toString(),
      "Seen": false,
      "Time": DateTime.now().hour.toString() + ":" + DateTime.now().minute.toString(),
      "Type": "WorkUpdateStatus",
    }).then((value){
      setState(() {
        isLoading = false;
      });
      Toast.show("Marked as Done", context, gravity: Toast.BOTTOM, duration: Toast.LENGTH_LONG);
    });
    }).catchError((onError){
      setState(() {
        isLoading = false;
        Toast.show("Error Updating Work Status :(", context, gravity: Toast.BOTTOM, duration: Toast.LENGTH_LONG);
        Navigator.pop(context);
      });
    });
  }

  _getWorkDetailsOfEmployee(){
    _fireStore.collection(globals.companyName).document("Works").collection("Employee").document(globals.userName)
        .collection(globals.userName).where("Status", isEqualTo: false).getDocuments().then((value){
      value.documents.forEach((element) {
        _populateTheListView(element.data["Start Date"], element.data["Description"], element.data["Priority"], element.data["Start Date"], element.data["Document"]);
      });
      setState(() {
        isLoading = false;
      });
    });
  }

  _populateTheListView(String endDate, String description, String priority, String startDate, String document){
    setState(() {
      _employeeDetailedWork.add(
        EmployeeWork(
          isExpanded: false,
          endDate: endDate,
          description: description,
          body: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(),
                TextHeading(text: "Description",),
                Padding(
                  padding: const EdgeInsets.only(left: 19.0, bottom: 3.0),
                  child: Text(
                    description,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextHeading(text: "Start Date:",),
                    Text(
                      startDate
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextHeading(text: "End Date:  ",),
                    Text(
                        endDate
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextHeading(text: "Priority:     ",),
                    Text(
                        priority
                    )
                  ],
                ),
                Center(
                  child: RaisedButton(
                    color: kLightBlue,
                    onPressed: (){
                      setState(() {
                        isLoading = true;
                      });
                      _updateTheWorkStatus(document, );
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      side: BorderSide(color: Colors.white, width: 1.0, style: BorderStyle.solid)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        "MARK AS DONE...?",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          circle: ClipOval(
            child: Material(
              color: kLightBlue,
              child: Padding(
                  padding: priority[0] == "L" ? EdgeInsets.symmetric(vertical: 14.0, horizontal: 19.0) : EdgeInsets.symmetric(vertical: 14.0, horizontal: 17.0),
                  child: Text(
                    priority[0],
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0
                    ),
                  )
              ),
            ),
          ),
        )
      );
    });
  }

  @override
  void initState() {
    super.initState();

    _getWorkDetailsOfEmployee();
  }

  @override
  Widget build(BuildContext context) {

    listCriteria =ListView(
      children: [
        Padding(
          padding: EdgeInsets.all(10.0),
          child: ExpansionPanelList(
            expansionCallback: (int index, bool isExpanded) {
              setState(() {
                _employeeDetailedWork[index].isExpanded = !_employeeDetailedWork[index].isExpanded;
              });
            },
            children: _employeeDetailedWork.map((EmployeeWork item) {
              return ExpansionPanel(
                  headerBuilder: (BuildContext context, bool isExpanded) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 6.5),
                      child: ListTile(
                        leading: item.circle,
                        title: Text(
                          item.description.length > 33 ? item.description.substring(0, 33) + "..." : item.description,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 7.0, bottom: 5.0),
                          child: Text(
                            "End Date: ${item.endDate}",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 14.0,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  isExpanded: item.isExpanded,
                  body: item.body
              );
            }).toList(),
          ),
        )
      ],
    );

    return Scaffold(
      body: SafeArea(
          child: Stack(
            children: [
              Stack(
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
                            "View Work",
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
                  Padding(
                    padding: const EdgeInsets.only(top: 60.0),
                    child: listCriteria,
                  ),
                ],
              ),

              isLoading
              ? circularProgress()
                  : SizedBox(),
            ],
          )
      ),
    );
  }
}




class EmployeeWork{
  bool isExpanded;
  final String description;
  final String endDate;
  final Widget body;
  final Widget circle;

  EmployeeWork({this.isExpanded, this.endDate, this.description, this.body, this.circle});
}
