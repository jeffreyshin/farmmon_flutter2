// Copyright 2023 Shin Jae-hoon. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:farmmon_flutter/view/view_applepage.dart';
import 'package:farmmon_flutter/view/view_weatherpage.dart';

//import 'package:csv/csv.dart';

import 'package:archive/archive_io.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:farmmon_flutter/weather.dart';

import 'package:farmmon_flutter/view/view_homepage.dart';
import 'package:farmmon_flutter/main.dart';
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

class output {
  String date;
  String type;
  double? LW;
  double? WT;
  double? PINF;
  double? WI;
  output(this.date, this.type, this.LW, this.WT, this.PINF, this.WI);
}

/////////////////////////////////////////////
/////////////////////////////////////////////
/////////////////////////////////////////////

class ApplePest {
  double? AppleBoks;
  double? AppleGuln;
  double? AppleAemo;
  double? ApplePano;
  double? AppleArchips;
  double? AppleWhiteRot;
  double? CherryTreeBorer;
  double? OrientalFruitMoth;
  double? PeachFruitMoth;
  double? PearBsun;
  double? PearGaru;
  double? PearScab;
  double? PlumFruitMoth;

  ApplePest(
      {this.AppleBoks,
      this.AppleGuln,
      this.AppleAemo,
      this.ApplePano,
      this.AppleArchips,
      this.AppleWhiteRot,
      this.CherryTreeBorer,
      this.OrientalFruitMoth,
      this.PeachFruitMoth,
      this.PearBsun,
      this.PearGaru,
      this.PearScab,
      this.PlumFruitMoth});
}

List<ApplePest> applePestL = [
  ApplePest(
      AppleBoks: 0.0,
      AppleGuln: 0.0,
      AppleAemo: 0.0,
      ApplePano: 0.0,
      AppleArchips: 0.0,
      AppleWhiteRot: 0.0,
      CherryTreeBorer: 0.0,
      OrientalFruitMoth: 0.0,
      PeachFruitMoth: 0.0,
      PearBsun: 0.0,
      PearGaru: 0.0,
      PearScab: 0.0,
      PlumFruitMoth: 0.0),
  ApplePest(
      AppleBoks: 0.0,
      AppleGuln: 0.0,
      AppleAemo: 0.0,
      ApplePano: 0.0,
      AppleArchips: 0.0,
      AppleWhiteRot: 0.0,
      CherryTreeBorer: 0.0,
      OrientalFruitMoth: 0.0,
      PeachFruitMoth: 0.0,
      PearBsun: 0.0,
      PearGaru: 0.0,
      PearScab: 0.0,
      PlumFruitMoth: 0.0),
  ApplePest(
      AppleBoks: 0.0,
      AppleGuln: 0.0,
      AppleAemo: 0.0,
      ApplePano: 0.0,
      AppleArchips: 0.0,
      AppleWhiteRot: 0.0,
      CherryTreeBorer: 0.0,
      OrientalFruitMoth: 0.0,
      PeachFruitMoth: 0.0,
      PearBsun: 0.0,
      PearGaru: 0.0,
      PearScab: 0.0,
      PlumFruitMoth: 0.0),
  ApplePest(
      AppleBoks: 0.0,
      AppleGuln: 0.0,
      AppleAemo: 0.0,
      ApplePano: 0.0,
      AppleArchips: 0.0,
      AppleWhiteRot: 0.0,
      CherryTreeBorer: 0.0,
      OrientalFruitMoth: 0.0,
      PeachFruitMoth: 0.0,
      PearBsun: 0.0,
      PearGaru: 0.0,
      PearScab: 0.0,
      PlumFruitMoth: 0.0),
  ApplePest(
      AppleBoks: 0.0,
      AppleGuln: 0.0,
      AppleAemo: 0.0,
      ApplePano: 0.0,
      AppleArchips: 0.0,
      AppleWhiteRot: 0.0,
      CherryTreeBorer: 0.0,
      OrientalFruitMoth: 0.0,
      PeachFruitMoth: 0.0,
      PearBsun: 0.0,
      PearGaru: 0.0,
      PearScab: 0.0,
      PlumFruitMoth: 0.0),
  ApplePest(
      AppleBoks: 0.0,
      AppleGuln: 0.0,
      AppleAemo: 0.0,
      ApplePano: 0.0,
      AppleArchips: 0.0,
      AppleWhiteRot: 0.0,
      CherryTreeBorer: 0.0,
      OrientalFruitMoth: 0.0,
      PeachFruitMoth: 0.0,
      PearBsun: 0.0,
      PearGaru: 0.0,
      PearScab: 0.0,
      PlumFruitMoth: 0.0),
  ApplePest(
      AppleBoks: 0.0,
      AppleGuln: 0.0,
      AppleAemo: 0.0,
      ApplePano: 0.0,
      AppleArchips: 0.0,
      AppleWhiteRot: 0.0,
      CherryTreeBorer: 0.0,
      OrientalFruitMoth: 0.0,
      PeachFruitMoth: 0.0,
      PearBsun: 0.0,
      PearGaru: 0.0,
      PearScab: 0.0,
      PlumFruitMoth: 0.0),
];

/////////////////////////////////////////////

class PearPest {
  double? AppleBoks;
  double? AppleGuln;
  double? AppleAemo;
  double? ApplePano;
  double? AppleArchips;
  double? AppleWhiteRot;
  double? CherryTreeBorer;
  double? OrientalFruitMoth;
  double? PeachFruitMoth;
  double? PearBsun;
  double? PearGaru;
  double? PearScab;
  double? PlumFruitMoth;
  double? PearJumb;
  double? PearRust;

  PearPest(
      {this.AppleBoks,
      this.AppleGuln,
      this.AppleAemo,
      this.ApplePano,
      this.AppleArchips,
      this.AppleWhiteRot,
      this.CherryTreeBorer,
      this.OrientalFruitMoth,
      this.PeachFruitMoth,
      this.PearBsun,
      this.PearGaru,
      this.PearScab,
      this.PlumFruitMoth,
      this.PearJumb,
      this.PearRust});
}

List<PearPest> pearPestL = [
  PearPest(
      AppleBoks: 0.0,
      AppleGuln: 0.0,
      AppleAemo: 0.0,
      ApplePano: 0.0,
      AppleArchips: 0.0,
      AppleWhiteRot: 0.0,
      CherryTreeBorer: 0.0,
      OrientalFruitMoth: 0.0,
      PeachFruitMoth: 0.0,
      PearBsun: 0.0,
      PearGaru: 0.0,
      PearScab: 0.0,
      PlumFruitMoth: 0.0,
      PearJumb: 0.0,
      PearRust: 0.0),
  PearPest(
      AppleBoks: 0.0,
      AppleGuln: 0.0,
      AppleAemo: 0.0,
      ApplePano: 0.0,
      AppleArchips: 0.0,
      AppleWhiteRot: 0.0,
      CherryTreeBorer: 0.0,
      OrientalFruitMoth: 0.0,
      PeachFruitMoth: 0.0,
      PearBsun: 0.0,
      PearGaru: 0.0,
      PearScab: 0.0,
      PlumFruitMoth: 0.0,
      PearJumb: 0.0,
      PearRust: 0.0),
  PearPest(
      AppleBoks: 0.0,
      AppleGuln: 0.0,
      AppleAemo: 0.0,
      ApplePano: 0.0,
      AppleArchips: 0.0,
      AppleWhiteRot: 0.0,
      CherryTreeBorer: 0.0,
      OrientalFruitMoth: 0.0,
      PeachFruitMoth: 0.0,
      PearBsun: 0.0,
      PearGaru: 0.0,
      PearScab: 0.0,
      PlumFruitMoth: 0.0,
      PearJumb: 0.0,
      PearRust: 0.0),
  PearPest(
      AppleBoks: 0.0,
      AppleGuln: 0.0,
      AppleAemo: 0.0,
      ApplePano: 0.0,
      AppleArchips: 0.0,
      AppleWhiteRot: 0.0,
      CherryTreeBorer: 0.0,
      OrientalFruitMoth: 0.0,
      PeachFruitMoth: 0.0,
      PearBsun: 0.0,
      PearGaru: 0.0,
      PearScab: 0.0,
      PlumFruitMoth: 0.0,
      PearJumb: 0.0,
      PearRust: 0.0),
  PearPest(
      AppleBoks: 0.0,
      AppleGuln: 0.0,
      AppleAemo: 0.0,
      ApplePano: 0.0,
      AppleArchips: 0.0,
      AppleWhiteRot: 0.0,
      CherryTreeBorer: 0.0,
      OrientalFruitMoth: 0.0,
      PeachFruitMoth: 0.0,
      PearBsun: 0.0,
      PearGaru: 0.0,
      PearScab: 0.0,
      PlumFruitMoth: 0.0,
      PearJumb: 0.0,
      PearRust: 0.0),
  PearPest(
      AppleBoks: 0.0,
      AppleGuln: 0.0,
      AppleAemo: 0.0,
      ApplePano: 0.0,
      AppleArchips: 0.0,
      AppleWhiteRot: 0.0,
      CherryTreeBorer: 0.0,
      OrientalFruitMoth: 0.0,
      PeachFruitMoth: 0.0,
      PearBsun: 0.0,
      PearGaru: 0.0,
      PearScab: 0.0,
      PlumFruitMoth: 0.0,
      PearJumb: 0.0,
      PearRust: 0.0),
  PearPest(
      AppleBoks: 0.0,
      AppleGuln: 0.0,
      AppleAemo: 0.0,
      ApplePano: 0.0,
      AppleArchips: 0.0,
      AppleWhiteRot: 0.0,
      CherryTreeBorer: 0.0,
      OrientalFruitMoth: 0.0,
      PeachFruitMoth: 0.0,
      PearBsun: 0.0,
      PearGaru: 0.0,
      PearScab: 0.0,
      PlumFruitMoth: 0.0,
      PearJumb: 0.0,
      PearRust: 0.0),
];

/////////////////////////////////////////////

class CitrusPest {
  /*ArrowHeadScale.json, ArrowHeadScale2.json, CitrusCranker.json, 
        CitrusMelanose.json, CitrusScab2.json, RiceBlast.json*/
  double? ArrowHeadScale;
  double? ArrowHeadScale2;
  double? CitrusCranker;
  double? CitrusMelanose;
  double? CitrusScab2;
  double? RiceBlast;

  CitrusPest({
    this.ArrowHeadScale,
    this.ArrowHeadScale2,
    this.CitrusCranker,
    this.CitrusMelanose,
    this.CitrusScab2,
    this.RiceBlast,
  });
}

