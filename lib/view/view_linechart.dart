// Copyright 2023 Shin Jae-hoon. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fl_chart/fl_chart.dart';
import 'package:farmmon_flutter/view/zoomable_chart.dart';
import 'package:farmmon_flutter/presentation/resources/app_resources.dart';

import 'package:farmmon_flutter/main.dart';
import 'view_homepage.dart';

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
    var appState = context.watch<MyAppState>();

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 50),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                farmList[ppfarm]['farmName'],
                style: TextStyle(fontSize: 25),
              ),
              SizedBox(width: 20),
              ElevatedButton(
                onPressed: () async {
                  ppfarm = (ppfarm + 1) % farmNo;
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.setInt('myFarm', ppfarm);
                  print('prefsLoad: ${(ppfarm + 1)} / $farmNo');
                  print("LineChartPage() - ppfarm: $ppfarm / ${farmNo - 1}");

                  await storage.readJsonAsString2().then((value) {
                    if (mounted) {
                      setState(() {
                        appState.pp = 0;
                        appState.getNext();
                      });
                    }
                  });
                },
                child: Text('다음'),
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
                  Text('엽면습윤:'),
                  Text(
                    '■',
                    style: TextStyle(
                      color: Colors.greenAccent,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text('CO2농도:'),
                  Text(
                    '■',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(width: 20),
          Expanded(
            child: MyLineChart(),
          ),
          SizedBox(height: 20),
        ],
      ),
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
    var appState = context.watch<MyAppState>();

    return Padding(
      padding: const EdgeInsets.all(10),
      // implement the bar chart
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: ZoomableChart(
          maxX: wMAXX.toDouble() - 1,
          builder: (minX, maxX) {
            return LineChart(
              // key: Key(farmList[ppfarm]['farmName']),
              LineChartData(
                clipData: FlClipData.all(),
                minX: minX,
                maxX: maxX,
                maxY: 100,
                minY: 0,
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
                        final multiplyer = [0.5, 1, 10, 1];
                        final unit = ['ºC', '%', 'ppm', ''];
                        final textStyle = TextStyle(
                          color: touchedSpot.bar.gradient?.colors[0] ??
                              touchedSpot.bar.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        );
                        return LineTooltipItem(
                          ' ${(touchedSpot.y * multiplyer[touchedSpot.barIndex]).toStringAsFixed(1)} ${unit[touchedSpot.barIndex]}',
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
                      for (int i = 0; i < wMAXX; i++)
                        FlSpot(
                            i.toDouble(),
                            double.parse(sensorLists[ppfarm]
                                        [appState.pp + (wMAXX - i - 1)]
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
                      for (int i = 0; i < wMAXX; i++)
                        FlSpot(
                            i.toDouble(),
                            double.parse(sensorLists[ppfarm]
                                    [appState.pp + (wMAXX - i - 1)]
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
                      for (int i = 0; i < wMAXX; i++)
                        FlSpot(
                            i.toDouble(),
                            double.parse(sensorLists[ppfarm]
                                        [appState.pp + (wMAXX - i - 1)]
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
                  LineChartBarData(
                    spots: [
                      for (int i = 0; i < wMAXX; i++)
                        FlSpot(
                            i.toDouble(),
                            double.parse(sensorLists[ppfarm]
                                        [appState.pp + (wMAXX - i - 1)]
                                    .leafwet
                                    .toString()) *
                                1)
                    ],
                    isCurved: true,
                    color: AppColors.contentColorGreen,
                    // gradient: LinearGradient(colors: gradientColors),
                    barWidth: 5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: false,
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.contentColorGreen,
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
                      reservedSize: 77,
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
    var appState = context.watch<MyAppState>();

    final style = TextStyle(
      // color: Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );
    String text;
    text = sensorLists[ppfarm][appState.pp + (wMAXX - value.toInt() - 1)]
        .xlabel
        .toString();
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
