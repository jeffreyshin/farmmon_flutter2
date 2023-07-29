# farmmon_flutter

https://github.com/jeffreyshin/farmmon_flutter/releases/download/v.0.2.1/app-release.apk

딸기 탄저병, 잿빛곰팡이병 발생 모니터링을 위한 안드로이드앱
- 충남 논산딸기연구소의 모델을 사용함

1. Layout: 품목을 좌측메뉴에 놓고 품목을 선택하면 우측창에 병해충별 위험도를 나타냄
2. 좌측창의 아이콘 품목아이콘으로 수정할 것
3. 우측창에는 fl_chart를 이용하여 날짜별 막대그래프로 위험도 표시
4. HTTP API post방식을 사용. multi-part data가 잘 안되서 json 전송방식으로 변경(기상데이터를 압축한 문자열을 json value값으로 전달)
5. 농가 등록메뉴 구성함(사용자편이 무시하고 기능만 구현: 농가명_필수, 장치명_선택, iot포털serviceKey_필수)
6. 시간별 환경데이터 갱신된 데이터만 받아오도록 수정
7. 복수의 농장에 대해 적용되도록 수정함(농장추가, 삭제가능)

beta test(23.6.23~) Bug Report:
1. IOT포털 데이터가져오기 처음했을 때 실패: backend의 문제로 추정(python도 동일증상) 
2. 네트워크 끊어졌을때 경고문구 표시
3. 정시가 지났는데, IOT포탈에 그 시각 자료가 없는 경우(15:06까지 15시자료 미수신) 오류
4. 다음주 병해충 발생 예측(기상청 단기예보 활용)
5. 딸기흰가루병, 총채벌레 모델 추가(보고서 확인할 것)
6. IOT포털 데이터가 누락되었을 때 weather.csv가 12시부터 시작되지 않는 문제
 

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

<img src="https://github.com/jeffreyshin/farmmon_flutter/assets/6800894/ee0a282a-695d-4eff-86d0-3598ab156b3c.jpg"  width="300" height="600">
<img src="https://github.com/jeffreyshin/farmmon_flutter/assets/6800894/876ffc6f-431b-4ed0-9eab-762326789174.jpg"  width="300" height="600">
<img src="https://github.com/jeffreyshin/farmmon_flutter/assets/6800894/c53b9030-3ff8-4add-9c8d-a05234117d5f.jpg"  width="300" height="600">



