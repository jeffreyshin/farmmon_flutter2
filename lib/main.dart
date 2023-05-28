import 'package:english_words/english_words.dart';
// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

///import 'package:fl_chart_app/presentation/resources/app_resources.dart';
///import 'package:fl_chart_app/util/extensions/color_extensions.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// import 'package:farmmon_flutter/icons/custom_icons_icons.dart';
// import 'package:dio/dio.dart';
import 'dart:io';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/////////////////////////////////////
var pp = 0;
var ppfarm = 0;
var farmNo = 1;
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
var xlabel = <String>[
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  ''
];
var customdt = <String>[
  '0',
  '0',
  '0',
  '0',
  '0',
  '0',
  '0',
  '0',
  '0',
  '0',
  '0',
  '0',
  '0',
  '0',
  '0',
  '0'
];
var temperature = <String>[
  '0',
  '0',
  '0',
  '0',
  '0',
  '0',
  '0',
  '0',
  '0',
  '0',
  '0',
  '0',
  '0',
  '0',
  '0',
  '0'
];
var humidity = <String>[
  '0',
  '0',
  '0',
  '0',
  '0',
  '0',
  '0',
  '0',
  '0',
  '0',
  '0',
  '0',
  '0',
  '0',
  '0',
  '0'
];
var cotwo = <String>[
  '0',
  '0',
  '0',
  '0',
  '0',
  '0',
  '0',
  '0',
  '0',
  '0',
  '0',
  '0',
  '0',
  '0',
  '0',
  '0'
];
var leafwet = <String>[
  '0',
  '0',
  '0',
  '0',
  '0',
  '0',
  '0',
  '0',
  '0',
  '0',
  '0',
  '0',
  '0',
  '0',
  '0',
  '0'
];
var gtemperature = <String>[
  '0',
  '0',
  '0',
  '0',
  '0',
  '0',
  '0',
  '0',
  '0',
  '0',
  '0',
  '0',
  '0',
  '0',
  '0',
  '0'
];
var quantum = <String>[
  '0',
  '0',
  '0',
  '0',
  '0',
  '0',
  '0',
  '0',
  '0',
  '0',
  '0',
  '0',
  '0',
  '0',
  '0',
  '0'
];
//////////////////////////////////////

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  HttpOverrides.global = MyHttpOverrides();
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
  void getData() {
    notifyListeners();
  }

  void getNext() {
    current = WordPair.random();
    notifyListeners();
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
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;
  void _prefsLoad() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    farmNo = (prefs.getInt('farmNumber') ?? 1);
    ppfarm = (prefs.getInt('myFarm') ?? 0);
    await prefs.setInt('farmNumber', farmNo);
    await prefs.setInt('myFarm', ppfarm);
    // print('prefsLoad: ${(ppfarm + 1)} / $farmNo');

    farmName[0] = (prefs.getString('farmName0') ?? farmName[0]);
    facilityName[0] = (prefs.getString('facilityName0') ?? facilityName[0]);
    serviceKey[0] = (prefs.getString('serviceKey0') ?? serviceKey[0]);

    for (int i = 1; i < farmNo; i++) {
      farmName.add(prefs.getString('farmName$i') ?? farmName[0]);
      facilityName.add(prefs.getString('facilityName$i') ?? facilityName[0]);
      serviceKey.add(prefs.getString('serviceKey$i') ?? serviceKey[0]);
    }
  }

  @override
  Widget build(BuildContext context) {
    _prefsLoad();
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = StrawberryPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      case 2:
        page = MyBarChart();
        break;
      case 3:
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
                    icon: Icon(FontAwesomeIcons.appleWhole),
                    label: Text('딸기'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(FontAwesomeIcons.solidLemon),
                    label: Text('토마토'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    label: Text('파프리카'),
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

  void callAPI() async {
    // var urltech = 'http://147.46.206.95:7890/SNFD';
    // var urlanthracnose = 'http://147.46.206.95:7897/Anthracnose';
    var urliot = 'http://iot.rda.go.kr/api';
    var apikey = serviceKey[ppfarm];

    /// iot포털 테스트
    var now = DateTime.now();
    String formatDate = DateFormat('yyyyMMdd').format(now);
    String formatTime = DateFormat('HH').format(now);
    var urliot2 = "$urliot/$apikey/$formatDate/$formatTime";
    var uriiot = Uri.parse(urliot2);

    var deltaT = int.parse(formatTime);
    // var deltaT12 = deltaT % 12;
    deltaT = 24;
    if (deltaT < 12) deltaT = deltaT + 12;

    ///print(deltaT+deltaT12);
    ///print('$formatDate');
    ///print('$formatTime');
    ///temperature.clear();
    ///customdt.clear();

    // _prefsLoad();

    for (var i = 0; i < 16; i++) {
      now = now.subtract(Duration(hours: 1));
      String formatDate = DateFormat('yyyyMMdd').format(now);
      String formatTime = DateFormat('HH').format(now);
      urliot2 = "$urliot/$apikey/$formatDate/$formatTime";

      ///print(urliot2);
      uriiot = Uri.parse(urliot2);
      http.Response response = await http.get(uriiot);

      ///    Map<String, dynamic> usem = jsonDecode(response.body);

      var jsonObj = jsonDecode(response.body);

      ///print(response.body);
      customdt[i] = jsonObj['datas'][0]['custom_dt'];
      humidity[i] = jsonObj['datas'][0]['humidity'];
      temperature[i] = jsonObj['datas'][0]['temperature'];
      leafwet[i] = jsonObj['datas'][0]['leafwet'];
      cotwo[i] = jsonObj['datas'][0]['cotwo'];
      gtemperature[i] = jsonObj['datas'][0]['gtemperature'];
      quantum[i] = jsonObj['datas'][0]['quantum'];
      DateTime xvalue = DateTime.parse(customdt[i]);
      xlabel[i] = DateFormat('HH:mm').format(xvalue);

      ///print(json_obj);
    }

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
    if (mounted) {
      setState(() {
        ///      temperature.add("changed");
      });
    }
  }

/////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }
    var now = DateTime.now();
    String formatDate = DateFormat('yyyy년 MM월 dd일').format(now);

    callAPI();

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 40),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${farmName[ppfarm]}',
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
                      callAPI();
                    });
                  }
                },
                child: Text('다음'),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text('딸기탄저병: $formatDate'),
          SizedBox(height: 20),
          Expanded(
            child: MyBarChart(),
          ),
          SizedBox(width: 10),
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
                  callAPI();
                },
                child: Text('이번주'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  pp = 0;
                  appState.getNext();
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
        for (int i = 1; i <= 25; i++) // var pair in appState.favorites
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
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30),
      // implement the bar chart
      child: BarChart(
        BarChartData(
          maxY: 35,
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
                  toY: double.parse(temperature[pp + 6]),
                  width: 5,
                  color: Colors.amber),
            ]),
            BarChartGroupData(x: 2, barRods: [
              BarChartRodData(
                  toY: double.parse(temperature[pp + 5]),
                  width: 5,
                  color: Colors.amber),
            ]),
            BarChartGroupData(x: 3, barRods: [
              BarChartRodData(
                  toY: double.parse(temperature[pp + 4]),
                  width: 5,
                  color: Colors.amber),
            ]),
            BarChartGroupData(x: 4, barRods: [
              BarChartRodData(
                  toY: double.parse(temperature[pp + 3]),
                  width: 5,
                  color: Colors.amber),
            ]),
            BarChartGroupData(x: 5, barRods: [
              BarChartRodData(
                  toY: double.parse(temperature[pp + 2]),
                  width: 5,
                  color: Colors.amber),
            ]),
            BarChartGroupData(x: 6, barRods: [
              BarChartRodData(
                  toY: double.parse(temperature[pp + 1]),
                  width: 5,
                  color: Colors.amber),
            ]),
            BarChartGroupData(x: 7, barRods: [
              BarChartRodData(
                  toY: double.parse(temperature[pp + 0]),
                  width: 5,
                  color: Colors.amber),
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
                getTitlesWidget: getTitles,
                reservedSize: 38,
              ),
            ),
          ),
        ),
        swapAnimationDuration: Duration(milliseconds: 500), // Optional
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
      ///      case 0:
      ///        text = xlabel[pp+7];
      ///        break;
      case 1:
        text = xlabel[pp + 6];
        break;

      ///      case 2:
      ///        text = xlabel[pp+5];
      ///        break;
      case 3:
        text = xlabel[pp + 4];
        break;

      ///      case 4:
      ///        text = xlabel[pp+3];
      ///        break;
      case 5:
        text = xlabel[pp + 2];
        break;

      ///      case 6:
      ///        text = xlabel[pp+1];
      ///        break;
      case 7:
        text = xlabel[pp + 0];
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

