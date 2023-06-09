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

// import 'package:flutter/foundation.dart';
// import 'package:flutter/services.dart';
// import 'dart:ffi';
// import 'package:flutter/cupertino.dart';
// import 'package:farmmon_flutter/util/extensions/color_extensions.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'dart:ui';
// import 'package:dio/dio.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';

var pp = 0;
var ppfarm = 0;
var farmNo = 1;
var lastDatetime = '';
var updateKey = '';
var MAXX = 24;
var difference = 0;
var r = 0;

var registerdfarms = <String>[
  '',
];
var farmName = <String>[
  '기본농장',
];
var facilityName = <String>[
  '1번온실',
];
var serviceKey = <String>[
  'r34df5d2d566049e2a809c41da915adc6',
];

// var xlabel = List<String>.filled(50, '', growable: true);
// var customdt = List<String>.filled(50, '0', growable: true);
// var temperature = List<String>.filled(50, '0', growable: true);
// var humidity = List<String>.filled(50, '0', growable: true);
// var cotwo = List<String>.filled(50, '0', growable: true);
// var leafwet = List<String>.filled(50, '0', growable: true);
// var gtemperature = List<String>.filled(50, '0', growable: true);
// var quantum = List<String>.filled(50, '0', growable: true);

/////////////////////////////////////////////
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
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

final today = DateTime.now();
final twodaysago = today.subtract(const Duration(days: 2));
final twodaysagoString = DateFormat('yyyy-MM-dd HH:00:00').format(twodaysago);

Sensor sensor = Sensor(
  customDt: twodaysagoString,
  temperature: 0.0,
  humidity: 0.0,
  cotwo: 0.0,
  leafwet: 0.0,
  gtemperature: 0.0,
  quantum: 0.0,
  xlabel: " ",
);

// List<Sensor> sensorList = <Sensor>[];
var sensorList = List<Sensor>.filled(50, sensor, growable: true);

/////////////////////////////////////////////////////////////

void prefsLoad() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  farmNo = (prefs.getInt('farmNumber') ?? 1);
  ppfarm = (prefs.getInt('myFarm') ?? 0);

  final today = DateTime.now();
  final twodaysago = today.subtract(const Duration(days: 2));
  final twodaysagoString = DateFormat('yyyy-MM-dd HH:00:00').format(twodaysago);
  lastDatetime = (prefs.getString('lastDatetime') ?? twodaysagoString);

  // prefs.setInt('farmNumber', farmNo);
  // prefs.setInt('myFarm', ppfarm);
  // await prefs.setString('lastDatetime', lastDatetime);
  print("prefs Loading... lastDatetime: $lastDatetime");

  print('prefsLoad: ${(ppfarm + 1)} / $farmNo');

  farmName[0] = (prefs.getString('farmName0') ?? farmName[0]);
  facilityName[0] = (prefs.getString('facilityName0') ?? facilityName[0]);
  serviceKey[0] = (prefs.getString('serviceKey0') ?? serviceKey[0]);

  for (int i = 1; i < farmNo; i++) {
    farmName.add(prefs.getString('farmName$i') ?? farmName[0]);
    facilityName.add(prefs.getString('facilityName$i') ?? facilityName[0]);
    serviceKey.add(prefs.getString('serviceKey$i') ?? serviceKey[0]);
  }
}

