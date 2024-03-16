// Copyright 2023 Shin Jae-hoon. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:farmmon_flutter/view/view_heatmap.dart';
import 'package:farmmon_flutter/view/view_linechart.dart';
import 'package:farmmon_flutter/view/view_settingpage.dart';
import 'package:farmmon_flutter/view/view_strawberrypage.dart';
import 'package:farmmon_flutter/view/view_applepage.dart';
import 'package:farmmon_flutter/view/view_pearpage.dart';
import 'package:farmmon_flutter/view/view_gamgyulpage.dart';
import 'package:farmmon_flutter/view/view_grapepage.dart';
import 'package:farmmon_flutter/view/view_potatopage.dart';
import 'package:farmmon_flutter/view/view_pepperpage.dart';
import 'package:farmmon_flutter/view/view_garlicpage.dart';
import 'package:farmmon_flutter/view/view_ricepage.dart';
import 'package:farmmon_flutter/view/view_weatherpage.dart';

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
      case 1:
        page = ApplePage(); //Placeholder();
        break;
      case 2:
        page = PearPage(); //Placeholder();
        break;
      case 3:
        page = GamgyulPage(); //Placeholder();
        break;
      case 4:
        page = PepperPage(); //Placeholder();
        break;
      case 5:
        page = WeatherPage2(); // GrapePage();
        break;
      case 6:
        page = MyLineChartPage();
        break;
      case 7:
        page = WeatherPage(); //Placeholder();
        break;
      case 8:
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
                  NavigationRailDestination(
                    icon: Icon(Icons.apple), //solidLemon
                    label: Text('사과'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(CustomIcons.bellpepper), //solidLemon
                    label: Text('배'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(CustomIcons.tomato), //solidLemon
                    label: Text('감귤'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.home), //solidLemon
                    label: Text('고추'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.home), //solidLemon
                    label: Text('기타'),
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
