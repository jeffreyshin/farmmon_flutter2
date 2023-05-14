import 'package:english_words/english_words.dart';
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
    var now = new DateTime.now();
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
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  appState.toggleFavorite();
                },
                child: Text('전날'),
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
          maxY: 25,
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
              BarChartRodData(toY: 10, width: 15, color: Colors.amber),
            ]),
            BarChartGroupData(x: 2, barRods: [
              BarChartRodData(toY: 9, width: 15, color: Colors.amber),
            ]),
            BarChartGroupData(x: 3, barRods: [
              BarChartRodData(toY: 4, width: 15, color: Colors.amber),
            ]),
            BarChartGroupData(x: 4, barRods: [
              BarChartRodData(toY: 2, width: 15, color: Colors.amber),
            ]),
            BarChartGroupData(x: 5, barRods: [
              BarChartRodData(toY: 13, width: 15, color: Colors.amber),
            ]),
            BarChartGroupData(x: 6, barRods: [
              BarChartRodData(toY: 17, width: 15, color: Colors.amber),
            ]),
            BarChartGroupData(x: 7, barRods: [
              BarChartRodData(toY: 19, width: 15, color: Colors.amber),
            ]),
            BarChartGroupData(x: 8, barRods: [
              BarChartRodData(toY: 21, width: 15, color: Colors.amber),
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

/*
    var now = new DateTime.now();
    String formatDate = DateFormat('yyMMdd').format(now);
    String formatTime = DateFormat('HH').format(now);
    var deltaT = int.parse(formatTime);
    var deltaT12 = deltaT % 12;
    deltaT = 24;
    print(deltaT+deltaT12);
    print('$formatDate');
    print('$formatTime');

    for (var i=0; i<deltaT+deltaT12; i++) {
      var urliot2 = "${urliot}/${apikey}/${formatDate}/12";
      print(urliot2);
      var uriiot = Uri.parse(urliot2);
      http.Response response = await http.get(uriiot);
      print(response.headers);
      print(response.statusCode);
      print(response.body);
      print(response.runtimeType);

    }
*/
    var dio = Dio();
    var file = './usem.csv';
    var response = await dio.post(
        urlanthracnose,
        data: FormData.fromMap({
          'file':file,
        })
    );
    print(response.statusCode);

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
*/
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

