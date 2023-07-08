import 'my_location.dart';
import 'dart:convert';
// import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';

// import 'package:flutter_config/flutter_config.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:farmmon_flutter/kma.dart';
// import 'package:hiiidan_weather/screens/weather_screen.dart';
import 'package:intl/intl.dart';
// import 'weather_screen.dart';
// import 'package:hiiidan_weather/data/my_location.dart';
import 'package:http/http.dart' as http;

// final String apiKey = FlutterConfig.get('apiKey');
// final String kakaoApiKey = FlutterConfig.get('kakao_api');

class Loading extends StatefulWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
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
    super.initState();
    getLocation();
    initMyLibrary(); //라이센스 페이지에 내 라이센스 추가
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

  void getLocation() async {
    MyLocation userLocation = MyLocation();
    await userLocation.getMyCurrentLocation(); //사용자의 현재 위치 불러올 때까지 대기

    xCoordinate = userLocation.currentX; //x좌표
    yCoordinate = userLocation.currentY; //y좌표

    userLati = userLocation.lati;
    userLongi = userLocation.longi;

    var tm_x;
    var tm_y;

    var obsJson;
    var obs;

    print(xCoordinate);
    print(yCoordinate);

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

    var apiKey = "";
    //근접 측정소
    var closeObs =
        'http://apis.data.go.kr/B552584/MsrstnInfoInqireSvc/getNearbyMsrstnList?'
        'tmX=$tm_x&tmY=$tm_y&returnType=json&serviceKey=$apiKey';
    http.Response responseObs = await http.get(Uri.parse(closeObs));
    if (responseObs.statusCode == 200) {
      obsJson = jsonDecode(responseObs.body);
    }
    obs = obsJson['response']['body']['items'][0]['stationName'];
    print('측정소: $obs');

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

    // print(baseDate);
    // print(baseTime);
    // print(currentBaseTime); //초단기 실황
    // print(currentBaseDate);
    // print(sswBaseTime); //초단기 예보
    // print(sswBaseDate);

    String airConditon =
        'http://apis.data.go.kr/B552584/ArpltnInforInqireSvc/getMsrstnAcctoRltmMesureDnsty?'
        'stationName=$obs&dataTerm=DAILY&pageNo=1&ver=1.0'
        '&numOfRows=1&returnType=json&serviceKey=$apiKey';

    KMA network = KMA(today2am, shortTermWeather, currentWeather,
        superShortWeather, airConditon);

    // json 데이터
    var today2amData = await network.getToday2amData();
    var shortTermWeatherData = await network.getShortTermWeatherData();
    var currentWeatherData = await network.getCurrentWeatherData();
    var superShortWeatherData = await network.getSuperShortWeatherData();
    var airConditionData = await network.getAirConditionData();
    // var addrData = jsonDecode(addr);

    // print('2am: $today2amData');
    // print('shortTermWeather: $shortTermWeatherData');
    // print('currentWeather: $currentWeatherData');
    // print('superShortWeather: $superShortWeatherData');
    // print('air: $airConditionData');

    // Navigator.push(context, MaterialPageRoute(builder: (context) {
    //   return WeatherScreen(
    //       parse2amData: today2amData,
    //       parseShortTermWeatherData: shortTermWeatherData,
    //       parseCurrentWeatherData: currentWeatherData,
    //       parseSuperShortWeatherData: superShortWeatherData,
    //       parseAirConditionData: airConditionData,
    //       parseAddrData: addrData);
    // }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // SpinKitWave(
            //   color: Colors.white,
            //   size: 60.0,
            // ),
            SizedBox(
              height: 20,
            ),
            Text(
              '위치 정보 업데이트 중',
              style: TextStyle(
                  fontFamily: 'tmon', fontSize: 20.0, color: Colors.black87),
            )
          ],
        ),
      ),
    );
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

