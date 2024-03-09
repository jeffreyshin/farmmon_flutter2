// Copyright 2023 Shin Jae-hoon. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';
import 'dart:convert';
import 'package:farmmon_flutter/view/splash.dart';
import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

//import 'package:csv/csv.dart';

import 'package:archive/archive_io.dart';
// import 'package:fluttertoast/fluttertoast.dart';
import 'package:farmmon_flutter/viewmodel/my_location.dart';
// import 'package:farmmon_flutter/weather.dart';

import 'package:farmmon_flutter/viewmodel/kakao_login.dart';
import 'package:farmmon_flutter/viewmodel/main_view_model.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;

import 'package:farmmon_flutter/viewmodel/google_login.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:farmmon_flutter/view/view_homepage.dart';

import 'model/model.dart';

// import 'package:flutter/services.dart';
// import 'dart:ffi';
// import 'package:flutter/cupertino.dart';
// import 'package:farmmon_flutter/util/extensions/color_extensions.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'dart:ui';
// import 'package:dio/dio.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// var pp = 0;
var ppfarm = 0;
var farmNo = 2;
var signinMethod = 'Kakao';
var lastDatetime = '';
var wMAXX = 72;
var someDAYS = 16;
var difference = 0;
var statusCode = 0;

var viewModel = MainViewModel(GoogleLogin());
kakao.User? user;

Map<String, dynamic> firestoreData = {
  'email': "",
  'apikey': "",
  'username': ""
};

Map<String, String?> loginInfo = {
  'uid': "",
  'displayName': "",
  'email': "",
  'photoURL': ""
};

Map farm1 = {
  'farmName': '기본농장',
  'facilityName': '1번온실',
  'serviceKey': 'v8UppqLzoaGtPqyRaEXiRCM8KAukLvivR',
};
Map farm2 = {
  'farmName': '농장2',
  'facilityName': '1번온실',
  'serviceKey': 'r64f2ea0960a74f4f8c48a0b3a6953973',
};

var farmList = [farm1, farm2];

///////////////////////////////////////////////////////////

final today = DateTime.now();
final somedaysago = today.subtract(Duration(days: someDAYS));
final somedaysagoString = DateFormat('yyyyMMdd HH00').format(somedaysago);

Sensor sensorBlank = Sensor(
  customDt: somedaysagoString,
  temperature: 0.0,
  humidity: 0.0,
  cotwo: 0.0,
  leafwet: 0.0,
  gtemperature: 0.0,
  quantum: 0.0,
  xlabel: " ",
);

var sensorList = List<Sensor>.filled(wMAXX, sensorBlank, growable: true); //
var sensorLists = List<List<Sensor>>.filled(2, sensorList, growable: true);

/////////////////////////////////////////////////////////////

final somedaysagoString2 = DateFormat('yyyy-MM-dd').format(somedaysago);

PINF pinfBlank = PINF(
  customDt: somedaysagoString2,
  anthracnose: 0.0,
  botrytis: 0.0,
  xlabel: " ",
);

var pinfList = List<PINF>.filled(50, pinfBlank, growable: true);
var pinfLists = List<List<PINF>>.filled(2, pinfList, growable: true);