List<CitrusPest> citrusPestL = [
  CitrusPest(
    ArrowHeadScale: 0.0,
    ArrowHeadScale2: 0.0,
    CitrusCranker: 0.0,
    CitrusMelanose: 0.0,
    CitrusScab2: 0.0,
    RiceBlast: 0.0,
  ),
  CitrusPest(
    ArrowHeadScale: 0.0,
    ArrowHeadScale2: 0.0,
    CitrusCranker: 0.0,
    CitrusMelanose: 0.0,
    CitrusScab2: 0.0,
    RiceBlast: 0.0,
  ),
  CitrusPest(
    ArrowHeadScale: 0.0,
    ArrowHeadScale2: 0.0,
    CitrusCranker: 0.0,
    CitrusMelanose: 0.0,
    CitrusScab2: 0.0,
    RiceBlast: 0.0,
  ),
  CitrusPest(
    ArrowHeadScale: 0.0,
    ArrowHeadScale2: 0.0,
    CitrusCranker: 0.0,
    CitrusMelanose: 0.0,
    CitrusScab2: 0.0,
    RiceBlast: 0.0,
  ),
  CitrusPest(
    ArrowHeadScale: 0.0,
    ArrowHeadScale2: 0.0,
    CitrusCranker: 0.0,
    CitrusMelanose: 0.0,
    CitrusScab2: 0.0,
    RiceBlast: 0.0,
  ),
  CitrusPest(
    ArrowHeadScale: 0.0,
    ArrowHeadScale2: 0.0,
    CitrusCranker: 0.0,
    CitrusMelanose: 0.0,
    CitrusScab2: 0.0,
    RiceBlast: 0.0,
  ),
  CitrusPest(
    ArrowHeadScale: 0.0,
    ArrowHeadScale2: 0.0,
    CitrusCranker: 0.0,
    CitrusMelanose: 0.0,
    CitrusScab2: 0.0,
    RiceBlast: 0.0,
  ),
];
/////////////////////////////////////////////////

class PepperPest {
  double? Pepper_Antracnose;
  double? PepperBacterialLeafSpot;
  double? PepperBacterialWilt;
  double? PepperOrientalTobaccoBudworm;
  double? WesternFlowerThrips;

  PepperPest({
    this.Pepper_Antracnose,
    this.PepperBacterialLeafSpot,
    this.PepperBacterialWilt,
    this.PepperOrientalTobaccoBudworm,
    this.WesternFlowerThrips,
  });
}

List<PepperPest> pepperPestL = [
  PepperPest(
    Pepper_Antracnose: 0.0,
    PepperBacterialLeafSpot: 0.0,
    PepperBacterialWilt: 0.0,
    PepperOrientalTobaccoBudworm: 0.0,
    WesternFlowerThrips: 0.0,
  ),
  PepperPest(
    Pepper_Antracnose: 0.0,
    PepperBacterialLeafSpot: 0.0,
    PepperBacterialWilt: 0.0,
    PepperOrientalTobaccoBudworm: 0.0,
    WesternFlowerThrips: 0.0,
  ),
  PepperPest(
    Pepper_Antracnose: 0.0,
    PepperBacterialLeafSpot: 0.0,
    PepperBacterialWilt: 0.0,
    PepperOrientalTobaccoBudworm: 0.0,
    WesternFlowerThrips: 0.0,
  ),
  PepperPest(
    Pepper_Antracnose: 0.0,
    PepperBacterialLeafSpot: 0.0,
    PepperBacterialWilt: 0.0,
    PepperOrientalTobaccoBudworm: 0.0,
    WesternFlowerThrips: 0.0,
  ),
  PepperPest(
    Pepper_Antracnose: 0.0,
    PepperBacterialLeafSpot: 0.0,
    PepperBacterialWilt: 0.0,
    PepperOrientalTobaccoBudworm: 0.0,
    WesternFlowerThrips: 0.0,
  ),
  PepperPest(
    Pepper_Antracnose: 0.0,
    PepperBacterialLeafSpot: 0.0,
    PepperBacterialWilt: 0.0,
    PepperOrientalTobaccoBudworm: 0.0,
    WesternFlowerThrips: 0.0,
  ),
  PepperPest(
    Pepper_Antracnose: 0.0,
    PepperBacterialLeafSpot: 0.0,
    PepperBacterialWilt: 0.0,
    PepperOrientalTobaccoBudworm: 0.0,
    WesternFlowerThrips: 0.0,
  ),
];
/////////////////////////////////////////////////

class RicePest {
  double? AppleBoks;
  double? AppleGuln;
  double? AppleAemo;
  double? ApplePano;
  double? AppleArchips;
  double? AppleWhiteRot;
  double? CherryTreeBorer;
  double? OrientalFruitMoth;
  double? PeachFruitMoth;
  double? PearBsun;
  double? PearGaru;
  double? PearScab;
  double? PlumFruitMoth;
  double? PearJumb;
  double? PearRust;

  RicePest(
      {this.AppleBoks,
      this.AppleGuln,
      this.AppleAemo,
      this.ApplePano,
      this.AppleArchips,
      this.AppleWhiteRot,
      this.CherryTreeBorer,
      this.OrientalFruitMoth,
      this.PeachFruitMoth,
      this.PearBsun,
      this.PearGaru,
      this.PearScab,
      this.PlumFruitMoth,
      this.PearJumb,
      this.PearRust});
}

List<RicePest> ricePestL = [
  RicePest(
      AppleBoks: 0.0,
      AppleGuln: 0.0,
      AppleAemo: 0.0,
      ApplePano: 0.0,
      AppleArchips: 0.0,
      AppleWhiteRot: 0.0,
      CherryTreeBorer: 0.0,
      OrientalFruitMoth: 0.0,
      PeachFruitMoth: 0.0,
      PearBsun: 0.0,
      PearGaru: 0.0,
      PearScab: 0.0,
      PlumFruitMoth: 0.0,
      PearJumb: 0.0,
      PearRust: 0.0),
  RicePest(
      AppleBoks: 0.0,
      AppleGuln: 0.0,
      AppleAemo: 0.0,
      ApplePano: 0.0,
      AppleArchips: 0.0,
      AppleWhiteRot: 0.0,
      CherryTreeBorer: 0.0,
      OrientalFruitMoth: 0.0,
      PeachFruitMoth: 0.0,
      PearBsun: 0.0,
      PearGaru: 0.0,
      PearScab: 0.0,
      PlumFruitMoth: 0.0,
      PearJumb: 0.0,
      PearRust: 0.0),
  RicePest(
      AppleBoks: 0.0,
      AppleGuln: 0.0,
      AppleAemo: 0.0,
      ApplePano: 0.0,
      AppleArchips: 0.0,
      AppleWhiteRot: 0.0,
      CherryTreeBorer: 0.0,
      OrientalFruitMoth: 0.0,
      PeachFruitMoth: 0.0,
      PearBsun: 0.0,
      PearGaru: 0.0,
      PearScab: 0.0,
      PlumFruitMoth: 0.0,
      PearJumb: 0.0,
      PearRust: 0.0),
  RicePest(
      AppleBoks: 0.0,
      AppleGuln: 0.0,
      AppleAemo: 0.0,
      ApplePano: 0.0,
      AppleArchips: 0.0,
      AppleWhiteRot: 0.0,
      CherryTreeBorer: 0.0,
      OrientalFruitMoth: 0.0,
      PeachFruitMoth: 0.0,
      PearBsun: 0.0,
      PearGaru: 0.0,
      PearScab: 0.0,
      PlumFruitMoth: 0.0,
      PearJumb: 0.0,
      PearRust: 0.0),
  RicePest(
      AppleBoks: 0.0,
      AppleGuln: 0.0,
      AppleAemo: 0.0,
      ApplePano: 0.0,
      AppleArchips: 0.0,
      AppleWhiteRot: 0.0,
      CherryTreeBorer: 0.0,
      OrientalFruitMoth: 0.0,
      PeachFruitMoth: 0.0,
      PearBsun: 0.0,
      PearGaru: 0.0,
      PearScab: 0.0,
      PlumFruitMoth: 0.0,
      PearJumb: 0.0,
      PearRust: 0.0),
  RicePest(
      AppleBoks: 0.0,
      AppleGuln: 0.0,
      AppleAemo: 0.0,
      ApplePano: 0.0,
      AppleArchips: 0.0,
      AppleWhiteRot: 0.0,
      CherryTreeBorer: 0.0,
      OrientalFruitMoth: 0.0,
      PeachFruitMoth: 0.0,
      PearBsun: 0.0,
      PearGaru: 0.0,
      PearScab: 0.0,
      PlumFruitMoth: 0.0,
      PearJumb: 0.0,
      PearRust: 0.0),
  RicePest(
      AppleBoks: 0.0,
      AppleGuln: 0.0,
      AppleAemo: 0.0,
      ApplePano: 0.0,
      AppleArchips: 0.0,
      AppleWhiteRot: 0.0,
      CherryTreeBorer: 0.0,
      OrientalFruitMoth: 0.0,
      PeachFruitMoth: 0.0,
      PearBsun: 0.0,
      PearGaru: 0.0,
      PearScab: 0.0,
      PlumFruitMoth: 0.0,
      PearJumb: 0.0,
      PearRust: 0.0),
];
/////////////////////////////////////////////////

