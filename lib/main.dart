// Copyright 2023 Shin Jae-hoon. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'package:farmmon_flutter/zoomable_chart.dart';
import 'package:farmmon_flutter/presentation/resources/app_resources.dart';
import 'package:farmmon_flutter/icons/custom_icons_icons.dart';
import 'package:archive/archive_io.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:farmmon_flutter/my_location.dart';
import 'package:farmmon_flutter/kma.dart';

import 'package:flutter/foundation.dart';
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
var lastDatetime = '';
var wMAXX = 72;
var someDAYS = 16;
var difference = 0;
var statusCode = 0;

Map farm1 = {
  'farmName': '기본농장',
  'facilityName': '1번온실',
  'serviceKey': 'r34df5d2d566049e2a809c41da915adc6',
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

var sensorList = List<Sensor>.filled(wMAXX, sensorBlank, growable: true);
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

/////////////////////////////////////////////////////////

class Sensor {
  String? customDt;
  double? temperature;
  double? humidity;
  double? cotwo;
  double? leafwet;
  double? gtemperature;
  double? quantum;
  String? xlabel;

  Sensor({
    this.customDt,
    this.temperature,
    this.humidity,
    this.cotwo,
    this.leafwet,
    this.gtemperature,
    this.quantum,
    this.xlabel,
  });

  factory Sensor.fromJson(Map<String, dynamic> json) => Sensor(
        customDt: json['custom_dt'],
        temperature: json['temperature'],
        humidity: json['humidity'],
        cotwo: json['cotwo'],
        leafwet: json['leafwet'],
        gtemperature: json['gtemperature'],
        quantum: json['quantum'],
        xlabel: json['xlabel'],
      );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['custom_dt'] = customDt;
    data['temperature'] = temperature;
    data['humidity'] = humidity;
    data['cotwo'] = cotwo;
    data['leafwet'] = leafwet;
    data['gtemperature'] = gtemperature;
    data['quantum'] = quantum;
    data['xlabel'] = xlabel;
    return data;
  }
}

/////////////////////////////////////////////

class SensorList {
  List<Sensor>? sensors;
  SensorList({this.sensors});

  factory SensorList.fromJson(String jsonString) {
    List<dynamic> listFromJson = json.decode(jsonString);
    List<Sensor> sensors = <Sensor>[];

    sensors = listFromJson.map((sensor) => Sensor.fromJson(sensor)).toList();
    return SensorList(sensors: sensors);
  }
}

///////////////////////////////////////////////////////////

class PINF {
  String? customDt;
  double? anthracnose;
  double? botrytis;
  String? xlabel;

  PINF({
    this.customDt,
    this.anthracnose,
    this.botrytis,
    this.xlabel,
  });

  factory PINF.fromJson(Map<String, dynamic> json) => PINF(
        customDt: json['custom_dt'],
        anthracnose: json['anthracnose'],
        botrytis: json['botrytis'],
        xlabel: json['xlabel'],
      );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['custom_dt'] = customDt;
    data['anthracnose'] = anthracnose;
    data['botrytis'] = botrytis;
    data['xlabel'] = xlabel;
    return data;
  }
}

//////////////////////////////////////////////////////////

class PINFList {
  List<PINF>? pinfs;
  PINFList({this.pinfs});

  factory PINFList.fromJson(String jsonString) {
    List<dynamic> listFromJson = json.decode(jsonString);
    List<PINF> pinfs = <PINF>[];

    pinfs = listFromJson.map((pinf) => PINF.fromJson(pinf)).toList();
    return PINFList(pinfs: pinfs);
  }
}

class AppStorage {
  Future readJsonAsString() async {
    try {
      for (int i = 0; i < farmNo; i++) {
        // final dir = await getExternalStorageDirectory();
        // Directory dir = Directory('/storage/emulated/0/Documents');
        // print('${dir.path}/sensor.json');
        print('readJsonAsString() - read json file $i');

        final path = await _localPath;
        final file = File('$path/sensor$ppfarm.json');
        final file2 = File('$path/pinf$ppfarm.json');

        // Read the file
        final routeFromJsonFile = await file.readAsString();

        sensorList =
            (SensorList.fromJson(routeFromJsonFile).sensors ?? <Sensor>[]);
        if (i < 2) sensorLists[i] = sensorList;
        if (i >= 2) sensorLists.add(sensorList);
        final routeFromJsonFile2 = await file2.readAsString();
        pinfList = (PINFList.fromJson(routeFromJsonFile2).pinfs ?? <PINF>[]);
        if (i < 2) pinfLists[i] = pinfList;
        if (i >= 2) pinfLists.add(pinfList);
      }
    } catch (e) {
      // If encountering an error, return 0
      if (Platform.isAndroid) showToast("읽기오류입니다", Colors.red);
      print("읽기오류입니다");
      return 0;
    }
  }

  Future readJsonAsString2() async {
    try {
      // final dir = await getExternalStorageDirectory();
      // Directory dir = Directory('/storage/emulated/0/Documents');
      // print('${dir.path}/sensor.json');

      final path = await _localPath;
      final file = File('$path/sensor$ppfarm.json');
      final file2 = File('$path/pinf$ppfarm.json');

      // Read the file
      final routeFromJsonFile = await file.readAsString();

      sensorList =
          (SensorList.fromJson(routeFromJsonFile).sensors ?? <Sensor>[]);
      sensorLists[ppfarm] = sensorList;
      final routeFromJsonFile2 = await file2.readAsString();
      pinfList = (PINFList.fromJson(routeFromJsonFile2).pinfs ?? <PINF>[]);
      pinfLists[ppfarm] = pinfList;
      print('readJsonAsString2() - read json file $ppfarm');
    } catch (e) {
      // If encountering an error, return 0
      print("읽기오류입니다");
      return 0;
    }
  }

  Future<File> writeJsonAsString(String? file, String? data) async {
    // final file = File('json/sensor.json');
    final dir = await getApplicationDocumentsDirectory();
    // Directory dir = Directory('/storage/emulated/0/Documents');
    // print('${dir.path}/sensor.json');
    print('writeJsonAsString() - writing json file: $file');
    if (Platform.isAndroid) showToast("파일을 저장했습니다", Colors.blueAccent);
    // notifyListeners();
    return File('${dir.path}/$file').writeAsString(data ?? '');
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }
}

