import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Welcome to Flutter, title',
        home: Scaffold(
          appBar: AppBar
            (
            elevation: 2.0,
            backgroundColor: Colors.white,
            title: Text('딸기 탄저병 예측', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 30.0)),
            actions: <Widget>
            [
              Container
                (
                margin: EdgeInsets.only(right: 8.0),
                child: Row
                  (
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>
                  [
                    Text('FarmBiz.xyz', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w700, fontSize: 14.0)),
                    Icon(Icons.arrow_drop_down, color: Colors.black54)
                  ],
                ),
              )
            ],
          ),
          body: MyBody(),
          bottomNavigationBar: BottomAppBar(
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.menu),
                  onPressed: () {},
                ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.more_vert),
                  onPressed: () {},
                )
              ],
            ),
          ),      )
    );
  }
}



class MyBody extends StatelessWidget {
  const MyBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(left: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const Text(''),
            const Text('딸기 탄저병 예측 결과',
                style: TextStyle(
                  color: Colors.blueGrey,
                  fontSize: 25,
                )
            ),
            const Text('1. iot포털 환경데이터 가져오기', style: TextStyle(fontSize: 15),),
            const Text('2. 환경데이터 파일 작성', style: TextStyle(fontSize: 15),),
            const Text('3. 탄저병 예측 API호출', style: TextStyle(fontSize: 15),),
            const Text('4. 예측결과를 출력', style: TextStyle(fontSize: 15),),
          ],
        )
    );
  }
}
