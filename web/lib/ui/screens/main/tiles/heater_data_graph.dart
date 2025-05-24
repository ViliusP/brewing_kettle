import 'dart:ui';

import 'package:brew_kettle_dashboard/core/data/models/timeseries/timeseries.dart';
import 'package:brew_kettle_dashboard/core/service_locator.dart';
import 'package:brew_kettle_dashboard/localizations/localization.dart';
import 'package:brew_kettle_dashboard/stores/heater_controller_state/heater_controller_state_store.dart';
import 'package:brew_kettle_dashboard/ui/common/drawer_menu/drawer_menu.dart';
import 'package:brew_kettle_dashboard/ui/screens/main/tiles/heater_graph_settings_menu.dart';
import 'package:brew_kettle_dashboard/ui/screens/main/tiles/history_graph_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:graphic/graphic.dart';

class HeaterDataGraph extends StatefulWidget {
  const HeaterDataGraph({super.key});

  @override
  State<HeaterDataGraph> createState() => _HeaterDataGraphState();
}

class _HeaterDataGraphState extends State<HeaterDataGraph> {
  final HeaterControllerStateStore _temperatureStore = getIt<HeaterControllerStateStore>();

  bool _showInfo = false;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = ColorScheme.of(context);

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 16.0, top: 16.0, bottom: 8.0),
          child: Observer(
            builder: (context) {
              final List<TimeSeriesViewEntry> temperatureHistory = _temperatureStore.stateHistory;
              if (temperatureHistory.length < 2) return _HeaterDataChart(data: []);
              return _HeaterDataChart(data: temperatureHistory);
            },
          ),
        ),
        Positioned.fill(
          child: AnimatedSwitcher(
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            duration: Durations.medium2,
            child: switch (_showInfo) {
              true => SizedBox(
                key: Key("_showInfo = true"),
                child: ColoredBox(
                  color: colorScheme.surface,
                  child: Center(child: const HistoryGraphInfo()),
                ),
              ),
              false => SizedBox.shrink(key: Key("_showInfo = false")),
            },
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Align(
            alignment: Alignment.topRight,
            child: _HeaterChartControlButtons(
              onInfoHover: (value) {
                setState(() {
                  _showInfo = value;
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaterDataChart extends StatelessWidget {
  final List<TimeSeriesViewEntry> data;

  const _HeaterDataChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = TextTheme.of(context);
    final localizations = AppLocalizations.of(context)!;

    var convertedData =
        data
            .map(
              (e) => {
                _ControllerStateFields.date: e.date,
                _ControllerStateFields.currentTemperature: e.value?['current_temperature'] ?? 0,
                _ControllerStateFields.targetTemperature: e.value?['target_temperature'] ?? 0,
                _ControllerStateFields.power: e.value?['power'] ?? 0,
              },
            )
            .toList();

    // Graphics library cannot be used with empty data, so it will be added when
    // provided data is empty.
    if (data.isEmpty) {
      convertedData.add({
        _ControllerStateFields.date: DateTime.now(),
        _ControllerStateFields.currentTemperature: 0,
        _ControllerStateFields.targetTemperature: 0,
        _ControllerStateFields.power: 0,
      });
    }

    return MouseRegion(
      cursor: SystemMouseCursors.precise,
      child: Chart(
        padding: (_) => const EdgeInsets.fromLTRB(50, 8, 24, 24),
        // Another quirk of graphics library, if data changes from default to store's,
        // axes won't rebuild itself.
        rebuild: data.length == 2 ? true : false,
        data: convertedData,
        variables: {
          _ControllerStateFields.date: Variable(
            accessor: (Map map) => map[_ControllerStateFields.date] as DateTime,
            scale: TimeScale(
              min: data.isEmpty ? DateTime.now().subtract(Duration(hours: 1)) : null,
              max: data.isEmpty ? DateTime.now() : null,
              marginMin: data.isNotEmpty ? 0 : null,
              marginMax: data.isNotEmpty ? 0 : null,
              tickCount: 3,
              formatter: (d) {
                String hours = d.hour.toString().padLeft(2, '0');
                String minutes = d.minute.toString().padLeft(2, '0');
                String seconds = d.second.toString().padLeft(2, '0');
                return '$hours:$minutes:$seconds';
              },
            ),
          ),
          _ControllerStateFields.currentTemperature: Variable(
            accessor: (Map map) => map[_ControllerStateFields.currentTemperature] as num,
            scale: LinearScale(
              min: 0,
              max: 105,
              tickCount: 7,
              formatter: (v) => v.toStringAsFixed(1),
            ),
          ),
          _ControllerStateFields.targetTemperature: Variable(
            accessor: (Map map) => map[_ControllerStateFields.targetTemperature] as num,
            scale: LinearScale(min: 0, max: 105, formatter: (v) => v.toStringAsFixed(1)),
          ),
          _ControllerStateFields.power: Variable(
            accessor: (Map map) => map[_ControllerStateFields.power] as num,
            scale: LinearScale(min: 0, max: 100, formatter: (v) => v.toStringAsFixed(1)),
          ),
        },
        marks: [
          LineMark(
            position:
                Varset(_ControllerStateFields.date) *
                Varset(_ControllerStateFields.currentTemperature),
            shape: ShapeEncode(value: BasicLineShape(smooth: true)),
            size: SizeEncode(value: 3),
            color: ColorEncode(value: colorScheme.outline),
          ),
          LineMark(
            position:
                Varset(_ControllerStateFields.date) *
                Varset(_ControllerStateFields.targetTemperature),
            size: SizeEncode(value: 2),
            color: ColorEncode(value: colorScheme.error.withAlpha(96)),
            shape: ShapeEncode(value: BasicLineShape(dash: [24, 2])),
          ),
          LineMark(
            position: Varset(_ControllerStateFields.date) * Varset(_ControllerStateFields.power),
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
            label: LabelStyle(textStyle: textTheme.labelMedium, offset: const Offset(0, 7.5)),
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
                _ => LabelStyle(textStyle: textTheme.labelMedium, offset: const Offset(-10, 0)),
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
                ),
              };
            },
            gridMapper: (_, index, __) {
              return switch (index) {
                0 => null,
                _ => PaintStyle(
                  strokeWidth: 1,
                  strokeColor: colorScheme.outline.withAlpha(35),
                  strokeCap: StrokeCap.round,
                ),
              };
            },
          ),
        ],
        selections: {
          _ChartSelections.tooltipShow: _ChartSelections.tooltipShowSettings,
          _ChartSelections.crosshairShow: _ChartSelections.crossHairShowSettings,
        },
        // TODO: fix tooltip when top data point is selected.
        tooltip: TooltipGuide(
          selections: {_ChartSelections.tooltipShow},
          followPointer: [false, false],
          renderer: (size, anchor, selectedTuples) {
            ColorScheme colorScheme = Theme.of(context).colorScheme;

            var values = selectedTuples.entries.firstOrNull?.value;
            double padding = 6;

            String repr = "";
            var maybeDate = values?[_ControllerStateFields.date];
            if (maybeDate != null && maybeDate is DateTime) {
              repr += "${localizations.generalDate}: ";
              repr += [
                maybeDate.hour,
                maybeDate.minute,
                maybeDate.second,
              ].map((v) => v.toString().padLeft(2, "0")).join(":");
            }

            var targetTemperature = values?[_ControllerStateFields.targetTemperature];
            if (targetTemperature != null && targetTemperature is num) {
              repr += "\n${localizations.generalTargetTemperature}: ";
              repr += "${targetTemperature.toStringAsFixed(0)}°C";
            }

            var maybeTemperature = values?[_ControllerStateFields.currentTemperature];
            if (maybeTemperature != null && maybeTemperature is num) {
              repr += "\n${localizations.generalTemperature}: ";
              repr += "${maybeTemperature.toStringAsFixed(0)}°C";
            }

            var maybePower = values?[_ControllerStateFields.power];
            if (maybePower != null && maybePower is num) {
              repr += "\n${localizations.generalPower}: ";
              repr += "${maybePower.toStringAsFixed(0)}%";
            }

            LabelElement tooltipLabelGen(Offset offset, String text) => LabelElement(
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
            var textElement = tooltipLabelGen(offsetedAncher, repr);
            var textRect = textElement.getBlock();
            if (textRect.left.isNegative) {
              textElement = tooltipLabelGen(offsetedAncher.translate(textRect.left.abs(), 0), repr);
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
                return [
                  val.hour,
                  val.minute,
                  val.second,
                ].map((v) => v.toString().padLeft(2, "0")).join(":");
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
      ),
    );
  }
}

class _ControllerStateFields {
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
    clear: {GestureType.mouseExit},
    nearest: true,
    devices: {PointerDeviceKind.mouse},
    variable: 'date',
    dim: Dim.x,
  );

  static final PointSelection tooltipShowSettings = PointSelection(
    on: {GestureType.scaleUpdate, GestureType.tapDown, GestureType.longPressMoveUpdate},
    clear: {GestureType.mouseExit, GestureType.scaleEnd},
    nearest: true,
    devices: {PointerDeviceKind.mouse},
    variable: 'date',
    dim: Dim.x,
  );
}

class _HeaterChartControlButtons extends StatefulWidget {
  final Function(bool)? onInfoHover;

  const _HeaterChartControlButtons({this.onInfoHover});

  @override
  State<_HeaterChartControlButtons> createState() => _HeaterChartControlButtonsState();
}

class _HeaterChartControlButtonsState extends State<_HeaterChartControlButtons> {
  bool drawerOpened = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          style: ButtonStyle(
            splashFactory: NoSplash.splashFactory,
            overlayColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
              if (states.contains(WidgetState.pressed)) {
                return const Color.fromARGB(0, 0, 0, 0);
              }
              return null; // Use the component's default.
            }),
          ),
          onPressed: () {},
          icon: Icon(MdiIcons.helpCircleOutline, size: 32),
          mouseCursor: SystemMouseCursors.help,
          onHover: widget.onInfoHover,
        ),
        IconButton(
          onPressed: () {
            if (drawerOpened) return;

            drawerOpened = true;
            DrawerMenu.show(
              context: context,
              drawerOptions: DrawerRouteOptions(dragToDismiss: true),
              builder: (context) => HeaterGraphSettingsMenu(),
            ).then((_) {
              if (mounted) {
                drawerOpened = false;
              }
            });
          },
          icon: Icon(MdiIcons.dotsVerticalCircleOutline),
          iconSize: 32,
        ),
      ],
    );
  }
}
