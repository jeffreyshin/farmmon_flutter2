import 'package:english_words/english_words.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:farmmon_flutter/icons/custom_icons_icons.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


/////////////////////////////////////
final custom_dt = <String>['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11'];
final temperature = <String>['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11'];
//////////////////////////////////////

void main() {
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
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  void getData()  {
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

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      case 2:
        page = MyBarChart();
        break;
      case 3:
        page = MyAPI();
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
                    icon: Icon(FontAwesomeIcons.carrot),
                    label: Text('파프리카'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(FontAwesomeIcons.pepperHot),
                    label: Text('사과'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
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

class GeneratorPage extends StatelessWidget {

/////////////////////////////////////////////////////

  void _callAPI() async {
    var urltech = 'http://147.46.206.95:7890/SNFD';
    var urlanthracnose = 'http://147.46.206.95:7897/Anthracnose';
    var urliot = 'http://iot.rda.go.kr/api';
    var apikey = 'r34df5d2d566049e2a809c41da915adc6';

    /// iot포털 테스트
    var now = new DateTime.now();
    String formatDate = DateFormat('yyyyMMdd').format(now);
    String formatTime = DateFormat('HH').format(now);
    var urliot2 = "$urliot/$apikey/$formatDate/$formatTime";
    var uriiot = Uri.parse(urliot2);

    final custom_dt = <String>[];
    final humidity = <String>[];
///    final temperature = <String>[];
    final cotwo = <String>[];
    final leafwet = <String>[];
    final gtemperature = <String>[];
    final quantum = <String>[];

    var deltaT = int.parse(formatTime);
    var deltaT12 = deltaT % 12;
    deltaT = 24;
    if (deltaT < 12) deltaT = deltaT + 12;
    ///print(deltaT+deltaT12);
    ///print('$formatDate');
    ///print('$formatTime');
    temperature.clear();
    custom_dt.clear();
    for (var i=0; i<deltaT+deltaT12; i++) {
      now = now.subtract(Duration(hours:1));
      String formatDate = DateFormat('yyyyMMdd').format(now);
      String formatTime = DateFormat('HH').format(now);
      urliot2 = "${urliot}/${apikey}/${formatDate}/${formatTime}";
      ///print(urliot2);
      uriiot = Uri.parse(urliot2);
      http.Response response = await http.get(uriiot);
      ///    Map<String, dynamic> usem = jsonDecode(response.body);

      var json_obj = jsonDecode(response.body);
      ///print(response.body);

      custom_dt.add(json_obj['datas'][0]['custom_dt']);
      humidity.add(json_obj['datas'][0]['humidity']);
      temperature.add(json_obj['datas'][0]['temperature']);
      leafwet.add(json_obj['datas'][0]['leafwet']);
      cotwo.add(json_obj['datas'][0]['cotwo']);
      gtemperature.add(json_obj['datas'][0]['gtemperature']);
      quantum.add(json_obj['datas'][0]['quantum']);

      ///print(json_obj);
    }
    print(custom_dt);
    print(temperature);


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
    print(response.statusCode);
    print(response.headers);
    print(response.body);

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
    String formatDate = DateFormat('yy년 MM월 dd일').format(now);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Text('딸기 탄저병', style: TextStyle(fontSize: 25),),
          SizedBox(height: 10),
          Text('$formatDate'),
          SizedBox(height: 10),
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
                  _callAPI();
                },
                child: const Text('자료불러오기'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.toggleFavorite();
                },
                child: Text('자료보기'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('다음날'),
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
        for (var pair in appState.favorites)
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(pair.asLowerCase),
          ),
      ],
    );
  }
}

class MyBarChart extends StatelessWidget {
  const MyBarChart({super.key});

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(30),
      // implement the bar chart
      child: BarChart(BarChartData(
          maxY: 40,
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
              BarChartRodData(toY: double.parse(temperature[11]), width: 15, color: Colors.amber),
            ]),
            BarChartGroupData(x: 2, barRods: [
              BarChartRodData(toY: double.parse(temperature[10]), width: 15, color: Colors.amber),
            ]),
            BarChartGroupData(x: 3, barRods: [
              BarChartRodData(toY: double.parse(temperature[9]), width: 15, color: Colors.amber),
            ]),
            BarChartGroupData(x: 4, barRods: [
              BarChartRodData(toY: double.parse(temperature[8]), width: 15, color: Colors.amber),
            ]),
            BarChartGroupData(x: 5, barRods: [
              BarChartRodData(toY: double.parse(temperature[7]), width: 15, color: Colors.amber),
            ]),
            BarChartGroupData(x: 6, barRods: [
              BarChartRodData(toY: double.parse(temperature[6]), width: 15, color: Colors.amber),
            ]),
            BarChartGroupData(x: 7, barRods: [
              BarChartRodData(toY: double.parse(temperature[5]), width: 15, color: Colors.amber),
            ]),
            BarChartGroupData(x: 8, barRods: [
              BarChartRodData(toY: double.parse(temperature[4]), width: 15, color: Colors.amber),
            ]),
            BarChartGroupData(x: 9, barRods: [
              BarChartRodData(toY: double.parse(temperature[3]), width: 15, color: Colors.amber),
            ]),
            BarChartGroupData(x: 10, barRods: [
              BarChartRodData(toY: double.parse(temperature[2]), width: 15, color: Colors.amber),
            ]),
            BarChartGroupData(x: 11, barRods: [
              BarChartRodData(toY: double.parse(temperature[1]), width: 15, color: Colors.amber),
            ]),
            BarChartGroupData(x: 12, barRods: [
              BarChartRodData(toY: double.parse(temperature[0]), width: 15, color: Colors.amber),
            ]),
          ])),
    );
  }
}