final AppStorage storage = AppStorage();

/////////////////////////////////////////////////////////////
Future prefsLoad() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  farmNo = (prefs.getInt('farmNumber') ?? 2);
  // ppfarm = (prefs.getInt('myFarm') ?? 0);
  ppfarm = 0;
  await prefs.setInt('myFarm', ppfarm);

  final today = DateTime.now();
  final somedaysago = today.subtract(Duration(days: someDAYS));
  final somedaysagoString = DateFormat('yyyyMMdd HH00').format(somedaysago);
  lastDatetime = (prefs.getString('lastDatetime') ?? somedaysagoString);

  // prefs.setInt('farmNumber', farmNo);
  // prefs.setInt('myFarm', ppfarm);
  // await prefs.setString('lastDatetime', lastDatetime);
  print("prefsLoad() - lastDatetime: $lastDatetime");
  print('prefsLoad() - prefsLoad: $ppfarm / ${farmNo - 1}');

  // farmList[0]['farmName'] =
  //     (prefs.getString('farmName0') ?? farmList[0]['farmName']);
  // farmList[0]['facilityName'] =
  //     (prefs.getString('facilityName0') ?? farmList[0]['facilityName']);
  // farmList[0]['serviceKey'] =
  //     (prefs.getString('serviceKey0') ?? farmList[0]['serviceKey']);

  farmList.clear();
  farmList.add(farm1);
  farmList.add(farm2);
  for (int i = 2; i < farmNo; i++) {
    var farm3 = {};
    farm3['farmName'] =
        (prefs.getString('farmName$i') ?? farmList[0]['farmName']);
    farm3['facilityName'] =
        (prefs.getString('facilityName$i') ?? farmList[0]['facilityName']);
    farm3['serviceKey'] =
        (prefs.getString('serviceKey$i') ?? farmList[0]['serviceKey']);
    farmList.add(farm3);
    print('prefsLoad() - ppfarm: $i - ${farmList[i]['farmName']}');
    // print('prefsLoad() - ppfarm: $i - ${farmList[i]['facilityName']}');
    // print('prefsLoad() - ppfarm: $i - ${farmList[i]['serviceKey']}');
  }
  return 0;
}

/////////////////////////////////////////////////////////////

showToast(String message, Color colar) {
  return Fluttertoast.showToast(
    msg: message,
    gravity: ToastGravity.BOTTOM,
    backgroundColor: colar,
    fontSize: 20,
    textColor: Colors.white,
    toastLength: Toast.LENGTH_SHORT,
  );
}

//////////////////////////////////////////////////////////////

Future<void> getMyCurrentLocation() async {
  try {
    // LocationPermission permission = await Geolocator.requestPermission();
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    var long = position.longitude;
    var lat = position.latitude;
    if (Platform.isAndroid) showToast("location: $long, $lat", Colors.red);
    print('My current location: $long, $lat');
  } catch (e) {
    print('네트워크 연결을 확인해주세요');
  }
}

