import 'dart:ui';

import 'package:brew_kettle_dashboard/ui/common/code_view/json/definition.dart';
import 'package:flutter/material.dart';

class JsonHighlightingTheme {
  final double lineHeight;
  final JsonTokenColors tokenColors;

  const JsonHighlightingTheme({required this.tokenColors, required this.lineHeight});

  const JsonHighlightingTheme.materialThemeDarker()
    : tokenColors = const JsonTokenColors.materialThemeDarker(),
      lineHeight = 1.5;

  const JsonHighlightingTheme.catpucinLatte()
    : tokenColors = const JsonTokenColors.catpucinLatte(),
      lineHeight = 1.5;
}

class JsonTokenColors {
  final Color stringValue;
  final Color booleanValue;
  final Color numericValue;
  final Color nullValue;
  final Color punctuation;
  final Color key;

  const JsonTokenColors({
    required this.stringValue,
    required this.booleanValue,
    required this.numericValue,
    required this.nullValue,
    required this.punctuation,
    required this.key,
  });

  const JsonTokenColors.materialThemeDarker()
    : stringValue = const Color.fromARGB(255, 196, 232, 141),
      booleanValue = const Color.fromARGB(255, 254, 100, 11),
      numericValue = const Color.fromARGB(255, 254, 100, 11),
      nullValue = const Color.fromARGB(255, 254, 100, 11),
      punctuation = const Color.fromARGB(255, 137, 221, 255),
      key = const Color.fromARGB(255, 199, 146, 234);

  const JsonTokenColors.catpucinLatte()
    : stringValue = const Color.fromARGB(255, 64, 160, 43),
      booleanValue = const Color.fromARGB(255, 137, 221, 255),
      numericValue = const Color.fromARGB(255, 247, 140, 108),
      nullValue = const Color.fromARGB(255, 137, 221, 255),
      punctuation = const Color.fromARGB(255, 124, 127, 147),
      key = const Color.fromARGB(255, 30, 102, 245);

  Color? tokenTypeToColor(JsonTokenType type) {
    return switch (type) {
      JsonTokenType.key => key,
      JsonTokenType.keyQuote => punctuation,
      JsonTokenType.objectBracket => punctuation,
      JsonTokenType.valueQuote => punctuation,
      JsonTokenType.valueNumber => numericValue,
      JsonTokenType.valueBool => booleanValue,
      JsonTokenType.valueString => stringValue,
      JsonTokenType.valueNull => nullValue,
      JsonTokenType.colon => punctuation,
      JsonTokenType.comma => punctuation,
      JsonTokenType.punctuation => punctuation,
      JsonTokenType.whitespace => null,
    };
  }
}
