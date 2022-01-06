import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:employee/Teams/info_page.dart';
import 'package:employee/constants.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../Globals.dart' as globals;
import 'create_teams.dart';

Firestore _fireStore = Firestore.instance;

class ViewTeamsCEO extends StatefulWidget {
  @override
  _ViewTeamsCEOState createState() => _ViewTeamsCEOState();
}

class _ViewTeamsCEOState extends State<ViewTeamsCEO> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column (
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
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
                        "Teams",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                          letterSpacing: 1.0
                        ),
                      ),
                      globals.position == "CEO"
                      ? GestureDetector(
                        onTap: (){
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CreateTeam(
                            enable: true,
                            showMoreOptions: true,
                          )));
                        },
                        child: Icon(
                          Icons.add_box,
                          color: Colors.black,
                          size: 25.0,
                        ),
                      )
                          : SizedBox(width: 10.0,)
                    ],
                  ),
                ),
              ),
            ),
            GetTeams()
          ],
        ),
      ),
    );
  }
}

class GetTeams extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _fireStore.collection(globals.companyName).document("Teams").collection("Teams").snapshots(),
      builder: (context, snapshots){
        if(snapshots.hasData){
          final teams = snapshots.data.documents;
          List<DisplayTeams> displayTeams = [];
          for(var team in teams){
            final tag = team.data["Tag"];
            final date = team.data["Create Date"];
            List<dynamic> members = team.data["Members"];

            if(team.data["Done"] == true){
              if(globals.position == "CEO"){
                final displayTeamsWidget = DisplayTeams(
                  teamName: tag,
                  createdOn: date,
                  teamLength: members,
                );

                displayTeams.add(displayTeamsWidget);
              }else if(globals.position == "Employee"){
                if(members.contains(globals.userName)){
                  final displayTeamsWidget = DisplayTeams(
                    teamName: tag,
                    createdOn: date,
                    teamLength: members,
                  );

                  displayTeams.add(displayTeamsWidget);
                }
              }
            }
          }

          return Expanded(
            child: ListView(
              children: displayTeams,
            ),
          );
        }else{
          return Center(
            child: Text(
              ""
            ),
          );
        }
      },
    );
  }
}

class DisplayTeams extends StatelessWidget {

  DisplayTeams({@required this.teamName, this.createdOn, @required this.teamLength});
  final String teamName;
  final String createdOn;
  final List<dynamic> teamLength;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10.0))
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        child: GestureDetector(
          onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => InfoPageOfTeams(
              teamTag: teamName,
              selectedEmployee: [],
            )));
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  ClipOval(
                    child: Material(
                      color: kLightBlue,
                      child: InkWell(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 11.0),
                          child: Text(
                            teamName[0],
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0
                            ),
                          )
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 15.0,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        teamName,
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 17.0
                        ),
                      ),
                      SizedBox(
                        height: 3.0,
                      ),
                      Text(
                        "Created on:- $createdOn",
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 15.0,
                        ),
                      )
                    ],
                  ),
                ],
              ),

              globals.position == "CEO"
              ? GestureDetector(
                onTap: (){
                  Alert(
                    context: context,
                    title: "Are you Sure?",
                    desc: "Want to remove $teamName",
                    buttons: [
                      DialogButton(
                        child: Text(
                          "YES",
                          style: TextStyle(color: Colors.white, fontSize: 15),
                        ),
                        onPressed: (){
                          Navigator.pop(context);

                          _fireStore.collection(globals.companyName).document("Teams").collection("Teams").document(teamName).delete();
                        },
                      ),
                      DialogButton(
                        child: Text(
                          "NO",
                          style: TextStyle(color: Colors.white, fontSize: 15),
                        ),
                        onPressed: (){
                          Navigator.pop(context);
                        },
                      )
                    ],
                  ).show();
                },
                child: Icon(
                  Icons.delete_forever,
                  color: kLightBlue,
                  size: 30.0,
                ),
              )
                  : SizedBox()
            ],
          ),
        ),
      ),
    );
  }
}


