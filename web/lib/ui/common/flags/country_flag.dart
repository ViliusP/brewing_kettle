import 'package:brew_kettle_dashboard/ui/common/flags/gb_flag_painter.dart';
import 'package:brew_kettle_dashboard/ui/common/flags/lt_flag_painter.dart';
import 'package:flutter/material.dart';

enum CountryCode {
  lt,
  gb;
}

class CountryFlag extends StatelessWidget {
  final CountryCode code;

  CustomPainter get painter => switch (code) {
        CountryCode.lt => LtFlagPainter(),
        CountryCode.gb => GbFlagPainter(),
      };

  const CountryFlag({super.key, required this.code});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: painter,
    );
  }
}