class MyAPI extends StatelessWidget {
  const MyAPI({Key? key}) : super(key: key);

  void _callAPI() async {
    var urltech = 'http://147.46.206.95:7890/SNFD';
    var urlanthracnose = 'http://147.46.206.95:7897/Anthracnose';
    var urliot = 'http://iot.rda.go.kr/api';
    var apikey = 'r34df5d2d566049e2a809c41da915adc6';

/// iot포털 테스트
    var now = new DateTime.now();
    String formatDate = DateFormat('yyyyMMdd').format(now);
    String formatTime = DateFormat('HH').format(now);
    var urliot2 = "${urliot}/${apikey}/${formatDate}/${formatTime}";
    var uriiot = Uri.parse(urliot2);

    final custom_dt = <String>[];
    final humidity = <String>[];
    final temperature = <String>[];
    final cotwo = <String>[];
    final leafwet = <String>[];
    final gtemperature = <String>[];
    final quantum = <String>[];

    var deltaT = int.parse(formatTime);
    var deltaT12 = deltaT % 12;
    deltaT = 24;
    if (deltaT < 12) deltaT = deltaT + 12;
    ///print(deltaT+deltaT12);
    ///print('$formatDate');
    ///print('$formatTime');
    now = now.subtract(Duration(hours:deltaT+deltaT12));

    for (var i=0; i<deltaT+deltaT12; i++) {
      now = now.add(Duration(hours:1));
      String formatDate = DateFormat('yyyyMMdd').format(now);
      String formatTime = DateFormat('HH').format(now);
      urliot2 = "${urliot}/${apikey}/${formatDate}/${formatTime}";
      ///print(urliot2);
      uriiot = Uri.parse(urliot2);
      http.Response response = await http.get(uriiot);
      ///    Map<String, dynamic> usem = jsonDecode(response.body);

      var json_obj = jsonDecode(response.body);
      ///print(response.body);

      custom_dt.add(json_obj['datas'][0]['custom_dt']);
      humidity.add(json_obj['datas'][0]['humidity']);
      temperature.add(json_obj['datas'][0]['temperature']);
      leafwet.add(json_obj['datas'][0]['leafwet']);
      cotwo.add(json_obj['datas'][0]['cotwo']);
      gtemperature.add(json_obj['datas'][0]['gtemperature']);
      quantum.add(json_obj['datas'][0]['quantum']);

      ///print(json_obj);
    }
    print(custom_dt);
    print(temperature);

/*  마지막으로 테스트한 코드
    var imagePath = './lib/usem.csv';
    File imageFile = File(imagePath);
    List<int> imageBytes = imageFile.readAsBytesSync();
    String base64Image = base64Encode(imageBytes);
    print(base64Image);
    Uri url = Uri.parse(urlanthracnose);
    http.Response response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      }, // this header is essential to send json data
      body: jsonEncode([
        {'image': '$base64Image'}
      ]),
    );
    print(response.body);
    print(response.statusCode);
*/
/*
    var myFile = File('./lib/usem.csv');
    List<File> imageFileList = List.empty(growable: true);
    imageFileList.add(myFile);

///    var request = http.Request("POST",  Uri.parse(urlanthracnose));

    var request = http.MultipartRequest("POST", Uri.parse(urlanthracnose));

    request.fields['parameter1'] = '보내고 싶은 파라미터';
    request.fields['parameter2'] = '보내고 싶은 파라미터2';

    for (var imageFile in imageFileList) {
      request.files.add(await http.MultipartFile.fromPath('imageFileList', imageFile.path));
    }

    var response = await request.send();
    print(response.statusCode);
    print(response.headers);
    print(response.request);
*/
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
    print(response.statusCode);
    print(response.headers);
    print(response.body);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Example'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _callAPI,
          child: const Text('Call API'),
        ),
      ),
    );
  }
}

