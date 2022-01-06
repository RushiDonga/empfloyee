class GeneralInfo{

  String getTodayDateYMD(){
    String strYear = DateTime.now().year.toString();
    String strMonth;
    String strDay;
    int month = DateTime.now().month;
    int day = DateTime.now().day;

    if(month < 10){
      strMonth = "0" + DateTime.now().month.toString();
    }else{
      strMonth = DateTime.now().month.toString();
    }

    if(day < 10){
      strDay = "0" + DateTime.now().day.toString();
    }else{
      strDay = DateTime.now().day.toString();
    }
    print(DateTime.now().weekday);
    return strYear + "-" + strMonth + "-" + strDay;
  }

  String getTodayDateDMY(){
    String strYear = DateTime.now().year.toString();
    String strMonth;
    String strDay;
    int month = DateTime.now().month;
    int day = DateTime.now().day;

    if(month < 10){
      strMonth = "0" + DateTime.now().month.toString();
    }else{
      strMonth = DateTime.now().month.toString();
    }

    if(day < 10){
      strDay = "0" + DateTime.now().day.toString();
    }else{
      strDay = DateTime.now().day.toString();
    }
    print(DateTime.now().weekday);
    return strDay + "-" + strMonth + "-" + strYear;
  }

  bool checkIfLeap(int year) {
    if (year % 400 == 0) {
      return true;
    } else if (year % 100 == 0) {
      return false;
    } else if (year % 4 == 0) {
      return true;
    } else {
      return false;
    }
  }
}