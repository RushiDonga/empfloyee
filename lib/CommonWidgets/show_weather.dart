import 'dart:convert';

import 'package:employee/CEO/NavigationPages/today_page_ceo.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';

class DisplayWeather extends StatefulWidget {
  @override
  _DisplayWeatherState createState() => _DisplayWeatherState();
}

class _DisplayWeatherState extends State<DisplayWeather> {

  DateTime now = DateTime.now();

  double latitude = 21.4963495;
  double longitude = 71.1022486;

  String description = "";
  String cityName = "";
  int temperature = 0;
  String greetings = "";
  String weatherImage = "assets/sky.png";

  _getWeatherInfo() async {
    http.Response response = await http.get("https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$apiKey");
    if(response.statusCode == 200){
      String data = response.body;
      var decodedData = jsonDecode(data);

      print(response.body);

      setState(() {
        description = decodedData["weather"][0]["description"];
        cityName = decodedData["name"];
        temperature = (decodedData["main"]["temp"] - 272).round();

        var timeNow = int.parse(DateFormat("kk").format(now));

        if(description.contains("rain")){
          weatherImage =  "assets/rain.png";
        }else if(description.contains("cloud")){
          weatherImage =  "assets/cloudy.png";
        }else if(description.contains("clear")){
          weatherImage = "assets/sky.png";
        }else if(timeNow <= 12){
          weatherImage =  "assets/morning.png";
        }else if((timeNow > 12) && (timeNow <= 16)){
          weatherImage =  "assets/sky.png";
        }else if((timeNow > 16) && (timeNow < 20)){
          weatherImage = "assets/sunset.png";
        }else{
          weatherImage =  "assets/moon.png";
        }
      });
    }else{
      print(response.statusCode);
    }
  }

   _getGreetings(){

    var timeNow = int.parse(DateFormat("kk").format(now));
    if(timeNow <= 12){
      greetings =  "Good Morning";
    }else if((timeNow > 12) && (timeNow <= 16)){
      greetings =  "Good Afternoon";
    }else if((timeNow > 16) && (timeNow < 20)){
      greetings =  "Good Evening";
    }else{
      greetings = "Good Night";
    }
  }

  @override
  void initState() {
    super.initState();

    _getGreetings();
    _getWeatherInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
      width: MediaQuery.of(context).size.width  ,
      decoration: BoxDecoration(
          color: kLightBlue,
          borderRadius: BorderRadius.all(Radius.circular(10.0))
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  textBaseline: TextBaseline.alphabetic,
                  children: <Widget>[
                    Text(
                      "$temperature",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 60.0
                      ),
                    ),
                    SizedBox(
                      width: 5.0,
                    ),
                    Column(
                      children: <Widget>[
                        Text(
                          "o",
                          style: TextStyle(
                              color: Colors.white
                          ),
                        ),
                        Text(
                          "C",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15.0
                          ),
                        ),
                        SizedBox(
                          height: 20.0,
                        )
                      ],
                    )
                  ],
                ),
                Text(
                  "$description",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: description.length > 13 ? 20 : 23
                  ),
                ),
                Text(
                  "$cityName",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0
                  ),
                )
              ],
            ),
            Column(
              children: <Widget>[
                Image(
                  image: AssetImage("$weatherImage"),
                  height: 100.0,
                ),
                Text(
                  "$greetings Rushi",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15.0
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}


