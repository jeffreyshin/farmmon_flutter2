// Copyright 2023 Shin Jae-hoon. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:farmmon_flutter/view/view_linechart.dart';
import 'package:farmmon_flutter/view/view_settingpage.dart';
import 'package:farmmon_flutter/view/view_strawberrypage.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

import 'package:fl_chart/fl_chart.dart';
import 'package:farmmon_flutter/view/zoomable_chart.dart';
import 'package:farmmon_flutter/presentation/resources/app_resources.dart';
import 'package:farmmon_flutter/icons/custom_icons_icons.dart';

// import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';

import 'package:farmmon_flutter/model/kma.dart';
// import 'package:farmmon_flutter/weather.dart';

import 'package:flutter/foundation.dart';

import 'package:farmmon_flutter/viewmodel/kakao_login.dart';
import 'package:farmmon_flutter/viewmodel/main_view_model.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;

import 'package:farmmon_flutter/viewmodel/google_login.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:farmmon_flutter/main.dart';

import 'package:farmmon_flutter/model/model.dart';

/////////////////////////////////////////////////////////////////////
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
      // if (Platform.isAndroid) showToast(context, "읽기오류입니다", Colors.red);
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
    // if (Platform.isAndroid) showToast("데이터를 저장합니다", Colors.blueAccent);
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
  signinMethod = (prefs.getString('signinMethod') ?? 'Google');
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

  farm1['farmName'] = (prefs.getString('farmName0') ?? '기본농장');
  farm2['farmName'] = (prefs.getString('farmName1') ?? '농장2');
  farm1['serviceKey'] =
      (prefs.getString('serviceKey0') ?? 'v8UppqLzoaGtPqyRaEXiRCM8KAukLvivR');
  farm2['serviceKey'] =
      (prefs.getString('serviceKey1') ?? 'r64f2ea0960a74f4f8c48a0b3a6953973');

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

  try {
    user = await kakao.UserApi.instance.me();
    print("${user!.id.toString()}");
    print("${user!.kakaoAccount!.profile!.nickname}");
    print("${user!.kakaoAccount!.email!}");
  } catch (e) {
    print("error");
  }

  return 0;
}

/////////////////////////////////////////////////////////////

showToast(BuildContext context, String message, Color color) {
  ScaffoldMessenger.of(context).removeCurrentSnackBar();
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: color, //Colors.teal,
      margin: EdgeInsets.fromLTRB(40, 0, 50, 40),
      duration: Duration(milliseconds: 1000),
      behavior: SnackBarBehavior.floating,
      // action: SnackBarAction(
      //   label: 'Undo',
      //   textColor: Colors.white,
      //   onPressed: () => print('Pressed'),
      // ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: color,
          // width: 2,
        ),
      ),
    ),
  );
  // return Fluttertoast.showToast(
  //   msg: message,
  //   gravity: ToastGravity.BOTTOM,
  //   backgroundColor: colar,
  //   fontSize: 20,
  //   textColor: Colors.white,
  //   // toastLength: Toast.LENGTH_SHORT,
  //   // toastLength: Duration(seconds: 3),
  // );
}

//////////////////////////////////////////////////////////////

Future<void> getMyCurrentLocation() async {
  try {
    // LocationPermission permission = await Geolocator.requestPermission();
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    var long = position.longitude;
    var lat = position.latitude;
    // if (Platform.isAndroid) showToast(context, "location: $long, $lat", Colors.red);
    print('My current location: $long, $lat');
  } catch (e) {
    print('네트워크 연결을 확인해주세요');
  }
}

