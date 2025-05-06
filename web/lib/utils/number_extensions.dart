import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';

extension IntegerExtensions on int {
  String toIconCodePoints() {
    String stringInt = toString();

    String text = "";
    for (int i = 0; i < stringInt.length; i++) {
      MdiIcons? icon = switch (stringInt[i]) {
        "-" => MdiIcons.minus,
        "0" => MdiIcons.numeric0,
        "1" => MdiIcons.numeric1,
        "2" => MdiIcons.numeric2,
        "3" => MdiIcons.numeric3,
        "4" => MdiIcons.numeric4,
        "5" => MdiIcons.numeric5,
        "6" => MdiIcons.numeric6,
        "7" => MdiIcons.numeric7,
        "8" => MdiIcons.numeric8,
        "9" => MdiIcons.numeric9,
        _ => null,
      };
      if (icon != null) {
        String char = String.fromCharCode(icon.codePoint);
        if (text.isNotEmpty) text += " ";
        text += char;
      }
    }
    return text;
  }
}
