// Copyright 2023 Shin Jae-hoon. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';
import 'dart:convert';
import 'package:farmmon_flutter/view/view_barchart.dart';
import 'package:farmmon_flutter/view/view_homepage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:farmmon_flutter/main.dart';

/////////////////////////////////////////////////////////////////////

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
          SizedBox(height: 40),
          // SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(signinMethod),
              Column(
                children: [
                  Image.network(
                      width: 30,
                      height: 30,
                      fit: BoxFit.cover,
                      loginInfo['photoURL'] ?? '/assets/images/app_icon.png'),
                  // user?.kakaoAccount?.profile?.profileImageUrl ?? ''),
                  Text(
                    loginInfo['displayName'] ?? '',
                    // "${user?.kakaoAccount?.profile?.nickname ?? ''}",
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
              SizedBox(width: 10),
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

                  // if (Platform.isAndroid)
                  //   showToast(context, signinMethod, Colors.redAccent);

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
                      showToast(context, "다시한번 시도해주세요", Colors.redAccent);
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
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.pp = 7;
                  appState.toggleFavorite();
                  // if (Platform.isAndroid)
                  //   showToast(context, viewModel.isLoggedin.toString(),
                  //       Colors.redAccent);
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
                    showToast(context, "IOT포털에서 데이터를 가져옵니다", Colors.blueAccent);
                    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    //   content: Text("IOT포털에서 데이터를 가져옵니다"),
                    //   duration: Duration(seconds: 1),
                    // ));
                  }
                  print('IOT포털에서 데이터를 가져옵니다 $ppfarm');

                  await appState.apiRequestIOT(context).then((value) async {
                    if (Platform.isAndroid) {
                      showToast(context, "병해충예측모델을 실행합니다", Colors.blueAccent);

                      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      //   content: Text("병해충예측모델을 실행합니다"),
                      //   duration: Duration(seconds: 1),
                      // ));
                    }
                    print('병해충예측모델을 실행합니다 $ppfarm');

                    await appState.apiRequestPEST(context).then((value) {
                      // print(difference);
                      // print(statusCode);

                      if (value == -1) appState.userMsg = "재시도";
                      setState(() {
                        lastDatetime =
                            sensorLists[ppfarm][0].customDt.toString();
                        lastDatetime = "${lastDatetime.substring(0, 11)}00";
                        print("데이터 갱신: $lastDatetime");
                        if ((difference >= 0)) {
                          // difference >= 0
                          //(statusCode == 200) &&
                          String jsonString = jsonEncode(sensorLists[ppfarm]);
                          storage.writeJsonAsString(
                              'sensor$ppfarm.json', jsonString);
                          jsonString = jsonEncode(pinfLists[ppfarm]);
                          storage.writeJsonAsString(
                              'pinf$ppfarm.json', jsonString);
                          // if (Platform.isAndroid) {
                          //   showToast("데이터를 저장합니다", Colors.blueAccent);
                          // }
                          // print("데이터를 저장합니다");

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
              // SizedBox(width: 10),
              // ElevatedButton(
              //   onPressed: () async {
              //     appState.pp = 0;
              //     if (Platform.isAndroid) {
              //       showToast(context, "개발중입니다", Colors.greenAccent);
              //     }
              //     getMyCurrentLocation();
              //     KMA kma;
              //     // await apiRequestPEST().then((value) {
              //     if (mounted) {
              //       setState(() {
              //         // lastDatetime = sensorLists[ppfarm][0].customDt.toString();
              //         // appState.userMsg = lastDatetime;
              //         appState.getNext();
              //       });
              //     }
              //     // });
              //   },
              //   child: Text('다음주'),
              // ),
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
