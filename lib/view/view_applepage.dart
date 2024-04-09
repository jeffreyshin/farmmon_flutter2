import 'dart:math';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_heatmap/fl_heatmap.dart';
import 'package:farmmon_flutter/view/view_homepage.dart';
import 'package:farmmon_flutter/view/view_weatherpage.dart';
import 'package:farmmon_flutter/main.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:farmmon_flutter/model/model.dart';

///////////////////////////////////////////////////////////////////

var fcstDate = List<String>.filled(200, '20230801', growable: true);
var fcstTime = List<String>.filled(200, '1200', growable: true);

var tag2 = 0;

var avgTa = List<String>.filled(200, '0.0', growable: true);

NCPMS apple = NCPMS();

class ApplePage extends StatefulWidget {
  const ApplePage({Key? key}) : super(key: key);

  @override
  _ApplePageState createState() => _ApplePageState();
}

class _ApplePageState extends State<ApplePage> {
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
    // getWeather2();
    _initExampleData();
    super.initState();
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

  Future getWeather2() async {
    var appState = context.read<MyAppState>();

    var i;
    var region = 'hadong';

    DateFormat("yyyyMMdd").format(DateTime.now().subtract(Duration(days: 1)));

    var itemsList = [
      'tavg',
      'tmax',
      'tmin',
      'hm',
      'ins',
      'sunshine',
      'wsa',
      'wsx',
      'rain'
    ];
    var daysList = [
      DateFormat("yyyyMMdd").format(DateTime.now().subtract(Duration(days: 4))),
      DateFormat("yyyyMMdd").format(DateTime.now().subtract(Duration(days: 3))),
      DateFormat("yyyyMMdd").format(DateTime.now().subtract(Duration(days: 2))),
      DateFormat("yyyyMMdd").format(DateTime.now().subtract(Duration(days: 1))),
      DateFormat("yyyyMMdd").format(DateTime.now()),
      DateFormat("yyyyMMdd").format(DateTime.now().add(Duration(days: 1))),
      DateFormat("yyyyMMdd").format(DateTime.now().add(Duration(days: 2))),
    ];
    var items = itemsList.join(', ');
    var days = daysList.join(', ');

    var geocode = '127.72743,35.09714';
    var rda_30mUrl =
        "https://hadong.agmet.kr/farm/pickvalue/${region}/${items}/${days}/${geocode}/json";

    print(rda_30mUrl);
    if (Platform.isAndroid) {
      showToast(context, "농장 기상 데이터를 가져옵니다", Colors.blueAccent);
    }
// request url
    var headers = {
      'Accept': 'application/json; charset=utf-8',
      'Content-Type': 'application/json; charset=utf-8'
    };
//response = requests.get(api_url, headers=headers)
    var ewsData;
    http.Response response = await http.get(Uri.parse(rda_30mUrl));
    if (response.statusCode == 200) {
      String jsonData = response.body;
      ewsData = jsonDecode(jsonData);
      //print(ewsData);
    }

///////////////////////////////////////////////////////////////////////////
// get EWS data
    var ews_json;
    var elist = [];

    if (response.statusCode == 200) {
      for (var j in daysList) {
        var edata = {
          'date': j,
          'hour': '0.0',
          'tair': (ewsData['tavg'][j][geocode] == ''
              ? '0.0'
              : ewsData['tavg'][j][geocode].toString()),
          'humi': (ewsData['hm'][j][geocode] == ''
              ? '0.0'
              : ewsData['hm'][j][geocode].toString()),
          'radi': (ewsData['ins'][j][geocode] == ''
              ? '0.0'
              : ewsData['ins'][j][geocode].toString()),
          'rain': (ewsData['rain'][j][geocode] == ''
              ? '0.0'
              : ewsData['rain'][j][geocode].toString()),
          'maxAirtemp': (ewsData['tmax'][j][geocode] == ''
              ? '0.0'
              : ewsData['tmax'][j][geocode].toString()),
          'minAirtemp': (ewsData['tmin'][j][geocode] == ''
              ? '0.0'
              : ewsData['tmin'][j][geocode].toString()),
          'wet': '0.0',
          'wspd': (ewsData['wsa'][j][geocode] == ''
              ? '0.0'
              : ewsData['wsa'][j][geocode].toString()),
          'tGrowth': '0.0',
          'tHI': '0.0',
          'av_t_7d': '0.0',
          'av_rh_5d': '0.0',
          'deg0': '0.0',
          'deg1': '0.0',
        };
        elist.add(edata);
        //print(edata.toString());
        // for (var k in itemsList) {
        //   if (ewsData[k][j][geocode] != null) {
        //     print("$j $k ${ewsData[k][j][geocode]}");
        //   }
        // }
      }
    }

    // int totalCountEWS = ewsData['response']['body']['totalCount'];

    // for (int i = 0; i < totalCountASOS; i++) {
    //데이터 전체를 돌면서 원하는 데이터 추출
    // ews_json = ewsData['response']['body']['items']['item'][i];

    // print(i);
    // }

    print('ews elist added!!!!!!!!!!!!!!!!!!!!');
    //print(elist.length);
    ewsList.clear();

    for (int i = 0; i < elist.length; i++) {
      //print(elist[i]['date']);
      Ews ewsdata = Ews(
        date: elist[i]['date'],
        hour: double.parse(elist[i]['hour']),
        tair: double.parse(elist[i]['tair']),
        humi: double.parse(elist[i]['humi']),
        radi: double.parse(elist[i]['radi']),
        rain: double.parse(elist[i]['rain']),
        maxAirtemp: double.parse(elist[i]['maxAirtemp']),
        minAirtemp: double.parse(elist[i]['minAirtemp']),
        wet: double.parse(elist[i]['wet']),
        wspd: double.parse(elist[i]['wspd']),
        tGrowth: double.parse(elist[i]['tGrowth']),
        tHI: double.parse(elist[i]['tHI']),
        av_t_7d: double.parse(elist[i]['av_t_7d']),
        av_rh_5d: double.parse(elist[i]['av_rh_5d']),
        deg0: double.parse(elist[i]['deg0']),
        deg1: double.parse(elist[i]['deg1']),
      );
      ewsList.add(ewsdata);
      // print("after: ewsList.add(ewsdata);");
    }

///////////////////////////////////////////////////////////////////////////

    await apple.apiRequestApple(context).then((value) {
      _initExampleData();
      tag2 = 1; //1;
      setState(() {});
    });

    // await apple.apiRequestApple(context, "all").then((value) {
    //   _initExampleData();
    //   tag2 = 1; //1;
    //   setState(() {});
    // });
    // await apple.apiRequestApple(context, "all").then((value) {
    //   _initExampleData();
    //   tag2 = 1; //1;
    //   setState(() {});
    // });
    // await apple.apiRequestApple(context, "all").then((value) {
    //   _initExampleData();
    //   tag2 = 1; //1;
    //   setState(() {});
    // });

    // await appState.apiRequestApple(context).then((value) {
    //   _initExampleData();
    //   tag2 = 1; //1;
    //   setState(() {});
    // });

////////////////////////////////////////////////////////////////////////////
  }

