import 'package:brew_kettle_dashboard/utils/textstyle_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';

class TargetTempTile extends StatelessWidget {
  const TargetTempTile({super.key});

  final double temperature = 64;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              Spacer(),
              Row(
                children: [
                  Spacer(),
                  Text("$temperature",
                      style: Theme.of(context)
                          .textTheme
                          .displayMedium
                          ?.changeWeight(FontWeight.w800)),
                  Icon(
                    MdiIcons.temperatureCelsius,
                    size: 54,
                  ),
                  Spacer(),
                ],
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text(
                      "Tikslo temperatūra",
                      style: TextTheme.of(context).labelLarge,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12.0,
          ),
          child: VerticalDivider(
            indent: 12,
            endIndent: 12,
            width: 0,
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () {},
              icon: Icon(MdiIcons.arrowUpDropCircleOutline),
              iconSize: 60,
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(MdiIcons.arrowDownDropCircleOutline),
              iconSize: 60,
            )
          ],
        ),
        const Padding(padding: EdgeInsets.only(left: 12)),
      ],
    );
  }
}
