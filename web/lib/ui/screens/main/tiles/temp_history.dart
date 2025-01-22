import 'dart:math';

import 'package:brew_kettle_dashboard/core/service_locator.dart';
import 'package:brew_kettle_dashboard/stores/temperature/temperature_store.dart';
import 'package:brew_kettle_dashboard/utils/list_extensions.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

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
        List<FlSpot> points = _temperatureStore.tempHistory
            .takeLast(100)
            .map((e) => FlSpot(e.timestamp.toDouble(), e.temp))
            .toList();
        return TempHistoryChart(
          spots: points,
        );
      }),
    );
  }

  List<FlSpot> generateRandomPoints(int count) {
    List<FlSpot> points = [];
    final random = Random(15);
    for (int i = 0; i <= count; i++) {
      points.add(FlSpot(i.toDouble(), random.nextDouble() * 120));
    }
    return points;
  }

  List<FlSpot> generateNormalDistributionPoints(int count) {
    List<FlSpot> points = [];
    final random = Random(15);
    for (int i = 0; i <= count; i++) {
      double x = i.toDouble();
      double y = _generateNormalRandomValue(
        60,
        20,
        random,
      ); // mean = 60, stddev = 15
      points.add(FlSpot(x, y));
    }
    return points;
  }

  double _generateNormalRandomValue(double mean, double stddev, Random random) {
    // Using Box-Muller transform to generate a normally distributed value
    double u1 = random.nextDouble();
    double u2 = random.nextDouble();
    double z0 = sqrt(-2.0 * log(u1)) * cos(2.0 * pi * u2);
    return z0 * stddev + mean;
  }
}

class TempHistoryChart extends StatelessWidget {
  final List<FlSpot> spots;

  const TempHistoryChart({super.key, required this.spots});

  @override
  Widget build(BuildContext context) {
    Color borderColor = Theme.of(context).colorScheme.outline;
    Color dataLineColor = Theme.of(context).colorScheme.tertiary;
    Color tooltipBackgroundColor = Theme.of(context).colorScheme.inverseSurface;

    List<LineTooltipItem> lineTooltipItem(List<LineBarSpot> touchedSpots) =>
        touchedSpots.map((LineBarSpot spot) {
          DateTime date = DateTime.fromMillisecondsSinceEpoch(
            spot.x.toInt() * 1000,
          ).toLocal();

          String labelX =
              "${date.hour}:${date.minute}:${date.second.toString().padLeft(2, "0")}";

          final textStyle = TextTheme.of(context).bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onInverseSurface,
                  ) ??
              TextStyle();
          return LineTooltipItem(
            "${spot.y.toStringAsFixed(1)} °C\n$labelX",
            textStyle,
          );
        }).toList();

    List<TouchedSpotIndicatorData?> touchedSpotIndicator(
      LineChartBarData barData,
      List<int> spotIndexes,
    ) {
      return spotIndexes.map((index) {
        return TouchedSpotIndicatorData(
          FlLine(
            color: Theme.of(context).colorScheme.outlineVariant,
            strokeWidth: 2,
            dashArray: [5, 5],
          ),
          FlDotData(
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 2,
                color: Colors.transparent,
                strokeWidth: 3,
                strokeColor: Theme.of(context).colorScheme.outline,
              );
            },
          ),
        );
      }).toList();
    }

    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          handleBuiltInTouches: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => tooltipBackgroundColor,
            getTooltipItems: lineTooltipItem,
          ),
          getTouchedSpotIndicator: touchedSpotIndicator,
        ),
        borderData: FlBorderData(
          border: Border.all(
            width: 2,
            color: borderColor,
          ),
        ),
        clipData: FlClipData.all(),
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          verticalInterval: 10,
          horizontalInterval: 10,
          getDrawingVerticalLine: (value) {
            return const FlLine(
              color: Color.fromARGB(0, 0, 0, 0),
              strokeWidth: 0,
            );
          },
          getDrawingHorizontalLine: (value) {
            return const FlLine(
              color: Color.fromARGB(35, 0, 0, 0),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) => BottomAxisTickLabel(
                value,
                meta,
              ),
              interval: 10,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) => LeftAxisTickLabel(
                value,
                meta,
              ),
              reservedSize: 42,
              interval: 10,
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        minX: spots.firstOrNull?.x ?? 0.0,
        maxX: spots.lastOrNull?.x ?? 0.0,
        minY: 0,
        maxY: 110,
        lineBarsData: <LineChartBarData>[
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: .5,
            dotData: const FlDotData(show: false),
            preventCurveOverShooting: true,
            preventCurveOvershootingThreshold: 5,
            color: dataLineColor,
            barWidth: 3,
          ),
        ],
        // read about it in the LineChartData section
      ),
      duration: Duration(milliseconds: 150), // Optional
      curve: Curves.linear, // Optional
    );
  }
}

class LeftAxisTickLabel extends StatelessWidget {
  final double value;
  final TitleMeta chartTitleProperties;

  const LeftAxisTickLabel(
    this.value,
    this.chartTitleProperties, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    String label = chartTitleProperties.formattedValue;

    bool isLast = chartTitleProperties.max == value;

    if (isLast) {
      return Padding(
        padding: const EdgeInsets.only(right: 6.0),
        child: Align(
          alignment: Alignment.centerRight,
          child: Icon(
            MdiIcons.temperatureCelsius,
            size: 16,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Text(
        label,
        style: TextTheme.of(context).labelLarge,
        textAlign: TextAlign.right,
      ),
    );
  }
}

class BottomAxisTickLabel extends StatelessWidget {
  final double value;
  final TitleMeta chartTitleProperties;

  const BottomAxisTickLabel(
    this.value,
    this.chartTitleProperties, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(
      value.toInt() * 1000,
    ).toLocal();

    bool isLast = chartTitleProperties.max == value;

    if (isLast) {
      return Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Align(
          alignment: Alignment.centerRight,
          child: Icon(
            MdiIcons.clockOutline,
            size: 16,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 6.5),
      child: Text(
        "${date.hour}:${date.minute}",
        style: TextTheme.of(context).labelLarge,
      ),
    );
  }
}
