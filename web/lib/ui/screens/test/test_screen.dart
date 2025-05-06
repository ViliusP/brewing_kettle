import 'package:brew_kettle_dashboard/ui/common/better_range_slider/better_slider.dart';
import 'package:brew_kettle_dashboard/ui/common/better_range_slider/range.dart';
import 'package:brew_kettle_dashboard/ui/common/interactive_ink_response/widget_interaction_controller.dart';
import 'package:brew_kettle_dashboard/ui/common/interactive_ink_response/interactive_ink_response.dart';
import 'package:brew_kettle_dashboard/ui/common/utilities/number_text_to_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _FontTest(),
              Padding(padding: EdgeInsets.symmetric(vertical: 32)),
              Divider(),
              Text("Interactive Ink Response", style: TextTheme.of(context).headlineLarge),
              Padding(padding: EdgeInsets.symmetric(vertical: 8)),
              _InteractiveInkResponseTest(),
              Padding(padding: EdgeInsets.symmetric(vertical: 32)),
              Divider(),
              Text("Better Slider", style: TextTheme.of(context).headlineLarge),
              _BetterSliderPlayground(),
            ],
          ),
        ),
      ),
    );
  }
}

class _InteractiveInkResponseTest extends StatefulWidget {
  const _InteractiveInkResponseTest();

  @override
  State<_InteractiveInkResponseTest> createState() => _InteractiveInkResponseTestState();
}

class _InteractiveInkResponseTestState extends State<_InteractiveInkResponseTest> {
  final WidgetInteractionController interactionController = WidgetInteractionController();

  final formKey = GlobalKey<FormState>();
  final TextEditingController positionXFormFieldController = TextEditingController();
  final TextEditingController positionYFormFieldController = TextEditingController();
  final TextEditingController durationFormFieldController = TextEditingController();

  String lastAction = "none";

  void setLastAction(String value) {
    setState(() {
      lastAction = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 8,
          spacing: 16,
          children: [
            OutlinedButton(
              onPressed: () {
                interactionController.interact(const WidgetPress.tap());
              },
              style: OutlinedButton.styleFrom(textStyle: TextStyle(fontSize: 24)),
              child: Text("Simulate tap"),
            ),
            OutlinedButton(
              onPressed: () {
                interactionController.interact(const WidgetPress.long());
              },
              style: OutlinedButton.styleFrom(textStyle: TextStyle(fontSize: 24)),
              child: Text("Simulate long press"),
            ),
            OutlinedButton(
              onPressed: () {
                interactionController.interact(const WidgetPress(duration: Duration(seconds: 2)));
              },
              style: OutlinedButton.styleFrom(textStyle: TextStyle(fontSize: 24)),
              child: Text("Simulate custom duration press (2 second)"),
            ),
          ],
        ),
        Padding(padding: EdgeInsets.symmetric(vertical: 16)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: [
            OutlinedButton(
              onPressed: () {
                bool isFormInvalid = formKey.currentState?.validate() != true;
                if (isFormInvalid) return;

                String rawPositionX = positionXFormFieldController.text;
                double? positionX = double.tryParse(rawPositionX);
                if (positionX == null) return;

                String rawPositionY = positionYFormFieldController.text;
                double? positionY = double.tryParse(rawPositionY);
                if (positionY == null) return;

                String rawDurationInMs = durationFormFieldController.text;
                int? durationInMs = int.tryParse(rawDurationInMs);
                if (durationInMs == null) return;
                if (durationInMs.isNegative) return;
                if (durationInMs > 5000) return;
                interactionController.interact(
                  WidgetPress(
                    duration: Duration(milliseconds: durationInMs),
                    globalPosition: Offset(positionX, positionY),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(textStyle: TextStyle(fontSize: 24)),
              child: Text("Custom tap"),
            ),
            SizedBox(
              width: 300,
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 16,
                  children: [
                    TextFormField(
                      controller: positionXFormFieldController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        label: Text("Global position X"),
                      ),
                      validator: (rawValue) {
                        if (double.tryParse(rawValue ?? "") == null) return "Must be number";
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: positionYFormFieldController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        label: Text("Global position Y"),
                      ),
                      validator: (rawValue) {
                        if (double.tryParse(rawValue ?? "") == null) return "Must be number";
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: durationFormFieldController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        label: Text("Duration (in milliseconds)"),
                        helper: Text("Maximum value: 5000 ms"),
                      ),
                      validator: (rawValue) {
                        int? durationInMs = int.tryParse(rawValue ?? "");
                        if (durationInMs == null) return "Must be integer number";
                        if (durationInMs.isNegative) return "Must be positive number";
                        if (durationInMs > 5000) return "Must be smaller than 5000";
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        Padding(padding: EdgeInsets.symmetric(vertical: 8)),
        Material(
          elevation: 4,
          type: MaterialType.button,
          color: ColorScheme.of(context).primaryContainer,
          borderRadius: BorderRadius.all(Radius.circular(16)),
          clipBehavior: Clip.hardEdge,
          child: InteractiveInkResponse(
            splashColor: Colors.red,
            hoverColor: Colors.blueAccent,
            containedInkWell: true,
            highlightShape: BoxShape.rectangle,
            interactionController: interactionController,
            // onHover: (val) {
            //   setLastAction("onHover($val)");
            // },
            mouseCursor: SystemMouseCursors.click,
            onTap: () {
              setLastAction("onTap");
            },
            onLongPress: () {
              setLastAction("onLongPress");
            },
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(MdiIcons.abTesting, size: 32),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 4)),
                  Text(
                    "Interactive Ink Response Button",
                    style: TextTheme.of(context).labelLarge?.copyWith(fontSize: 32),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(padding: EdgeInsets.symmetric(vertical: 4)),
        Text("Last action: $lastAction", style: TextTheme.of(context).labelMedium),
      ],
    );
  }

  @override
  void dispose() {
    interactionController.dispose();
    positionXFormFieldController.dispose();
    positionYFormFieldController.dispose();
    durationFormFieldController.dispose();
    super.dispose();
  }
}

class _FontTest extends StatelessWidget {
  const _FontTest();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('FontWeight.w100', style: TextStyle(fontWeight: FontWeight.w100)),
        Text('FontWeight.w200', style: TextStyle(fontWeight: FontWeight.w200)),
        Text('FontWeight.w300', style: TextStyle(fontWeight: FontWeight.w300)),
        Text('FontWeight.w400', style: TextStyle(fontWeight: FontWeight.w400)),
        Text('FontWeight.w500', style: TextStyle(fontWeight: FontWeight.w500)),
        Text('FontWeight.w600', style: TextStyle(fontWeight: FontWeight.w600)),
        Text('FontWeight.w700', style: TextStyle(fontWeight: FontWeight.w700)),
        Text('FontWeight.w800', style: TextStyle(fontWeight: FontWeight.w800)),
        Text('FontWeight.w900', style: TextStyle(fontWeight: FontWeight.w900)),
        Divider(),
        Text(
          'FontWght 100',
          style: TextStyle(
            fontWeight: FontWeight.w100,
            fontVariations: [FontVariation('wght', 100)],
          ),
        ),
        Text(
          'FontWght 200',
          style: TextStyle(
            fontWeight: FontWeight.w200,
            fontVariations: [FontVariation('wght', 200)],
          ),
        ),
        Text(
          'FontWght 300',
          style: TextStyle(
            fontWeight: FontWeight.w300,
            fontVariations: [FontVariation('wght', 300)],
          ),
        ),
        Text(
          'FontWght 400',
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontVariations: [FontVariation('wght', 400)],
          ),
        ),
        Text(
          'FontWght 500',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontVariations: [FontVariation('wght', 500)],
          ),
        ),
        Text(
          'FontWght 600',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontVariations: [FontVariation('wght', 600)],
          ),
        ),
        Text(
          'FontWght 700',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontVariations: [FontVariation('wght', 700)],
          ),
        ),
        Text(
          'FontWght 800',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontVariations: [FontVariation('wght', 800)],
          ),
        ),
        Text(
          'FontWght 900',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontVariations: [FontVariation('wght', 900)],
          ),
        ),
      ],
    );
  }
}

