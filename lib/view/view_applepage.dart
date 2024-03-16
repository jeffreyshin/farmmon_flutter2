import 'dart:math';

import 'package:fl_heatmap/fl_heatmap.dart';
import 'package:flutter/material.dart';
import 'package:farmmon_flutter/main.dart';
import 'package:farmmon_flutter/model/kma.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

///////////////////////////////////////////////////////////////////

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

var avgTa = List<String>.filled(200, '0.0', growable: true);

class WeatherPage2 extends StatefulWidget {
  const WeatherPage2({Key? key}) : super(key: key);

  @override
  _WeatherPage2State createState() => _WeatherPage2State();
}

class _WeatherPage2State extends State<WeatherPage2> {
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
    _initExampleData();
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

    String ASOS =
        'http://apis.data.go.kr/1360000/AsosDalyInfoService/getWthrDataList'
        '?serviceKey=$apiKey&numOfRows=60&pageNo=1&'
        'DataType=JSON&dataCd=ASOS&dateCd=DAY&'
        'startDt=20100101&endDt=20100105&stnIds=119';

    KMA kmaData = KMA(today2am, shortTermWeather, currentWeather,
        superShortWeather, airConditon, ASOS);

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

    print(kmaData.ASOSUrl);
    var ASOSData = await kmaData.getASOSData();
    print(ASOSData.toString());

    print("pause");

///////////////////////////////////////////////////////////////////////////
// get ASOS data

    var asos_json;
    var asoslist = [];

    //ASOS data

    print(ASOSData['response']['body']['items']['item']);
    int totalCountASOS = ASOSData['response']['body']['totalCount'];
    for (int i = 0; i < totalCountASOS; i++) {
      //데이터 전체를 돌면서 원하는 데이터 추출
      asos_json = ASOSData['response']['body']['items']['item'][i];
      var asosdata = {
        'date': asos_json['tm'],
        'hour': 0,
        'tair': asos_json['avgTa'],
        'humi': asos_json['avgRhm'],
        'radi': asos_json['sumGsr'],
        'rain': asos_json['sumRn'],
        'maxAirtemp': asos_json['maxTa'],
        'minAirtemp': asos_json['minTa'],
        'wet': 0,
        'wspd': asos_json['avgWs'],
        'tGrowth': 0,
        'tHI': 0,
        'av_t_7d': asos_json['avgTa'],
        'av_rh_5d': asos_json['avgRhm'],
      };
      asoslist.add(asosdata);
    }

    int i;
    for (i = 0; i < 10; i++) {
      print(asoslist[i]['avgTa'].toString());
      avgTa[i] = asoslist[i]['avgTa'];
    }

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

////////////////////////////////////////////////////////////
  HeatmapItem? selectedItem;

  late HeatmapData heatmapDataPower;

  // @override
  // void initState() {
  //   _initExampleData();
  //   super.initState();
  // }

  void _initExampleData() {
    const rows = [
      '가루깍지벌레',
      '갈색무늬병',
      '검은별무늬병',
      '겹무늬썩음병',
      '굴나방',
      '꼬마배나무이',
      '복숭아순나방',
      '복숭아순나방붙이',
      '복숭아심식나방',
      '복숭아유리나방',
      '사과무늬잎말이나방',
      '사과응애',
      '사과탄저병',
      '애모무늬잎말이나방',
      '점박이응애'
    ];
    const columns = [
      '일',
      '월',
      '화',
      '수',
      '목',
      '금',
      '토',
    ];
    final r = double.parse(avgTa[0]); //Random();

    const String unit = '단위';
    final items = [
      for (int row = 0; row < rows.length; row++)
        for (int col = 0; col < columns.length; col++)
          HeatmapItem(
              value: 1.0, //r.nextDouble() * 6,
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
    // var appState = context.watch<MyAppState>();
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
              const SizedBox(height: 16),
              Text(title, textScaleFactor: 1.4),
              Text(subtitle),
              const SizedBox(height: 8),
              Heatmap(
                  onItemSelectedListener: (HeatmapItem? selectedItem) {
                    debugPrint(
                        'Item ${selectedItem?.yAxisLabel}/${selectedItem?.xAxisLabel} with value ${selectedItem?.value} selected');
                    setState(() {
                      this.selectedItem = selectedItem;
                    });
                  },
                  // rowsVisible: 5,
                  heatmapData: heatmapDataPower)
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
                    return SizedBox();
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

class ApplePage extends StatefulWidget {
  const ApplePage({Key? key}) : super(key: key);

  @override
  State<ApplePage> createState() => _ApplePageState();
}

class _ApplePageState extends State<ApplePage> {
  HeatmapItem? selectedItem;

  late HeatmapData heatmapDataPower;

  @override
  void initState() {
    _initExampleData();
    super.initState();
  }

  void _initExampleData() {
    const rows = [
      '가루깍지벌레',
      '갈색무늬병',
      '검은별무늬병',
      '겹무늬썩음병',
      '굴나방',
      '꼬마배나무이',
      '복숭아순나방',
      '복숭아순나방붙이',
      '복숭아심식나방',
      '복숭아유리나방',
      '사과무늬잎말이나방',
      '사과응애',
      '사과탄저병',
      '애모무늬잎말이나방',
      '점박이응애'
    ];
    const columns = [
      '일',
      '월',
      '화',
      '수',
      '목',
      '금',
      '토',
    ];
    final r = Random();
    const String unit = '단위';
    final items = [
      for (int row = 0; row < rows.length; row++)
        for (int col = 0; col < columns.length; col++)
          HeatmapItem(
              value: r.nextDouble() * 6,
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
    final title = selectedItem != null
        ? '${selectedItem!.value.toStringAsFixed(2)} ${selectedItem!.unit}'
        : '--- ${heatmapDataPower.items.first.unit}';
    final subtitle = selectedItem != null
        ? '${selectedItem!.xAxisLabel} ${selectedItem!.yAxisLabel}'
        : '---';
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('사과 병해충 예측'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),
              Text(title, textScaleFactor: 1.4),
              Text(subtitle),
              const SizedBox(height: 8),
              Heatmap(
                  onItemSelectedListener: (HeatmapItem? selectedItem) {
                    debugPrint(
                        'Item ${selectedItem?.yAxisLabel}/${selectedItem?.xAxisLabel} with value ${selectedItem?.value} selected');
                    setState(() {
                      this.selectedItem = selectedItem;
                    });
                  },
                  // rowsVisible: 5,
                  heatmapData: heatmapDataPower)
            ],
          ),
        ),
      ),
    );
  }
}
