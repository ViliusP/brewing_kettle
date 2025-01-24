import 'package:brew_kettle_dashboard/core/data/models/timeseries/timeseries.dart';
import 'package:brew_kettle_dashboard/core/service_locator.dart';
import 'package:brew_kettle_dashboard/stores/current_temperature/current_temperature_store.dart';
import 'package:brew_kettle_dashboard/utils/list_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:graphic/graphic.dart';

class TempHistoryTile extends StatelessWidget {
  TempHistoryTile({super.key});
  final CurrentTemperatureStore _temperatureStore =
      getIt<CurrentTemperatureStore>();

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

  const TempHistoryChart({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    var convertedData = data
        .takeLast(100)
        .map((e) => {'date': e.date, 'temperature': e.value ?? 0})
        .toList();

    return Chart(
      padding: (_) => const EdgeInsets.fromLTRB(50, 8, 24, 24),
      rebuild: false,
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
            formatter: (v) => v.toStringAsFixed(1),
          ),
        ),
      },
      marks: [
        LineMark(
          size: SizeEncode(value: 2),
          color: ColorEncode(value: colorScheme.inversePrimary),
        ),
      ],
      axes: [
        AxisGuide(
          dim: Dim.x,
          line: PaintStyle(strokeWidth: 1, strokeColor: colorScheme.outline),
          label: LabelStyle(
            textStyle: TextTheme.of(context).labelSmall,
            offset: const Offset(0, 7.5),
          ),
        ),
        AxisGuide(
          dim: Dim.y,
          line: PaintStyle(strokeWidth: 1, strokeColor: colorScheme.outline),
          labelMapper: (_, index, ___) {
            return switch (index) {
              0 => null,
              _ => LabelStyle(
                  textStyle: TextTheme.of(context).labelSmall,
                  offset: const Offset(-10, 0),
                )
            };
          },
          tickLineMapper: (_, index, ___) {
            return switch (index) {
              0 => null,
              _ => TickLine(
                  style: PaintStyle(
                    strokeWidth: 1,
                    strokeColor: colorScheme.outline,
                  ),
                )
            };
          },
          gridMapper: (_, index, __) {
            return switch (index) {
              0 => null,
              _ => PaintStyle(
                  strokeWidth: 1,
                  strokeColor: colorScheme.outline.withAlpha(35),
                )
            };
          },
        ),
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
        labelPaddings: const [8.0, 8.0],
        showLabel: const [true, true],
        followPointer: const [false, false],
        styles: [
          PaintStyle(strokeColor: Color.fromRGBO(0, 0, 0, 1)),
          PaintStyle(strokeColor: Color.fromRGBO(0, 0, 0, 1)),
        ],
      ),
    );
  }
}
