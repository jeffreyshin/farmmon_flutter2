// Copyright 2023 Shin Jae-hoon. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';
import 'dart:convert';

import 'package:farmmon_flutter/view/view_homepage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmmon_flutter/main.dart';
import 'package:farmmon_flutter/model/model.dart';

/////////////////////////////////////////////////////////////////////

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
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  getUserInfo(userID) async {
    var result = await firestore.collection('users').doc(userID).get();
    print(result.data());
    firestoreData = result.data()!;
  }

  @override
  void initState() {
    super.initState();
    getUserInfo('신재훈001');
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

    final String documentId;

    CollectionReference users = FirebaseFirestore.instance.collection('users');

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
                // Padding(
                //   padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
                //   child: TextFormField(
                //     controller: inputController2,
                //     validator: (value) {
                //       if (value!.trim().isEmpty) {
                //         return '센서위치를 입력하세요';
                //       }
                //       return null;
                //     },
                //     onChanged: (text) {
                //       // setState(() {
                //       //   facilityName[ppfarm] = text;
                //       // });
                //     },
                //     decoration: InputDecoration(
                //       labelText: farmList[ppfarm]['facilityName'],
                //       hintText: '센서위치를 입력해주세요',
                //       labelStyle: TextStyle(color: Colors.grey),
                //       focusedBorder: OutlineInputBorder(
                //         borderRadius: BorderRadius.all(Radius.circular(10.0)),
                //         borderSide: BorderSide(width: 1, color: Colors.grey),
                //       ),
                //       enabledBorder: OutlineInputBorder(
                //         borderRadius: BorderRadius.all(Radius.circular(10.0)),
                //         borderSide: BorderSide(width: 1, color: Colors.grey),
                //       ),
                //       border: OutlineInputBorder(
                //         borderRadius: BorderRadius.all(Radius.circular(10.0)),
                //       ),
                //     ),
                //     keyboardType: TextInputType.text,
                //   ),
                // ),
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
                    SizedBox(width: 10),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          if (mounted) {
                            String n = (ppfarm + 1).toString().padLeft(3, "0");

                            await getUserInfo(
                                '${user?.kakaoAccount?.profile?.nickname ?? ''}$n');
                            print(
                                '${user?.kakaoAccount?.profile?.nickname ?? ''}$n');
                            inputController3.text = firestoreData['apikey'];
                          }
                          setState(() {});
                        },
                        child: const Text('가져오기'),
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

                          sensorList =
                              List<Sensor>.filled(wMAXX, sensorBlank, //
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
                          await appState.prefsSave(context).then((value) {
                            if (mounted) {
                              setState(() {
                                // _printLatestValue();
                              });
                            }
                          });
                          print('저장완료: $ppfarm / ${farmNo - 1}');
                          if (Platform.isAndroid) {
                            showToast(context, "저장되었습니다", Colors.blue);
                          }
                        },
                        child: const Text('저장'),
                      ),
                    ),
                    SizedBox(width: 5),
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (ppfarm < 2) {
                            if (mounted) {
                              setState(() {
                                // _printLatestValue();
                                appState.removeData(context);
                                appState.getNext();
                              });
                            }
                          }
                          if (ppfarm >= 2) {
                            if (mounted) {
                              setState(() {
                                // _printLatestValue();
                                appState.removeData(context);
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
                              await appState.prefsClear(context).then((value) {
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
                // GetUserName('신재훈001'),
                Text("""Contributors
총괄기획, 앱 개발_농촌진흥청 신재훈
병해충모델개발, 검증_충남농업기술원 남명현
환경센서_(주)유샘인스트루먼트
데이터저장소_농촌진흥청 IOT포털 서비스
병해충모델API개발_서울대학교 작물생태정보연구실
기상예보_기상청 단기예보API
일러스트_스마트팜 농부 rawpixel.com, 출처 Freepik""",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    )),
                SizedBox(height: 10),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("v0.5.0   License:"),
                    IconButton(
                      icon: Icon(Icons.fact_check_outlined),
                      onPressed: () {
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => LicensePage()));
                      },
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await viewModel.logout();
                        setState(() {});
                      },
                      child: const Text('로그아웃'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
