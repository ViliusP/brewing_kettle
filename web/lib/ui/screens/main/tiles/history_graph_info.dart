import 'package:flutter/material.dart';

class HistoryGraphInfo extends StatelessWidget {
  const HistoryGraphInfo({super.key});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = TextTheme.of(context);

    const Duration dataInterval = Duration(seconds: 30);
    const Duration dataRange = Duration(seconds: 30 * 200);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Shows heater data of every ${dataInterval.inSeconds} seconds, for ${dataRange.inHours} hours.",
          style: textTheme.bodyLarge,
        ),
        Text(
          "Tap on graph points to see concrete values for that time.",
          style: textTheme.bodyLarge,
        ),
        Padding(padding: EdgeInsets.symmetric(vertical: 8)),
        Text("Line legend:", style: textTheme.headlineLarge),
        Padding(padding: EdgeInsets.symmetric(vertical: 2)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 12,
          children: [
            SizedBox(
              width: 32,
              height: 4,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.blueGrey,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
              ),
            ),
            Text("Current temp", style: textTheme.bodyLarge),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 12,
          children: [
            SizedBox(
              width: 32,
              height: 4,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
              ),
            ),
            Text("Target temperature", style: textTheme.bodyLarge),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 12,
          children: [
            SizedBox(
              width: 32,
              height: 4,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.amberAccent,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
              ),
            ),
            Text("Power", style: textTheme.bodyLarge),
          ],
        ),
      ],
    );
  }
}