class NCPMS {
  Future apiRequestApple(BuildContext context) async {
    print("apiRequestApple!!");

    // http request
    var urlapple0 = 'https://ncpms-apple-api.camp.re.kr/NCPMS/Apple';

    var apikey0 = "61cdc660a46f4fcc93004de201c58dff";
    var param0 = jsonEncode({'apiKey': apikey0});

// create session: server check
    var urlm0 = "$urlapple0/connect";
    print(urlm0);
    if (Platform.isAndroid) {
      showToast(context, "CAMP 깨우기", Colors.redAccent);
    }
    try {
      http.Response r = await http.post(
        Uri.parse(urlm0),
        headers: <String, String>{
          'Content-Type': 'application/json',
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: param0,
      );
    } catch (e) {
      if (Platform.isAndroid) {
        showToast(context, "모델호출 실패. 다시한번 시도해주세요", Colors.redAccent);
      }
      print("CAMP서버 깨우기");
      print(
          e.toString()); // checking an error at the first api call, 2023-07-31
    }
    var encoder = ZipFileEncoder();
    final dir = await getApplicationDocumentsDirectory();
    // Directory dir = Directory('/storage/emulated/0/Documents ');

    String formatTime = '';
    var kk = sensorLists[ppfarm].length;
    var k = 0;

    final today = DateTime.now();
    final sdate = today.subtract(Duration(days: 4));
    final edate = today.add(Duration(days: 2));
    var weatherString =
        'date,hour,tair,humi,radi,rain,maxAirtemp,minAirtemp,wet,'
        'wspd,tGrowth,tHI,av_t_7d,av_rh_5d\n';

    for (int i = 0; i < 7; i++) {
      var date = ewsList[i].date;
      // ignore: prefer_interpolation_to_compose_strings
      var dateString = date!.substring(0, 4) +
          "-" +
          date.substring(4, 6) +
          "-" +
          date.substring(6, 8);
      var v1 = dateString;
      var v2 = ewsList[i].hour.toString();
      var v3 = ewsList[i].tair.toString();
      var v4 = ewsList[i].humi.toString();
      var v5 = ewsList[i].radi.toString();
      var v6 = ewsList[i].rain.toString();
      var v7 = ewsList[i].maxAirtemp.toString();
      var v8 = ewsList[i].minAirtemp.toString();
      var v9 = ewsList[i].wet.toString();
      var v10 = ewsList[i].wspd.toString();
      var v11 = ewsList[i].tGrowth.toString();
      var v12 = ewsList[i].tHI.toString();
      var v13 = ewsList[i].av_t_7d.toString();
      var v14 = ewsList[i].av_rh_5d.toString();

      weatherString =
          "$weatherString$v1,$v2,$v3,$v4,$v5,$v6,$v7,$v8,$v9,$v10,$v11,$v12,$v13,$v14\n";
    }
    var sdateString = DateFormat('yyyy-MM-dd').format(sdate);
    var edateString = DateFormat('yyyy-MM-dd').format(edate);
    var weatherString2 = "$sdateString,$edateString,day,all";
    // print(weatherString);
    print(weatherString2);
    // zip weather.csv
    await (File('${dir.path}/setfile.txt').writeAsString(weatherString2))
        .then((value) async {
      await (File('${dir.path}/weather.csv').writeAsString(weatherString))
          .then((value) {
        encoder.create('${dir.path}/input.zip');
        encoder.addFile(File('${dir.path}/weather.csv'));
        encoder.addFile(File('${dir.path}/setfile.txt'));
        encoder.close();
      });
    });
    // base64 encoding
    var z = await File('${dir.path}/input.zip').readAsBytes();
    String token = base64.encode(z);
    print("input.zip done!!!");

/////////////////////////////////////
// apple Disease
/////////////////////////////////////

    // http request
    var urlapple = 'https://ncpms-apple-api.camp.re.kr/NCPMS/Apple';

    var apikey = "61cdc660a46f4fcc93004de201c58dff";
    var param = jsonEncode({'apiKey': apikey});

    if (Platform.isAndroid) {
      showToast(context, "병해충예측 서버에 접속합니다.", Colors.blueAccent);
    }
// create session
    var urlm = "$urlapple/connect";
    print(urlm);
    http.Response responseC = await http.post(
      Uri.parse(urlm),
      headers: <String, String>{
        'Content-Type': 'application/json',
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: param,
    );
    var jobID = responseC.body;
    print(responseC.statusCode);
    print("NCPMS jobID호출");
    print(jobID);

    if (responseC.statusCode == 200) {
// launch model by session key
      if (Platform.isAndroid) {
        showToast(context, "사과 병해충 예측 모델을 실행합니다", Colors.blueAccent);
      }
      param = jsonEncode({'apiKey': apikey, 'jobid': jobID, 'file': token});
      urlm = "$urlapple/launch";
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
      urlm = "$urlapple/getStatus";
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
          if (Platform.isAndroid) {
            showToast(context, "모델을 실행중입니다", Colors.blueAccent);
          }
        }
        rS = responseS.body;
        print(rS);
      }

// get output
      if (Platform.isAndroid) {
        showToast(context, "예측결과를 가져옵니다", Colors.blueAccent);
      }
      urlm = "$urlapple/getOutput";
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
      // var rOO = responseO.body;
      print("######################################");
      // print(rOO);

      await (File('${dir.path}/output.zip').writeAsBytes(rO));

// Decode the Zip file
      final bytes = rO;
      final archive = ZipDecoder().decodeBytes(bytes);

// Extract the contents of the Zip archive to disk.
      List<String> fList = [];
      fList.clear();
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
        fList.add(filename);
      }
      print(fList);

// Read the Zip file from disk.
      for (var pName in fList) {
        // print(pName);
        var rrr = await File('${dir.path}/$pName').readAsString();
        // print(rrr);
        var jsonObj = jsonDecode(rrr);
        // print(jsonObj.toString());
        switch (pName) {
          case 'AppleBoks.json':
            for (int i = 0; i < 7; i++) {
              applePestL[i].AppleBoks = jsonObj[i]['BoksDEG'] * 1.0;
            }
            break;
          case 'AppleGuln.json':
            for (int i = 0; i < 7; i++) {
              applePestL[i].AppleGuln = jsonObj[i]['GulnDEG'] * 1.0;
            }
            break;
          case 'AppleAemo.json':
            for (int i = 0; i < 7; i++) {
              applePestL[i].AppleAemo = jsonObj[i]['AemoDEG'] * 1.0;
            }
            break;
          case 'ApplePano.json':
            for (int i = 0; i < 7; i++) {
              applePestL[i].ApplePano = jsonObj[i]['PanoDEG'] * 1.0;
            }
            break;
          case 'AppleArchips.json':
            for (int i = 0; i < 7; i++) {
              applePestL[i].AppleArchips = jsonObj[i]['ArchDEG'] * 1.0;
            }
            break;
          case 'AppleWhiteRot.json':
            for (int i = 0; i < 7; i++) {
              applePestL[i].AppleWhiteRot = jsonObj[i]['DVS'] * 1.0;
            }
            break;
          case 'CherryTreeBorer.json':
            for (int i = 0; i < 7; i++) {
              applePestL[i].CherryTreeBorer = jsonObj[i]['CTB'] * 1.0;
            }
            break;
          case 'OrientalFruitMoth.json':
            for (int i = 0; i < 7; i++) {
              applePestL[i].OrientalFruitMoth = jsonObj[i]['OFMDD1'] * 1.0;
            }
            break;
          case 'PeachFruitMoth.json':
            for (int i = 0; i < 7; i++) {
              applePestL[i].PeachFruitMoth = jsonObj[i]['PFMDEG'] * 1.0;
            }
            break;
          case 'PearBsun.json':
            for (int i = 0; i < 7; i++) {
              applePestL[i].PearBsun = jsonObj[i]['BsunDEG'] * 1.0;
            }
            break;
          case 'PearGaru.json':
            for (int i = 0; i < 7; i++) {
              applePestL[i].PearGaru = jsonObj[i]['GaruDEG'] * 1.0;
            }
            break;
          case 'PearScab.json':
            for (int i = 0; i < 7; i++) {
              applePestL[i].PearScab = jsonObj[i]['ACCIR'] * 1.0;
            }
            break;
          case 'PlumFruitMoth.json':
            for (int i = 0; i < 7; i++) {
              applePestL[i].PlumFruitMoth = jsonObj[i]['PFMDD1'] * 1.0;
            }
            break;
        }
      }

// remove session
      urlm = "$urlapple/disconnect";
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

//////////////////////////////////////////////////////////////
      ///

      if (Platform.isAndroid) {
        showToast(context, "예측결과를 표시합니다", Colors.blueAccent);
      }
/////////////////////////////////////////////////////
      //pinf update

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

      // notifyListeners();
    } else {
      throw Exception("데이터가져오기 실패");
    }
    return 0;
  }

  Future apiRequestPear(BuildContext context) async {
    print("apiRequestPear!!");

    // http request
    var urlpear0 = 'https://ncpms-pear-api.camp.re.kr/NCPMS/Pear';

    var apikey0 = "61cdc660a46f4fcc93004de201c58dff";
    var param0 = jsonEncode({'apiKey': apikey0});

// create session: server check
    var urlm0 = "$urlpear0/connect";
    print(urlm0);
    http.Response r = await http.post(
      Uri.parse(urlm0),
      headers: <String, String>{
        'Content-Type': 'application/json',
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: param0,
    );

    var encoder = ZipFileEncoder();
    final dir = await getApplicationDocumentsDirectory();
    // Directory dir = Directory('/storage/emulated/0/Documents ');

    String formatTime = '';
    var kk = sensorLists[ppfarm].length;
    var k = 0;

    final today = DateTime.now();
    final sdate = today.subtract(Duration(days: 4));
    final edate = today.add(Duration(days: 2));
    var weatherString =
        'date,hour,tair,humi,radi,rain,maxAirtemp,minAirtemp,wet,'
        'wspd,tGrowth,tHI,av_t_7d,av_rh_5d\n';

    for (int i = 0; i < 7; i++) {
      var date = ewsList[i].date;
      // ignore: prefer_interpolation_to_compose_strings
      var dateString = date!.substring(0, 4) +
          "-" +
          date.substring(4, 6) +
          "-" +
          date.substring(6, 8);
      var v1 = dateString;
      var v2 = ewsList[i].hour.toString();
      var v3 = ewsList[i].tair.toString();
      var v4 = ewsList[i].humi.toString();
      var v5 = ewsList[i].radi.toString();
      var v6 = ewsList[i].rain.toString();
      var v7 = ewsList[i].maxAirtemp.toString();
      var v8 = ewsList[i].minAirtemp.toString();
      var v9 = ewsList[i].wet.toString();
      var v10 = ewsList[i].wspd.toString();
      var v11 = ewsList[i].tGrowth.toString();
      var v12 = ewsList[i].tHI.toString();
      var v13 = ewsList[i].av_t_7d.toString();
      var v14 = ewsList[i].av_rh_5d.toString();

      weatherString =
          "$weatherString$v1,$v2,$v3,$v4,$v5,$v6,$v7,$v8,$v9,$v10,$v11,$v12,$v13,$v14\n";
    }
    var sdateString = DateFormat('yyyy-MM-dd').format(sdate);
    var edateString = DateFormat('yyyy-MM-dd').format(edate);
    var weatherString2 = "$sdateString,$edateString,day,all";
    print(weatherString);
    print(weatherString2);
    // zip weather.csv
    await (File('${dir.path}/setfile.txt').writeAsString(weatherString2))
        .then((value) async {
      await (File('${dir.path}/weather.csv').writeAsString(weatherString))
          .then((value) {
        encoder.create('${dir.path}/input.zip');
        encoder.addFile(File('${dir.path}/weather.csv'));
        encoder.addFile(File('${dir.path}/setfile.txt'));
        encoder.close();
      });
    });
    // base64 encoding
    var z = await File('${dir.path}/input.zip').readAsBytes();
    String token = base64.encode(z);
    print("input.zip done!!!");

/////////////////////////////////////
// apple Disease
/////////////////////////////////////

    // http request
    var urlpear = 'https://ncpms-pear-api.camp.re.kr/NCPMS/Pear';

    var apikey = "61cdc660a46f4fcc93004de201c58dff";
    var param = jsonEncode({'apiKey': apikey});

    if (Platform.isAndroid) {
      showToast(context, "병해충예측 서버에 접속합니다.", Colors.blueAccent);
    }
// create session
    var urlm = "$urlpear/connect";
    print(urlm);
    http.Response responseC = await http.post(
      Uri.parse(urlm),
      headers: <String, String>{
        'Content-Type': 'application/json',
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: param,
    );
    var jobID = responseC.body;
    print(responseC.statusCode);
    print("NCPMS jobID호출");
    print(jobID);

    if (responseC.statusCode == 200) {
// launch model by session key
      if (Platform.isAndroid) {
        showToast(context, "배 병해충 예측 모델을 실행합니다", Colors.blueAccent);
      }
      param = jsonEncode({'apiKey': apikey, 'jobid': jobID, 'file': token});
      urlm = "$urlpear/launch";
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
      urlm = "$urlpear/getStatus";
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
          if (Platform.isAndroid) {
            showToast(context, "모델을 실행중입니다", Colors.blueAccent);
          }
        }
        rS = responseS.body;
        print(rS);
      }

// get output
      if (Platform.isAndroid) {
        showToast(context, "예측결과를 가져옵니다", Colors.blueAccent);
      }
      urlm = "$urlpear/getOutput";
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
      // var rOO = responseO.body;
      print("output A NCPMS ######################################");
      // print(rOO);

      await (File('${dir.path}/output.zip').writeAsBytes(rO));

// Decode the Zip file
      final bytes = rO;
      final archive = ZipDecoder().decodeBytes(bytes);

// Extract the contents of the Zip archive to disk.
      List<String> fList = [];
      fList.clear();
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
        fList.add(filename);
      }
      print(fList);

// Read the Zip file from disk.
      for (var pName in fList) {
        print(pName);
        var rrr = await File('${dir.path}/$pName').readAsString();
        // print(rrr);
        var jsonObj = jsonDecode(rrr);
        print(jsonObj.toString());
        switch (pName) {
          case 'AppleBoks.json':
            for (int i = 0; i < 7; i++) {
              pearPestL[i].AppleBoks = jsonObj[i]['BoksDEG'] * 1.0;
            }
            break;
          case 'AppleGuln.json':
            for (int i = 0; i < 7; i++) {
              pearPestL[i].AppleGuln = jsonObj[i]['GulnDEG'] * 1.0;
            }
            break;
          case 'AppleAemo.json':
            for (int i = 0; i < 7; i++) {
              pearPestL[i].AppleAemo = jsonObj[i]['AemoDEG'] * 1.0;
            }
            break;
          case 'ApplePano.json':
            for (int i = 0; i < 7; i++) {
              pearPestL[i].ApplePano = jsonObj[i]['PanoDEG'] * 1.0;
            }
            break;
          case 'AppleArchips.json':
            for (int i = 0; i < 7; i++) {
              pearPestL[i].AppleArchips = jsonObj[i]['ArchDEG'] * 1.0;
            }
            break;
          case 'AppleWhiteRot.json':
            for (int i = 0; i < 7; i++) {
              pearPestL[i].AppleWhiteRot = jsonObj[i]['DVS'] * 1.0;
            }
            break;
          case 'CherryTreeBorer.json':
            for (int i = 0; i < 7; i++) {
              pearPestL[i].CherryTreeBorer = jsonObj[i]['CTB'] * 1.0;
            }
            break;
          case 'OrientalFruitMoth.json':
            for (int i = 0; i < 7; i++) {
              pearPestL[i].OrientalFruitMoth = jsonObj[i]['OFMDD1'] * 1.0;
            }
            break;
          case 'PeachFruitMoth.json':
            for (int i = 0; i < 7; i++) {
              pearPestL[i].PeachFruitMoth = jsonObj[i]['PFMDEG'] * 1.0;
            }
            break;
          case 'PearBsun.json':
            for (int i = 0; i < 7; i++) {
              pearPestL[i].PearBsun = jsonObj[i]['BsunDEG'] * 1.0;
            }
            break;
          case 'PearGaru.json':
            for (int i = 0; i < 7; i++) {
              pearPestL[i].PearGaru = jsonObj[i]['ggomDEG'] * 1.0;
            }
            break;
          // case 'PearScab.json':
          //   for (int i = 0; i < 7; i++) {
          //     pearPestL[i].PearScab = jsonObj[i]['ACCIR'] * 1.0;
          //   }
          //   break;
          case 'PlumFruitMoth.json':
            for (int i = 0; i < 7; i++) {
              pearPestL[i].PlumFruitMoth = jsonObj[i]['PFMDD1'] * 1.0;
            }
            break;
          default:
            break;
        }
      }

// remove session
      urlm = "$urlpear/disconnect";
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

//////////////////////////////////////////////////////////////
      ///

      if (Platform.isAndroid) {
        showToast(context, "예측결과를 표시합니다", Colors.blueAccent);
      }
/////////////////////////////////////////////////////
      //pinf update

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

      // notifyListeners();
    } else {
      throw Exception("데이터가져오기 실패");
    }
    return 0;
  }

  Future apiRequestRice(BuildContext context) async {
    print("apiRequestRice!!");

    // http request
    var urlrice0 = 'https://ncpms-rice-api.camp.re.kr/NCPMS/Rice';

    var apikey0 = "61cdc660a46f4fcc93004de201c58dff";
    var param0 = jsonEncode({'apiKey': apikey0});

// create session: server check
    var urlm0 = "$urlrice0/connect";
    print(urlm0);
    http.Response r = await http.post(
      Uri.parse(urlm0),
      headers: <String, String>{
        'Content-Type': 'application/json',
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: param0,
    );
    print(r.statusCode);
    var encoder = ZipFileEncoder();
    final dir = await getApplicationDocumentsDirectory();
    // Directory dir = Directory('/storage/emulated/0/Documents ');

    String formatTime = '';
    var kk = sensorLists[ppfarm].length;
    var k = 0;

    final today = DateTime.now();
    final sdate = today.subtract(Duration(days: 4));
    final edate = today.add(Duration(days: 2));
    var weatherString =
        'date,hour,tair,humi,radi,rain,maxAirtemp,minAirtemp,wet,'
        'wspd,tGrowth,tHI,av_t_7d,av_rh_5d\n';

    for (int i = 0; i < 7; i++) {
      var date = ewsList[i].date;
      // ignore: prefer_interpolation_to_compose_strings
      var dateString = date!.substring(0, 4) +
          "-" +
          date.substring(4, 6) +
          "-" +
          date.substring(6, 8);
      var v1 = dateString;
      var v2 = ewsList[i].hour.toString();
      var v3 = ewsList[i].tair.toString();
      var v4 = ewsList[i].humi.toString();
      var v5 = ewsList[i].radi.toString();
      var v6 = ewsList[i].rain.toString();
      var v7 = ewsList[i].maxAirtemp.toString();
      var v8 = ewsList[i].minAirtemp.toString();
      var v9 = ewsList[i].wet.toString();
      var v10 = ewsList[i].wspd.toString();
      var v11 = ewsList[i].tGrowth.toString();
      var v12 = ewsList[i].tHI.toString();
      var v13 = ewsList[i].av_t_7d.toString();
      var v14 = ewsList[i].av_rh_5d.toString();

      weatherString =
          "$weatherString$v1,$v2,$v3,$v4,$v5,$v6,$v7,$v8,$v9,$v10,$v11,$v12,$v13,$v14\n";
    }
    var sdateString = DateFormat('yyyy-MM-dd').format(sdate);
    var edateString = DateFormat('yyyy-MM-dd').format(edate);
    var weatherString2 = "$sdateString,$edateString,day,all";
    print(weatherString);
    print(weatherString2);
    // zip weather.csv
    await (File('${dir.path}/setfile.txt').writeAsString(weatherString2))
        .then((value) async {
      await (File('${dir.path}/weather.csv').writeAsString(weatherString))
          .then((value) {
        encoder.create('${dir.path}/input.zip');
        encoder.addFile(File('${dir.path}/weather.csv'));
        encoder.addFile(File('${dir.path}/setfile.txt'));
        encoder.close();
      });
    });
    // base64 encoding
    var z = await File('${dir.path}/input.zip').readAsBytes();
    String token = base64.encode(z);
    print("input.zip done!!!");

/////////////////////////////////////
// rice Disease
/////////////////////////////////////

    // http request
    var urlrice = 'https://ncpms-rice-api.camp.re.kr/NCPMS/Rice';

    var apikey = "61cdc660a46f4fcc93004de201c58dff";
    var param = jsonEncode({'apiKey': apikey});

    if (Platform.isAndroid) {
      showToast(context, "병해충예측 서버에 접속합니다.", Colors.blueAccent);
    }
// create session
    var urlm = "$urlrice/connect";
    print(urlm);
    http.Response responseC = await http.post(
      Uri.parse(urlm),
      headers: <String, String>{
        'Content-Type': 'application/json',
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: param,
    );
    var jobID = responseC.body;
    print(responseC.statusCode);
    print("NCPMS jobID호출");
    print(jobID);

    if (responseC.statusCode == 200) {
// launch model by session key
      if (Platform.isAndroid) {
        showToast(context, "기타 병해충 예측 모델을 실행합니다", Colors.blueAccent);
      }
      param = jsonEncode({'apiKey': apikey, 'jobid': jobID, 'file': token});
      urlm = "$urlrice/launch";
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
      urlm = "$urlrice/getStatus";
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
          if (Platform.isAndroid) {
            showToast(context, "모델을 실행중입니다", Colors.blueAccent);
          }
        }
        rS = responseS.body;
        print(rS);
      }

// get output
      if (Platform.isAndroid) {
        showToast(context, "예측결과를 가져옵니다", Colors.blueAccent);
      }
      urlm = "$urlrice/getOutput";
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
      // var rOO = responseO.body;
      print("output A NCPMS ######################################");
      // print(rOO);

      await (File('${dir.path}/output.zip').writeAsBytes(rO));

// Decode the Zip file
      final bytes = rO;
      final archive = ZipDecoder().decodeBytes(bytes);

// Extract the contents of the Zip archive to disk.
      List<String> fList = [];
      fList.clear();
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
        fList.add(filename);
      }
      print(fList);

// Read the Zip file from disk.
      for (var pName in fList) {
        print(pName);
        var rrr = await File('${dir.path}/$pName').readAsString();
        // print(rrr);
        var jsonObj = jsonDecode(rrr);
        print(jsonObj.toString());
        switch (pName) {
          case 'AppleBoks.json':
            for (int i = 0; i < 7; i++) {
              applePestL[i].AppleBoks = jsonObj[i]['BoksDEG'] * 1.0;
            }
            break;
          case 'AppleGuln.json':
            for (int i = 0; i < 7; i++) {
              applePestL[i].AppleGuln = jsonObj[i]['GulnDEG'] * 1.0;
            }
            break;
          case 'AppleAemo.json':
            for (int i = 0; i < 7; i++) {
              applePestL[i].AppleAemo = jsonObj[i]['AemoDEG'] * 1.0;
            }
            break;
          case 'ApplePano.json':
            for (int i = 0; i < 7; i++) {
              applePestL[i].ApplePano = jsonObj[i]['PanoDEG'] * 1.0;
            }
            break;
          case 'AppleArchips.json':
            for (int i = 0; i < 7; i++) {
              applePestL[i].AppleArchips = jsonObj[i]['ArchDEG'] * 1.0;
            }
            break;
          case 'AppleWhiteRot.json':
            for (int i = 0; i < 7; i++) {
              applePestL[i].AppleWhiteRot = jsonObj[i]['DVS'] * 1.0;
            }
            break;
          case 'CherryTreeBorer.json':
            for (int i = 0; i < 7; i++) {
              applePestL[i].CherryTreeBorer = jsonObj[i]['CTB'] * 1.0;
            }
            break;
          case 'OrientalFruitMoth.json':
            for (int i = 0; i < 7; i++) {
              applePestL[i].OrientalFruitMoth = jsonObj[i]['OFMDD1'] * 1.0;
            }
            break;
          case 'PeachFruitMoth.json':
            for (int i = 0; i < 7; i++) {
              applePestL[i].PeachFruitMoth = jsonObj[i]['PFMDEG'] * 1.0;
            }
            break;
          case 'PearBsun.json':
            for (int i = 0; i < 7; i++) {
              applePestL[i].PearBsun = jsonObj[i]['BsunDEG'] * 1.0;
            }
            break;
          case 'PearGaru.json':
            for (int i = 0; i < 7; i++) {
              applePestL[i].PearGaru = jsonObj[i]['GaruDEG'] * 1.0;
            }
            break;
          case 'PearScab.json':
            for (int i = 0; i < 7; i++) {
              applePestL[i].PearScab = jsonObj[i]['ACCIR'] * 1.0;
            }
            break;
          case 'PlumFruitMoth.json':
            for (int i = 0; i < 7; i++) {
              applePestL[i].PlumFruitMoth = jsonObj[i]['PFMDD1'] * 1.0;
            }
            break;
        }
      }

// remove session
      urlm = "$urlrice/disconnect";
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

//////////////////////////////////////////////////////////////
      ///

      if (Platform.isAndroid) {
        showToast(context, "예측결과를 표시합니다", Colors.blueAccent);
      }
/////////////////////////////////////////////////////
      //pinf update

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

      // notifyListeners();
    } else {
      throw Exception("데이터가져오기 실패");
    }
    return 0;
  }

  Future apiRequestPotato(BuildContext context) async {
    print("apiRequestPotato!!");

    // http request
    var urlpotato0 = 'https://ncpms-potato-api.camp.re.kr/NCPMS/Potato';

    var apikey0 = "61cdc660a46f4fcc93004de201c58dff";
    var param0 = jsonEncode({'apiKey': apikey0});

// create session: server check
    var urlm0 = "$urlpotato0/connect";
    print(urlm0);
    http.Response r = await http.post(
      Uri.parse(urlm0),
      headers: <String, String>{
        'Content-Type': 'application/json',
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: param0,
    );

    var encoder = ZipFileEncoder();
    final dir = await getApplicationDocumentsDirectory();
    // Directory dir = Directory('/storage/emulated/0/Documents ');

    String formatTime = '';
    var kk = sensorLists[ppfarm].length;
    var k = 0;

    final today = DateTime.now();
    final sdate = today.subtract(Duration(days: 4));
    final edate = today.add(Duration(days: 2));
    var weatherString =
        'date,hour,tair,humi,radi,rain,maxAirtemp,minAirtemp,wet,'
        'wspd,tGrowth,tHI,av_t_7d,av_rh_5d\n';

    for (int i = 0; i < 7; i++) {
      var date = ewsList[i].date;
      // ignore: prefer_interpolation_to_compose_strings
      var dateString = date!.substring(0, 4) +
          "-" +
          date.substring(4, 6) +
          "-" +
          date.substring(6, 8);
      var v1 = dateString;
      var v2 = ewsList[i].hour.toString();
      var v3 = ewsList[i].tair.toString();
      var v4 = ewsList[i].humi.toString();
      var v5 = ewsList[i].radi.toString();
      var v6 = ewsList[i].rain.toString();
      var v7 = ewsList[i].maxAirtemp.toString();
      var v8 = ewsList[i].minAirtemp.toString();
      var v9 = ewsList[i].wet.toString();
      var v10 = ewsList[i].wspd.toString();
      var v11 = ewsList[i].tGrowth.toString();
      var v12 = ewsList[i].tHI.toString();
      var v13 = ewsList[i].av_t_7d.toString();
      var v14 = ewsList[i].av_rh_5d.toString();

      weatherString =
          "$weatherString$v1,$v2,$v3,$v4,$v5,$v6,$v7,$v8,$v9,$v10,$v11,$v12,$v13,$v14\n";
    }
    var sdateString = DateFormat('yyyy-MM-dd').format(sdate);
    var edateString = DateFormat('yyyy-MM-dd').format(edate);
    var weatherString2 = "$sdateString,$edateString,day,all";
    print(weatherString);
    print(weatherString2);
    // zip weather.csv
    await (File('${dir.path}/setfile.txt').writeAsString(weatherString2))
        .then((value) async {
      await (File('${dir.path}/weather.csv').writeAsString(weatherString))
          .then((value) {
        encoder.create('${dir.path}/input.zip');
        encoder.addFile(File('${dir.path}/weather.csv'));
        encoder.addFile(File('${dir.path}/setfile.txt'));
        encoder.close();
      });
    });
    // base64 encoding
    var z = await File('${dir.path}/input.zip').readAsBytes();
    String token = base64.encode(z);
    print("input.zip done!!!");

/////////////////////////////////////
// potato Disease
/////////////////////////////////////

    // http request
    var urlpotato = 'https://ncpms-potato-api.camp.re.kr/NCPMS/Potato';

    var apikey = "61cdc660a46f4fcc93004de201c58dff";
    var param = jsonEncode({'apiKey': apikey});

    if (Platform.isAndroid) {
      showToast(context, "병해충예측 서버에 접속합니다.", Colors.blueAccent);
    }
// create session
    var urlm = "$urlpotato/connect";
    print(urlm);
    http.Response responseC = await http.post(
      Uri.parse(urlm),
      headers: <String, String>{
        'Content-Type': 'application/json',
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: param,
    );
    var jobID = responseC.body;
    print(responseC.statusCode);
    print("NCPMS jobID호출");
    print(jobID);

    if (responseC.statusCode == 200) {
// launch model by session key
      if (Platform.isAndroid) {
        showToast(context, "감자 병해충 예측 모델을 실행합니다", Colors.blueAccent);
      }
      param = jsonEncode({'apiKey': apikey, 'jobid': jobID, 'file': token});
      urlm = "$urlpotato/launch";
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
      urlm = "$urlpotato/getStatus";
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
          if (Platform.isAndroid) {
            showToast(context, "모델을 실행중입니다", Colors.blueAccent);
          }
        }
        rS = responseS.body;
        print(rS);
      }

// get output
      if (Platform.isAndroid) {
        showToast(context, "예측결과를 가져옵니다", Colors.blueAccent);
      }
      urlm = "$urlpotato/getOutput";
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
      // var rOO = responseO.body;
      print("output A NCPMS ######################################");
      // print(rOO);

      await (File('${dir.path}/output.zip').writeAsBytes(rO));

// Decode the Zip file
      final bytes = rO;
      final archive = ZipDecoder().decodeBytes(bytes);

// Extract the contents of the Zip archive to disk.
      List<String> fList = [];
      fList.clear();
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
        fList.add(filename);
      }
      print(fList);

// Read the Zip file from disk.
      for (var pName in fList) {
        print(pName);
        var rrr = await File('${dir.path}/$pName').readAsString();
        // print(rrr);
        var jsonObj = jsonDecode(rrr);
        print(jsonObj.toString());
        switch (pName) {
          case 'AppleBoks.json':
            for (int i = 0; i < 7; i++) {
              applePestL[i].AppleBoks = jsonObj[i]['BoksDEG'] * 1.0;
            }
            break;
          case 'AppleGuln.json':
            for (int i = 0; i < 7; i++) {
              applePestL[i].AppleGuln = jsonObj[i]['GulnDEG'] * 1.0;
            }
            break;
          case 'AppleAemo.json':
            for (int i = 0; i < 7; i++) {
              applePestL[i].AppleAemo = jsonObj[i]['AemoDEG'] * 1.0;
            }
            break;
          case 'ApplePano.json':
            for (int i = 0; i < 7; i++) {
              applePestL[i].ApplePano = jsonObj[i]['PanoDEG'] * 1.0;
            }
            break;
          case 'AppleArchips.json':
            for (int i = 0; i < 7; i++) {
              applePestL[i].AppleArchips = jsonObj[i]['ArchDEG'] * 1.0;
            }
            break;
          case 'AppleWhiteRot.json':
            for (int i = 0; i < 7; i++) {
              applePestL[i].AppleWhiteRot = jsonObj[i]['DVS'] * 1.0;
            }
            break;
          case 'CherryTreeBorer.json':
            for (int i = 0; i < 7; i++) {
              applePestL[i].CherryTreeBorer = jsonObj[i]['CTB'] * 1.0;
            }
            break;
          case 'OrientalFruitMoth.json':
            for (int i = 0; i < 7; i++) {
              applePestL[i].OrientalFruitMoth = jsonObj[i]['OFMDD1'] * 1.0;
            }
            break;
          case 'PeachFruitMoth.json':
            for (int i = 0; i < 7; i++) {
              applePestL[i].PeachFruitMoth = jsonObj[i]['PFMDEG'] * 1.0;
            }
            break;
          case 'PearBsun.json':
            for (int i = 0; i < 7; i++) {
              applePestL[i].PearBsun = jsonObj[i]['BsunDEG'] * 1.0;
            }
            break;
          case 'PearGaru.json':
            for (int i = 0; i < 7; i++) {
              applePestL[i].PearGaru = jsonObj[i]['GaruDEG'] * 1.0;
            }
            break;
          case 'PearScab.json':
            for (int i = 0; i < 7; i++) {
              applePestL[i].PearScab = jsonObj[i]['ACCIR'] * 1.0;
            }
            break;
          case 'PlumFruitMoth.json':
            for (int i = 0; i < 7; i++) {
              applePestL[i].PlumFruitMoth = jsonObj[i]['PFMDD1'] * 1.0;
            }
            break;
        }
      }

// remove session
      urlm = "$urlpotato/disconnect";
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

//////////////////////////////////////////////////////////////
      ///

      if (Platform.isAndroid) {
        showToast(context, "예측결과를 표시합니다", Colors.blueAccent);
      }
/////////////////////////////////////////////////////
      //pinf update

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

      // notifyListeners();
    } else {
      throw Exception("데이터가져오기 실패");
    }
    return 0;
  }

  Future apiRequestPepper(BuildContext context) async {
    print("apiRequestPepper!!");

    // http request
    var urlpepper0 = 'https://ncpms-pepper-api.camp.re.kr/NCPMS/Pepper';

    var apikey0 = "61cdc660a46f4fcc93004de201c58dff";
    var param0 = jsonEncode({'apiKey': apikey0});

// create session: server check
    var urlm0 = "$urlpepper0/connect";
    print(urlm0);
    http.Response r = await http.post(
      Uri.parse(urlm0),
      headers: <String, String>{
        'Content-Type': 'application/json',
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: param0,
    );

    var encoder = ZipFileEncoder();
    final dir = await getApplicationDocumentsDirectory();
    // Directory dir = Directory('/storage/emulated/0/Documents ');

    String formatTime = '';
    var kk = sensorLists[ppfarm].length;
    var k = 0;

    final today = DateTime.now();
    final sdate = today.subtract(Duration(days: 4));
    final edate = today.add(Duration(days: 2));
    var weatherString =
        'date,hour,tair,humi,radi,rain,maxAirtemp,minAirtemp,wet,'
        'wspd,tGrowth,tHI,av_t_7d,av_rh_5d\n';

    for (int i = 0; i < 7; i++) {
      var date = ewsList[i].date;
      // ignore: prefer_interpolation_to_compose_strings
      var dateString = date!.substring(0, 4) +
          "-" +
          date.substring(4, 6) +
          "-" +
          date.substring(6, 8);
      var v1 = dateString;
      var v2 = ewsList[i].hour.toString();
      var v3 = ewsList[i].tair.toString();
      var v4 = ewsList[i].humi.toString();
      var v5 = ewsList[i].radi.toString();
      var v6 = ewsList[i].rain.toString();
      var v7 = ewsList[i].maxAirtemp.toString();
      var v8 = ewsList[i].minAirtemp.toString();
      var v9 = ewsList[i].wet.toString();
      var v10 = ewsList[i].wspd.toString();
      var v11 = ewsList[i].tGrowth.toString();
      var v12 = ewsList[i].tHI.toString();
      var v13 = ewsList[i].av_t_7d.toString();
      var v14 = ewsList[i].av_rh_5d.toString();

      weatherString =
          "$weatherString$v1,$v2,$v3,$v4,$v5,$v6,$v7,$v8,$v9,$v10,$v11,$v12,$v13,$v14\n";
    }
    var sdateString = DateFormat('yyyy-MM-dd').format(sdate);
    var edateString = DateFormat('yyyy-MM-dd').format(edate);
    var weatherString2 = "$sdateString,$edateString,day,all";
    print(weatherString);
    print(weatherString2);
    // zip weather.csv
    await (File('${dir.path}/setfile.txt').writeAsString(weatherString2))
        .then((value) async {
      await (File('${dir.path}/weather.csv').writeAsString(weatherString))
          .then((value) {
        encoder.create('${dir.path}/input.zip');
        encoder.addFile(File('${dir.path}/weather.csv'));
        encoder.addFile(File('${dir.path}/setfile.txt'));
        encoder.close();
      });
    });
    // base64 encoding
    var z = await File('${dir.path}/input.zip').readAsBytes();
    String token = base64.encode(z);
    print("input.zip done!!!");

/////////////////////////////////////
// pepper Disease
/////////////////////////////////////

    // http request
    var urlpepper = 'https://ncpms-pepper-api.camp.re.kr/NCPMS/Pepper';

    var apikey = "61cdc660a46f4fcc93004de201c58dff";
    var param = jsonEncode({'apiKey': apikey});

    if (Platform.isAndroid) {
      showToast(context, "병해충예측 서버에 접속합니다.", Colors.blueAccent);
    }
// create session
    var urlm = "$urlpepper/connect";
    print(urlm);
    http.Response responseC = await http.post(
      Uri.parse(urlm),
      headers: <String, String>{
        'Content-Type': 'application/json',
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: param,
    );
    var jobID = responseC.body;
    print(responseC.statusCode);
    print("NCPMS jobID호출");
    print(jobID);

    if (responseC.statusCode == 200) {
// launch model by session key
      if (Platform.isAndroid) {
        showToast(context, "고추 병해충 예측 모델을 실행합니다", Colors.blueAccent);
      }
      param = jsonEncode({'apiKey': apikey, 'jobid': jobID, 'file': token});
      urlm = "$urlpepper/launch";
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
      urlm = "$urlpepper/getStatus";
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
          if (Platform.isAndroid) {
            showToast(context, "모델을 실행중입니다", Colors.blueAccent);
          }
        }
        rS = responseS.body;
        print(rS);
      }

// get output
      if (Platform.isAndroid) {
        showToast(context, "예측결과를 가져옵니다", Colors.blueAccent);
      }
      urlm = "$urlpepper/getOutput";
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
      // var rOO = responseO.body;
      print("output NCPMS: pepper ######################################");
      // print(rOO);

      await (File('${dir.path}/output.zip').writeAsBytes(rO));

// Decode the Zip file
      final bytes = rO;
      final archive = ZipDecoder().decodeBytes(bytes);

// Extract the contents of the Zip archive to disk.
      List<String> fList = [];
      fList.clear();
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
        fList.add(filename);
      }
      print(fList);
/*
    Pepper_Antracnose,
    PepperBacterialLeafSpot,
    PepperBacterialWilt,
    PepperOrientalTobaccoBudworm,
    WesternFlowerThrips,
*/
// Read the Zip file from disk.
      for (var pName in fList) {
        print(pName);
        var rrr = await File('${dir.path}/$pName').readAsString();
        // print(rrr);
        var jsonObj = jsonDecode(rrr);
        print(jsonObj.toString());
        switch (pName) {
          case 'Pepper_Antracnose.json':
            for (int i = 0; i < 7; i++) {
              pepperPestL[i].Pepper_Antracnose = jsonObj[i]['ACCDRH'] * 1.0;
            }
            break;
          case 'PepperBacterialLeafSpot.json':
            for (int i = 0; i < 7; i++) {
              pepperPestL[i].PepperBacterialLeafSpot =
                  jsonObj[i]['surface'] * 1.0;
            }
            break;
          case 'PepperBacterialWilt.json':
            for (int i = 0; i < 7; i++) {
              pepperPestL[i].PepperBacterialWilt = jsonObj[i]['soil'] * 1.0;
            }
            break;
          case 'PepperOrientalTobaccoBudworm.json':
            for (int i = 0; i < 7; i++) {
              pepperPestL[i].PepperOrientalTobaccoBudworm =
                  jsonObj[i]['P1'] * 1.0;
            }
            break;
          case 'PlumFruitMoth.json': //WesternFlowerThrips.son
            for (int i = 0; i < 7; i++) {
              pepperPestL[i].WesternFlowerThrips = jsonObj[i]['WFT'] * 1.0;
            }
            break;
        }
      }

// remove session
      urlm = "$urlpepper/disconnect";
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

//////////////////////////////////////////////////////////////
      ///

      if (Platform.isAndroid) {
        showToast(context, "예측결과를 표시합니다", Colors.blueAccent);
      }
/////////////////////////////////////////////////////
      //pinf update

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

      // notifyListeners();
    } else {
      throw Exception("데이터가져오기 실패");
    }
    return 0;
  }

  Future apiRequestGarlic(BuildContext context) async {
    print("apiRequestGarlic!!");

    // http request
    var urlgarlic0 = 'https://ncpms-garlic-api.camp.re.kr/NCPMS/Garlic';

    var apikey0 = "61cdc660a46f4fcc93004de201c58dff";
    var param0 = jsonEncode({'apiKey': apikey0});

// create session: server check
    var urlm0 = "$urlgarlic0/connect";
    print(urlm0);
    http.Response r = await http.post(
      Uri.parse(urlm0),
      headers: <String, String>{
        'Content-Type': 'application/json',
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: param0,
    );

    var encoder = ZipFileEncoder();
    final dir = await getApplicationDocumentsDirectory();
    // Directory dir = Directory('/storage/emulated/0/Documents ');

    String formatTime = '';
    var kk = sensorLists[ppfarm].length;
    var k = 0;

    final today = DateTime.now();
    final sdate = today.subtract(Duration(days: 4));
    final edate = today.add(Duration(days: 2));
    var weatherString =
        'date,hour,tair,humi,radi,rain,maxAirtemp,minAirtemp,wet,'
        'wspd,tGrowth,tHI,av_t_7d,av_rh_5d\n';

    for (int i = 0; i < 7; i++) {
      var date = ewsList[i].date;
      // ignore: prefer_interpolation_to_compose_strings
      var dateString = date!.substring(0, 4) +
          "-" +
          date.substring(4, 6) +
          "-" +
          date.substring(6, 8);
      var v1 = dateString;
      var v2 = ewsList[i].hour.toString();
      var v3 = ewsList[i].tair.toString();
      var v4 = ewsList[i].humi.toString();
      var v5 = ewsList[i].radi.toString();
      var v6 = ewsList[i].rain.toString();
      var v7 = ewsList[i].maxAirtemp.toString();
      var v8 = ewsList[i].minAirtemp.toString();
      var v9 = ewsList[i].wet.toString();
      var v10 = ewsList[i].wspd.toString();
      var v11 = ewsList[i].tGrowth.toString();
      var v12 = ewsList[i].tHI.toString();
      var v13 = ewsList[i].av_t_7d.toString();
      var v14 = ewsList[i].av_rh_5d.toString();

      weatherString =
          "$weatherString$v1,$v2,$v3,$v4,$v5,$v6,$v7,$v8,$v9,$v10,$v11,$v12,$v13,$v14\n";
    }
    var sdateString = DateFormat('yyyy-MM-dd').format(sdate);
    var edateString = DateFormat('yyyy-MM-dd').format(edate);
    var weatherString2 = "$sdateString,$edateString,day,all";
    print(weatherString);
    print(weatherString2);
    // zip weather.csv
    await (File('${dir.path}/setfile.txt').writeAsString(weatherString2))
        .then((value) async {
      await (File('${dir.path}/weather.csv').writeAsString(weatherString))
          .then((value) {
        encoder.create('${dir.path}/input.zip');
        encoder.addFile(File('${dir.path}/weather.csv'));
        encoder.addFile(File('${dir.path}/setfile.txt'));
        encoder.close();
      });
    });
    // base64 encoding
    var z = await File('${dir.path}/input.zip').readAsBytes();
    String token = base64.encode(z);
    print("input.zip done!!!");

/////////////////////////////////////
// garlic Disease
/////////////////////////////////////

    // http request
    var urlgarlic = 'https://ncpms-garlic-api.camp.re.kr/NCPMS/Garlic';

    var apikey = "61cdc660a46f4fcc93004de201c58dff";
    var param = jsonEncode({'apiKey': apikey});

    if (Platform.isAndroid) {
      showToast(context, "병해충예측 서버에 접속합니다.", Colors.blueAccent);
    }
// create session
    var urlm = "$urlgarlic/connect";
    print(urlm);
    http.Response responseC = await http.post(
      Uri.parse(urlm),
      headers: <String, String>{
        'Content-Type': 'application/json',
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: param,
    );
    var jobID = responseC.body;
    print(responseC.statusCode);
    print("NCPMS jobID호출");
    print(jobID);

    if (responseC.statusCode == 200) {
// launch model by session key
      if (Platform.isAndroid) {
        showToast(context, "마늘 병해충 예측 모델을 실행합니다", Colors.blueAccent);
      }
      param = jsonEncode({'apiKey': apikey, 'jobid': jobID, 'file': token});
      urlm = "$urlgarlic/launch";
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
      urlm = "$urlgarlic/getStatus";
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
          if (Platform.isAndroid) {
            showToast(context, "모델을 실행중입니다", Colors.blueAccent);
          }
        }
        rS = responseS.body;
        print(rS);
      }

// get output
      if (Platform.isAndroid) {
        showToast(context, "예측결과를 가져옵니다", Colors.blueAccent);
      }
      urlm = "$urlgarlic/getOutput";
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
      // var rOO = responseO.body;
      print("output A NCPMS ######################################");
      // print(rOO);

      await (File('${dir.path}/output.zip').writeAsBytes(rO));

// Decode the Zip file
      final bytes = rO;
      final archive = ZipDecoder().decodeBytes(bytes);

// Extract the contents of the Zip archive to disk.
      List<String> fList = [];
      fList.clear();
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
        fList.add(filename);
      }
      print(fList);

// Read the Zip file from disk.
      for (var pName in fList) {
        print(pName);
        var rrr = await File('${dir.path}/$pName').readAsString();
        // print(rrr);
        var jsonObj = jsonDecode(rrr);
        print(jsonObj.toString());
        switch (pName) {
          case 'AppleBoks.json':
            for (int i = 0; i < 7; i++) {
              applePestL[i].AppleBoks = jsonObj[i]['BoksDEG'] * 1.0;
            }
            break;
          case 'AppleGuln.json':
            for (int i = 0; i < 7; i++) {
              applePestL[i].AppleGuln = jsonObj[i]['GulnDEG'] * 1.0;
            }
            break;
          case 'AppleAemo.json':
            for (int i = 0; i < 7; i++) {
              applePestL[i].AppleAemo = jsonObj[i]['AemoDEG'] * 1.0;
            }
            break;
          case 'ApplePano.json':
            for (int i = 0; i < 7; i++) {
              applePestL[i].ApplePano = jsonObj[i]['PanoDEG'] * 1.0;
            }
            break;
          case 'AppleArchips.json':
            for (int i = 0; i < 7; i++) {
              applePestL[i].AppleArchips = jsonObj[i]['ArchDEG'] * 1.0;
            }
            break;
          case 'AppleWhiteRot.json':
            for (int i = 0; i < 7; i++) {
              applePestL[i].AppleWhiteRot = jsonObj[i]['DVS'] * 1.0;
            }
            break;
          case 'CherryTreeBorer.json':
            for (int i = 0; i < 7; i++) {
              applePestL[i].CherryTreeBorer = jsonObj[i]['CTB'] * 1.0;
            }
            break;
          case 'OrientalFruitMoth.json':
            for (int i = 0; i < 7; i++) {
              applePestL[i].OrientalFruitMoth = jsonObj[i]['OFMDD1'] * 1.0;
            }
            break;
          case 'PeachFruitMoth.json':
            for (int i = 0; i < 7; i++) {
              applePestL[i].PeachFruitMoth = jsonObj[i]['PFMDEG'] * 1.0;
            }
            break;
          case 'PearBsun.json':
            for (int i = 0; i < 7; i++) {
              applePestL[i].PearBsun = jsonObj[i]['BsunDEG'] * 1.0;
            }
            break;
          case 'PearGaru.json':
            for (int i = 0; i < 7; i++) {
              applePestL[i].PearGaru = jsonObj[i]['GaruDEG'] * 1.0;
            }
            break;
          case 'PearScab.json':
            for (int i = 0; i < 7; i++) {
              applePestL[i].PearScab = jsonObj[i]['ACCIR'] * 1.0;
            }
            break;
          case 'PlumFruitMoth.json':
            for (int i = 0; i < 7; i++) {
              applePestL[i].PlumFruitMoth = jsonObj[i]['PFMDD1'] * 1.0;
            }
            break;
        }
      }

// remove session
      urlm = "$urlgarlic/disconnect";
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

//////////////////////////////////////////////////////////////
      ///

      if (Platform.isAndroid) {
        showToast(context, "예측결과를 표시합니다", Colors.blueAccent);
      }
/////////////////////////////////////////////////////
      //pinf update

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

      // notifyListeners();
    } else {
      throw Exception("데이터가져오기 실패");
    }
    return 0;
  }

  Future apiRequestGrape(BuildContext context) async {
    print("apiRequestGrape!!");

    // http request
    var urlgrape0 = 'https://ncpms-grape-api.camp.re.kr/NCPMS/Grape';

    var apikey0 = "61cdc660a46f4fcc93004de201c58dff";
    var param0 = jsonEncode({'apiKey': apikey0});

// create session: server check
    var urlm0 = "$urlgrape0/connect";
    print(urlm0);
    await http.post(
      Uri.parse(urlm0),
      headers: <String, String>{
        'Content-Type': 'application/json',
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: param0,
    );

    var encoder = ZipFileEncoder();
    final dir = await getApplicationDocumentsDirectory();
    // Directory dir = Directory('/storage/emulated/0/Documents ');

    String formatTime = '';
    var kk = sensorLists[ppfarm].length;
    var k = 0;

    final today = DateTime.now();
    final sdate = today.subtract(Duration(days: 4));
    final edate = today.add(Duration(days: 2));
    var weatherString =
        'date,hour,tair,humi,radi,rain,maxAirtemp,minAirtemp,wet,'
        'wspd,tGrowth,tHI,av_t_7d,av_rh_5d\n';

    for (int i = 0; i < 7; i++) {
      var date = ewsList[i].date;
      // ignore: prefer_interpolation_to_compose_strings
      var dateString = date!.substring(0, 4) +
          "-" +
          date.substring(4, 6) +
          "-" +
          date.substring(6, 8);
      var v1 = dateString;
      var v2 = ewsList[i].hour.toString();
      var v3 = ewsList[i].tair.toString();
      var v4 = ewsList[i].humi.toString();
      var v5 = ewsList[i].radi.toString();
      var v6 = ewsList[i].rain.toString();
      var v7 = ewsList[i].maxAirtemp.toString();
      var v8 = ewsList[i].minAirtemp.toString();
      var v9 = ewsList[i].wet.toString();
      var v10 = ewsList[i].wspd.toString();
      var v11 = ewsList[i].tGrowth.toString();
      var v12 = ewsList[i].tHI.toString();
      var v13 = ewsList[i].av_t_7d.toString();
      var v14 = ewsList[i].av_rh_5d.toString();

      weatherString =
          "$weatherString$v1,$v2,$v3,$v4,$v5,$v6,$v7,$v8,$v9,$v10,$v11,$v12,$v13,$v14\n";
    }
    var sdateString = DateFormat('yyyy-MM-dd').format(sdate);
    var edateString = DateFormat('yyyy-MM-dd').format(edate);
    var weatherString2 = "$sdateString,$edateString,day,all";
    print(weatherString);
    print(weatherString2);
    // zip weather.csv
    await (File('${dir.path}/setfile.txt').writeAsString(weatherString2))
        .then((value) async {
      await (File('${dir.path}/weather.csv').writeAsString(weatherString))
          .then((value) {
        encoder.create('${dir.path}/input.zip');
        encoder.addFile(File('${dir.path}/weather.csv'));
        encoder.addFile(File('${dir.path}/setfile.txt'));
        encoder.close();
      });
    });
    // base64 encoding
    var z = await File('${dir.path}/input.zip').readAsBytes();
    String token = base64.encode(z);
    print("input.zip done!!!");

/////////////////////////////////////
// grape Disease
/////////////////////////////////////

    // http request
    var urlgrape = 'https://ncpms-grape-api.camp.re.kr/NCPMS/Grape';

    var apikey = "61cdc660a46f4fcc93004de201c58dff";
    var param = jsonEncode({'apiKey': apikey});

    if (Platform.isAndroid) {
      showToast(context, "병해충예측 서버에 접속합니다.", Colors.blueAccent);
    }
// create session
    var urlm = "$urlgrape/connect";
    print(urlm);
    http.Response responseC = await http.post(
      Uri.parse(urlm),
      headers: <String, String>{
        'Content-Type': 'application/json',
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: param,
    );
    var jobID = responseC.body;
    print(responseC.statusCode);
    print("NCPMS jobID호출");
    print(jobID);

    if (responseC.statusCode == 200) {
// launch model by session key
      if (Platform.isAndroid) {
        showToast(context, "포도 병해충 예측 모델을 실행합니다", Colors.blueAccent);
      }
      param = jsonEncode({'apiKey': apikey, 'jobid': jobID, 'file': token});
      urlm = "$urlgrape/launch";
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
      urlm = "$urlgrape/getStatus";
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
          if (Platform.isAndroid) {
            showToast(context, "모델을 실행중입니다", Colors.blueAccent);
          }
        }
        rS = responseS.body;
        print(rS);
      }

// get output
      if (Platform.isAndroid) {
        showToast(context, "예측결과를 가져옵니다", Colors.blueAccent);
      }
      urlm = "$urlgrape/getOutput";
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
      // var rOO = responseO.body;
      print("output A NCPMS ######################################");
      // print(rOO);

      await (File('${dir.path}/output.zip').writeAsBytes(rO));

// Decode the Zip file
      final bytes = rO;
      final archive = ZipDecoder().decodeBytes(bytes);

// Extract the contents of the Zip archive to disk.
      List<String> fList = [];
      fList.clear();
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
        fList.add(filename);
      }
      print(fList);

// Read the Zip file from disk.
      for (var pName in fList) {
        print(pName);
        var rrr = await File('${dir.path}/$pName').readAsString();
        // print(rrr);
        var jsonObj = jsonDecode(rrr);
        print(jsonObj.toString());
        switch (pName) {
          case 'AppleBoks.json':
            for (int i = 0; i < 7; i++) {
              applePestL[i].AppleBoks = jsonObj[i]['BoksDEG'] * 1.0;
            }
            break;
          case 'AppleGuln.json':
            for (int i = 0; i < 7; i++) {
              applePestL[i].AppleGuln = jsonObj[i]['GulnDEG'] * 1.0;
            }
            break;
          case 'AppleAemo.json':
            for (int i = 0; i < 7; i++) {
              applePestL[i].AppleAemo = jsonObj[i]['AemoDEG'] * 1.0;
            }
            break;
          case 'ApplePano.json':
            for (int i = 0; i < 7; i++) {
              applePestL[i].ApplePano = jsonObj[i]['PanoDEG'] * 1.0;
            }
            break;
          case 'AppleArchips.json':
            for (int i = 0; i < 7; i++) {
              applePestL[i].AppleArchips = jsonObj[i]['ArchDEG'] * 1.0;
            }
            break;
          case 'AppleWhiteRot.json':
            for (int i = 0; i < 7; i++) {
              applePestL[i].AppleWhiteRot = jsonObj[i]['DVS'] * 1.0;
            }
            break;
          case 'CherryTreeBorer.json':
            for (int i = 0; i < 7; i++) {
              applePestL[i].CherryTreeBorer = jsonObj[i]['CTB'] * 1.0;
            }
            break;
          case 'OrientalFruitMoth.json':
            for (int i = 0; i < 7; i++) {
              applePestL[i].OrientalFruitMoth = jsonObj[i]['OFMDD1'] * 1.0;
            }
            break;
          case 'PeachFruitMoth.json':
            for (int i = 0; i < 7; i++) {
              applePestL[i].PeachFruitMoth = jsonObj[i]['PFMDEG'] * 1.0;
            }
            break;
          case 'PearBsun.json':
            for (int i = 0; i < 7; i++) {
              applePestL[i].PearBsun = jsonObj[i]['BsunDEG'] * 1.0;
            }
            break;
          case 'PearGaru.json':
            for (int i = 0; i < 7; i++) {
              applePestL[i].PearGaru = jsonObj[i]['GaruDEG'] * 1.0;
            }
            break;
          case 'PearScab.json':
            for (int i = 0; i < 7; i++) {
              applePestL[i].PearScab = jsonObj[i]['ACCIR'] * 1.0;
            }
            break;
          case 'PlumFruitMoth.json':
            for (int i = 0; i < 7; i++) {
              applePestL[i].PlumFruitMoth = jsonObj[i]['PFMDD1'] * 1.0;
            }
            break;
        }
      }

// remove session
      urlm = "$urlgrape/disconnect";
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

//////////////////////////////////////////////////////////////
      ///

      if (Platform.isAndroid) {
        showToast(context, "예측결과를 표시합니다", Colors.blueAccent);
      }
/////////////////////////////////////////////////////
      //pinf update

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

      // notifyListeners();
    } else {
      throw Exception("데이터가져오기 실패");
    }
    return 0;
  }

  Future apiRequestCitrus(BuildContext context) async {
    print("apiRequestCitrus!!");

    // http request
    var urlcitrus0 = 'https://ncpms-gamgyul-api.camp.re.kr/NCPMS/Gamgyul';
    var apikey0 = "61cdc660a46f4fcc93004de201c58dff";
    var param0 = jsonEncode({'apiKey': apikey0});

// create session: server check
    var urlm0 = "$urlcitrus0/connect";
    print(urlm0);
    http.Response r = await http.post(
      Uri.parse(urlm0),
      headers: <String, String>{
        'Content-Type': 'application/json',
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: param0,
    );

    var encoder = ZipFileEncoder();
    final dir = await getApplicationDocumentsDirectory();
    // Directory dir = Directory('/storage/emulated/0/Documents ');

    String formatTime = '';
    var kk = sensorLists[ppfarm].length;
    var k = 0;

    final today = DateTime.now();
    final sdate = today.subtract(Duration(days: 4));
    final edate = today.add(Duration(days: 2));
    var weatherString =
        'date,hour,tair,humi,radi,rain,maxAirtemp,minAirtemp,wet,'
        'wspd,tGrowth,tHI,av_t_7d,av_rh_5d\n';

    for (int i = 0; i < 7; i++) {
      var date = ewsList[i].date;
      // ignore: prefer_interpolation_to_compose_strings
      var dateString = date!.substring(0, 4) +
          "-" +
          date.substring(4, 6) +
          "-" +
          date.substring(6, 8);
      var v1 = dateString;
      var v2 = ewsList[i].hour.toString();
      var v3 = ewsList[i].tair.toString();
      var v4 = ewsList[i].humi.toString();
      var v5 = ewsList[i].radi.toString();
      var v6 = ewsList[i].rain.toString();
      var v7 = ewsList[i].maxAirtemp.toString();
      var v8 = ewsList[i].minAirtemp.toString();
      var v9 = ewsList[i].wet.toString();
      var v10 = ewsList[i].wspd.toString();
      var v11 = ewsList[i].tGrowth.toString();
      var v12 = ewsList[i].tHI.toString();
      var v13 = ewsList[i].av_t_7d.toString();
      var v14 = ewsList[i].av_rh_5d.toString();

      weatherString =
          "$weatherString$v1,$v2,$v3,$v4,$v5,$v6,$v7,$v8,$v9,$v10,$v11,$v12,$v13,$v14\n";
    }
    var sdateString = DateFormat('yyyy-MM-dd').format(sdate);
    var edateString = DateFormat('yyyy-MM-dd').format(edate);
    var weatherString2 = "$sdateString,$edateString,day,all";
    print(weatherString);
    print(weatherString2);
    // zip weather.csv
    await (File('${dir.path}/setfile.txt').writeAsString(weatherString2))
        .then((value) async {
      await (File('${dir.path}/weather.csv').writeAsString(weatherString))
          .then((value) {
        encoder.create('${dir.path}/input.zip');
        encoder.addFile(File('${dir.path}/weather.csv'));
        encoder.addFile(File('${dir.path}/setfile.txt'));
        encoder.close();
      });
    });
    // base64 encoding
    var z = await File('${dir.path}/input.zip').readAsBytes();
    String token = base64.encode(z);
    print("input.zip done!!!");

/////////////////////////////////////
// citrus Disease
/////////////////////////////////////

    // http request
    var urlcitrus = 'https://ncpms-gamgyul-api.camp.re.kr/NCPMS/Gamgyul';

    var apikey = "61cdc660a46f4fcc93004de201c58dff";
    var param = jsonEncode({'apiKey': apikey});

    if (Platform.isAndroid) {
      showToast(context, "병해충예측 서버에 접속합니다.", Colors.blueAccent);
    }
// create session
    var urlm = "$urlcitrus/connect";
    print(urlm);
    http.Response responseC = await http.post(
      Uri.parse(urlm),
      headers: <String, String>{
        'Content-Type': 'application/json',
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: param,
    );
    var jobID = responseC.body;
    print(responseC.statusCode);
    print("NCPMS jobID호출");
    print(jobID);

    if (responseC.statusCode == 200) {
// launch model by session key
      if (Platform.isAndroid) {
        showToast(context, "감귤 병해충 예측 모델을 실행합니다", Colors.blueAccent);
      }
      param = jsonEncode({'apiKey': apikey, 'jobid': jobID, 'file': token});
      urlm = "$urlcitrus/launch";
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
      if (Platform.isAndroid) {
        showToast(context, "getStatus.", Colors.blueAccent);
      }

// get Status model
      urlm = "$urlcitrus/getStatus";
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
          if (Platform.isAndroid) {
            showToast(context, "모델을 실행중입니다", Colors.blueAccent);
          }
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
        print(rS);
      }

// get output
      if (Platform.isAndroid) {
        showToast(context, "예측결과를 가져옵니다", Colors.blueAccent);
      }
      urlm = "$urlcitrus/getOutput";
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
      // var rOO = responseO.body;
      print("output A NCPMS ######################################");
      // print(rOO);

      await (File('${dir.path}/output.zip').writeAsBytes(rO));

// Decode the Zip file
      final bytes = rO;
      final archive = ZipDecoder().decodeBytes(bytes);

// Extract the contents of the Zip archive to disk.
      List<String> fList = [];
      fList.clear();
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
        fList.add(filename);
      }
      print(fList);

// Read the Zip file from disk.
      for (var pName in fList) {
        print(pName);

        /*ArrowHeadScale.json, ArrowHeadScale2.json, CitrusCranker.json, 
        CitrusMelanose.json, CitrusScab2.json, RiceBlast.json*/

        var rrr = await File('${dir.path}/$pName').readAsString();
        // print(rrr);
        var jsonObj = jsonDecode(rrr);
        print(jsonObj.toString());
        switch (pName) {
          case 'ArrowHeadScale.json':
            for (int i = 0; i < 7; i++) {
              citrusPestL[i].ArrowHeadScale = jsonObj[i]['ASDD'] * 1.0;
            }
            break;
          case ' ArrowHeadScale2.json':
            for (int i = 0; i < 7; i++) {
              citrusPestL[i].ArrowHeadScale2 = jsonObj[i]['ASDD'] * 1.0;
            }
            break;
          case 'CitrusCranker.json':
            for (int i = 0; i < 7; i++) {
              citrusPestL[i].CitrusCranker = jsonObj[i]['ir'] * 1.0;
            }
            break;
          case 'CitrusMelanose.json':
            for (int i = 0; i < 7; i++) {
              citrusPestL[i].CitrusMelanose = jsonObj[i]['CM_IP'] * 1.0;
            }
            break;
          case 'CitrusScab2.json':
            for (int i = 0; i < 7; i++) {
              citrusPestL[i].CitrusScab2 = jsonObj[i]['ir'] * 1.0;
            }
            break;
          case 'RiceBlast.json':
            for (int i = 0; i < 7; i++) {
              citrusPestL[i].RiceBlast = jsonObj[i]['YTT'] * 1.0;
            }
            break;
          default:
            break;
        }
      }

// remove session
      urlm = "$urlcitrus/disconnect";
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

//////////////////////////////////////////////////////////////
      ///

      if (Platform.isAndroid) {
        showToast(context, "예측결과를 표시합니다", Colors.blueAccent);
      }
/////////////////////////////////////////////////////
      //pinf update

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

      // notifyListeners();
    } else {
      throw Exception("데이터가져오기 실패");
    }
    return 0;
  }
}
