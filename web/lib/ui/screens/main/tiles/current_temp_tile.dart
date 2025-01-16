import 'package:brew_kettle_dashboard/ui/common/arc_slider/arc_slider.dart';
import 'package:flutter/material.dart';

class CurrentTempTile extends StatefulWidget {
  const CurrentTempTile({super.key});

  @override
  State<CurrentTempTile> createState() => _CurrentTempTileState();
}

class _CurrentTempTileState extends State<CurrentTempTile> {
  double currentTemp = 0;
  double targetTemp = 0;

  @override
  Widget build(BuildContext context) {
    Color primary = Theme.of(context).colorScheme.primary.withOpacity(0.54);
    Color secondary = Theme.of(context).colorScheme.primary;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Slider(
        //   activeColor: primary,
        //   secondaryActiveColor: secondary,
        //   secondaryTrackValue: currentTemp,
        //   // allowedInteraction: SliderInteraction.slideOnly
        //   min: 0,
        //   max: 100,
        //   value: targetTemp,
        //   onChanged: (double value) {
        //     setState(() {
        //       targetTemp = value;
        //     });
        //   },
        // ),

        RepaintBoundary(
          child: ArcSlider(
            min: 0,
            max: 100,
            value: targetTemp,
            secondaryValue: 3,
            onChanged: (double value) {
              setState(() {
                targetTemp = value;
              });
            },
          ),
        ),
        // ArcSlider2(
        //   numberOfSegments: 10,
        //   segmentDividerColor: Colors.transparent,
        //   segmentDividerWidth: 0,
        //   padding: EdgeInsets.zero,
        //   focusedMargin: EdgeInsets.zero,
        // ),
      ],
    );
  }
}