/////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  prefsLoad();
  print(sensorList[0].customDt.toString());
  HttpOverrides.global = MyHttpOverrides();
  // Future.delayed(const Duration(milliseconds: 3000), () {
  print(sensorList[0].customDt.toString());
  lastDatetime = sensorList[0].customDt.toString();

  runApp(MyApp());
  // });
  // readJsonAsString();
  // print(sensorList[0].temperature.toString());
  // print('main : read Json file');
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
  var farmNoUpdate = 1;
  void getData() {
    notifyListeners();
  }

  void getNext() {
    current = WordPair.random();
    notifyListeners();

    // readJsonAsString();
  }

  var favorites = <WordPair>[];

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }

  Future<void> getSensorList() async {
    // final dir = await getApplicationDocumentsDirectory();
    // Directory dir = Directory('/storage/emulated/0/Documents');
    // final routeFromJsonFile =
    //     await rootBundle.loadString('${dir.path}/sensor.json');
    // final routeFromJsonFile = await rootBundle
    // .loadString('/storage/emulated/0/Documents/sensor.json');
    // sensorList = (SensorList.fromJson(routeFromJsonFile).sensors ?? <Sensor>[]);
    // print('getSensorList====================');
    // print(sensorList[0].customDt);
    // print(sensorList[0].customDt);
    // print(sensorList[0].customDt);

    // print(jsonString);

    // current = WordPair.random();
    notifyListeners();
    // String jsonString = jsonEncode(sensorList);
    // print(jsonString);
  }

  Future<File> writeJsonAsString(String? data) async {
    // final file = File('json/sensor.json');
    final dir = await getApplicationDocumentsDirectory();
    // Directory dir = Directory('/storage/emulated/0/Documents');
    // print('${dir.path}/sensor.json');
    print('writing json file');
    // notifyListeners();
    return File('${dir.path}/sensor.json').writeAsString(data ?? '');
    // return file.writeAsString(data ?? '');
  }

  Future callAPI() async {
    // var urltech = 'http://147.46.206.95:7890/SNFD';
    // var urlanthracnose = 'http://147.46.206.95:7897/Anthracnose';
    var urliot = 'http://iot.rda.go.kr/api';
    var apikey = serviceKey[ppfarm];

    // iot portal test
    var now = DateTime.now();
    var nowtosave = now;
    lastDatetime = sensorList[0].customDt.toString();
    lastDatetime = "${lastDatetime.substring(0, 14)}00:00";

    // Json data load
    // readJsonAsString();
    difference = int.parse(
        now.difference(DateTime.parse(lastDatetime)).inHours.toString());
    print('Difference: $difference');
    String formatDate = DateFormat('yyyyMMdd').format(now);
    String formatTime = DateFormat('HH').format(now);

    var urliotString = "$urliot/$apikey/$formatDate/$formatTime";
    var uriiot = Uri.parse(urliotString);

    var deltaT = int.parse(formatTime);
    var deltaT12 = deltaT % 12;
    deltaT = 24;
    if (deltaT < 12) deltaT = deltaT + deltaT12;

    ///print(deltaT+deltaT12);
    ///print('$formatDate');
    ///print('$formatTime');
    ///temperature.clear();
    ///customdt.clear();

    // prefsLoad();

// 데이터 저장해놓고 마지막 데이터만 호출하는 것으로 수정할 것
    print('before for loop');
    for (int i = 0; i < difference; i++) {
      String formatDate = DateFormat('yyyyMMdd').format(now);
      String formatTime = DateFormat('HH').format(now);
      urliotString = "$urliot/$apikey/$formatDate/$formatTime";

      ///print(urliot2);
      uriiot = Uri.parse(urliotString);
      http.Response response = await http.get(uriiot);
      now = now.subtract(Duration(hours: 1));
      // print(response.body);
      r = response.statusCode;
      // print(r);
      //    Map<String, dynamic> usem = jsonDecode(response.body);

      var jsonObj = jsonDecode(response.body);

      //print(response.body);

      // customdt.insert(i, jsonObj['datas'][0]['custom_dt']);
      // humidity.insert(i, jsonObj['datas'][0]['humidity']);
      // temperature.insert(i, jsonObj['datas'][0]['temperature']);
      // leafwet.insert(i, jsonObj['datas'][0]['leafwet']);
      // cotwo.insert(i, jsonObj['datas'][0]['cotwo']);
      // gtemperature.insert(i, jsonObj['datas'][0]['gtemperature']);
      // quantum.insert(i, jsonObj['datas'][0]['quantum']);
      // DateTime xvalue = DateTime.parse(jsonObj['datas'][0]['custom_dt']);
      // xlabel.insert(i, DateFormat('HH:mm').format(xvalue));

      // customdt[i] = jsonObj['datas'][0]['custom_dt'];
      // humidity[i] = jsonObj['datas'][0]['humidity'];
      // temperature[i] = jsonObj['datas'][0]['temperature'];
      // leafwet[i] = jsonObj['datas'][0]['leafwet'];
      // cotwo[i] = jsonObj['datas'][0]['cotwo'];
      // gtemperature[i] = jsonObj['datas'][0]['gtemperature'];
      // quantum[i] = jsonObj['datas'][0]['quantum'];
      // DateTime xvalue = DateTime.parse(customdt[i]);
      // xlabel[i] = DateFormat('HH:mm').format(xvalue);

      Sensor nsensor = Sensor(
        customDt: jsonObj['datas'][0]['custom_dt'],
        temperature: double.parse(jsonObj['datas'][0]['temperature']),
        humidity: double.parse(jsonObj['datas'][0]['humidity']),
        cotwo: double.parse(jsonObj['datas'][0]['cotwo']),
        leafwet: double.parse(jsonObj['datas'][0]['leafwet']),
        gtemperature: double.parse(jsonObj['datas'][0]['gtemperature']),
        quantum: double.parse(jsonObj['datas'][0]['quantum']),
        xlabel: DateFormat('HH:mm').format(
          DateTime.parse(jsonObj['datas'][0]['custom_dt']),
        ),
      );

      // sensorList.insert(0, nsensor);
      sensorList.insert(i, nsensor);
      print('$i----${nsensor.customDt}');
    }
    print('after for loop');

    ///print(customdt);
    ///print(temperature);
/*
    http.Response response = await http.post(
      Uri.parse(urltech),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'mPH': 5.4,
        'mEC': 3.6,
        'mNO3': 179,
        'mPO4': 155,
        'mEH': 370,
        'mSO4': 250,
        'mCL': 100,
        'mCROP': "good"
      }),
    );
    ///print(response.statusCode);
    ///print(response.headers);
    ///print(response.body);
*/
    // if (mounted) {
    //   setState(() {
    //     ///      temperature.add("changed");
    //   });
    // }
    notifyListeners();
    return 0;
  }

