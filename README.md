# farmmon_flutter

딸기 탄저병, 잿빛곰팡이병 발생 모니터링을 위한 안드로이드앱
- 충남 논산딸기연구소의 모델을 사용함

1. Layout: 품목을 좌측메뉴에 놓고 품목을 선택하면 우측창에 병해충별 위험도를 나타냄
2. 좌측창의 아이콘 품목아이콘으로 수정할 것
3. 우측창에는 fl_chart를 이용하여 날짜별 막대그래프로 위험도 표시
4. HTTP API post SNFD로 확인 완료. file도 비슷하게 하면 될듯
5. file post는 http대신 dio를 쓴다고 함
6. json 피싱처리 작업
7. iot호출 기상파일 만들기





var response = await dio.post(
'주소',
data: FormData.fromMap({
'content':content,
'file':file,
})
);

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

![Screenshot_20230515-134357](https://github.com/jeffreyshin/farmmon_flutter/assets/6800894/39b65be9-f3c1-4278-ac80-ee93ff5e8258)

             
             
.                  
                  
                  
                
