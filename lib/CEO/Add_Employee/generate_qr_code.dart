import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';

class DisplayQRCode extends StatefulWidget {
  @override
  _DisplayQRCodeState createState() => _DisplayQRCodeState();

  DisplayQRCode({this.code});

  final String code;
}

class _DisplayQRCodeState extends State<DisplayQRCode> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SafeArea(
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
                            "QR Code",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 20.0,
                                letterSpacing: 1.0
                            ),
                          ),
                          IconButton(
                            onPressed: (){},
                            icon: FaIcon(
                                FontAwesomeIcons.qrcode,
                            ),
                            color: Colors.black,
                            iconSize: 20.0,

                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Text(
                  "Allow the Employee to Scan the Code below, \n So that the Employee can make a safe Registration under the Company",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[800],
                    letterSpacing: 0.5,
                    fontSize: 15.0
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: Container(
                  height: 200.0,
                  width: 200.0,
                  child: Card(
                    elevation: 2.0,
                    child: QrImage(
                      data: widget.code,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
