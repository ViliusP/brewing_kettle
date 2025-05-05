import 'package:brew_kettle_dashboard/ui/common/interactive_ink_response/widget_interaction_controller.dart';
import 'package:brew_kettle_dashboard/ui/common/interactive_ink_response/interactive_ink_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Text Weights')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _FontTest(),
            Padding(padding: EdgeInsets.symmetric(vertical: 32)),
            Divider(),
            Text("Interactive Ink Response", style: TextTheme.of(context).headlineLarge),
            Padding(padding: EdgeInsets.symmetric(vertical: 8)),
            _InteractiveInkResponseTest(),
          ],
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
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
