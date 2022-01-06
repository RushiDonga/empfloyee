import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../constants.dart';
import 'add_todo.dart';
import '../../Globals.dart' as globals;

final _fireStore = Firestore.instance;

class TodoList extends StatefulWidget {
  @override
  _TodoListState createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
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
                          "Todo's List",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                              letterSpacing: 1.0
                          ),
                        ),
                        IconButton(
                          onPressed: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => Todo(
                              state: "new",
                            )));
                          },
                          icon: FaIcon(FontAwesomeIcons.plusCircle),
                          color: Colors.black,
                          iconSize: 20.0,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            GetTodo()
          ],
        ),
      ),
    );
  }
}

class GetTodo extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _fireStore.collection(globals.companyName).document("CEO TODOs").collection("Todo").snapshots(),
      builder: (context, snapshots){
        if(snapshots.hasData){
          final todos = snapshots.data.documents;
          List<DisplayTodos> displayTodo = [];
          for(var todo in todos){
            final tag = todo.data["tag"];
            final description = todo.data["Description"];

            final displayTodoWidget = DisplayTodos(
              tag: tag,
              description: description,
            );
            displayTodo.add(displayTodoWidget);
          }
          return Expanded(
            child: ListView(
              children: displayTodo,
            ),
          );
        }else{
          return Center(
            child: Text(""),
          );
        }
      },
    );
  }
}

class DisplayTodos extends StatelessWidget {

  DisplayTodos({this.tag, this.description});

  final String tag;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 20.0, top: 5.0, bottom: 5.0),
      child: Card(
        color: kLightBlue,
        margin: EdgeInsets.only(left: 0.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topRight: Radius.circular(15.0), bottomRight: Radius.circular(15.0))
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 6,
              child: GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Todo(
                    state: "HISTORY",
                    tag: tag,
                  )));
                },
                child: Card(
                  elevation: 0.2,
                  color: Colors.white,
                  margin: EdgeInsets.all(0.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(topRight: Radius.circular(15.0), bottomRight: Radius.circular(15.0)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                    child: Row(
                      children: <Widget>[
                        SizedBox(
                          width: 10.0,
                        ),
                        ClipOval(
                          child: Material(
                            color: kLightBlue,
                            child: InkWell(
                              child: SizedBox(
                                width: 45,
                                height: 45,
                                child: Center(
                                  child: Text(
                                    tag[0],
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20.0
                                    ),
                                  ),
                                ),
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
                              tag,
                              style: TextStyle(
                                  color: kLightBlue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17.0
                              ),
                            ),
                            SizedBox(
                              height: 3.0,
                            ),
                            Text(
                              description.length > 30 ? description.substring(0, 30) : description,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Colors.grey[900],
                                  fontSize: 14.0,
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                child:GestureDetector(
                  onTap: (){
                    _fireStore.collection(globals.companyName).document("CEO TODOs").collection("Todo").document(tag).delete();
                  },
                  child: Icon(
                    Icons.delete_forever,
                    color: Colors.white,
                    size: 28.0,
                  ),
                )
              ),
            )
          ],
        ),
      ),
    );
  }
}