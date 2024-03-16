import 'dart:math';

import 'package:fl_heatmap/fl_heatmap.dart';
import 'package:flutter/material.dart';

class GrapePage extends StatefulWidget {
  const GrapePage({Key? key}) : super(key: key);

  @override
  State<GrapePage> createState() => _HeatmapState();
}

class _HeatmapState extends State<GrapePage> {
  HeatmapItem? selectedItem;

  late HeatmapData heatmapDataPower;

  @override
  void initState() {
    _initExampleData();
    super.initState();
  }

  void _initExampleData() {
    const rows = ['포도노균병'];
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
      colorPalette: colorPaletteBlue,
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
          title: const Text('포도 병해충 예측'),
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