void main() async {
  await Future.delayed(Duration(seconds: 1));
  kakao.KakaoSdk.init(nativeAppKey: '3dba5c41ff1963c8cac077f92b4def2a');
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  HttpOverrides.global = MyHttpOverrides();
  MyLocation home;
  getMyCurrentLocation();
  if (signinMethod == 'Kakao') {
    viewModel = MainViewModel(KakaoLogin());
  }
  if (signinMethod == 'Google') {
    viewModel = MainViewModel(GoogleLogin());
  }
  // if (!viewModel.isLoggedin) {
  // await viewModel.login(); // retrieve user information
  // }

  // if (!viewModel.isLogined) {
  //   await viewModel.login().then((value) {
  runApp(const SplashScreen());
  // });
  // }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: '농장보기(FarmMon)',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        debugShowCheckedModeBanner: false,
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var favorites = <WordPair>[];
  var pp = 0;
  var chart = 0;
  // var ppfarm = 0;

  var userMsg = '';

  Future prefsSave(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('farmNumber', farmNo);
    await prefs.setInt('myFarm', ppfarm);
    await prefs.setString('signinMethod', signinMethod);

    for (int i = 0; i < farmNo; i++) {
      print('prefs Save: $i / ${farmNo - 1} ${farmList[i]['farmName']}');

      await prefs.setString('farmName$i', farmList[i]['farmName']);
      await prefs.setString('facilityName$i', farmList[i]['facilityName']);
      await prefs.setString('serviceKey$i', farmList[i]['serviceKey']);
    }
  }

  Future prefsClear(BuildContext context) async {
    farmList[0] = farm1;
    farmList[1] = farm2;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    // print('prefs clear $farmNo');
    prefs.clear();
    if (farmNo > 2) {
      farmList.removeRange(2, farmNo);
      pinfLists.removeRange(2, farmNo);
      sensorLists.removeRange(2, farmNo);
    }
    final today = DateTime.now();
    final somedaysago = today.subtract(Duration(days: someDAYS));
    lastDatetime = DateFormat('yyyyMMdd HH00').format(somedaysago);

    for (int i = 0; i < 2; i++) {
      sensorList = List<Sensor>.filled(wMAXX, sensorBlank, growable: true); //
      sensorLists[i] = sensorList;
      String jsonString = jsonEncode(sensorList);
      await storage.writeJsonAsString('sensor$i.json', jsonString);

      pinfList = List<PINF>.filled(50, pinfBlank, growable: true);
      pinfLists[i] = pinfList;
      jsonString = jsonEncode(pinfList);
      await storage.writeJsonAsString('pinf$i.json', jsonString);
    }
    farmNo = 2;
    ppfarm = 0;
    await prefs.setInt('farmNumber', farmNo);
    await prefs.setInt('ppfarm', ppfarm);
    print('prefs cleared: only $farmNo farm left');

    if (Platform.isAndroid) showToast(context, "초기화 완료", Colors.blueAccent);
    notifyListeners();
  }

  void removeData(BuildContext context) async {
    if (ppfarm < 2) {
      sensorList =
          List<Sensor>.filled(wMAXX, sensorBlank, growable: true); // wMAXX
      sensorLists[ppfarm] = sensorList;
      String jsonString = jsonEncode(sensorList);
      await storage.writeJsonAsString('sensor$ppfarm.json', jsonString);

      pinfList = List<PINF>.filled(50, pinfBlank, growable: true);
      pinfLists[ppfarm] = pinfList;
      jsonString = jsonEncode(pinfList);
      await storage.writeJsonAsString('pinf$ppfarm.json', jsonString);
      if (Platform.isAndroid) {
        showToast(context, "${ppfarm + 1}번째 농장 데이터만 삭제했습니다", Colors.blueAccent);
      }
      print("ppfarm ${ppfarm + 1} 농장 데이터만 삭제했습니다");
    }
    print("$ppfarm 데이터만 삭제");

    if (ppfarm >= 2) {
      final today = DateTime.now();
      final somedaysago = today.subtract(Duration(days: someDAYS));
      lastDatetime = DateFormat('yyyyMMdd HH00').format(somedaysago);
      print('prefs cleared: only $farmNo farm left');

      sensorLists.removeAt(ppfarm);
      String jsonString = jsonEncode(sensorList);
      await storage.writeJsonAsString('sensor$ppfarm.json', jsonString);

      // pinfList = List<PINF>.filled(50, pinfBlank, growable: true);
      // pinfLists[ppfarm] = pinfList;
      pinfLists.removeAt(ppfarm);
      jsonString = jsonEncode(pinfList);
      await storage.writeJsonAsString('pinf$ppfarm.json', jsonString);
      farmList.removeAt(ppfarm);
      print("$ppfarm 삭제");
      if (Platform.isAndroid) {
        showToast(context, "${ppfarm + 1}번째 농장을 삭제했습니다", Colors.blueAccent);
      }
      print("ppfarm ${ppfarm + 1} 농장을 삭제했습니다");
      ppfarm--;
      farmNo = farmNo - 1;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('farmNumber', farmNo);
      await prefs.setInt('ppfarm', ppfarm);
    }

    notifyListeners();
  }

  Future apiRequestIOT(BuildContext context) async {
    var urlanthracnose = 'https://anthracnose-api.camp.re.kr/Anthracnose';
    try {
      http.Response response3 = await http.post(
        Uri.parse(urlanthracnose),
        headers: <String, String>{
          'Content-Type': 'application/json',
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: "",
      );
      print("==================");
      print(response3.body.toString());
    } catch (e) {
      // if (Platform.isAndroid) {
      //   showToast("모델호출 실패. 다시한번 시도해주세요", Colors.redAccent);
      // }
      print("API서버 깨우기");
      print(
          e.toString()); // checking an error at the first api call, 2023-07-31
    }

    // #########################################3

    var urliot = 'http://iot.rda.go.kr/api';
    var apikey = farmList[ppfarm]['serviceKey'];

    // IOT portal data update
    var now = DateTime.now();
    lastDatetime = sensorLists[ppfarm][0].customDt.toString();
    lastDatetime = "${lastDatetime.substring(0, 11)}00";
    print(
        "IOT()- ppfarm: $ppfarm - lastDateTime: $lastDatetime now we are at IOT()");

    difference = int.parse(
        now.difference(DateTime.parse(lastDatetime)).inHours.toString());
    if (difference > 380) difference = 380;
    print('IOT()- ppfarm: $ppfarm - Difference: $difference');
    String formatDate = DateFormat('yyyyMMdd').format(now);
    String formatTime = DateFormat('HH').format(now);

    var urliotString = "$urliot/$apikey/$formatDate/$formatTime";
    var uriiot = Uri.parse(urliotString);

    // var deltaT = int.parse(formatTime);
    // var deltaT12 = deltaT % 12;
    // deltaT = 24;
    // if (deltaT < 12) deltaT = deltaT + deltaT12;
    // now = now.subtract(Duration(hours: deltaT + deltaT12));

    try {
      // print('before for loop');
      int ii = 0;
      for (int i = 0; i < difference; i++) {
        String formatDate = DateFormat('yyyyMMdd').format(now);
        String formatTime = DateFormat('HH').format(now);
        urliotString = "$urliot/$apikey/$formatDate/$formatTime";

        ///print(urliot2);

        HttpClient().idleTimeout = const Duration(seconds: 10);

        uriiot = Uri.parse(urliotString);
        http.Response response = await http.get(uriiot);
        now = now.subtract(Duration(hours: 1));
        // print(response.body);
        statusCode = response.statusCode;
        if (response.statusCode != 200) {
          if (Platform.isAndroid) {
            showToast(context, "네트워크 상태를 확인해주세요", Colors.redAccent);
          }
          print("네트워크 상태를 확인해주세요");
          return -1;
        }
        var jsonObj = jsonDecode(response.body);
        if (jsonObj['datas'].length <= 0) {
          if (Platform.isAndroid) {
            showToast(context, "일부 데이터를 가져오지 못했습니다", Colors.redAccent);
          }
          print('일부 데이터를 가져오지 못했습니다');
          continue;
          // return 0;
        }
        var customDT = jsonObj['datas'][0]['custom_dt'].toString();
        customDT = DateFormat('yyyyMMdd HH00').format(DateTime.parse(customDT));
        Sensor nsensor = Sensor(
          customDt: customDT,
          temperature: double.parse(jsonObj['datas'][0]['temperature']),
          humidity: double.parse(jsonObj['datas'][0]['humidity']),
          cotwo: double.parse(jsonObj['datas'][0]['cotwo']),
          leafwet: double.parse(jsonObj['datas'][0]['leafwet']),
          gtemperature: double.parse(jsonObj['datas'][0]['gtemperature']),
          quantum: double.parse(jsonObj['datas'][0]['quantum']),
          xlabel: DateFormat('MM/dd HH').format(
            DateTime.parse(jsonObj['datas'][0]['custom_dt']),
          ),
        );

        // sensorList.insert(0, nsensor);
        sensorList.insert(ii, nsensor);
        ii++;
        print('IOT()- $i----${nsensor.customDt}');
        var progress = ((i + 1) / difference) * 100;
        userMsg = "${progress.toStringAsFixed(0)}%";
        notifyListeners();
      }
    } catch (e) {
      if (Platform.isAndroid) {
        showToast(context, "네트워크 상태를 확인해주세요", Colors.redAccent);
      }
      print("네트워크 상태를 확인해주세요");
      notifyListeners();
      return -1;
    }

    sensorLists[ppfarm] = sensorList;

    // print('after for loop');
    // print(statusCode);
    userMsg = "";
    notifyListeners();
    return statusCode;
  }

  Future apiRequestPEST(BuildContext context) async {
    var encoder = ZipFileEncoder();
    final dir = await getApplicationDocumentsDirectory();
    // Directory dir = Directory('/storage/emulated/0/Documents ');
    var test = sensorLists[ppfarm][0].customDt.toString();
    print("apiPEST() - ppfarm: $ppfarm  - test: $test");
    String formatTime = '';
    var kk = sensorLists[ppfarm].length;
    // kk = 380;    2023-09-24
    var k = 0;
    for (k = kk - 1; k >= 0; k--) {
      var v1 = sensorLists[ppfarm][k].customDt.toString();
      var d1 = DateTime.parse(v1);
      formatTime = DateFormat('HH').format(d1);
      if (formatTime == '12') {
        print("12H found!!");
        print(sensorLists[ppfarm][k].customDt.toString());
        break;
      }
    }

    if (formatTime != '12') {
      print("12시를 못찾았습니다");
      return -1;
    }

    var weatherString = 'datetime,temperature,humidity,leafwet\n';
    for (int j = k; j >= 0; j--) {
      var v1 = sensorLists[ppfarm][j].customDt.toString();
      var v2 = sensorLists[ppfarm][j].temperature.toString();
      var v3 = sensorLists[ppfarm][j].humidity.toString();
      var v4 = sensorLists[ppfarm][j].leafwet.toString();
      weatherString = "$weatherString$v1,$v2,$v3,$v4\n";
    }
    // print(weatherString);
    // zip weather.csv
    await (File('${dir.path}/weather.csv').writeAsString(weatherString))
        .then((value) {
      encoder.create('${dir.path}/input.zip');
      encoder.addFile(File('${dir.path}/weather.csv'));
      encoder.close();
    });

    // base64 encoding
    var z = await File('${dir.path}/input.zip').readAsBytes();
    String token = base64.encode(z);
/*
    var body = jsonEncode({
      'Input': token,
      'type': "file",
    });
*/

/////////////////////////////////////
// anthracnose
/////////////////////////////////////

    // http request
    var urlanthracnose = 'https://anthracnose-api.camp.re.kr/Anthracnose';
    var urlbotrytis = 'https://botrytis-api.camp.re.kr/Botrytis';

    var apikey = "61cdc660a46f4fcc93004de201c58dff";
    var param = jsonEncode({'apiKey': apikey});

// create session
    var urlm = "$urlanthracnose/connect";
//    print(urlm);
    http.Response responseC = await http.post(
      Uri.parse(urlm),
      headers: <String, String>{
        'Content-Type': 'application/json',
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: param,
    );
    var jobID = responseC.body;
    print("jobID호출");
    print(jobID);

// launch model by session key
    param = jsonEncode({'apiKey': apikey, 'jobid': jobID, 'file': token});
    urlm = "$urlanthracnose/launch";
    http.Response responseL = await http.post(
      Uri.parse(urlm),
      headers: <String, String>{
        'Content-Type': 'application/json',
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: param,
    );
    var rL = responseL.body;
    print(rL);

// get Status model
    urlm = "$urlanthracnose/getStatus";
    param = jsonEncode({'apiKey': apikey, 'jobid': jobID});
    http.Response responseS = await http.post(
      Uri.parse(urlm),
      headers: <String, String>{
        'Content-Type': 'application/json',
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: param,
    );
    var rS = responseS.body;
    print(rS);

    if (responseS.statusCode == 200) {
      while (true) {
        if (responseS.body == "completed") break;
        responseS = await http.post(
          Uri.parse(urlm),
          headers: <String, String>{
            'Content-Type': 'application/json',
            HttpHeaders.contentTypeHeader: 'application/json',
          },
          body: param,
        );
        await Future.delayed(Duration(seconds: 1));
      }
      rS = responseS.body;
      // print(rgetStatus);
    }

// get output
    urlm = "$urlanthracnose/getOutput";
    param = jsonEncode({'apiKey': apikey, 'jobid': jobID, 'variable': "all"});
    http.Response responseO = await http.post(
      Uri.parse(urlm),
      headers: <String, String>{
        'Content-Type': 'application/json',
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: param,
    );
    var rO = responseO.bodyBytes;
    // print("output A ######################################");
    // print(rgetOutput);

    await (File('${dir.path}/output.zip').writeAsBytes(rO));

// Decode the Zip file
    final bytes = rO;
    final archive = ZipDecoder().decodeBytes(bytes);

// Extract the contents of the Zip archive to disk.
    for (final file in archive) {
      final filename = file.name;
      if (file.isFile) {
        final data = file.content as List<int>;
        File('${dir.path}/$filename')
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
      } else {
        File('${dir.path}/$filename').create(recursive: true);
      }
    }

// Read the Zip file from disk.
    var rrr = await File('${dir.path}/output.csv').readAsString();
    print(rrr);
// remove session
    urlm = "$urlanthracnose/disconnect";
    param = jsonEncode({'apiKey': apikey, 'jobid': jobID});
    http.Response responseD = await http.post(
      Uri.parse(urlm),
      headers: <String, String>{
        'Content-Type': 'application/json',
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: param,
    );
    var rD = responseD.body;
    print(rD);

    // http request
    // try {
/*
    http.Response response3 = await http.post(
      Uri.parse(urlanthracnose),
      headers: <String, String>{
        'Content-Type': 'application/json',
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: body,
    );
    var r = response3.body;
    print(r);
*/

//////////////////////////////////////////////////////////////
    ///

    var outputA = <output>[];
    File file = File('${dir.path}/output.csv');
    outputA = file
        .readAsLinesSync()
        .skip(1) // Skip the header row
        .map((line) {
      final parts = line.split(',');
      return output(
          parts[0],
          parts[1],
          double.tryParse(parts[2]),
          double.tryParse(parts[3]),
          double.tryParse(parts[4])! * 100.0,
          double.tryParse(parts[5]));
    }).toList();

//    List<List<dynamic>> outputA = CsvToListConverter().convert(rrr);

    // print(outputA[0].date);
    // print(outputA[0].type);

    // if (Platform.isAndroid) {
    //   showToast(
    //       context, "${outputA[0].date}, ${outputA[0].type}", Colors.redAccent);
    // }

/*
    var r = rrr.replaceAll("\\", "");
    print(r);
    var i = r.indexOf('output');
    var ii = r.indexOf("}]");
    if (ii < 0) {
      if (Platform.isAndroid) {
        showToast(context, "기상데이터는 12시부터 시작해야합니다", Colors.redAccent);
      }
      print("기상데이터는 12시부터 시작해야합니다");
      return 0;
    }
    var rr = r.substring(i + 10, ii + 2);
    final outputA = json.decode(rr);
*/

/////////////////////////////////////
// botrytis
/////////////////////////////////////

// create session
    var urlm2 = "$urlbotrytis/connect";
//    print(urlm2);
    http.Response responseC2 = await http.post(
      Uri.parse(urlm2),
      headers: <String, String>{
        'Content-Type': 'application/json',
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: param,
    );
    var jobID2 = responseC2.body;
    print("jobID호출");
    print(jobID2);

// launch model by session key
    param = jsonEncode({'apiKey': apikey, 'jobid': jobID2, 'file': token});
    urlm2 = "$urlbotrytis/launch";
    http.Response responseL2 = await http.post(
      Uri.parse(urlm2),
      headers: <String, String>{
        'Content-Type': 'application/json',
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: param,
    );
    var rL2 = responseL2.body;
    print(rL2);

// get Status model
    urlm2 = "$urlbotrytis/getStatus";
    param = jsonEncode({'apiKey': apikey, 'jobid': jobID2});
    http.Response responseS2 = await http.post(
      Uri.parse(urlm2),
      headers: <String, String>{
        'Content-Type': 'application/json',
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: param,
    );
    var rS2 = responseS2.body;
    print(rS2);

    if (responseS2.statusCode == 200) {
      while (true) {
        if (responseS2.body == "completed") break;
        responseS2 = await http.post(
          Uri.parse(urlm2),
          headers: <String, String>{
            'Content-Type': 'application/json',
            HttpHeaders.contentTypeHeader: 'application/json',
          },
          body: param,
        );
        await Future.delayed(Duration(seconds: 1));
      }
      rS2 = responseS2.body;
      // print(rgetStatus2);
    }

// get output
    urlm2 = "$urlbotrytis/getOutput";
    param = jsonEncode({'apiKey': apikey, 'jobid': jobID2, 'variable': "all"});
    http.Response responseO2 = await http.post(
      Uri.parse(urlm2),
      headers: <String, String>{
        'Content-Type': 'application/json',
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: param,
    );
    var rO2 = responseO2.bodyBytes;
    // print("outputB ##############################");
    // print(rgetOutput2);

    await (File('${dir.path}/output.zip').writeAsBytes(rO2));

// Decode the Zip file
    final bytes2 = rO2;
    final archive2 = ZipDecoder().decodeBytes(bytes2);

// Extract the contents of the Zip archive to disk.
    for (final file in archive2) {
      final filename = file.name;
      if (file.isFile) {
        final data = file.content as List<int>;
        File('${dir.path}/$filename')
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
      } else {
        File('${dir.path}/$filename').create(recursive: true);
      }
    }

// Read the Zip file from disk.
    var rrr2 = await File('${dir.path}/output.csv').readAsString();
    print(rrr2);

// remove session
    urlm2 = "$urlbotrytis/disconnect";
    param = jsonEncode({'apiKey': apikey, 'jobid': jobID2});
    http.Response responseD2 = await http.post(
      Uri.parse(urlm2),
      headers: <String, String>{
        'Content-Type': 'application/json',
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: param,
    );
    var rD2 = responseD2.body;
    print(rD2);

/*
    http.Response response2 = await http.post(
      Uri.parse(urlbotrytis),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: body,
    );
*/

    var outputB = <output>[];
    File file2 = File('${dir.path}/output.csv');
    outputB = file2
        .readAsLinesSync()
        .skip(1) // Skip the header row
        .map((line) {
      final parts = line.split(',');
      return output(
          parts[0],
          parts[1],
          double.tryParse(parts[2]),
          double.tryParse(parts[3]),
          double.tryParse(parts[4])! * 100.0,
          double.tryParse(parts[5]));
    }).toList();

    // if (Platform.isAndroid) {
    //   showToast(
    //       context, "${outputB[0].date}, ${outputB[0].type}", Colors.redAccent);
    // }

//    List<List<dynamic>> outputB = CsvToListConverter().convert(rrr);
//    print(outputB);
//    print(outputB);

/*
    var r2 = rrr2.replaceAll("\\", "");
    print(r2);

    var i2 = r2.indexOf('output');
    var ii2 = r2.indexOf("}]");
    var rr2 = r2.substring(i2 + 10, ii2 + 2);
    final outputB = json.decode(rr2);

    // print(rr);
    // print(rr2);
    // print(output.runtimeType);
*/

/////////////////////////////////////////////////////
    //pinf update
    pinfList = List<PINF>.filled(50, pinfBlank, growable: true);
    pinfLists[ppfarm] = pinfList;
    int j = outputA.length - 1;
    int jj = j;
    for (int i = 0; i <= jj; i++) {
      var customDT = outputA[j].date;
      double? PINFA = outputA[j].PINF;
      double? PINFB = outputB[j].PINF;

      PINF npinf = PINF(
        customDt: customDT,
        anthracnose: PINFA,
        botrytis: PINFB,
        xlabel: DateFormat('MM/dd').format(
          DateTime.parse(outputA[j].date),
        ),
      );
      j--;

      //        botrytis: double.parse((outputB[j].PINF).toStringAsFixed(1)),

      // pinfList.insert(i, npinf);
      pinfLists[ppfarm].insert(i, npinf);
      // print(customDT.toString());
      // print("apiPEST() - pinfList update, ppfarm: $ppfarm");

      notifyListeners();
      // print('$j: $custom_dt');
    }
    // } catch (e) {
    //   if (Platform.isAndroid) {
    //     showToast("모델호출 실패. 다시한번 시도해주세요", Colors.redAccent);
    //   }
    //   print("모델호출 실패. 다시한번 시도해주세요");
    //   print(
    //       e.toString()); // checking an error at the first api call, 2023-07-31
    //   notifyListeners();
    //   return -1;
    // }

    return 0;
  }

  void getData() {
    notifyListeners();
  }

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  void toggleFavorite() {
    // if (favorites.contains(current)) {
    //   favorites.remove(current);
    // } else {
    //   favorites.add(current);
    // }
    notifyListeners();
  }
}
