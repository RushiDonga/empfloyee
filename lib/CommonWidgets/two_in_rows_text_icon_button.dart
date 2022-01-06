import 'package:flutter/material.dart';

class TwoInRowTextIconButton extends StatelessWidget {

  TwoInRowTextIconButton({@required this.text, @required this.iconData, @required this.color, @required this.onButtonPressed, @required this.buttonText});
  final String text;
  final IconData iconData;
  final Color color;
  final dynamic onButtonPressed;
  final String buttonText;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 10.0, left: 10.0),
                  child: Text(
                    text,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                Icon(
                  iconData,
                  color: Colors.black,
                  size: 20.0,
                )
              ],
            ),
            SizedBox(
              height: 10.0,
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 15.0),
              width: MediaQuery.of(context).size.width,
              child: RaisedButton(
                onPressed: onButtonPressed,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    side: BorderSide(color: Colors.white)
                ),
                color: color,
                child: Text(
                  buttonText,
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}