  // final AppStorage storage = AppStorage();
  Future _future() async {
    // await Future.delayed(Duration(seconds: 5));
    if (tag2 == 0) {
      // if (Platform.isAndroid) {
      //   showToast(context, "날씨 데이터를 가져옵니다", Colors.blueAccent);
      // }
      print("날씨 데이터를 가져옵니다");

      return await getWeather2();
    }
    return 0;
    // return 'done!';
  }

////////////////////////////////////////////////////////////
  HeatmapItem? selectedItem;

  late HeatmapData heatmapDataPower;

  // @override
  // void initState() {
  //   _initExampleData();
  //   super.initState();
  // }

  void _initExampleData() {
    print("_initExampleData()");
    const rows = [
      '가루깍지벌레',
      '검은별무늬병',
      '겹무늬썩음병',
      '굴나방',
      '꼬마배나무이',
      '복숭아순나방',
      '복숭아순나방2',
      '복숭아심식나방',
      '복숭아심식나방2',
      '복숭아유리나방',
      '사과무늬잎말이나방',
      '사과응애',
      '애모무늬잎말이나방',
    ];

    const columns = [
      '-4D',
      '-3D',
      '-2d',
      '-1d',
      '0d',
      '+1d',
      '+2d',
    ];

    final r = ewsList[0].deg0; //Random();
    final rr = Random();

    const String unit = '단위';
    final items = [
      for (int row = 0; row < rows.length; row++)
        for (int col = 0; col < columns.length; col++)
          HeatmapItem(
              value: ((row == 0)
                  ? (applePestL[col].PearGaru as double)
                  : (row == 1)
                      ? (applePestL[col].PearScab as double)
                      : (row == 2)
                          ? (applePestL[col].AppleWhiteRot as double)
                          : (row == 3)
                              ? (applePestL[col].AppleGuln as double)
                              : (row == 4)
                                  ? (applePestL[col].PearBsun as double)
                                  : (row == 5)
                                      ? (applePestL[col].OrientalFruitMoth
                                          as double)
                                      : (row == 6)
                                          ? (applePestL[col].PlumFruitMoth
                                              as double)
                                          : (row == 7)
                                              ? (applePestL[col].AppleBoks
                                                  as double)
                                              : (row == 8)
                                                  ? (applePestL[col]
                                                      .PeachFruitMoth as double)
                                                  : (row == 9)
                                                      ? (applePestL[col]
                                                              .CherryTreeBorer
                                                          as double)
                                                      : (row == 10)
                                                          ? (applePestL[col]
                                                                  .AppleArchips
                                                              as double)
                                                          : (row == 11)
                                                              ? (applePestL[col]
                                                                      .ApplePano
                                                                  as double)
                                                              : applePestL[col]
                                                                      .AppleAemo
                                                                  as double), //r.nextDouble() * 6,
              // style: row == 0 && col > 1
              //     ? HeatmapItemStyle.hatched
              //     : HeatmapItemStyle.filled,
              style: HeatmapItemStyle.filled,
              unit: unit,
              xAxisLabel: columns[col],
              yAxisLabel: rows[row]),
    ];
    heatmapDataPower = HeatmapData(
      rows: rows,
      columns: columns,
      radius: 6.0,
      items: items,
      colorPalette: colorPaletteRed,
    );
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final title = selectedItem != null
        ? '${selectedItem!.value.toStringAsFixed(2)} ${selectedItem!.unit}'
        : '--- ${heatmapDataPower.items.first.unit}';
    final subtitle = selectedItem != null
        ? '${selectedItem!.xAxisLabel} ${selectedItem!.yAxisLabel}'
        : '---';
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 50),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "사과 병해충",
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
                  if (Platform.isAndroid) {
                    showToast(context, "날씨 데이터를 가져옵니다", Colors.blueAccent);
                  }
                  print("날씨 데이터를 가져옵니다");
                  await getWeather2().then((value) {
                    if (mounted) {
                      setState(() {
                        // appState.pp = 0;
                        appState.getNext();
                        // print("setState");
                      });
                    }
                  });
                  // await storage.readJsonAsString2().then((value) {
                  // });
                },
                child: Text('예측'),
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            // DateTime.now(). toString(),
            DateFormat('yyyy-MM-dd').format(DateTime.now()),
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(height: 10),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 10),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [],
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
                        // Expanded(child: MyLineChart2()),
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
                    return Column(
                      children: [
                        // Expanded(child: MyLineChart2()),
                        const SizedBox(height: 16),
                        Text(title, textScaleFactor: 1.4),
                        Text(subtitle),
                        const SizedBox(height: 8),
                        Heatmap(
                            onItemSelectedListener:
                                (HeatmapItem? selectedItem) {
                              debugPrint(
                                  'Item ${selectedItem?.yAxisLabel}/${selectedItem?.xAxisLabel} with value ${selectedItem?.value} selected');
                              setState(() {
                                this.selectedItem = selectedItem;
                              });
                            },
                            // rowsVisible: 7,
                            heatmapData: heatmapDataPower)
                      ],
                    );

                    // return MyLineChart2();

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

///////////////////////////////////////////////////////////////////
