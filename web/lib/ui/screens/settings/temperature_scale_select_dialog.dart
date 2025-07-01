import 'package:brew_kettle_dashboard/core/data/models/common/temperature_scale.dart';
import 'package:brew_kettle_dashboard/localizations/localization.dart';
import 'package:brew_kettle_dashboard/ui/screens/utilities.dart';
import 'package:flutter/material.dart';

class TemperatureScaleSelectDialog extends StatelessWidget {
  final TemperatureScale? currentScale;

  const TemperatureScaleSelectDialog({super.key, this.currentScale});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(localizations.temperatureScaleDialogTitle),
      content: SizedBox(
        width: 260,
        child: ListView.builder(
          shrinkWrap: true,
          primary: false,
          itemCount: TemperatureScale.values.length,
          itemBuilder: (BuildContext context, int index) {
            final TemperatureScale scale = TemperatureScale.values[index];

            return ListTile(
              selected: scale == currentScale,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
              leading: Icon(scale.icon),
              title: Text(localizations.temperatureUnit(scale.name)),
              onTap: () => Navigator.of(context).pop(scale),
            );
          },
        ),
      ),
    );
  }
}