void addMyLicense() {
  //add License
  LicenseRegistry.addLicense(() async* {
    yield const LicenseEntryWithLineBreaks(<String>['farmmon_flutter'], '''
The BSD 2-Clause License

Copyright (c) 2023, Shin Jae-hoon
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
''');
  });
}
/////////////////////////////////////////////////////////////

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  HttpOverrides.global = MyHttpOverrides();
  MyLocation home;
  getMyCurrentLocation();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'FarmMon App',
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
  // var ppfarm = 0;

  var userMsg = '';

  Future prefsSave() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('farmNumber', farmNo);
    await prefs.setInt('myFarm', ppfarm);

    for (int i = 0; i < farmNo; i++) {
      print('prefs Save: $i / ${farmNo - 1} ${farmList[i]['farmName']}');

      await prefs.setString('farmName$i', farmList[i]['farmName']);
      await prefs.setString('facilityName$i', farmList[i]['facilityName']);
      await prefs.setString('serviceKey$i', farmList[i]['serviceKey']);
    }
  }

  Future prefsClear() async {
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
      sensorList = List<Sensor>.filled(wMAXX, sensorBlank, growable: true);
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

    if (Platform.isAndroid) showToast("초기화 완료", Colors.blueAccent);
    notifyListeners();
  }

  void removeData() async {
    final today = DateTime.now();
    final somedaysago = today.subtract(Duration(days: someDAYS));
    lastDatetime = DateFormat('yyyyMMdd HH00').format(somedaysago);
    print('prefs cleared: only $farmNo farm left');

    if (ppfarm >= 2) {
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
      ppfarm--;
      farmNo = farmNo - 1;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('farmNumber', farmNo);
      await prefs.setInt('ppfarm', ppfarm);
    }

    if (Platform.isAndroid) {
      showToast("ppfarm ${ppfarm + 1}번 농장 데이터를 삭제했습니다", Colors.blueAccent);
    }
    print("ppfarm ${ppfarm + 1} 농장 데이터를 삭제했습니다");
    notifyListeners();
  }

  Future apiRequestIOT() async {
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
    print('IOT()- ppfarm: $ppfarm - Difference: $difference');
    String formatDate = DateFormat('yyyyMMdd').format(now);
    String formatTime = DateFormat('HH').format(now);

    var urliotString = "$urliot/$apikey/$formatDate/$formatTime";
    var uriiot = Uri.parse(urliotString);

    var deltaT = int.parse(formatTime);
    var deltaT12 = deltaT % 12;
    deltaT = 24;
    if (deltaT < 12) deltaT = deltaT + deltaT12;
    try {
      // print('before for loop');
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
            showToast("네트워크 상태를 확인해주세요", Colors.redAccent);
          }
          print("네트워크 상태를 확인해주세요");
          return -1;
        }
        var jsonObj = jsonDecode(response.body);
        if (jsonObj['datas'].length <= 0) {
          if (Platform.isAndroid) {
            showToast("새로 가져올 데이터가 없습니다", Colors.blueAccent);
          }
          print('새로 가져올 데이터가 없습니다');
          return 0;
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
        sensorList.insert(i, nsensor);
        print('IOT()- $i----${nsensor.customDt}');
        var progress = ((i + 1) / difference) * 100;
        userMsg = "${progress.toStringAsFixed(0)}%";
        notifyListeners();
      }
    } catch (e) {
      if (Platform.isAndroid) showToast("네트워크 상태를 확인해주세요", Colors.redAccent);
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

  Future apiRequestPEST() async {
    var encoder = ZipFileEncoder();
    final dir = await getApplicationDocumentsDirectory();
    // Directory dir = Directory('/storage/emulated/0/Documents ');
    var test = sensorLists[ppfarm][0].customDt.toString();
    print("apiPEST() - ppfarm: $ppfarm  - test: $test");
    String formatTime = '';
    var k = 0;
    for (k = 0; k < wMAXX; k++) {
      var v1 = sensorLists[ppfarm][k].customDt.toString();
      var d1 = DateTime.parse(v1);
      formatTime = DateFormat('HH').format(d1);
      if (formatTime == '12') break;
    }
    if (formatTime != '12') {
      print("12시를 못찾았습니다");
      return -1;
    }
    var weatherString = 'datetime,temperature,humidity,leafwet\n';
    for (int j = (k + (someDAYS - 1) * 24); j >= 0; j--) {
      var v1 = sensorLists[ppfarm][j].customDt.toString();
      var v2 = sensorLists[ppfarm][j].temperature.toString();
      var v3 = sensorLists[ppfarm][j].humidity.toString();
      var v4 = sensorLists[ppfarm][j].leafwet.toString();
      weatherString = "$weatherString$v1,$v2,$v3,$v4\n";
    }
    print(weatherString);
    await (File('${dir.path}/weather.csv').writeAsString(weatherString))
        .then((value) {
      encoder.create('${dir.path}/input.zip');
      encoder.addFile(File('${dir.path}/weather.csv'));
      encoder.close();
    });

    // zip weather.csv
    // base64 encoding
    var z = await File('${dir.path}/input.zip').readAsBytes();
    String token = base64.encode(z);

    var body = jsonEncode({
      'Input': token,
      'type': "file",
    });

    // http request
    var urlanthracnose = 'http://147.46.206.95:7897/Anthracnose';
    var urlbotrytis = 'http://147.46.206.95:7898/Botrytis';
    try {
      http.Response response = await http.post(
        Uri.parse(urlanthracnose),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: body,
      );

      var r = response.body;
      print(r);
      r = r.replaceAll("\\", "");
      print(r);
      var i = r.indexOf('output');
      var ii = r.indexOf("}]");
      if (ii < 0) {
        if (Platform.isAndroid) {
          showToast("기상데이터는 12시부터 시작해야합니다", Colors.redAccent);
        }
        print("기상데이터는 12시부터 시작해야합니다");
        return 0;
      }
      var rr = r.substring(i + 10, ii + 2);
      final outputA = json.decode(rr);

      http.Response response2 = await http.post(
        Uri.parse(urlbotrytis),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: body,
      );

      var r2 = response2.body;
      r = r2.replaceAll("\\", "");
      var i2 = r.indexOf('output');
      var ii2 = r.indexOf("}]");
      var rr2 = r.substring(i2 + 10, ii2 + 2);
      final outputB = json.decode(rr2);

      // print(rr);
      // print(rr2);
      // print(output.runtimeType);

/////////////////////////////////////////////////////
      //pinf update
      pinfList = List<PINF>.filled(50, pinfBlank, growable: true);
      pinfLists[ppfarm] = pinfList;
      int j = someDAYS - 1;
      for (int i = 0; i < someDAYS - 1; i++) {
        var customDT = outputA[j]['date'].toString();

        PINF npinf = PINF(
          customDt: customDT,
          anthracnose:
              double.parse((outputA[j]['PINF'] * 100).toStringAsFixed(1)),
          botrytis: double.parse((outputB[j]['PINF'] * 100).toStringAsFixed(1)),
          xlabel: DateFormat('MM/dd').format(
            DateTime.parse(outputA[j]['date']),
          ),
        );
        j--;
        // pinfList.insert(i, npinf);
        pinfLists[ppfarm].insert(i, npinf);
        print("apiPEST() - pinfList update, ppfarm: $ppfarm");

        notifyListeners();
        // print('$j: $custom_dt');
      }
    } catch (e) {
      if (Platform.isAndroid) {
        showToast("모델호출 실패. 다시한번 시도해주세요", Colors.redAccent);
      }
      print("모델호출 실패. 다시한번 시도해주세요");
      notifyListeners();
      return -1;
    }

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

/////////////////////////////////////////////////////////////////////

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // var appState = context.watch<MyAppState>();
    addMyLicense();
    prefsLoad().then((value) async {
      await storage.readJsonAsString().then((value) {
        setState(() {
          //   lastDatetime = sensorLists[ppfarm][0].customDt.toString();
          //   lastDatetime = "${lastDatetime.substring(0, 11)}00";
          //   print('HomePage initState - $lastDatetime');
          //   print('HomePage initState - farmNo: $farmNo');
        });
      });
    });
    print('initState');
  }

  @override
  Widget build(BuildContext context) {
    // var appState = context.watch<MyAppState>();

    Widget page;

    switch (selectedIndex) {
      case 0:
        page = StrawberryPage();
        break;
      case 1:
        page = Placeholder();
        break;
      case 2:
        page = Placeholder(); //FavoritesPage();
        break;
      case 3:
        page = MyLineChartPage();
        break;
      case 4:
        page = MySetting();
        break;
      case 5:
        page = LicensePage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    // appState.prefsLoad();

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                ///                extended: constraints.maxWidth >= 600,
                labelType: NavigationRailLabelType.all,
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(CustomIcons.strawberry), //solidLemon
                    label: Text('딸기'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(CustomIcons.tomato), //solidLemon
                    label: Text('토마토'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(CustomIcons.bellpepper), //solidLemon
                    label: Text('파프리카'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.thermostat),
                    label: Text('환경'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.settings),
                    label: Text('설정'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.fact_check_outlined),
                    label: Text('라이선스'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  if (mounted) {
                    setState(() {
                      selectedIndex = value;
                    });
                  }
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class StrawberryPage extends StatefulWidget {
  @override
  State<StrawberryPage> createState() => _StrawberryPageState();
}

class _StrawberryPageState extends State<StrawberryPage> {
/////////////////////////////////////////////////////

/////////////////////////////////////////////////////
  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   print('didChangeDependencies 호출');
  // }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    // var pair = appState.current;

    // IconData icon;
    // if (appState.favorites.contains(pair)) {
    //   icon = Icons.favorite;
    // } else {
    //   icon = Icons.favorite_border;
    // }

    // var now = DateTime.now();
    // String formatDate = DateFormat('yyyy년 MM월 dd일').format(now);
    // print("StrawBerryPage() - $ppfarm - ${farmList[ppfarm]['farmName']}");

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 30),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                farmList[ppfarm]['farmName'],
                style: TextStyle(fontSize: 25),
              ),
              SizedBox(width: 20),
              ElevatedButton(
                onPressed: () async {
                  ppfarm = (ppfarm + 1) % farmNo;
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.setInt('myFarm', ppfarm);

                  //just for check the state

                  // print("StrawBerryPage() - ppfarm: $ppfarm / ${farmNo - 1}");
                  // print("prefsLoad and readJsonAsString");
                  appState.pp = 0;
                  try {
                    await storage.readJsonAsString2().then((value) {
                      // print('ReLoad the data');
                      if (mounted) {
                        setState(() {
                          appState.getNext();
                        });
                      }
                    });
                  } catch (e) {
                    if (Platform.isAndroid) {
                      showToast("다시한번 시도해주세요", Colors.redAccent);
                    }
                    print('다시한번 시도해주세요');
                  }
                },
                child: Text('다음'),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('탄저병:'),
              Text(
                '■',
                style: TextStyle(
                  color: Colors.pink,
                ),
              ),
              SizedBox(width: 10),
              Text('잿빛곰팡이병:'),
              Text(
                '■',
                style: TextStyle(
                  color: Colors.indigo,
                ),
              ),
              SizedBox(width: 10),
              Tooltip(message: """탄저병: 3~11월 발생
잿빛곰팡이병: 9월~이듬해5월 발생

* 병 예측 낮음은 약제 살포 안함
* 병 예측 다소높음은 약제살포
  (1주일 전 약제살포했으면 약제살포 안함)
* 병 예측 위험은 약제살포
  (5일 이내 약제살포했으면 약제살포 안함)""", child: Icon(Icons.help_outline)),
            ],
          ),
          Expanded(
            child: MyBarChart(),
          ),
          // Text(lastDatetime),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  appState.pp = 7;
                  appState.toggleFavorite();
                },
                child: Text('지난주'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.indigoAccent),
                onPressed: () async {
                  //just for check the state
                  lastDatetime = sensorLists[ppfarm][0].customDt.toString();
                  lastDatetime = "${lastDatetime.substring(0, 11)}00";
                  print("ppfarm: $ppfarm - lastDateTime: $lastDatetime");
                  // print("prefsLoad and readJsonAsString");

                  // prefsLoad().then((value) {
                  await storage.readJsonAsString2().then((value) {
                    // lastDatetime = sensorLists[ppfarm][0].customDt.toString();
                    // lastDatetime = "${lastDatetime.substring(0, 11)}00";
                    print("이번주 시작 - ppfarm: $ppfarm - $lastDatetime");
                    // print('ReLoad the data');

                    if (mounted) {
                      setState(() {
                        appState.getNext();
                      });
                    }
                  });
                  // });

                  ///redundunt but, check it out

                  appState.pp = 0;

                  if (Platform.isAndroid) {
                    showToast("IOT포털에서 데이터를 가져옵니다", Colors.blueAccent);
                  }
                  print('IOT포털에서 데이터를 가져옵니다 $ppfarm');

                  await appState.apiRequestIOT().then((value) async {
                    if (Platform.isAndroid) {
                      showToast("병해충예측모델을 실행합니다", Colors.blueAccent);
                    }
                    print('병해충예측모델을 실행합니다 $ppfarm');

                    await appState.apiRequestPEST().then((value) {
                      // print(difference);
                      // print(statusCode);

                      if (value == -1) appState.userMsg = "재시도";
                      setState(() {
                        lastDatetime =
                            sensorLists[ppfarm][0].customDt.toString();
                        lastDatetime = "${lastDatetime.substring(0, 11)}00";
                        print("데이터 갱신: $lastDatetime");
                        if ((difference >= 0)) {
                          //(statusCode == 200) &&
                          String jsonString = jsonEncode(sensorLists[ppfarm]);
                          storage.writeJsonAsString(
                              'sensor$ppfarm.json', jsonString);
                          jsonString = jsonEncode(pinfLists[ppfarm]);
                          storage.writeJsonAsString(
                              'pinf$ppfarm.json', jsonString);
                          if (Platform.isAndroid) {
                            showToast("데이터를 저장합니다", Colors.blueAccent);
                          }
                          print("데이터를 저장합니다");

                          lastDatetime =
                              sensorLists[ppfarm][0].customDt.toString();
                          lastDatetime = "${lastDatetime.substring(0, 11)}00";
                          print(lastDatetime);
                          // appState.getNext();
                        }
                      });
                    });
                    // print('after data update procedure... ');

                    if (mounted) {
                      setState(() {
                        appState.getNext();
                      });
                    }
                  });
                },
                child: Text('이번주'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () async {
                  appState.pp = 0;
                  if (Platform.isAndroid) {
                    showToast("개발중입니다", Colors.greenAccent);
                  }
                  getMyCurrentLocation();
                  KMA kma;
                  // await apiRequestPEST().then((value) {
                  if (mounted) {
                    setState(() {
                      // lastDatetime = sensorLists[ppfarm][0].customDt.toString();
                      // appState.userMsg = lastDatetime;
                      appState.getNext();
                    });
                  }
                  // });
                },
                child: Text('다음주'),
              ),
              SizedBox(width: 10),
              Text(appState.userMsg),
            ],
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

class MyLineChartPage extends StatefulWidget {
  const MyLineChartPage({super.key});

  @override
  State<MyLineChartPage> createState() => _MyLineChartPageState();
}

class _MyLineChartPageState extends State<MyLineChartPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 50),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                farmList[ppfarm]['farmName'],
                style: TextStyle(fontSize: 25),
              ),
              SizedBox(width: 20),
              ElevatedButton(
                onPressed: () async {
                  ppfarm = (ppfarm + 1) % farmNo;
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.setInt('myFarm', ppfarm);
                  print('prefsLoad: ${(ppfarm + 1)} / $farmNo');
                  print("LineChartPage() - ppfarm: $ppfarm / ${farmNo - 1}");

                  await storage.readJsonAsString2().then((value) {
                    if (mounted) {
                      setState(() {
                        appState.pp = 0;
                        appState.getNext();
                      });
                    }
                  });
                },
                child: Text('다음'),
              ),
            ],
          ),
          SizedBox(height: 10),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('기온:'),
                  Text(
                    '■',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text('상대습도:'),
                  Text(
                    '■',
                    style: TextStyle(
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('엽면습윤:'),
                  Text(
                    '■',
                    style: TextStyle(
                      color: Colors.greenAccent,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text('CO2농도:'),
                  Text(
                    '■',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(width: 20),
          Expanded(
            child: MyLineChart(),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          "예측결과",
          style: style,
          semanticsLabel: "탄저병 예측 결과 차트",
        ),
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    // if (appState.favorites.isEmpty) {
    //   return Center(
    //     child: Text('No favorites yet.'),
    //   );
    // }
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => LicensePage()));

    return ListView(
      children: [
        // Padding(
        //   padding: const EdgeInsets.all(20),
        //   child: Text('You have '
        //       '${appState.favorites.length} favorites:'),
        // ),
        // for (int i = 1; i <= 5; i++) // var pair in appState.favorites
        //   ListTile(
        //     leading: Icon(Icons.favorite),
        //     title: Text('공주농가$i'), // ${pair.asLowerCase}
        //   ),
      ],
    );
  }
}

class MyBarChart extends StatefulWidget {
  const MyBarChart({super.key});

  @override
  State<MyBarChart> createState() => _MyBarChartState();
}

class _MyBarChartState extends State<MyBarChart> {
  @override
  void initState() {
    super.initState();

    print('Bar Chart initState 호출');
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Padding(
      padding: const EdgeInsets.all(20),
      // implement the bar chart
      child: BarChart(
        // key: ValueKey(ppfarm),
        // key: Key(farmList[ppfarm]['farmName']),

        BarChartData(
          maxY: 100,
          rangeAnnotations: RangeAnnotations(
            horizontalRangeAnnotations: [
              HorizontalRangeAnnotation(
                y1: 0,
                y2: 20,
                color: AppColors.contentColorGreen.withOpacity(0.3),
              ),
              HorizontalRangeAnnotation(
                y1: 20,
                y2: 50,
                color: AppColors.contentColorYellow.withOpacity(0.3),
              ),
              HorizontalRangeAnnotation(
                y1: 50,
                y2: 100,
                color: AppColors.contentColorOrange.withOpacity(0.3),
              ),
            ],
          ),
          // uncomment to see ExtraLines with RangeAnnotations
          extraLinesData: ExtraLinesData(
//         extraLinesOnTop: true,
            horizontalLines: [
              HorizontalLine(
                y: 10,
                // color: AppColors.contentColorBlack,
                strokeWidth: 0,
                dashArray: [5, 10],
                label: HorizontalLineLabel(
                  show: true,
                  alignment: Alignment.topRight,
                  padding: const EdgeInsets.only(right: 5, bottom: 15),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  labelResolver: (line) => '낮음',
                ),
              ),
              HorizontalLine(
                y: 40,
                // color: AppColors.contentColorRed,
                strokeWidth: 0,
                dashArray: [5, 10],
                label: HorizontalLineLabel(
                  show: true,
                  alignment: Alignment.topRight,
                  padding: const EdgeInsets.only(right: 5, bottom: 15),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  labelResolver: (line) => '다소높음',
                ),
              ),
              HorizontalLine(
                y: 90,
                // color: AppColors.contentColorWhite,
                strokeWidth: 0,
                dashArray: [5, 10],
                label: HorizontalLineLabel(
                  show: true,
                  alignment: Alignment.topRight,
                  padding: const EdgeInsets.only(right: 5, bottom: 15),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  labelResolver: (line) => '위험',
                ),
              ),
            ],
          ),
          borderData: FlBorderData(
              border: const Border(
            top: BorderSide.none,
            right: BorderSide.none,
            left: BorderSide(width: 1),
            bottom: BorderSide(width: 1),
          )),
          groupsSpace: 10,
          // add bars
          barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
            maxContentWidth: 100,
            tooltipBgColor: Colors.white,
          )),
          barGroups: [
            BarChartGroupData(x: 1, barRods: [
              BarChartRodData(
                  toY: double.parse(pinfLists[ppfarm][appState.pp + 6]
                      .anthracnose
                      .toString()),
                  width: 5,
                  color: Colors.pink),
              BarChartRodData(
                  toY: double.parse(
                      pinfLists[ppfarm][appState.pp + 6].botrytis.toString()),
                  width: 5,
                  color: Colors.indigo),
            ]),
            BarChartGroupData(x: 2, barRods: [
              BarChartRodData(
                  toY: double.parse(pinfLists[ppfarm][appState.pp + 5]
                      .anthracnose
                      .toString()),
                  width: 5,
                  color: Colors.pink),
              BarChartRodData(
                  toY: double.parse(
                      pinfLists[ppfarm][appState.pp + 5].botrytis.toString()),
                  width: 5,
                  color: Colors.indigo),
            ]),
            BarChartGroupData(x: 3, barRods: [
              BarChartRodData(
                  toY: double.parse(pinfLists[ppfarm][appState.pp + 4]
                      .anthracnose
                      .toString()),
                  width: 5,
                  color: Colors.pink),
              BarChartRodData(
                  toY: double.parse(
                      pinfLists[ppfarm][appState.pp + 4].botrytis.toString()),
                  width: 5,
                  color: Colors.indigo),
            ]),
            BarChartGroupData(x: 4, barRods: [
              BarChartRodData(
                  toY: double.parse(pinfLists[ppfarm][appState.pp + 3]
                      .anthracnose
                      .toString()),
                  width: 5,
                  color: Colors.pink),
              BarChartRodData(
                  toY: double.parse(
                      pinfLists[ppfarm][appState.pp + 3].botrytis.toString()),
                  width: 5,
                  color: Colors.indigo),
            ]),
            BarChartGroupData(x: 5, barRods: [
              BarChartRodData(
                  toY: double.parse(pinfLists[ppfarm][appState.pp + 2]
                      .anthracnose
                      .toString()),
                  width: 5,
                  color: Colors.pink),
              BarChartRodData(
                  toY: double.parse(
                      pinfLists[ppfarm][appState.pp + 2].botrytis.toString()),
                  width: 5,
                  color: Colors.indigo),
            ]),
            BarChartGroupData(x: 6, barRods: [
              BarChartRodData(
                  toY: double.parse(pinfLists[ppfarm][appState.pp + 1]
                      .anthracnose
                      .toString()),
                  width: 5,
                  color: Colors.pink),
              BarChartRodData(
                  toY: double.parse(
                      pinfLists[ppfarm][appState.pp + 1].botrytis.toString()),
                  width: 5,
                  color: Colors.indigo),
            ]),
            BarChartGroupData(x: 7, barRods: [
              BarChartRodData(
                  toY: double.parse(pinfLists[ppfarm][appState.pp + 0]
                      .anthracnose
                      .toString()),
                  width: 5,
                  color: Colors.pink),
              BarChartRodData(
                  toY: double.parse(
                      pinfLists[ppfarm][appState.pp + 0].botrytis.toString()),
                  width: 5,
                  color: Colors.indigo),
            ]),
          ],
          titlesData: FlTitlesData(
            show: true,
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 38,
              ),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, titleMeta) {
                  return Padding(
                    // You can use any widget here
                    padding: EdgeInsets.only(top: 8.0),
                    child: RotatedBox(
                      quarterTurns: 1,
                      child: getTitles(value, titleMeta),
                    ),
                  );
                },
                reservedSize: 47,
                // interval: 12,
              ),
            ),
          ),
        ),
        swapAnimationDuration: Duration(milliseconds: 300), // Optional
        swapAnimationCurve: Curves.linear, // Optional
      ),
    );
  }

  Widget getTitles(double value, TitleMeta meta) {
    var appState = context.watch<MyAppState>();

    final style = TextStyle(
      ///      color: AppColors.contentColorBlue.darken(20),
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );
    String text;
    switch (value.toInt()) {
      case 0:
        text = pinfLists[ppfarm][appState.pp + 7].xlabel.toString();
        break;
      case 1:
        text = pinfLists[ppfarm][appState.pp + 6].xlabel.toString();
        break;
      case 2:
        text = pinfLists[ppfarm][appState.pp + 5].xlabel.toString();
        break;
      case 3:
        text = pinfLists[ppfarm][appState.pp + 4].xlabel.toString();
        break;
      case 4:
        text = pinfLists[ppfarm][appState.pp + 3].xlabel.toString();
        break;
      case 5:
        text = pinfLists[ppfarm][appState.pp + 2].xlabel.toString();
        break;
      case 6:
        text = pinfLists[ppfarm][appState.pp + 1].xlabel.toString();
        break;
      case 7:
        text = pinfLists[ppfarm][appState.pp + 0].xlabel.toString();
        break;
      default:
        text = '';
        break;
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4,
      child: Text(text, style: style),
    );
  }
}

