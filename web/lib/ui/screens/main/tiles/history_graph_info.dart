import 'package:brew_kettle_dashboard/localizations/localization.dart';
import 'package:flutter/material.dart';

class HistoryGraphInfo extends StatelessWidget {
  const HistoryGraphInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final TextTheme textTheme = TextTheme.of(context);

    const Duration dataInterval = Duration(seconds: 30);
    const Duration dataRange = Duration(seconds: 30 * 200);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(localizations.pMainGraphInfoTitle, style: textTheme.headlineLarge),
        Padding(padding: EdgeInsets.symmetric(vertical: 2)),
        Text(
          localizations.pMainGraphInfoText(
            dataInterval.inSeconds,
            dataRange.inHours,
          ),
          style: textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        Padding(padding: EdgeInsets.symmetric(vertical: 8)),
        Text(
          localizations.pMainGraphInfoLegend,
          style: textTheme.headlineMedium,
        ),
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
