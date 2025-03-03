import 'package:brew_kettle_dashboard/ui/common/flags/gb_flag_painter.dart';
import 'package:brew_kettle_dashboard/ui/common/flags/lt_flag_painter.dart';
import 'package:brew_kettle_dashboard/ui/common/flags/lv_flag_painter.dart';
import 'package:flutter/material.dart';

enum CountryCode {
  lt,
  gb,
  lv;

  static CountryCode fromLanguageCode(String value) {
    return switch (value) {
      "en" => CountryCode.gb,
      "lt" => CountryCode.lt,
      _ => CountryCode.lv,
    };
  }
}

class CountryFlag extends StatelessWidget {
  final CountryCode code;

  CustomPainter get painter => switch (code) {
    CountryCode.lt => LtFlagPainter(),
    CountryCode.gb => GbFlagPainter(),
    CountryCode.lv => LvFlagPainter(),
  };

  double get aspectRatio => switch (code) {
    CountryCode.lt => 5 / 3,
    CountryCode.gb => 2 / 1,
    CountryCode.lv => 2 / 1,
  };

  const CountryFlag({super.key, required this.code});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(aspectRatio: aspectRatio, child: CustomPaint(painter: painter));
  }
}
