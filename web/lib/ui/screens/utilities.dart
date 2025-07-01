import 'package:brew_kettle_dashboard/core/data/models/common/temperature_scale.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';

extension TemperatureScaleIcon on TemperatureScale {
  IconData get icon => switch (this) {
    TemperatureScale.celsius => MdiIcons.temperatureCelsius,
    TemperatureScale.fahrenheit => MdiIcons.temperatureFahrenheit,
    TemperatureScale.kelvin => MdiIcons.temperatureKelvin,
  };
}
