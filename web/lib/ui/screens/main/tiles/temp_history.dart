import 'package:brew_kettle_dashboard/core/data/models/timeseries/timeseries.dart';
import 'package:brew_kettle_dashboard/core/service_locator.dart';
import 'package:brew_kettle_dashboard/stores/temperature/temperature_store.dart';
import 'package:brew_kettle_dashboard/utils/list_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:graphic/graphic.dart';

class TempHistoryTile extends StatelessWidget {
  TempHistoryTile({super.key});
  final TemperatureStore _temperatureStore = getIt<TemperatureStore>();

  final int maxX = 100;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 8.0,
        right: 16.0,
        top: 16.0,
        bottom: 8.0,
      ),
      child: Observer(builder: (context) {
        return TempHistoryChart(data: _temperatureStore.temperatureHistory);
      }),
    );
  }
}

class TempHistoryChart extends StatelessWidget {
  final List<TimeseriesViewEntry> data;
  final List<PaintStyle?> _showCrosshairOnPrice = [
    PaintStyle(strokeColor: Colors.black),
    PaintStyle(strokeColor: Colors.black),
  ];

  final List<double> _labelPaddingOnPrice = [8.0, 8.0];

  TempHistoryChart({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    var convertedData = data
        .takeLast(100)
        .map((e) => {
              'date': e.date,
              'temperature': e.value ?? 0,
            })
        .toList();

    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 0),
          color: Theme.of(context).colorScheme.surfaceContainer,
          width: double.maxFinite,
          height: 280,
          child: Chart(
            padding: (_) => const EdgeInsets.fromLTRB(36, 8, 16, 24),
            rebuild: true,
            data: convertedData,
            variables: {
              'date': Variable(
                accessor: (Map map) => map['date'] as DateTime,
                scale: TimeScale(
                    marginMin: 0,
                    marginMax: 0,
                    tickCount: 3,
                    formatter: (d) {
                      String hours = d.hour.toString().padLeft(2, '0');
                      String minutes = d.minute.toString().padLeft(2, '0');
                      String seconds = d.second.toString().padLeft(2, '0');
                      return '$hours:$minutes:$seconds';
                    }),
              ),
              'temperature': Variable(
                accessor: (Map map) => map['temperature'] as num,
                scale: LinearScale(
                  min: 0,
                  max: 105,
                  tickCount: 7,
                  formatter: (v) => v.toStringAsFixed(2),
                ),
              ),
            },
            marks: [
              LineMark(
                size: SizeEncode(value: 2),
                color: ColorEncode(
                  value: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
            ],
            axes: [
              AxisGuide(
                dim: Dim.x,
                line: PaintStyle(
                  strokeWidth: 1,
                  strokeColor: Theme.of(context).colorScheme.outline,
                ),
                label: LabelStyle(
                  textStyle: TextTheme.of(context).labelSmall,
                  offset: const Offset(0, 7.5),
                ),
              ),
              Defaults.verticalAxis
                ..gridMapper =
                    (_, index, __) => index == 0 ? null : Defaults.strokeStyle,
            ],
            selections: {
              'touchMove': PointSelection(
                on: {
                  GestureType.scaleUpdate,
                  GestureType.tapDown,
                  GestureType.longPressMoveUpdate
                },
                dim: Dim.x,
              )
            },
            crosshair: CrosshairGuide(
              labelPaddings: _labelPaddingOnPrice,
              showLabel: [true, true],
              followPointer: [false, false],
              styles: _showCrosshairOnPrice,
            ),
          ),
        ),
      ],
    );
  }
}
