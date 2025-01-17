import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class TempHistoryTile extends StatelessWidget {
  const TempHistoryTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 8.0,
        right: 16.0,
        top: 16.0,
        bottom: 8.0,
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawHorizontalLine: true,
            verticalInterval: 10,
            horizontalInterval: 10,
            getDrawingVerticalLine: (value) {
              return const FlLine(
                color: Color.fromARGB(30, 0, 0, 0),
                strokeWidth: 1,
              );
            },
            getDrawingHorizontalLine: (value) {
              return const FlLine(
                color: Color.fromARGB(30, 0, 0, 0),
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
                // getTitlesWidget: bottomTitleWidgets,
                interval: 10,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) => LeftAxisTickLabel(value),
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
          minX: 0,
          maxX: 90,
          minY: 0,
          maxY: 120,
          lineBarsData: <LineChartBarData>[
            LineChartBarData(
              spots: generateNormalDistributionPoints(90),
              isCurved: true,
              curveSmoothness: 0.1,
              dotData: const FlDotData(show: false),
            )
          ],
          // read about it in the LineChartData section
        ),
        duration: Duration(milliseconds: 150), // Optional
        curve: Curves.linear, // Optional
      ),
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

class LeftAxisTickLabel extends StatelessWidget {
  final double value;
  final TitleMeta? chartTitleProperties;

  const LeftAxisTickLabel(
    this.value, {
    super.key,
    this.chartTitleProperties,
  });

  @override
  Widget build(BuildContext context) {
    return Text(value.toString());
  }
}