class MySetting extends StatefulWidget {
  const MySetting({Key? key}) : super(key: key);

  @override
  State<MySetting> createState() => _MySettingState();
}

class _MySettingState extends State<MySetting> {
  void _prefsLoad() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    farmNo = (prefs.getInt('farmNumber') ?? 1);
    ppfarm = (prefs.getInt('myFarm') ?? 0);

    await prefs.setInt('farmNumber', farmNo);
    await prefs.setInt('myFarm', ppfarm);

    // print('prefsLoad: ${(ppfarm + 1)} / $farmNo');

    farmName[0] = (prefs.getString('farmName0') ?? farmName[0]);
    facilityName[0] = (prefs.getString('facilityName0') ?? facilityName[0]);
    serviceKey[0] = (prefs.getString('serviceKey0') ?? serviceKey[0]);

    for (int i = 1; i < farmNo; i++) {
      farmName.add(prefs.getString('farmName$i') ?? farmName[0]);
      facilityName.add(prefs.getString('facilityName$i') ?? facilityName[0]);
      serviceKey.add(prefs.getString('serviceKey$i') ?? serviceKey[0]);
    }
  }

  void _prefsClear() async {
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
    // print('cleared $farmNo');
  }

  TextEditingController inputController1 = TextEditingController();
  TextEditingController inputController2 = TextEditingController();
  TextEditingController inputController3 = TextEditingController();
  // String inputText = '';
  // String text = 'first';

  @override
  void initState() {
    super.initState();
    _prefsLoad();
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
                      // farmName[ppfarm] = text;
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
                      // facilityName[ppfarm] = text;
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
                      // serviceKey[ppfarm] = text;
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
                  child: Text('총 $farmNo농가가 등록되었습니다!!!'),
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
                          // print('$ppfarm / $farmNo');
                          farmNo++;
                          // print('$ppfarm / $farmNo');

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
                          // print('prefsLoad: ${(ppfarm + 1)} / $farmNo');
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
                              _prefsClear();
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