class MyLineChart extends StatefulWidget {
  const MyLineChart({super.key});

  @override
  State<MyLineChart> createState() => _MyLineChartState();
}

class _MyLineChartState extends State<MyLineChart> {
  List<Color> gradientColors = [
    AppColors.contentColorCyan,
    AppColors.contentColorBlue,
  ];

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Padding(
      padding: const EdgeInsets.all(10),
      // implement the bar chart
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: ZoomableChart(
          maxX: wMAXX.toDouble() - 1,
          builder: (minX, maxX) {
            return LineChart(
              // key: Key(farmList[ppfarm]['farmName']),
              LineChartData(
                clipData: FlClipData.all(),
                minX: minX,
                maxX: maxX,
                maxY: 100,
                minY: 0,
                borderData: FlBorderData(
                    border: const Border(
                  top: BorderSide.none,
                  right: BorderSide(width: 1),
                  left: BorderSide(width: 1),
                  bottom: BorderSide(width: 1),
                )),
                // groupsSpace: 10,
                // add bars
                lineTouchData:
                    // LineTouchData(enabled: false),
                    LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    maxContentWidth: 100,
                    tooltipBgColor: Colors.black,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((LineBarSpot touchedSpot) {
                        final multiplyer = [0.5, 1, 10, 1];
                        final unit = ['ºC', '%', 'ppm', ''];
                        final textStyle = TextStyle(
                          color: touchedSpot.bar.gradient?.colors[0] ??
                              touchedSpot.bar.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        );
                        return LineTooltipItem(
                          ' ${(touchedSpot.y * multiplyer[touchedSpot.barIndex]).toStringAsFixed(1)} ${unit[touchedSpot.barIndex]}',
                          textStyle,
                        );
                      }).toList();
                    },
                  ),
                  handleBuiltInTouches: true,
                  getTouchLineStart: (data, index) => 0,
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      for (int i = 0; i < wMAXX; i++)
                        FlSpot(
                            i.toDouble(),
                            double.parse(sensorLists[ppfarm]
                                        [appState.pp + (wMAXX - i - 1)]
                                    .temperature
                                    .toString()) *
                                2)
                    ],

                    isCurved: true,
                    color: AppColors.contentColorRed,
                    // gradient: LinearGradient(colors: gradientColors),
                    barWidth: 5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                    ),
                  ),
                  LineChartBarData(
                    spots: [
                      for (int i = 0; i < wMAXX; i++)
                        FlSpot(
                            i.toDouble(),
                            double.parse(sensorLists[ppfarm]
                                    [appState.pp + (wMAXX - i - 1)]
                                .humidity
                                .toString()))
                    ],
                    isCurved: true,
                    color: AppColors.contentColorBlue,
                    // gradient: LinearGradient(colors: gradientColors),
                    barWidth: 5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                    ),
                  ),
                  LineChartBarData(
                    spots: [
                      for (int i = 0; i < wMAXX; i++)
                        FlSpot(
                            i.toDouble(),
                            double.parse(sensorLists[ppfarm]
                                        [appState.pp + (wMAXX - i - 1)]
                                    .cotwo
                                    .toString()) /
                                10)
                    ],
                    isCurved: true,
                    color: AppColors.contentColorBlack,
                    gradient: LinearGradient(colors: gradientColors),
                    barWidth: 0,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: false,
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      // color: gradientColors.map((color) => color.withOpacity(0.3)).toList(),
                    ),
                  ),
                  LineChartBarData(
                    spots: [
                      for (int i = 0; i < wMAXX; i++)
                        FlSpot(
                            i.toDouble(),
                            double.parse(sensorLists[ppfarm]
                                        [appState.pp + (wMAXX - i - 1)]
                                    .leafwet
                                    .toString()) *
                                1)
                    ],
                    isCurved: true,
                    color: AppColors.contentColorGreen,
                    // gradient: LinearGradient(colors: gradientColors),
                    barWidth: 5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: false,
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.contentColorGreen,
                      // color: gradientColors.map((color) => color.withOpacity(0.3)).toList(),
                    ),
                  ),
                ],

                titlesData: FlTitlesData(
                  show: true,
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, titleMeta) {
                        return Padding(
                          // You can use any widget here
                          padding: EdgeInsets.only(top: 8.0),
                          child: getTitles2(value, titleMeta),
                        );
                      },
                      reservedSize: 38,
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, titleMeta) {
                        return Padding(
                          // You can use any widget here
                          padding: EdgeInsets.only(top: 8.0),
                          child: getTitles3(value, titleMeta),
                        );
                      },
                      reservedSize: 38,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      reservedSize: 77,
                      getTitlesWidget: (value, titleMeta) {
                        return Padding(
                          // You can use any widget here
                          padding: EdgeInsets.only(top: 8.0),
                          child: RotatedBox(
                            quarterTurns: 1,
                            child: getTitles(value, titleMeta),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              swapAnimationDuration: Duration(milliseconds: 250), // Optional
              swapAnimationCurve: Curves.linear, // Optional
            );
          },
        ),
      ),
    );
  }

  Widget getTitles(double value, TitleMeta meta) {
    var appState = context.watch<MyAppState>();

    final style = TextStyle(
      // color: Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );
    String text;
    text = sensorLists[ppfarm][appState.pp + (wMAXX - value.toInt() - 1)]
        .xlabel
        .toString();
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4,
      child: Text(text, style: style),
    );
  }

  Widget getTitles2(double value, TitleMeta meta) {
    final stylered = TextStyle(
      color: Colors.redAccent,
      // color: AppColors.contentColorBlue,
      // fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4,
      child: Text('${value ~/ 2}', style: stylered),
    );
  }

  Widget getTitles3(double value, TitleMeta meta) {
    final styleblue = TextStyle(
      color: Colors.blueAccent,
      // color: AppColors.contentColorBlue,
      // fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4,
      child: Text(value.toStringAsFixed(0), style: styleblue),
    );
  }
}

