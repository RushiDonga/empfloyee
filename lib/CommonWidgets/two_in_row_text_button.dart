import 'package:flutter/material.dart';

class TwoInRowTextButton extends StatelessWidget {

  TwoInRowTextButton({@required this.text, @required this.buttonText, @required this.color, @required this.onButtonPressed});
  final String text;
  final String buttonText;
  final Color color;
  final dynamic onButtonPressed;

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
            Padding(
              padding: EdgeInsets.only(top: 12.0),
              child: Text(
                text,
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    fontSize: 17.0
                ),
              ),
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
                color: Colors.white,
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