// Copyright 2023 Shin Jae-hoon. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:farmmon_flutter/presentation/resources/app_resources.dart';
import 'package:farmmon_flutter/main.dart';

class MyBarChart extends StatefulWidget {
  const MyBarChart({super.key});

  @override
  State<MyBarChart> createState() => _MyBarChartState();
}

class _MyBarChartState extends State<MyBarChart> {
  @override
  void initState() {
    super.initState();

    print('Bar Chart initState 호출');
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Padding(
      padding: const EdgeInsets.all(20),
      // implement the bar chart
      child: BarChart(
        // key: ValueKey(ppfarm),
        // key: Key(farmList[ppfarm]['farmName']),

        BarChartData(
          maxY: 100,
          rangeAnnotations: RangeAnnotations(
            horizontalRangeAnnotations: [
              HorizontalRangeAnnotation(
                y1: 0,
                y2: 20,
                color: AppColors.contentColorGreen.withOpacity(0.3),
              ),
              HorizontalRangeAnnotation(
                y1: 20,
                y2: 50,
                color: AppColors.contentColorYellow.withOpacity(0.3),
              ),
              HorizontalRangeAnnotation(
                y1: 50,
                y2: 100,
                color: AppColors.contentColorOrange.withOpacity(0.3),
              ),
            ],
          ),
          // uncomment to see ExtraLines with RangeAnnotations
          extraLinesData: ExtraLinesData(
//         extraLinesOnTop: true,
            horizontalLines: [
              HorizontalLine(
                y: 10,
                // color: AppColors.contentColorBlack,
                strokeWidth: 0,
                dashArray: [5, 10],
                label: HorizontalLineLabel(
                  show: true,
                  alignment: Alignment.topRight,
                  padding: const EdgeInsets.only(right: 5, bottom: 15),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  labelResolver: (line) => '낮음',
                ),
              ),
              HorizontalLine(
                y: 40,
                // color: AppColors.contentColorRed,
                strokeWidth: 0,
                dashArray: [5, 10],
                label: HorizontalLineLabel(
                  show: true,
                  alignment: Alignment.topRight,
                  padding: const EdgeInsets.only(right: 5, bottom: 15),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  labelResolver: (line) => '다소높음',
                ),
              ),
              HorizontalLine(
                y: 90,
                // color: AppColors.contentColorWhite,
                strokeWidth: 0,
                dashArray: [5, 10],
                label: HorizontalLineLabel(
                  show: true,
                  alignment: Alignment.topRight,
                  padding: const EdgeInsets.only(right: 5, bottom: 15),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  labelResolver: (line) => '위험',
                ),
              ),
            ],
          ),
          borderData: FlBorderData(
              border: const Border(
            top: BorderSide.none,
            right: BorderSide.none,
            left: BorderSide(width: 1),
            bottom: BorderSide(width: 1),
          )),
          groupsSpace: 10,
          // add bars
          barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
            maxContentWidth: 100,
            tooltipBgColor: Colors.white,
          )),
          barGroups: [
            BarChartGroupData(x: 1, barRods: [
              BarChartRodData(
                  toY: double.parse(pinfLists[ppfarm][appState.pp + 6]
                      .anthracnose
                      .toString()),
                  width: 5,
                  color: Colors.pink),
              BarChartRodData(
                  toY: double.parse(
                      pinfLists[ppfarm][appState.pp + 6].botrytis.toString()),
                  width: 5,
                  color: Colors.indigo),
            ]),
            BarChartGroupData(x: 2, barRods: [
              BarChartRodData(
                  toY: double.parse(pinfLists[ppfarm][appState.pp + 5]
                      .anthracnose
                      .toString()),
                  width: 5,
                  color: Colors.pink),
              BarChartRodData(
                  toY: double.parse(
                      pinfLists[ppfarm][appState.pp + 5].botrytis.toString()),
                  width: 5,
                  color: Colors.indigo),
            ]),
            BarChartGroupData(x: 3, barRods: [
              BarChartRodData(
                  toY: double.parse(pinfLists[ppfarm][appState.pp + 4]
                      .anthracnose
                      .toString()),
                  width: 5,
                  color: Colors.pink),
              BarChartRodData(
                  toY: double.parse(
                      pinfLists[ppfarm][appState.pp + 4].botrytis.toString()),
                  width: 5,
                  color: Colors.indigo),
            ]),
            BarChartGroupData(x: 4, barRods: [
              BarChartRodData(
                  toY: double.parse(pinfLists[ppfarm][appState.pp + 3]
                      .anthracnose
                      .toString()),
                  width: 5,
                  color: Colors.pink),
              BarChartRodData(
                  toY: double.parse(
                      pinfLists[ppfarm][appState.pp + 3].botrytis.toString()),
                  width: 5,
                  color: Colors.indigo),
            ]),
            BarChartGroupData(x: 5, barRods: [
              BarChartRodData(
                  toY: double.parse(pinfLists[ppfarm][appState.pp + 2]
                      .anthracnose
                      .toString()),
                  width: 5,
                  color: Colors.pink),
              BarChartRodData(
                  toY: double.parse(
                      pinfLists[ppfarm][appState.pp + 2].botrytis.toString()),
                  width: 5,
                  color: Colors.indigo),
            ]),
            BarChartGroupData(x: 6, barRods: [
              BarChartRodData(
                  toY: double.parse(pinfLists[ppfarm][appState.pp + 1]
                      .anthracnose
                      .toString()),
                  width: 5,
                  color: Colors.pink),
              BarChartRodData(
                  toY: double.parse(
                      pinfLists[ppfarm][appState.pp + 1].botrytis.toString()),
                  width: 5,
                  color: Colors.indigo),
            ]),
            BarChartGroupData(x: 7, barRods: [
              BarChartRodData(
                  toY: double.parse(pinfLists[ppfarm][appState.pp + 0]
                      .anthracnose
                      .toString()),
                  width: 5,
                  color: Colors.pink),
              BarChartRodData(
                  toY: double.parse(
                      pinfLists[ppfarm][appState.pp + 0].botrytis.toString()),
                  width: 5,
                  color: Colors.indigo),
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
                reservedSize: 47,
                // interval: 12,
              ),
            ),
          ),
        ),
        swapAnimationDuration: Duration(milliseconds: 300), // Optional
        swapAnimationCurve: Curves.linear, // Optional
      ),
    );
  }

  Widget getTitles(double value, TitleMeta meta) {
    var appState = context.watch<MyAppState>();

    final style = TextStyle(
      ///      color: AppColors.contentColorBlue.darken(20),
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );
    String text;
    switch (value.toInt()) {
      case 0:
        text = pinfLists[ppfarm][appState.pp + 7].xlabel.toString();
        break;
      case 1:
        text = pinfLists[ppfarm][appState.pp + 6].xlabel.toString();
        break;
      case 2:
        text = pinfLists[ppfarm][appState.pp + 5].xlabel.toString();
        break;
      case 3:
        text = pinfLists[ppfarm][appState.pp + 4].xlabel.toString();
        break;
      case 4:
        text = pinfLists[ppfarm][appState.pp + 3].xlabel.toString();
        break;
      case 5:
        text = pinfLists[ppfarm][appState.pp + 2].xlabel.toString();
        break;
      case 6:
        text = pinfLists[ppfarm][appState.pp + 1].xlabel.toString();
        break;
      case 7:
        text = pinfLists[ppfarm][appState.pp + 0].xlabel.toString();
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
