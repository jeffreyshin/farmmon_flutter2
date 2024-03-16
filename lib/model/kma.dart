import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class KMA {
  final String today2amUrl; //최저, 최고 기온
  final String shortTermWeatherUrl; //단기예보
  final String currentWeatherUrl; //초단기 실황
  final String superShortWeatherUrl; //초단기 예보
  final String airConditionUrl; //대기오염 정보
  final String ASOSUrl;

  KMA(this.today2amUrl, this.shortTermWeatherUrl, this.currentWeatherUrl,
      this.superShortWeatherUrl, this.airConditionUrl, this.ASOSUrl);

  //최저, 최고기온 json
  Future<dynamic> getToday2amData() async {
    http.Response response = await http.get(Uri.parse(today2amUrl));
    if (response.statusCode == 200) {
      String jsonData = response.body;
      var parsingData = jsonDecode(jsonData); //json형식 문자열을 배열 또는 객체로 변환하는 함수
      // print(parsingData);
      return parsingData;
    }
  }

  //단기예보 json
  Future<dynamic> getShortTermWeatherData() async {
    http.Response response = await http.get(Uri.parse(shortTermWeatherUrl));
    if (response.statusCode == 200) {
      String jsonData = response.body;
      var parsingData = jsonDecode(jsonData);
      // print(parsingData);
      return parsingData;
    }
  }

  //초단기 실황 json
  Future<dynamic> getCurrentWeatherData() async {
    http.Response response = await http.get(Uri.parse(currentWeatherUrl));
    if (response.statusCode == 200) {
      String jsonData = response.body;
      var parsingData = jsonDecode(jsonData);
      // print(parsingData);
      return parsingData;
    }
  }

  //초단기 예보 json
  Future<dynamic> getSuperShortWeatherData() async {
    http.Response response = await http.get(Uri.parse(superShortWeatherUrl));
    if (response.statusCode == 200) {
      String jsonData = response.body;
      var parsingData = jsonDecode(jsonData);
      // print(parsingData);
      return parsingData;
    }
  }

  //에어코리아 json
  Future<dynamic> getAirConditionData() async {
    http.Response response = await http.get(Uri.parse(airConditionUrl));
    if (response.statusCode == 200) {
      String jsonData = response.body;
      var parsingData = jsonDecode(jsonData);
      // print(parsingData);
      return parsingData;
    }
  }

  // ASOS
  Future<dynamic> getASOSData() async {
    http.Response response = await http.get(Uri.parse(ASOSUrl));
    if (response.statusCode == 200) {
      String jsonData = response.body;
      var parsingData = jsonDecode(jsonData);
      // print(parsingData);
      return parsingData;
    }
  }
}

DateTime now = DateTime(2023);
var baseDate;
var baseTime;

//오늘 날짜 20201109 형태로 리턴
String getSystemTime() {
  return DateFormat("yyyyMMdd").format(now);
}

//어제 날짜 20201109 형태로 리턴
String getYesterdayDate() {
  return DateFormat("yyyyMMdd")
      .format(DateTime.now().subtract(Duration(days: 1)));
}

void shortWeatherDate() {
  if (now.hour < 2 || (now.hour == 2 && now.minute <= 10)) {
    //0시~2시 10분 사이 예보
    baseDate = getYesterdayDate(); //어제 날짜
    baseTime = "2300";
  } else if (now.hour < 5 || (now.hour == 5 && now.minute <= 10)) {
    //2시 11분 ~ 5시 10분 사이 예보
    baseDate = getSystemTime();
    baseTime = "0200";
  } else if (now.hour < 8 || (now.hour == 8 && now.minute <= 10)) {
    //5시 11분 ~ 8시 10분 사이 예보
    baseDate = getSystemTime();
    baseTime = "0500";
  } else if (now.hour < 11 || (now.hour == 11 && now.minute <= 10)) {
    //8시 11분 ~ 11시 10분 사이 예보
    baseDate = getSystemTime();
    baseTime = "0800";
  } else if (now.hour < 14 || (now.hour == 14 && now.minute <= 10)) {
    //11시 11분 ~ 14시 10분 사이 예보
    baseDate = getSystemTime();
    baseTime = "1100";
  } else if (now.hour < 17 || (now.hour == 17 && now.minute <= 10)) {
    //14시 11분 ~ 17시 10분 사이 예보
    baseDate = getSystemTime();
    baseTime = "1400";
  } else if (now.hour < 20 || (now.hour == 20 && now.minute <= 10)) {
    //17시 11분 ~ 20시 10분 사이 예보
    baseDate = getSystemTime();
    baseTime = "1700";
  } else if (now.hour < 23 || (now.hour == 23 && now.minute <= 10)) {
    //20시 11분 ~ 23시 10분 사이 예보
    baseDate = getSystemTime();
    baseTime = "2000";
  } else if (now.hour == 23 && now.minute >= 10) {
    //23시 11분 ~ 24시 사이 예보
    baseDate = getSystemTime();
    baseTime = "2300";
  }
}
