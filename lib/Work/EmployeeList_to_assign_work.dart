import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:employee/CommonWidgets/text_heading.dart';
import 'package:employee/constants.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:employee/Globals.dart' as globals;
import 'AssignWork.dart';
import '../CommonWidgets/CircularLoadingIndicator.dart';

Firestore _fireStore = Firestore.instance;

class EmployeeListAssignWork extends StatefulWidget {
  @override
  _EmployeeListAssignWorkState createState() => _EmployeeListAssignWorkState();
}

class _EmployeeListAssignWorkState extends State<EmployeeListAssignWork> {

  bool isLoading = true;

  List<dynamic> _employeeList = [];
  ListView listCriteria;
  List<PerEmployeeWork> _employeeWorkDetails = List<PerEmployeeWork>();

  _getEmployeeList() async {
    await _fireStore.collection(globals.companyName).document("Employee").get().then((value){
      setState(() {
        _employeeList.addAll(value.data["EmployeeList"]);
      });
    }).then((value) async {
      List<Container> individualWork = [];
      for(int i=0; i<_employeeList.length; i++){
        await _fireStore.collection(globals.companyName).document("Works").collection("Employee").document(_employeeList[i])
            .collection(_employeeList[i]).where("Status", isEqualTo: false).getDocuments().then((value){
          individualWork.clear();
              value.documents.forEach((element) {
             setState(() {
               individualWork.add(
                   Container(
                     padding: EdgeInsets.symmetric(horizontal: 21.0,vertical: 2.0),
                     child: GestureDetector(
                       onTap: (){
                         Navigator.push(context, MaterialPageRoute(builder: (context) => AssignWork(
                           name: _employeeList[i],
                           newWork: false,
                           description: element.data["Description"],
                           startDate: element.data["Start Date"],
                           endDate: element.data["End Date"],
                           priority: element.data["Priority"],
                           document: element.data["Document"],
                         )));
                       },
                       child: Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                           Text(
                             element.data["Description"].toString(),
                             style: TextStyle(
                                 color: Colors.grey[800],
                                 fontSize: 15,
                                 fontWeight: FontWeight.w500
                             ),
                           ),
                           Icon(
                             Icons.arrow_right,
                             color: Colors.grey[800],
                             size: 30.0,
                           )
                         ],
                       ),
                     ),
                   )
               );
             });
           });
           _populateTheDisplayWidget(_employeeList[i], individualWork);
        });
      }
    });
    isLoading = false;
  }

  _populateTheDisplayWidget(String employeeName, List<Container> employeeWork){
    setState(() {
      _employeeWorkDetails.add(
        PerEmployeeWork(
          isExpanded: false,
          employeeName: employeeName,
          body: Container(
            child: Column(
              children: [
                Divider(),
                TextHeading(text: "Assigned Work",),
                Column(
                  children: employeeWork,
                )
              ],
            ),
          ),
            circle: ClipOval(
              child: Material(
                color: kLightBlue,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.5, horizontal: 14.5),
                  child: employeeWork.length > 0
                    ? Icon(
                    Icons.work,
                    color: Colors.white,
                    size: 18.0,
                  )
                      : Icon(
                    Icons.free_breakfast,
                    color: Colors.white,
                    size: 18.0,
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

    _getEmployeeList();
  }

  @override
  Widget build(BuildContext context) {

    listCriteria =ListView(
      physics: BouncingScrollPhysics(),
      children: [
        Padding(
          padding: EdgeInsets.all(10.0),
          child: ExpansionPanelList(
            expansionCallback: (int index, bool isExpanded) {
              setState(() {
                _employeeWorkDetails[index].isExpanded = !_employeeWorkDetails[index].isExpanded;
              });
            },
            children: _employeeWorkDetails.map((PerEmployeeWork item) {
              return ExpansionPanel(
                  headerBuilder: (BuildContext context, bool isExpanded) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 6.5),
                      child: ListTile(
                        leading: item.circle,
                        title: Text(
                          item.employeeName,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Container(
                          height: 30.0,
                          margin: EdgeInsets.only(right: 65.0, top: 6.0, bottom: 7.0),
                          child: RaisedButton(
                            color: kLightBlue,
                            onPressed: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => AssignWork(
                                name: item.employeeName,
                                newWork: true,
                              )));
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(6.0))
                            ),
                            child: Text(
                              "ASSIGN WORK",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.0
                              ),
                            ),
                          ),
                        )
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
      body: Stack(
        children: [
          SafeArea(
            child: Stack(
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
                          "Work Details",
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
                )
              ],
            ),
          ),

          isLoading
          ? circularProgress()
              : SizedBox(),
        ],
      )
    );
  }
}






class PerEmployeeWork{
  bool isExpanded;
  final String employeeName;
  final Widget body;
  final Widget circle;

  PerEmployeeWork({this.isExpanded, this.employeeName, this.body, this.circle});
}