/////////////////////////////////////////////////////////////////////
  ///

  void prefsClear() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // print('prefs clear $farmNo');
    prefs.clear();
    if (farmNo > 1) {
      farmName.removeRange(1, farmNo);
      facilityName.removeRange(1, farmNo);
      serviceKey.removeRange(1, farmNo);
    }
    farmNo = 1;
    ppfarm = 0;
    final today = DateTime.now();
    final twodaysago = today.subtract(const Duration(days: 2));
    lastDatetime = DateFormat('yyyy-MM-dd HH:00:00').format(twodaysago);
    sensorList = List<Sensor>.filled(50, sensor, growable: true);
    String jsonString = jsonEncode(sensorList);
    await writeJsonAsString(jsonString);
    print('prefs cleared: only $farmNo farm left');
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  Future readJsonAsString() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      // Directory dir = Directory('/storage/emulated/0/Documents');
      // print('${dir.path}/sensor.json');
      print('read json file');
      var routeFromJsonFile =
          await File('${dir.path}/sensor.json').readAsString();
      // print(routeFromJsonFile);
      sensorList =
          (SensorList.fromJson(routeFromJsonFile).sensors ?? <Sensor>[]);
      // print(sensorList[0].customDt.toString());
      // print(sensorList[5].customDt.toString());
      // print(sensorList[10].customDt.toString());
      // notifyListeners();
    } catch (e) {
      return 0;
    }
  }

  @override
  void initState() {
    super.initState();
    readJsonAsString().then((value) {
      setState(() {
        lastDatetime = sensorList[0].customDt.toString();
        lastDatetime = "${lastDatetime.substring(0, 14)}00:00";
        print(lastDatetime);
        print('farmNo at initState: $farmNo');
      });
    });
    print('initState');
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    Widget page;
    switch (selectedIndex) {
      case 0:
        appState.farmNoUpdate = farmNo;
        print('farmNo update:  ${appState.farmNoUpdate}');
        page = StrawberryPage();
        break;
      case 1:
        page = Placeholder();
        break;
      case 2:
        page = Placeholder();
        break;
      case 3:
        page = MyLineChartPage();
        break;
      case 4:
        appState.farmNoUpdate = farmNo;
        print('farmNo update:  ${appState.farmNoUpdate}');
        page = MySetting();
        break;

      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

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
                    // icon: Icon(FontAwesomeIcons.appleWhole),
                    // icon: Image(
                    // image: AssetImage("images/strawberry.png"),
                    // width: 27.0),
                    label: Text('딸기'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(CustomIcons.tomato), //solidLemon
                    // icon: Image(
                    // image: AssetImage("images/tomato.png"), width: 25.0),
                    label: Text('토마토'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(CustomIcons.bellpepper), //solidLemon
                    // icon: Image(
                    // image: AssetImage("images/bellpepper.png"),
                    // width: 30.0),
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
  @override
  void didChangeDependencies() {
    print('didChangeDependencies 호출');
    updateKey = DateTime.now().toString();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;
    // callAPI();

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }
    var now = DateTime.now();
    String formatDate = DateFormat('yyyy년 MM월 dd일').format(now);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 40),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                farmName[ppfarm],
                style: TextStyle(fontSize: 25),
              ),
              SizedBox(width: 20),
              ElevatedButton(
                onPressed: () async {
                  ppfarm = (ppfarm + 1) % farmNo;
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.setInt('myFarm', ppfarm);
                  // print('prefsLoad: ${(ppfarm + 1)} / $farmNo');

                  // appState.callAPI();

                  appState.callAPI().then((value) {
                    setState(() {
                      lastDatetime = sensorList[0].customDt.toString();
                      lastDatetime = "${lastDatetime.substring(0, 14)}00:00";
                      print(lastDatetime);
                    });
                  });

                  // Future.delayed(const Duration(milliseconds: 1000), () {
                  // if (mounted) {
                  setState(() {
                    pp = 0;
                    appState.getNext();
                    // print('after 1000 milliseconds');
                    // });
                    // }
                  });
                },
                child: Text('다음'),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(formatDate),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('탄저병:'),
              Text(
                '■',
                style: TextStyle(
                  color: Colors.amber,
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
                  pp = 7;
                  appState.toggleFavorite();
                },
                child: Text('지난주'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.amber,
                  backgroundColor: Colors.blueGrey, // Text Color
                ),
                onPressed: () {
                  pp = 0;
                  // appState.callAPI();
                  appState.callAPI().then((value) {
                    setState(() {
                      lastDatetime = sensorList[0].customDt.toString();
                      lastDatetime = "${lastDatetime.substring(0, 14)}00:00";
                      print(lastDatetime);
                      if ((r == 200) && (difference > 0)) {
                        String jsonString = jsonEncode(sensorList);
                        appState.writeJsonAsString(jsonString);

                        // SharedPreferences prefs = await SharedPreferences.getInstance();
                        // lastDatetime = DateFormat('yyyy-MM-dd HH:mm:ss').format(nowtosave);

                        lastDatetime = sensorList[0].customDt.toString();
                        lastDatetime = "${lastDatetime.substring(0, 14)}00:00";

                        // await prefs.setString('lastDatetime', lastDatetime);
                        print("prefs Save lastDatetime $lastDatetime");
                      }
                    });
                  });
                  print('after data update procedure... ');
                  // updateKey = DateTime.now().toString();

                  // var temp = sensorList[0].temperature;
                  // sensorList[0].temperature = temp;

                  if (mounted) {
                    setState(() {
                      appState.getNext();
                    });
                  }
                },
                child: Text('이번주'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  pp = 0;
                  // lastDatetime = "2023-06-04 02:07:11";
                  // appState.readJsonAsString();
                  // appState.getSensorList();

                  // print('getSensorList====================');
                  // print(sensorList[0].customDt);
                  // print(sensorList[0].customDt);
                  // print(sensorList[0].customDt);

                  // String jsonString = jsonEncode(sensorList);
                  // print(jsonString);
                  // writeJsonAsString(jsonString);
                  if (mounted) {
                    setState(() {
                      appState.getNext();
                    });
                  }
                },
                child: Text('다음주'),
              ),
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 50),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                farmName[ppfarm],
                style: TextStyle(fontSize: 25),
              ),
              SizedBox(width: 20),
              ElevatedButton(
                onPressed: () async {
                  ppfarm = (ppfarm + 1) % farmNo;
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.setInt('myFarm', ppfarm);
                  // print('prefsLoad: ${(ppfarm + 1)} / $farmNo');

                  if (mounted) {
                    setState(() {
                      pp = 0;
                    });
                  }
                },
                child: Text('다음'),
              ),
            ],
          ),
          SizedBox(height: 30),
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

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have '
              '${appState.favorites.length} favorites:'),
        ),
        for (int i = 1; i <= 5; i++) // var pair in appState.favorites
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text('공주농가$i'), // ${pair.asLowerCase}
          ),
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
    updateKey = DateTime.now().toString();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30),
      // implement the bar chart
      child: BarChart(
        // key: ValueKey(sensorList[0].customDt),
        // key: ValueKey(updateKey),
        BarChartData(
          maxY: 50,
          borderData: FlBorderData(
              border: const Border(
            top: BorderSide.none,
            right: BorderSide.none,
            left: BorderSide(width: 1),
            bottom: BorderSide(width: 1),
          )),
          groupsSpace: 10,
          // add bars
          barGroups: [
            BarChartGroupData(x: 1, barRods: [
              BarChartRodData(
                  toY: double.parse(sensorList[pp + 6].temperature.toString()),
                  width: 5,
                  color: Colors.amber),
              BarChartRodData(
                  toY: double.parse(sensorList[pp + 6].humidity.toString()) / 2,
                  width: 5,
                  color: Colors.indigo),
            ]),
            BarChartGroupData(x: 2, barRods: [
              BarChartRodData(
                  toY: double.parse(sensorList[pp + 5].temperature.toString()),
                  width: 5,
                  color: Colors.amber),
              BarChartRodData(
                  toY: double.parse(sensorList[pp + 5].humidity.toString()) / 2,
                  width: 5,
                  color: Colors.indigo),
            ]),
            BarChartGroupData(x: 3, barRods: [
              BarChartRodData(
                  toY: double.parse(sensorList[pp + 4].temperature.toString()),
                  width: 5,
                  color: Colors.amber),
              BarChartRodData(
                  toY: double.parse(sensorList[pp + 4].humidity.toString()) / 2,
                  width: 5,
                  color: Colors.indigo),
            ]),
            BarChartGroupData(x: 4, barRods: [
              BarChartRodData(
                  toY: double.parse(sensorList[pp + 3].temperature.toString()),
                  width: 5,
                  color: Colors.amber),
              BarChartRodData(
                  toY: double.parse(sensorList[pp + 3].humidity.toString()) / 2,
                  width: 5,
                  color: Colors.indigo),
            ]),
            BarChartGroupData(x: 5, barRods: [
              BarChartRodData(
                  toY: double.parse(sensorList[pp + 2].temperature.toString()),
                  width: 5,
                  color: Colors.amber),
              BarChartRodData(
                  toY: double.parse(sensorList[pp + 2].humidity.toString()) / 2,
                  width: 5,
                  color: Colors.indigo),
            ]),
            BarChartGroupData(x: 6, barRods: [
              BarChartRodData(
                  toY: double.parse(sensorList[pp + 1].temperature.toString()),
                  width: 5,
                  color: Colors.amber),
              BarChartRodData(
                  toY: double.parse(sensorList[pp + 1].humidity.toString()) / 2,
                  width: 5,
                  color: Colors.indigo),
            ]),
            BarChartGroupData(x: 7, barRods: [
              BarChartRodData(
                  toY: double.parse(sensorList[pp + 0].temperature.toString()),
                  width: 5,
                  color: Colors.amber),
              BarChartRodData(
                  toY: double.parse(sensorList[pp + 0].humidity.toString()) / 2,
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
                reservedSize: 57,
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
    final style = TextStyle(
      ///      color: AppColors.contentColorBlue.darken(20),
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );
    String text;
    switch (value.toInt()) {
      case 0:
        text = sensorList[pp + 7].xlabel.toString();
        break;
      case 1:
        text = sensorList[pp + 6].xlabel.toString();
        break;
      case 2:
        text = sensorList[pp + 5].xlabel.toString();
        break;
      case 3:
        text = sensorList[pp + 4].xlabel.toString();
        break;
      case 4:
        text = sensorList[pp + 3].xlabel.toString();
        break;
      case 5:
        text = sensorList[pp + 2].xlabel.toString();
        break;
      case 6:
        text = sensorList[pp + 1].xlabel.toString();
        break;
      case 7:
        text = sensorList[pp + 0].xlabel.toString();
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
    return Padding(
      padding: const EdgeInsets.all(10),
      // implement the bar chart
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: ZoomableChart(
          maxX: MAXX.toDouble() - 1,
          builder: (minX, maxX) {
            return LineChart(
              LineChartData(
                clipData: FlClipData.all(),
                minX: minX,
                maxX: maxX,
                maxY: 100,
                minY: 1,
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
                        final multiplyer = [0.5, 1, 10];
                        final textStyle = TextStyle(
                          color: touchedSpot.bar.gradient?.colors[0] ??
                              touchedSpot.bar.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        );
                        return LineTooltipItem(
                          ' ${(touchedSpot.y * multiplyer[touchedSpot.barIndex]).toStringAsFixed(1)} ',
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
                      for (int i = 0; i < MAXX; i++)
                        FlSpot(
                            i.toDouble(),
                            double.parse(sensorList[pp + (MAXX - i - 1)]
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
                      for (int i = 0; i < MAXX; i++)
                        FlSpot(
                            i.toDouble(),
                            double.parse(sensorList[pp + (MAXX - i - 1)]
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
                      for (int i = 0; i < MAXX; i++)
                        FlSpot(
                            i.toDouble(),
                            double.parse(sensorList[pp + (MAXX - i - 1)]
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
                      reservedSize: 57,
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
    final style = TextStyle(
      // color: Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );
    String text;
    text = sensorList[pp + (MAXX - value.toInt() - 1)].xlabel.toString();
/*
    switch (value.toInt()) {
      case 0:
        text = xlabel[pp + 13]
        break;
      case 1:
        text = xlabel[pp + 12];
        break;
      case 2:
        text = xlabel[pp + 11];
        break;
      case 3:
        text = xlabel[pp + 10];
        break;
      case 4:
        text = xlabel[pp + 9];
        break;
      case 5:
        text = xlabel[pp + 8];
        break;
      case 6:
        text = xlabel[pp + 7];
        break;
      case 7:
        text = xlabel[pp + 6];
        break;
      case 8:
        text = xlabel[pp + 5];
        break;
      case 9:
        text = xlabel[pp + 4];
        break;
      case 10:
        text = xlabel[pp + 3];
        break;
      case 11:
        text = xlabel[pp + 2];
        break;
      case 12:
        text = xlabel[pp + 1];
        break;
      case 13:
        text = xlabel[pp + 0];
        break;
      default:
        text = '';
        break;
    }
    */
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
    prefsLoad();
    print(farmNo);
    // Start listening to changes.
    inputController1.addListener(_printLatestValue);
    inputController2.addListener(_printLatestValue);
    inputController3.addListener(_printLatestValue);

    inputController1.text = farmName[ppfarm];
    inputController2.text = facilityName[ppfarm];
    inputController3.text = serviceKey[ppfarm];
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
        backgroundColor: Colors.blue,
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
                        return '농가를 입력하세요';
                      }
                      return null;
                    },
                    onChanged: (text) {
                      // setState(() {
                      //   farmName[ppfarm] = text;
                      // });
                    },
                    decoration: InputDecoration(
                      labelText: farmName[ppfarm],
                      hintText: '농가를 입력해주세요',
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
                      labelText: facilityName[ppfarm],
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
                    key: Key(farmName[ppfarm]),
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
                      labelText: serviceKey[ppfarm],
                      hintText: '데이터저장소 인증키를 입력해주세요',
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
                  child: Text('총 ${appState.farmNoUpdate}농가가 등록되었습니다!!!'),
                ),
                Text('선택농가: ${ppfarm + 1} - 이름: ${farmName[ppfarm]}'),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          print('$ppfarm / $farmNo');
                          farmNo++;
                          print('$ppfarm / $farmNo');

                          farmName.add('추가농가$farmNo');
                          facilityName.add('');
                          serviceKey.add('');

                          if (mounted) {
                            setState(() {
                              ppfarm = farmNo - 1;
                              // print(ppfarm);
                              // for (int i = 0; i < farmNo; i++) {
                              // print(farmName[i]);
                              // }
                              inputController1.text = '추가농가$farmNo';
                              inputController2.text = '';
                              inputController3.text = '';
                            });
                          }
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          await prefs.setInt('farmNumber', farmNo);
                          await prefs.setInt('myFarm', ppfarm);
                        },
                        child: const Text('농장추가'),
                      ),
                    ),
                    SizedBox(width: 10),
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          // save prefs info of the new farm
                          // _printLatestValue();
                          farmName[ppfarm] = inputController1.text;
                          facilityName[ppfarm] = inputController2.text;
                          serviceKey[ppfarm] = inputController3.text;

                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          await prefs.setInt('farmNumber', farmNo);

                          for (int i = 0; i < farmNo; i++) {
                            await prefs.setString('farmName$i', farmName[i]);
                            await prefs.setString(
                                'facilityName$i', facilityName[i]);
                            await prefs.setString(
                                'serviceKey$i', serviceKey[i]);
                          }
                          // go to the next farm
                          ppfarm = (ppfarm + 1) % farmNo;

                          // SharedPreferences prefs =
                          // await SharedPreferences.getInstance();
                          await prefs.setInt('myFarm', ppfarm);
                          print('prefsLoad: ${(ppfarm + 1)} / $farmNo');
                          if (mounted) {
                            setState(() {
                              // _printLatestValue();
                              inputController1.text = farmName[ppfarm];
                              inputController2.text = facilityName[ppfarm];
                              inputController3.text = serviceKey[ppfarm];
                              // print('next farm: ${(ppfarm + 1)} / $farmNo');
                            });
                          }
                        },
                        child: const Text('다음'),
                      ),
                    ),
                    SizedBox(width: 10),
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (mounted) {
                            setState(() {
                              // _printLatestValue();
                              appState.prefsClear();
                            });
                          }
                        },
                        child: const Text('리셋'),
                      ),
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