class _BetterSliderPlayground extends StatefulWidget {
  const _BetterSliderPlayground();

  @override
  State<_BetterSliderPlayground> createState() => __BetterSliderPlaygroundState();
}

class __BetterSliderPlaygroundState extends State<_BetterSliderPlayground> {
  double value0 = 50;
  double value1 = 25.5;
  double value2 = 2;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SliderUnit(
          number: 0,
          slider: Slider(
            min: 2,
            max: 100,
            value: value0,
            onChanged: (double value) {
              setState(() {
                value0 = value;
              });
            },
          ),
        ),
        _SliderUnit(
          number: 10,
          slider: BetterSlider(
            onChanged: (double value) {
              value1 = value;
              setState(() {});
            },
            limits: NumericalRange(-100, 100),
            value: value1,
          ),
          description: "Enabled, controllable (-100;100)",
        ),
        _SliderUnit(
          number: 1,
          slider: BetterSlider(onChanged: (_) {}, limits: NumericalRange(2, 100), value: value0),
          description: "Enabled, synchronious with 0th slider.",
        ),
        _SliderUnit(
          number: 2,
          slider: BetterSlider(onChanged: (_) {}, limits: NumericalRange(0, 100), value: 50),
          description: "Enabled, const value in center",
        ),
        _SliderUnit(
          number: 3,
          slider: BetterSlider(onChanged: (_) {}, value: 0, limits: NumericalRange<double>(0, 100)),
          description: "Enabled, min const value.",
        ),
        _SliderUnit(
          number: 4,
          slider: BetterSlider(onChanged: (_) {}, value: 100, limits: NumericalRange(0, 100)),
          description: "Enabled, max const value.",
        ),
        _SliderUnit(
          number: 5,
          slider: BetterSlider(onChanged: null, limits: NumericalRange(0, 100), value: 50),
          description: "Disabled, const value in center",
        ),
        _SliderUnit(
          number: 6,
          slider: BetterSlider(onChanged: null, value: 0, limits: NumericalRange<double>(0, 100)),
          description: "Disabled, min const value.",
        ),
        _SliderUnit(
          number: 7,
          slider: BetterSlider(onChanged: null, value: 100, limits: NumericalRange(0, 100)),
          description: "Disabled, max const value.",
        ),
      ],
    );
  }
}

class _SliderUnit extends StatelessWidget {
  final Widget slider;
  final int number;
  final String description;

  const _SliderUnit({required this.slider, required this.number, this.description = ""});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (description.isNotEmpty) ...[
          Padding(padding: EdgeInsets.symmetric(vertical: 8)),
          Text(description, style: TextTheme.of(context).labelSmall),
          Padding(padding: EdgeInsets.symmetric(vertical: 1)),
        ],
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 16),
              child: Text(
                numberTextToIcons(number),
                style: TextTheme.of(context).labelSmall?.copyWith(fontSize: 8),
              ),
            ),
            Expanded(child: slider),
          ],
        ),
      ],
    );
  }
}
