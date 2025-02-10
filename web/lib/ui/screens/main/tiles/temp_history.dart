import 'dart:ui';

import 'package:brew_kettle_dashboard/core/data/models/timeseries/timeseries.dart';
import 'package:brew_kettle_dashboard/core/service_locator.dart';
import 'package:brew_kettle_dashboard/stores/heater_controller_state/heater_controller_state_store.dart';
import 'package:brew_kettle_dashboard/utils/list_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:graphic/graphic.dart';

class TempHistoryTile extends StatelessWidget {
  TempHistoryTile({super.key});
  final HeaterControllerStateStore _temperatureStore =
      getIt<HeaterControllerStateStore>();

  static const entriesLimit = 100;

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
        var tempHistory = _temperatureStore.stateHistory.takeLast(entriesLimit);
        return TempHistoryChart(data: tempHistory);
      }),
    );
  }
}

class TempHistoryChart extends StatelessWidget {
  final List<TimeSeriesViewEntry> data;

  const TempHistoryChart({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = TextTheme.of(context);

    var convertedData = data
        .map((e) => {
              'date': e.date,
              'temperature': e.value?['current_temperature'] ?? 0,
              'target_temperature': e.value?['target_temperature'] ?? 0,
              'power': e.value?['power'] ?? 0,
            })
        .toList();

    // Graphics library cannot be used with empty data, so it will be added when
    // provided data is empty.
    if (data.isEmpty) {
      convertedData.add(
        {
          'date': DateTime.now(),
          'temperature': 0,
          'target_temperature': 0,
          'power': 0,
        },
      );
    }

    return Chart(
      padding: (_) => const EdgeInsets.fromLTRB(50, 8, 24, 24),
      // Another quirk of graphics library, if data changes from default to store's,
      // axes won't rebuild itself.
      rebuild: data.length == 2 ? true : false,
      data: convertedData,
      variables: {
        'date': Variable(
          accessor: (Map map) => map['date'] as DateTime,
          scale: TimeScale(
              min: data.isEmpty
                  ? DateTime.now().subtract(Duration(hours: 1))
                  : null,
              max: data.isEmpty ? DateTime.now() : null,
              marginMin: data.isNotEmpty ? 0 : null,
              marginMax: data.isNotEmpty ? 0 : null,
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
        'target_temperature': Variable(
          accessor: (Map map) => map['target_temperature'] as num,
          scale: LinearScale(
            min: 0,
            max: 105,
            formatter: (v) => v.toStringAsFixed(1),
          ),
        ),
        'power': Variable(
          accessor: (Map map) => map['power'] as num,
          scale: LinearScale(
            min: 0,
            max: 100,
            formatter: (v) => v.toStringAsFixed(1),
          ),
        ),
      },
      marks: [
        LineMark(
          position: Varset('date') * Varset('temperature'),
          shape: ShapeEncode(value: BasicLineShape(smooth: true)),
          size: SizeEncode(value: 3),
          color: ColorEncode(value: colorScheme.outline),
        ),
        LineMark(
          position: Varset('date') * Varset('target_temperature'),
          size: SizeEncode(value: 2),
          color: ColorEncode(value: colorScheme.error.withAlpha(96)),
          shape: ShapeEncode(value: BasicLineShape(dash: [24, 2])),
        ),
        LineMark(
          position: Varset('date') * Varset('power'),
          shape: ShapeEncode(value: BasicLineShape(dash: [12, 2])),
          size: SizeEncode(value: 2),
          color: ColorEncode(value: colorScheme.inversePrimary),
        ),
      ],
      axes: [
        AxisGuide(
          dim: Dim.x,
          line: PaintStyle(
            strokeWidth: 1,
            strokeColor: colorScheme.outline.withAlpha(128),
            strokeCap: StrokeCap.round,
          ),
          label: LabelStyle(
            textStyle: textTheme.labelMedium,
            offset: const Offset(0, 7.5),
          ),
        ),
        AxisGuide(
          dim: Dim.y,
          line: PaintStyle(
            strokeWidth: 1,
            strokeColor: colorScheme.outline.withAlpha(128),
            strokeCap: StrokeCap.round,
          ),
          labelMapper: (_, index, ___) {
            return switch (index) {
              0 => null,
              _ => LabelStyle(
                  textStyle: textTheme.labelMedium,
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
                    strokeCap: StrokeCap.round,
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
                  strokeCap: StrokeCap.round,
                )
            };
          },
        ),
      ],
      selections: {
        _ChartSelections.tooltipShow: _ChartSelections.tooltipShowSettings,
        _ChartSelections.crosshairShow: _ChartSelections.crossHairShowSettings,
      },
      tooltip: TooltipGuide(
        selections: {_ChartSelections.tooltipShow},
        followPointer: [false, false],
        renderer: (size, anchor, selectedTuples) {
          ColorScheme colorScheme = Theme.of(context).colorScheme;

          var values = selectedTuples.entries.firstOrNull?.value;
          double padding = 6;

          String repr = "";
          var maybeDate = values?[ControllerStateFields.date];
          if (maybeDate != null && maybeDate is DateTime) {
            repr += "Date: ";
            repr += [maybeDate.hour, maybeDate.minute, maybeDate.second]
                .map((v) => v.toString().padLeft(2, "0"))
                .join(":");
          }

          var targetTemperature =
              values?[ControllerStateFields.targetTemperature];
          if (targetTemperature != null && targetTemperature is num) {
            repr += "\nTarget temperature: ";
            repr += "${targetTemperature.toStringAsFixed(0)}°C";
          }

          var maybeTemperature =
              values?[ControllerStateFields.currentTemperature];
          if (maybeTemperature != null && maybeTemperature is num) {
            repr += "\nTemperature: ${maybeTemperature.toStringAsFixed(0)}°C";
          }

          var maybePower = values?[ControllerStateFields.power];
          if (maybePower != null && maybePower is num) {
            repr += "\nPower: ${maybePower.toStringAsFixed(0)}%";
          }

          LabelElement tooltipLabelGen(Offset offset, String text) =>
              LabelElement(
                defaultAlign: Alignment.topLeft,
                text: text,
                anchor: offset,
                style: LabelStyle(
                  textStyle: textTheme.labelMedium?.copyWith(
                    color: colorScheme.onInverseSurface,
                    backgroundColor: Colors.transparent,
                  ),
                ),
              );

          var offsetedAncher = anchor.translate(-2 * padding, -2 * padding);
          var textElement = tooltipLabelGen(
            offsetedAncher,
            repr,
          );
          var textRect = textElement.getBlock();
          if (textRect.left.isNegative) {
            textElement = tooltipLabelGen(
              offsetedAncher.translate(textRect.left.abs(), 0),
              repr,
            );
          }
          textRect = textElement.getBlock();

          var rectElement = RectElement(
            rect: textRect.inflate(padding),
            borderRadius: BorderRadius.all(Radius.circular(4)),
            style: PaintStyle(fillColor: colorScheme.inverseSurface),
          );

          return [rectElement, textElement];
        },
      ),
      crosshair: CrosshairGuide(
        selections: {_ChartSelections.crosshairShow},
        labelPaddings: const [8.0, 8.0],
        showLabel: const [true, true],
        followPointer: const [false, false],
        formatter: [
          // Date
          (val) {
            if (val is DateTime) {
              return [val.hour, val.minute, val.second]
                  .map((v) => v.toString().padLeft(2, "0"))
                  .join(":");
            }
            return val.toString();
          },
          // Temperature
          (val) {
            if (val is num) {
              return "${val.toStringAsFixed(2)}°C";
            }
            return val.toString();
          },
        ],
        labelStyles: [
          // Date
          LabelStyle(
            textStyle: textTheme.labelMedium?.copyWith(
              color: colorScheme.onInverseSurface,
              backgroundColor: Colors.transparent,
            ),
          ),
          // Temperature
          LabelStyle(
            offset: Offset(-4, 0),
            textStyle: textTheme.labelMedium?.copyWith(
              color: colorScheme.onInverseSurface,
              backgroundColor: Colors.transparent,
            ),
          ),
        ],
        labelBackgroundStyles: [
          PaintStyle(fillColor: colorScheme.inverseSurface),
          PaintStyle(fillColor: colorScheme.inverseSurface),
        ],
        styles: [
          PaintStyle(
            strokeColor: Color.fromRGBO(0, 0, 0, .25),
            strokeCap: StrokeCap.round,
            strokeWidth: 3,
          ),
          PaintStyle(
            strokeColor: Color.fromRGBO(0, 0, 0, .25),
            strokeCap: StrokeCap.round,
            strokeWidth: 3,
          ),
        ],
      ),
    );
  }
}

class ControllerStateFields {
  static const currentTemperature = "temperature";
  static const targetTemperature = "target_temperature";
  static const power = "power";
  static const date = "date";
}

class _ChartSelections {
  static const crosshairShow = "crosshair_show";
  static const tooltipShow = "tooltip_show";

  static final PointSelection crossHairShowSettings = PointSelection(
    on: {
      GestureType.hover,
      GestureType.scaleUpdate,
      GestureType.tapDown,
      GestureType.longPressMoveUpdate,
    },
    clear: {
      GestureType.mouseExit,
    },
    nearest: true,
    devices: {PointerDeviceKind.mouse},
    variable: 'date',
    dim: Dim.x,
  );

  static final PointSelection tooltipShowSettings = PointSelection(
    on: {
      GestureType.scaleUpdate,
      GestureType.tapDown,
      GestureType.longPressMoveUpdate,
    },
    clear: {
      GestureType.mouseExit,
      GestureType.scaleEnd,
    },
    nearest: true,
    devices: {PointerDeviceKind.mouse},
    variable: 'date',
    dim: Dim.x,
  );
}