void addMyLicense() {
  //add License
  LicenseRegistry.addLicense(() async* {
    yield const LicenseEntryWithLineBreaks(<String>['@farmmon_flutter'], '''
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

    // if (!viewModel.isLoggedin) {
    // await viewModel.login(); // retrieve user information
    // }
    // if (signinMethod == 'Kakao') await viewModel.login();
    print('initState');
  }

  @override
  Widget build(BuildContext context) {
    // var appState = context.watch<MyAppState>();

    Widget page;

    switch (selectedIndex) {
      case 0:
        page = StrawberryPage(); // LoginPage();
        break;
      case 2:
        page = WeatherPage(); //Placeholder();
        break;
      // case 2:
      //   page = FavoritesPage(); //Placeholder();
      //   break;
      case 1:
        page = MyLineChartPage();
        break;
      case 3:
        page = MySetting();
        break;
      // case 5:
      //   page = LicensePage();
      //   break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    // appState.prefsLoad();

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        resizeToAvoidBottomInset: false,
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
                  // NavigationRailDestination(
                  //   icon: Icon(CustomIcons.tomato), //solidLemon
                  //   label: Text('토마토'),
                  // ),
                  // NavigationRailDestination(
                  //   icon: Icon(CustomIcons.bellpepper), //solidLemon
                  //   label: Text('파프리카'),
                  // ),
                  NavigationRailDestination(
                    icon: Icon(Icons.thermostat),
                    label: Text('환경'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.sunny), //solidLemon
                    label: Text('기상예보'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.settings),
                    label: Text('설정'),
                  ),
                  // NavigationRailDestination(
                  //   icon: Icon(Icons.fact_check_outlined),
                  //   label: Text('라이선스'),
                  // ),
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

class LoginPage extends StatefulWidget {
  // const LoginPage({Key? key, required this.title}) : super(key: key);

  // final String title;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // final viewModel1 = MainViewModel(KakaoLogin());

  @override
  Widget build(BuildContext context) {
    print('LoginPage: isLoggedin - ${viewModel.isLoggedin}');
    return Scaffold(
      resizeToAvoidBottomInset: false,
      // appBar: AppBar(
      //   title: Center(child: Text('농장보기')),
      // ),
      body: Center(
        child: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '농장보기',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      Image.asset(
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                          "assets/images/app_icon.png"),
                      SizedBox(height: 50),
                      InkWell(
                        onTap: () async {
                          viewModel = MainViewModel(KakaoLogin());
                          await viewModel.login().then((value) {
                            setState(() {
                              print(
                                  "In StreamBuilder: ${viewModel.isLoggedin}");
                              // runApp(const MyApp());
                            });
                          });
                        },
                        child: Image.asset(
                            "assets/images/kakao_login_medium_wide.png"),
                      ),
                      SizedBox(height: 30),
                      InkWell(
                        onTap: () async {
                          viewModel = MainViewModel(GoogleLogin());
                          await viewModel.login().then((value) {
                            setState(() {
                              print(
                                  "In StreamBuilder: ${viewModel.isLoggedin}");
                              // runApp(const MyApp());
                            });
                          });
                        },
                        child: Image.asset(
                            "assets/images/btn_google_signin_light_normal_web@2x.jpg"),
                      ),
                      // ElevatedButton(
                      //   onPressed: () async {
                      //     await viewModel.logout();
                      //     setState(() {});
                      //   },
                      //   child: const Text('Logout'),
                      // ),
                      // Image.network(viewModel
                      //         .user?.kakaoAccount?.profile?.profileImageUrl ??
                      //     ''),
                      // ElevatedButton(
                      //   onPressed: () async {
                      //     await viewModel.login();
                      //     setState(() {});
                      //   },
                      //   child: const Text('Login'),
                      // ),
                    ],
                  ),
                );
              }
              print("snapshot.hasData: ${viewModel.isLoggedin}");
              return MaterialApp(
                  home:
                      Scaffold(resizeToAvoidBottomInset: false, body: MyApp()));
              // return Column(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: <Widget>[
              //     Image.network(
              //         viewModel.user?.kakaoAccount?.profile?.profileImageUrl ??
              //             ''),
              //     Text(
              //       '${viewModel.isLoggedin}',
              //       style: Theme.of(context).textTheme.headline4,
              //     ),
              //     ElevatedButton(
              //       onPressed: () async {
              //         await viewModel.logout();
              //         setState(() {});
              //       },
              //       child: const Text('Logout'),
              //     ),
              //   ],
              // );
            }),
      ),
    );
  }
}
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             // Image.network(
//             //     width: 50,
//             //     height: 50,
//             //     fit: BoxFit.cover,
//             //     viewModel.user?.kakaoAccount?.profile?.profileImageUrl ?? ''),
//             // Text(
//             //   '${viewModel.isLogined}',
//             //   style: Theme.of(context).textTheme.headlineMedium,
//             // ),
//             InkWell(
//               onTap: () async {
//                 await viewModel.login();
//                 setState(() {
//                   print("${viewModel.isLogined}");
//                   runApp(const MyApp());
//                 });
//               },
//               child: Image.asset("assets/images/kakao_login_medium_wide.png"),
//             ),
//             // ElevatedButton(
//             //   onPressed: () async {
//             //     await viewModel.login();
//             //     setState(() {
//             //       runApp(const MyApp());
//             //     });
//             //   },
//             //   child: const Text('login'),
//             // ),
//             SizedBox(height: 20),
//             SizedBox(
//               width: 300, //MediaQuery.of(context).size.width,
//               child: CupertinoButton(
//                 onPressed: () async {
//                   await viewModel.logout();
//                   setState(() {});
//                 },
//                 color: Colors.grey.shade300,
//                 child: Text(
//                   '로그아웃',
//                   style: TextStyle(
//                     fontSize: 15,
//                     color: Colors.black87,
//                   ),
//                 ),
//               ),
//             ),
//             // ElevatedButton(
//             //   onPressed: () async {
//             //     await viewModel.logout();
//             //     setState(() {});
//             //   },
//             //   child: const Text('logout'),
//             // ),
//           ],
//         ),
//       ),
//     );
//   }
// }

/////////////////////////////////////////////////////////////

class WeatherPage extends StatefulWidget {
  const WeatherPage({Key? key}) : super(key: key);

  @override
  _WeatherPageState createState() => _WeatherPageState();
}

class Fcst {
  String? fcstDate;
  String? fcstTime;
  String? TMP;
  String? REH;
  String? WSD;

  Fcst({
    this.fcstDate,
    this.fcstTime,
    this.TMP,
    this.REH,
    this.WSD,
  });
}

Fcst fcstBlank = Fcst(
  fcstDate: '20230801',
  fcstTime: '1200',
  TMP: '0.0',
  REH: '0.0',
  WSD: '0.0',
);

var fcstList = List<Fcst>.filled(200, fcstBlank, growable: true);
var fcstDate = List<String>.filled(200, '20230801', growable: true);
var fcstTime = List<String>.filled(200, '1200', growable: true);
var TMP = List<String>.filled(200, '0.0', growable: true);
var REH = List<String>.filled(200, '0.0', growable: true);
var WSD = List<String>.filled(200, '0.0', growable: true);
var tag = 0;

class _WeatherPageState extends State<WeatherPage> {
  String? baseTime;
  String? baseDate;
  String? baseDate_2am;
  String? baseTime_2am;
  String? currentBaseTime; //초단기 실황
  String? currentBaseDate;
  String? sswBaseTime; //초단기 예보
  String? sswBaseDate;

  int? xCoordinate;
  int? yCoordinate;
  double? userLati;
  double? userLongi;

  var now = DateTime.now();

  @override
  void initState() {
    super.initState();
    // getWeather();
  }

  //오늘 날짜 20201109 형태로 리턴
  String getSystemTime() {
    return DateFormat("yyyyMMdd").format(now);
  }

  //어제 날짜 20201109 형태로 리턴
  String getYesterdayDate() {
    return DateFormat("yyyyMMdd")
        .format(DateTime.now().subtract(Duration(days: 1)));
  }

  Future getWeather() async {
    // MyLocation userLocation = MyLocation();
    // await userLocation.getMyCurrentLocation(); //사용자의 현재 위치 불러올 때까지 대기
    // var appState = context.watch<MyAppState>();

    xCoordinate = 55; // userLocation.currentX; //x좌표
    yCoordinate = 127; // userLocation.currentY; //y좌표

    // userLati = userLocation.lati;
    // userLongi = userLocation.longi;

    var tm_x = 55;
    var tm_y = 127;

    var obsJson;
    var obs;

    // print(xCoordinate);
    // print(yCoordinate);

    //카카오맵 역지오코딩
    // var kakaoGeoUrl = Uri.parse(
    //     'https://dapi.kakao.com/v2/local/geo/coord2address.json?x=$userLongi&y=$userLati&input_coord=WGS84');
    // var kakaoGeo = await http
    //     .get(kakaoGeoUrl, headers: {"Authorization": "KakaoAK $kakaoApiKey"});
    //jason data
    // String addr = kakaoGeo.body;

    //카카오맵 좌표계 변환
    // var kakaoXYUrl =
    //     Uri.parse('https://dapi.kakao.com/v2/local/geo/transcoord.json?'
    //         'x=$userLongi&y=$userLati&input_coord=WGS84&output_coord=TM');
    // var kakaoTM = await http
    //     .get(kakaoXYUrl, headers: {"Authorization": "KakaoAK $kakaoApiKey"});
    // var TM = jsonDecode(kakaoTM.body);
    // tm_x = TM['documents'][0]['x'];
    // tm_y = TM['documents'][0]['y'];

    var apiKey =
        "Mhl9mL16kvqOfLoUJxorRFlPrkeLeO%2FoTgVPBEjFs4pj73UcWtPnsTpOikSTt1Xu9tSM7%2ByzbcMh4WyL7TGypA%3D%3D";
    //근접 측정소
    // var closeObs =
    //     'http://apis.data.go.kr/B552584/MsrstnInfoInqireSvc/getNearbyMsrstnList?'
    //     'tmX=$tm_x&tmY=$tm_y&returnType=json&serviceKey=$apiKey';
    // http.Response responseObs = await http.get(Uri.parse(closeObs));
    // if (responseObs.statusCode == 200) {
    //   obsJson = jsonDecode(responseObs.body);
    // }
    // obs = obsJson['response']['body']['items'][0]['stationName'];
    // print('측정소: $obs');

    if (now.hour < 2 || now.hour == 2 && now.minute < 10) {
      baseDate_2am = getYesterdayDate();
      baseTime_2am = "2300";
    } else {
      baseDate_2am = getSystemTime();
      baseTime_2am = "0200";
    }
    // print(baseDate_2am);
    // print(baseTime_2am);
    //단기 예보 시간별 baseTime, baseDate
    //오늘 최저 기온
    String today2am =
        'http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getVilageFcst?'
        'serviceKey=$apiKey&numOfRows=1000&pageNo=1&'
        'base_date=$baseDate_2am&base_time=$baseTime_2am&nx=$xCoordinate&ny=$yCoordinate&dataType=JSON';

    shortWeatherDate();
    //단기 예보 데이터
    String shortTermWeather =
        'http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getVilageFcst?'
        'serviceKey=$apiKey&numOfRows=1000&pageNo=1&'
        'base_date=$baseDate&base_time=$baseTime&nx=$xCoordinate&ny=$yCoordinate&dataType=JSON';

    currentWeatherDate();
    //현재 날씨(초단기 실황)
    String currentWeather =
        'http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtNcst?'
        'serviceKey=$apiKey&numOfRows=10&pageNo=1&'
        'base_date=$currentBaseDate&base_time=$currentBaseTime&nx=$xCoordinate&ny=$yCoordinate&dataType=JSON';

    superShortWeatherDate();
    //초단기 예보
    String superShortWeather =
        'http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtFcst'
        '?serviceKey=$apiKey&numOfRows=60&pageNo=1'
        '&base_date=$sswBaseDate&base_time=$sswBaseTime&nx=$xCoordinate&ny=$yCoordinate&dataType=JSON';

    print(baseDate);
    print(baseTime);
    // print(currentBaseTime); //초단기 실황
    // print(currentBaseDate);
    // print(sswBaseTime); //초단기 예보
    // print(sswBaseDate);

    String airConditon =
        'http://apis.data.go.kr/B552584/ArpltnInforInqireSvc/getMsrstnAcctoRltmMesureDnsty?'
        'stationName=$obs&dataTerm=DAILY&pageNo=1&ver=1.0'
        '&numOfRows=1&returnType=json&serviceKey=$apiKey';

    KMA kmaData = KMA(today2am, shortTermWeather, currentWeather,
        superShortWeather, airConditon);

    // json 데이터
    var today2amData = await kmaData.getToday2amData();
    var shortTermWeatherData = await kmaData.getShortTermWeatherData();
    print("getShortTermWeatherData");
    print(kmaData.shortTermWeatherUrl);
    // var currentWeatherData = await kmaData.getCurrentWeatherData();
    // var superShortWeatherData = await kmaData.getSuperShortWeatherData();
    // var airConditionData = await kmaData.getAirConditionData();
    // var addrData = jsonDecode(addr);

    // print('2am: $today2amData');
    // print('shortTermWeather: $shortTermWeatherData');
    print("pause");

///////////////////////////////////////////////////////////////////////////

    var fcst_json;
    var wlist = [];

    //단기예보
    //내일, 모레 최고 최저 온도

    // print(shortTermWeatherData['response']['body']['items']['item']);
    int totalCount = shortTermWeatherData['response']['body']['totalCount'];
    for (int i = 0; i < totalCount; i++) {
      //데이터 전체를 돌면서 원하는 데이터 추출
      fcst_json = shortTermWeatherData['response']['body']['items']['item'][i];
      // print(parsed_json['fcstTime']);
      //기온
      var wdata = {
        'baseTime': fcst_json['baseDate'],
        'baseDate': fcst_json['baseTime'],
        'fcstDate': fcst_json['fcstDate'],
        'fcstTime': fcst_json['fcstTime'],
        'category': fcst_json['category'],
        'fcstValue': fcst_json['fcstValue'],
        'nx': fcst_json['nx'],
        'ny': fcst_json['ny'],
      };

      wlist.add(wdata);
    }
    //습도
    // if (parsed_json['category'] == 'REH') {
    //   var REH = parsed_json['fcstValue'];
    //   print("RH: $REH");
    // }
    //SKY 코드값
    // if (parsed_json['category'] == 'SKY') {
    //   var SKY = parsed_json['fcstValue'];
    //   print("SKY: $SKY");
    // }
    int j = 0;
    fcstDate.clear();
    fcstTime.clear();
    TMP.clear();
    REH.clear();
    WSD.clear();
    for (int i = 0; i < wlist.length; i++) {
      if (wlist[i]['category'] == 'TMP') {
        fcstDate.add(wlist[i]['fcstDate']);
        fcstTime.add(wlist[i]['fcstTime']);
        TMP.add(wlist[i]['fcstValue']);
      }
      if (wlist[i]['category'] == 'REH') {
        REH.add(wlist[i]['fcstValue']);
      }
      if (wlist[i]['category'] == 'WSD') {
        WSD.add(wlist[i]['fcstValue']);
      }
    }

    for (int i = 0; i < fcstTime.length; i++) {
      Fcst fcstData = Fcst(
        fcstDate: fcstDate[i],
        fcstTime: fcstTime[i],
        TMP: TMP[i],
        REH: REH[i],
        WSD: WSD[i],
      );
      fcstList.add(fcstData);
      var t = fcstData.fcstDate.toString();
      var tt = fcstData.fcstTime.toString();
      var ttt = fcstData.TMP.toString();
      var tttt = fcstData.REH.toString();
      var ttttt = fcstData.WSD.toString();
      print("$t $tt : $ttt, $tttt, $ttttt");
    }
    print("pause");
    //내일, 모레 sky 코드

    //모레

    //PTY 코드값

    //내일, 모레 pty 코드

    //모레

////////////////////////////////////////////////////////////////////////////

    // print('currentWeather: $currentWeatherData');
    // print('superShortWeather: $superShortWeatherData');
    // print('air: $airConditionData');

    // Navigator.push(context, MaterialPageRoute(builder: (context) {
    //   return WeatherScreen(
    // parse2amData: today2amData,
    // parseShortTermWeatherData: shortTermWeatherData,
    // parseCurrentWeatherData: currentWeatherData,
    // parseSuperShortWeatherData: superShortWeatherData,
    // parseAirConditionData: airConditionData,
    // parseAddrData: addrData,
    //   );
    // }));
    // Navigator.push(context, MaterialPageRoute(builder: (context) {
    //   return WeatherPage();
    // }));
    tag = 1;
    return 0;
  }

  // final AppStorage storage = AppStorage();
  Future _future() async {
    // await Future.delayed(Duration(seconds: 5));
    if (tag == 0) {
      return await getWeather();
    }
    return 0;
    // return 'done!';
  }

  @override
  Widget build(BuildContext context) {
    // var appState = context.watch<MyAppState>();

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 50),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "기상예보",
                style: TextStyle(fontSize: 25),
              ),
              SizedBox(width: 20),
              ElevatedButton(
                onPressed: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.setInt('myFarm', ppfarm);
                  print('prefsLoad: ${(ppfarm + 1)} / $farmNo');
                  print("LineChartPage() - ppfarm: $ppfarm / ${farmNo - 1}");
                  await getWeather().then((value) {
                    if (mounted) {
                      setState(() {
                        // appState.pp = 0;
                        // appState.getNext();
                      });
                    }
                  });
                  // await storage.readJsonAsString2().then((value) {
                  // });
                },
                child: Text('불러오기'),
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
                  Text('풍속:'),
                  Text(
                    '■',
                    style: TextStyle(
                      color: Colors.yellowAccent,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20),
          Expanded(
            child: FutureBuilder(
                future: _future(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData == false) {
                    return Column(
                      children: [
                        CircularProgressIndicator(),
                        Expanded(child: MyLineChart2()),
                      ],
                    );
                    // Expanded(
                    //   child: Center(child: CircularProgressIndicator()),
                    // );
                  } else if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: TextStyle(fontSize: 15),
                      ),
                    );
                  } else {
                    return MyLineChart2();

                    // Padding(
                    //   padding: const EdgeInsets.all(8.0),
                    //   child: Text(
                    //     snapshot.data.toString(),
                    //     style: TextStyle(fontSize: 15),
                    //   ),
                    // );
                  }
                }),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
    // return Scaffold(
    //   backgroundColor: Theme.of(context).colorScheme.primaryContainer,
    //   body: Center(
    //     child: Column(
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       children: [
    //         // SpinKitWave(
    //         //   color: Colors.white,
    //         //   size: 60.0,
    //         // ),
    //         SizedBox(
    //           height: 20,
    //         ),
    //         Text(
    //           '날씨정보 가져오는 중',
    //           style: TextStyle(fontSize: 12.0, color: Colors.black87),
    //         )
    //       ],
    //     ),
    //   ),
    // );
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

  //초단기 실황
  void currentWeatherDate() {
    //40분 이전이면 현재 시보다 1시간 전 `base_time`을 요청한다.
    if (now.minute <= 40) {
      // 단. 00:40분 이전이라면 `base_date`는 전날이고 `base_time`은 2300이다.
      if (now.hour == 0) {
        currentBaseDate =
            DateFormat('yyyyMMdd').format(now.subtract(Duration(days: 1)));
        currentBaseTime = '2300';
      } else {
        currentBaseDate = DateFormat('yyyyMMdd').format(now);
        currentBaseTime =
            DateFormat('HH00').format(now.subtract(Duration(hours: 1)));
      }
    }
    //40분 이후면 현재 시와 같은 `base_time`을 요청한다.
    else {
      currentBaseDate = DateFormat('yyyyMMdd').format(now);
      currentBaseTime = DateFormat('HH00').format(now);
    }
  }

  //초단기 예보
  void superShortWeatherDate() {
    //45분 이전이면 현재 시보다 1시간 전 `base_time`을 요청한다.
    if (now.minute <= 45) {
      // 단. 00:45분 이전이라면 `base_date`는 전날이고 `base_time`은 2330이다.
      if (now.hour == 0) {
        sswBaseDate =
            DateFormat('yyyyMMdd').format(now.subtract(Duration(days: 1)));
        sswBaseTime = '2330';
      } else {
        sswBaseDate = DateFormat('yyyyMMdd').format(now);
        sswBaseTime =
            DateFormat('HH30').format(now.subtract(Duration(hours: 1)));
      }
    }
    //45분 이후면 현재 시와 같은 `base_time`을 요청한다.
    else {
      //if (now.minute > 45)
      sswBaseDate = DateFormat('yyyyMMdd').format(now);
      sswBaseTime = DateFormat('HH30').format(now);
    }
  }
}

class MyLineChart2 extends StatefulWidget {
  const MyLineChart2({super.key});

  @override
  State<MyLineChart2> createState() => _MyLineChartState2();
}

class _MyLineChartState2 extends State<MyLineChart2> {
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
        child: ZoomableChart2(
          maxX: 56,
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
                        final multiplyer = [0.5, 1, 0.1];
                        final unit = ['ºC', '%', 'm/s'];
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
                      for (int i = 0; i < TMP.length; i++)
                        FlSpot(i.toDouble(), (double.parse(TMP[i]) * 2))
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
                      for (int i = 0; i < REH.length; i++)
                        FlSpot(i.toDouble(), double.parse(REH[i]))
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
                      for (int i = 0; i < WSD.length; i++)
                        FlSpot(i.toDouble(), (double.parse(WSD[i]) * 10))
                    ],
                    isCurved: true,
                    color: AppColors.contentColorYellow,
                    // gradient: LinearGradient(colors: gradientColors),
                    barWidth: 0,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: false,
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.contentColorYellow,
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
    var text = "";
    try {
      text = DateFormat('MM/dd HH').format(DateTime.parse(
          "${fcstDate[value.toInt()]} ${fcstTime[value.toInt()]}"));
    } catch (e) {
      text = "";
    }

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

class AddUser extends StatelessWidget {
  final String fullName;
  final String company;
  final int age;

  AddUser(this.fullName, this.company, this.age);

  @override
  Widget build(BuildContext context) {
    // Create a CollectionReference called users that references the firestore collection
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    Future<void> addUser() {
      // Call the user's CollectionReference to add a new user
      return users
          .add({
            'full_name': fullName, // John Doe
            'company': company, // Stokes and Sons
            'age': age // 42
          })
          .then((value) => print("User Added"))
          .catchError((error) => print("Failed to add user: $error"));
    }

    return TextButton(
      onPressed: addUser,
      child: Text(
        "Add User",
      ),
    );
  }
}

class GetUserName extends StatelessWidget {
  final String documentId;

  GetUserName(this.documentId);

  @override
  Widget build(BuildContext context) {
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    return FutureBuilder<DocumentSnapshot>(
      future: users.doc(documentId).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text("Something went wrong");
        }

        if (snapshot.hasData && !snapshot.data!.exists) {
          return Text("Document does not exist");
        }

        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;

          var firestoreData = data;

          return Text("${data['email']} ${data['apikey']}");
        }

        return Text("loading");
      },
    );
  }
}