void initMyLibrary() {
  //라이선스 추가 함수
  LicenseRegistry.addLicense(() async* {
    yield const LicenseEntryWithLineBreaks(<String>['kakao map'], '''
https://apis.map.kakao.com/
''');
  });

  LicenseRegistry.addLicense(() async* {
    yield const LicenseEntryWithLineBreaks(<String>['background image'], '''
https://coolbackgrounds.io/
''');
  });

  LicenseRegistry.addLicense(() async* {
    yield const LicenseEntryWithLineBreaks(<String>['Weather Icon'], '''
Bas milius (https://github.com/basmilius/weather-icons)

MIT License

Copyright (c) 2020-2021 Bas Milius

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
''');
  });

  LicenseRegistry.addLicense(() async* {
    yield const LicenseEntryWithLineBreaks(
        <String>['expression/setting/menu Icon'], '''
Icons by Orion Icon Library (https://orioniconlibrary.com)
''');
  });

  LicenseRegistry.addLicense(() async* {
    yield const LicenseEntryWithLineBreaks(
        <String>['Micro dust inform box background image'], '''
Photo by Pero Kalimero on Unsplash 
(https://unsplash.com/images/nature/cloud?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText)

License

Unsplash photos are made to be used freely. Our license reflects that.

All photos can be downloaded and used for free

Commercial and non-commercial purposes

No permission needed (though attribution is appreciated!)

What is not permitted 👎

Photos cannot be sold without significant modification.

Compiling photos from Unsplash to replicate a similar or competing service.

Longform

Unsplash grants you an irrevocable, nonexclusive, worldwide copyright license to download, copy, modify, distribute, perform, and use photos from Unsplash for free, including for commercial purposes, without permission from or attributing the photographer or Unsplash. This license does not include the right to compile photos from Unsplash to replicate a similar or competing service.


''');
  });

  LicenseRegistry.addLicense(() async* {
    yield const LicenseEntryWithLineBreaks(
        <String>['Timon TmonMonsori Font'], '''
라이선스

Copyright (c) 2016, TICKETMONSTER, Inc. (http://www.ticketmonster.co.kr),
 
with Reserved Font Name TmonMonsori.
This Font Software is licensed under the SIL Open Font License, Version 1.1.
This license is copied below, and is also available with a FAQ at: http://scripts.sil.org/OFL
SIL OPEN FONT LICENSE
Version 1.1 - 26 February 2007
 
> ‘Tmon몬소리체’ 폰트명에 대해 Ticket Monster (http://www.ticketmonster.co.kr)이 저작권을 소유하고 있습니다.
본 폰트 소프트웨어는 SIL 오픈 폰트 라이선스 버전 1.1에 따라 라이선스 취득을 하였습니다.
본 라이선스는 하단에 복사되었고 http://scripts.sil.org/OFL의 FAQ란 에서도 열람가능 합니다.  
 
SIL 오픈 폰트 라이선스
버전 1.1 (2007년 2월 26일)
DEFINITIONS (정의)

"Font Software" refers to the set of files released by the Copyright Holder(s) under this license and clearly marked as such. This may include source files, build scripts and documentation.  
 
"Reserved Font Name" refers to any names specified as such after the copyright statement(s).  
"Original Version" refers to the collection of Font Software components as distributed by the Copyright Holder(s).  
 
"Modified Version" refers to any derivative made by adding to, deleting, or substituting in part or in whole any of the components of the Original Version, by changing formats or by porting the Font Software to a new environment.‘  
 
"Author" refers to any designer, engineer, programmer, technical writer or other person who contributed to the Font Software.  
 
>  ‘폰트 소프트웨어’는 본 라이선스에 입거해 저작권자가 배포하고 명확하게 같은 표시가 된 파일들의 집합을 뜻하며, 여기에는 소스 파일, 빌드 스크립트와 문서가 이에 포함됩니다. 
‘저작권이 있는 폰트명’은 저작권 정책에 따라서 지정된 이름을 말합니다. 
‘원본’은 저작권자가 배포한 폰트 소프트웨어 구성요소를 의미합니다. 
‘수정본’은 포맷의 변경이나 폰트 소프트웨어를 새로운 환경에 포팅시켜, 원본의 일부 혹은 전체에 추가, 삭제 대체해 만든 파생 저작물을 의미합니다.
‘저자’는 폰트 소프트웨어에 기여한 디자이너, 엔지니어, 프로그래머, 기술 전문가 등을 의미합니다.

PREAMBLE (전문)

The goals of the Open Font License (OFL) are to stimulate worldwide development of collaborative font projects,
to support the font creation efforts of academic and linguistic communities, and to provide a free and open framework  in which fonts may be shared and improved in partnership with others.
The OFL allows the licensed fonts to be used, studied, modified and redistributed freely as long as they are not sold 
by themselves. The fonts, including any derivative works, can be bundled, embedded, redistributed and/or sold with any software provided that any reserved names are not used by derivative works. 
The fonts and derivatives, however, cannot be released under any other type of license.
The requirement for fonts to remain under this license does not apply to any document created using the fonts or their derivatives.  

> 본 폰트 라이선스를 오픈 하는 것은(이하 OFL)는 전 세계 폰트 개발 프로젝트를 지원하고 학계와 언어 관련 학계의 폰트 개발을 위한 연구를 지지하기 위해서인 동시에, 폰트 제휴를 통해 폰트가 공유되고 개선될 수 있는 자유롭게 개방된 환경을 만들기 위해서 입니다.  
 
OFL은 라이선스를 취득한 폰트가 그 자체로 판매되지 않는 한 자유롭게 사용, 연구, 수정, 재배포 하는 것을 허가합니다. 수정된 폰트를 포함한 폰트는 저작권 명이 사용되지 않는 한 기타 소프트웨어와 함께 묶이거나 삽입, 재배포 할 수 있습니다. 단 폰트와 수정된 폰트는 기타 다른 라이선스에 포함되어 배포될 수는 없습니다. 이 라이선스 하에 있기 위한 폰트에 대한 요구사항은 본 폰트나 수정본을 사용하여 제작된 어떠한 문서에도 적용되지 않습니다. 

PERMISSION & CONDITIONS (허가 및 조건)

Permission is hereby granted, free of charge, to any person obtaining a copy of the Font Software, to use, study, copy, merge, embed, modify, redistribute, and sell modified and unmodified copies of the Font Software, subject to the following conditions:  

> 본 폰트 소프트웨어를 사용하도록 허가 받은 개인/기업/단체 누구라도 다음 명시된 조건에 따라 폰트 소프트웨어의 수정 혹은 수정되지 않은 복사본을 무료로 사용, 연구, 복사, 통합, 삽입, 수정, 재배포할 수 있도록 허가합니다.  

1) Neither the Font Software nor any of its individual components,in Original or Modified Versions, may be sold by itself.
 원본이나 수정본의 폰트 소프트웨어 혹은 개별 구성요소인 폰트 자체가 판매되어서는 안됩니다.
 
2) Original or Modified Versions of the Font Software may be bundled, redistributed and/or sold with any software, provided that each copy contains the above copyright notice and this license. These can be included either as stand-alone text files, human-readable headers or in the appropriate machine-readable metadata fields within text or binary files as long as those fields can be easily viewed by the user.  
 
본 폰트 소프트웨어의 원본 혹은 수정본은 상기 저작권 안내와 본 라이선스에 대한 내용을 포함하는 경우에는 다른 소프트웨어와 함께 묶이거나 재배포 혹은 판매가 가능합니다. 이는 독립 텍스트 파일과 가독성이 있는 헤더 혹은 유저가 용이하게 열람 가능한 이상 텍스트파일 혹은 이진파일 내 기계가 읽을 수 있는 메타데이터 형태를 모두 의미 합니다.  
 
3) No Modified Version of the Font Software may use the Reserved Font Name(s) unless explicit written
permission is granted by the corresponding Copyright Holder. This restriction only applies to the primary font name as presented to the users.  
 
본 폰트 소프트웨어의 어떠한 수정본도 동일한 저작권자가 명시적 허가서를 부여하지 않는 한 저작권이 있는 폰트명을 사용해서는 안 됩니다. 본 제한 사항은 유저들에게 제공된 기존 폰트명을 뜻합니다.
 
4) The name(s) of the Copyright Holder(s) or the Author(s) of the Font Software shall not be used to promote, endorse or advertise any Modified Version, except to acknowledge the contribution(s) of the Copyright Holder(s) and the Author(s) or with their explicit written permission.  
 
본 폰트 소프트웨어의 저작권자 혹은 저자의 이름은 그들의 명시적 서면 허가가 있거나 또는 그들의 공헌을 인정하기 위한 경우를 제외하고는 수정본에 대한 사용을 유도,추천 혹은 광고하기 위한 목적으로 사용할 수 없습니다.  
 
5) The Font Software, modified or unmodified, in part or in whole, must be distributed entirely under this license, and must not be distributed any other license. The requirement for fonts to remain under this license does not apply to any document created using the Font Software.
 
본 폰트 소프트웨어는 전체나 부분, 혹은 수정 여부에 상관없이 본 라이선스 하에 배포가 되어야 하며 기타 다른 라이선스 하에서는 배포를 할 수 없습니다. 폰트에 대한 요구조건은 이 라이선스 하에서만 유효하며 이 라이선스 하에 있기 위한 폰트에 대한 요구사항은 본 폰트 소프트웨어를 사용해 제작한 어떠한 문서에도 적용되지 않습니다.

TERMINATION (계약의 종료)

This license becomes null and void if any of the above conditions are not met. 

> 본 라이선스는 상기 조건 중 일부라도 부합되지 않으면 무효가 될 수 있습니다.

DISCLAIMER (면책조항)

THE FONT SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT OF COPYRIGHT, PATENT, TRADEMARK, OR OTHER RIGHT. IN NO EVENT SHALL THE COPYRIGHT HOLDER BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, INCLUDING ANY GENERAL, SPECIAL, INDIRECT, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF THE USE OR INABILITY TO USE THE FONT SOFTWARE OR FROM OTHER DEALINGS IN THE FONT SOFTWARE.  
 
> 본 폰트 소프트웨어는 저작권, 특허권, 상표권 및 기타 권리의 비침해성과 특정 목적에의 적합성 포함한 명시적, 묵시적인 어떠한 종류의 보증 없이 “있는 그대로” 제공됩니다. 어떠한 경우에도 저작권자는 본 폰트 소프트웨어의 사용 또는 이의 사용불가, 그밖에 폰트 소프트웨어의 취급과 관련하여 발생하는 모든 계약, 불법행위 혹은 다른 일로 하여금 발생하는 일반적, 특수적, 간접적, 부차적 혹은 필연적 손해를 포함하는 소송, 손해, 혹은 기타 책임에 대한 의무를 가지지 않습니다.



''');
  });
}