/////////////////////////////////////////////////////////////

class MySetting extends StatefulWidget {
  const MySetting({Key? key}) : super(key: key);

  @override
  State<MySetting> createState() => _MySettingState();
}

class _MySettingState extends State<MySetting> {
  TextEditingController inputController1 = TextEditingController();
  TextEditingController inputController2 = TextEditingController();
  TextEditingController inputController3 = TextEditingController();
  // String inputText = '';
  // String text = 'first';

  @override
  void initState() {
    super.initState();
    // var appState = context.watch<MyAppState>();

    // Start listening to changes.
    inputController1.addListener(_printLatestValue);
    inputController2.addListener(_printLatestValue);
    inputController3.addListener(_printLatestValue);
    // appState.prefsLoad().then((value) {
    inputController1.text = farmList[ppfarm]['farmName'];
    inputController2.text = farmList[ppfarm]['facilityName'];
    inputController3.text = farmList[ppfarm]['serviceKey'];
    // });
    print('SettingState() - initState - farmNo: $farmNo');
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    inputController1.dispose();
    inputController2.dispose();
    inputController3.dispose();
    super.dispose();
  }

  void _printLatestValue() {
    print('첫번째 텍스트필드: ${inputController1.text}');
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        toolbarHeight: 50,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        title: const Text('농장정보 입력'),
      ),
      body: Center(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
                  child: TextFormField(
                    controller: inputController1,
                    validator: (value) {
                      if (value!.trim().isEmpty) {
                        return '농장명을 입력하세요';
                      }
                      return null;
                    },
                    onChanged: (text) {
                      // setState(() {
                      //   farmName[ppfarm] = text;
                      // });
                    },
                    decoration: InputDecoration(
                      labelText: farmList[ppfarm]['farmName'],
                      hintText: '농장명을 입력해주세요',
                      labelStyle: TextStyle(color: Colors.grey),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(width: 1, color: Colors.grey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(width: 1, color: Colors.grey),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                    ),
                    keyboardType: TextInputType.text,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
                  child: TextFormField(
                    controller: inputController2,
                    validator: (value) {
                      if (value!.trim().isEmpty) {
                        return '센서위치를 입력하세요';
                      }
                      return null;
                    },
                    onChanged: (text) {
                      // setState(() {
                      //   facilityName[ppfarm] = text;
                      // });
                    },
                    decoration: InputDecoration(
                      labelText: farmList[ppfarm]['facilityName'],
                      hintText: '센서위치를 입력해주세요',
                      labelStyle: TextStyle(color: Colors.grey),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(width: 1, color: Colors.grey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(width: 1, color: Colors.grey),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                    ),
                    keyboardType: TextInputType.text,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
                  child: TextFormField(
                    // key: Key(farmList[ppfarm]['farmName']),
                    controller: inputController3,
                    validator: (value) {
                      if (value!.trim().isEmpty) {
                        return '인증키를 입력하세요';
                      }
                      return null;
                    },
                    onChanged: (text) {
                      // setState(() {
                      //   serviceKey[ppfarm] = text;
                      // });
                    },
                    decoration: InputDecoration(
                      labelText: farmList[ppfarm]['serviceKey'],
                      hintText: '데이터저장소(IOT포털) 인증키를 입력해주세요',
                      labelStyle: TextStyle(color: Colors.grey),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(width: 1, color: Colors.grey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(width: 1, color: Colors.grey),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                    ),
                    keyboardType: TextInputType.text,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: Text('총 $farmNo농장이 등록되었습니다!!!'),
                ),
                Text(
                    '선택농가: ${ppfarm + 1} - 이름: ${farmList[ppfarm]['farmName']}'),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          if (mounted) {
                            setState(() {
                              ppfarm = (ppfarm - 1);
                              if (ppfarm == -1) ppfarm = farmNo - 1;
                              inputController1.text =
                                  farmList[ppfarm]['farmName'];
                              inputController2.text =
                                  farmList[ppfarm]['facilityName'];
                              inputController3.text =
                                  farmList[ppfarm]['serviceKey'];
                              // _printLatestValue();
                            });
                          }
                        },
                        child: const Text('이전'),
                      ),
                    ),
                    SizedBox(width: 10),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          // save prefs info of the new farm
                          // _printLatestValue();
                          // go to the next farm
                          if (mounted) {
                            setState(() {
                              ppfarm = (ppfarm + 1) % farmNo;
                              inputController1.text =
                                  farmList[ppfarm]['farmName'];
                              inputController2.text =
                                  farmList[ppfarm]['facilityName'];
                              inputController3.text =
                                  farmList[ppfarm]['serviceKey'];
                              // _printLatestValue();
                            });
                          }
                        },
                        child: const Text('다음'),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          print('추가전 - $ppfarm / ${farmNo - 1}');
                          farmNo++;
                          Map farm = {
                            'farmName': '농장$farmNo',
                            'facilityName': '  ',
                            'serviceKey': '  ',
                          };
                          farmList.add(farm);
                          sensorLists.add(sensorList);
                          pinfLists.add(pinfList);

                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();

                          await prefs.setInt('farmNumber', farmNo);
                          await prefs.setInt('myFarm', ppfarm);

                          sensorList = List<Sensor>.filled(wMAXX, sensorBlank,
                              growable: true);
                          String jsonString = jsonEncode(sensorList);
                          await storage.writeJsonAsString(
                              'sensor${farmNo - 1}.json', jsonString);

                          pinfList =
                              List<PINF>.filled(50, pinfBlank, growable: true);
                          jsonString = jsonEncode(pinfList);
                          await storage.writeJsonAsString(
                              'pinf${farmNo - 1}.json', jsonString);
                          print('추가후 - $ppfarm / ${farmNo - 1}');

                          if (mounted) {
                            setState(() {
                              ppfarm = farmNo - 1;
                              // print(ppfarm);
                              // for (int i = 0; i < farmNo; i++) {
                              // print(farmName[i]);
                              // }
                              inputController1.text = '농장$farmNo';
                              inputController2.text = '';
                              inputController3.text = '';
                            });
                          }
                        },
                        child: const Text('추가'),
                      ),
                    ),
                    SizedBox(width: 5),
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          // save prefs info of the new farm
                          // _printLatestValue();

                          Map farm = {
                            'farmName': inputController1.text,
                            'facilityName': inputController2.text,
                            'serviceKey': inputController3.text,
                          };
                          farmList[ppfarm] = farm;

                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          await prefs.setInt('myFarm', ppfarm);
                          await prefs.setInt('farmNumber', farmNo);
                          await prefs.setString(
                              'farmName$ppfarm', farmList[ppfarm]['farmName']);
                          await prefs.setString('facilityName$ppfarm',
                              farmList[ppfarm]['facilityName']);
                          await prefs.setString('serviceKey$ppfarm',
                              farmList[ppfarm]['serviceKey']);
                          await appState.prefsSave().then((value) {
                            if (mounted) {
                              setState(() {
                                // _printLatestValue();
                              });
                            }
                          });
                          print('저장완료: $ppfarm / ${farmNo - 1}');
                          if (Platform.isAndroid) {
                            showToast("저장되었습니다", Colors.blue);
                          }
                        },
                        child: const Text('저장'),
                      ),
                    ),
                    SizedBox(width: 5),
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (ppfarm >= 2) {
                            if (mounted) {
                              setState(() {
                                // _printLatestValue();
                                appState.removeData();
                                inputController1.text =
                                    farmList[ppfarm - 1]['farmName'];
                                inputController2.text =
                                    farmList[ppfarm - 1]['facilityName'];
                                inputController3.text =
                                    farmList[ppfarm - 1]['serviceKey'];
                                appState.getNext();
                              });
                            }
                          }
                        },
                        child: const Text('삭제'),
                      ),
                    ),
                    SizedBox(width: 5),
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (mounted) {
                            setState(() async {
                              // _printLatestValue();
                              await appState.prefsClear().then((value) {
                                inputController1.text =
                                    farmList[ppfarm]['farmName'];
                                inputController2.text =
                                    farmList[ppfarm]['facilityName'];
                                inputController3.text =
                                    farmList[ppfarm]['serviceKey'];
                              });
                            });
                          }
                        },
                        child: const Text('초기화'),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Text("""Contributors
앱개발_농촌진흥청 신재훈
모델러_충청남도농업기술원 남명현(탄저병, 잿빛곰팡이병)
외부API_농촌진흥청 IOT포털, 서울대학교 병해충API
일러스트_스마트팜 농부 rawpixel.com, 출처 Freepik""",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
