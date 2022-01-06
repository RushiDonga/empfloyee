import 'package:url_launcher/url_launcher.dart';

class CommonMethods{

  launchURL(String url) async {
    print("URL $url");
    if(await canLaunch(url)){
      launch(url);
    }else{
      throw "COULD NOT LAUNCH $url";
    }
  }

  sendEmail(String email) async {
    final url = "mailto:$email?subject=&body=";
    if(await canLaunch(url)){
      await launch(url);
    }else{
      throw "COULD NOT LAUNCH $url";
    }
  }

  makePhoneCall(String phoneNumber) async {
    final url = "tel://$phoneNumber";
    if(await canLaunch(url)){
      await launchURL(url);
    }else{
      throw "COULD NOT LAUNCH $url";
    }
  }

}