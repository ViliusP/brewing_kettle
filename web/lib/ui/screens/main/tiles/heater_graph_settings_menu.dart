import 'package:brew_kettle_dashboard/constants/app.dart';
import 'package:brew_kettle_dashboard/core/data/models/timeseries/timeseries.dart';
import 'package:brew_kettle_dashboard/core/service_locator.dart';
import 'package:brew_kettle_dashboard/localizations/localization.dart';
import 'package:brew_kettle_dashboard/stores/heater_controller_state/heater_controller_state_store.dart';

import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';

class HeaterGraphSettingsMenu extends StatelessWidget {
  const HeaterGraphSettingsMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    final TextTheme textTheme = TextTheme.of(context);

    return Material(
      elevation: 8.0,
      child: Container(
        width: 350, // Example width
        color: Theme.of(context).canvasColor, // Or your desired background
        child: Column(
          children: <Widget>[
            Padding(padding: EdgeInsets.symmetric(vertical: 8)),
            Text("Graph controls", style: TextTheme.of(context).displaySmall),
            Padding(padding: EdgeInsets.symmetric(vertical: 8)),
            _GraphRangeSelect(),
            Divider(indent: 8, endIndent: 8),
            _AggregationOptions(),
            Spacer(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: FilledButton.tonalIcon(
                icon: Icon(AppConstants.backIcon),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size.fromHeight(48),
                  textStyle: textTheme.labelLarge?.copyWith(fontSize: 18),
                  iconSize: 18,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                label: Text(localizations.generalGoBack),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GraphRangeSelect extends StatefulWidget {
  const _GraphRangeSelect();

  @override
  State<_GraphRangeSelect> createState() => _GraphRangeSelectState();
}

class _GraphRangeSelectState extends State<_GraphRangeSelect> {
  RangeValues _currentRangeValues = const RangeValues(0.0, 1.0);
  bool switchValue = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SwitchListTile(
          value: switchValue,
          onChanged: (bool? value) {
            if (value == null) return;
            setState(() {
              switchValue = value;
            });
          },
          title: Text("Lock"),
        ),
        SliderTheme(
          data: SliderThemeData(showValueIndicator: ShowValueIndicator.onlyForContinuous),
          child: RangeSlider(
            values: _currentRangeValues,
            labels: RangeLabels(
              _currentRangeValues.start.toString(),
              _currentRangeValues.end.toString(),
            ),
            min: 0.0,
            max: 1.0,
            onChanged: (RangeValues value) {
              setState(() {
                _currentRangeValues = value;
              });
            },
          ),
        ),
      ],
    );
  }
}

class _AggregationOptions extends StatefulWidget {
  const _AggregationOptions();

  @override
  State<_AggregationOptions> createState() => _AggregationOptionsState();
}

class _AggregationOptionsState extends State<_AggregationOptions> {
  final HeaterControllerStateStore _heaterStateStore = getIt<HeaterControllerStateStore>();

  static final _dropdownEntriesForDefault =
      AggregationMethod.values
          .map((e) => _DropddownEntryData<AggregationMethod>(label: e.name, value: e))
          .toList();

  static final _dropdownEntries = [
    ..._dropdownEntriesForDefault,
    _DropddownEntryData<AggregationMethod?>(label: "DEFAULT", value: null),
  ];

  static final double sliderMin = 1.0;
  static final double sliderMax = 60.0;
  static final int sliderDivisions = (sliderMax - sliderMin).toInt();

  int sliderValue = 1;
  ReactionDisposer? aggregationIntervalReactionDispose;

  @override
  void initState() {
    aggregationIntervalReactionDispose = autorun((_) {
      sliderValue = _heaterStateStore.aggregationInterval.value;
      if (mounted) {
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        spacing: 8,
        children: [
          Text("Data aggregation options", style: TextTheme.of(context).headlineSmall),
          Padding(padding: EdgeInsets.symmetric(vertical: 2)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Aggregation interval: $sliderValue s.",
                style: TextTheme.of(context).labelLarge,
              ),

              SliderTheme(
                data: SliderThemeData(
                  year2023: false,
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                ),
                child: Slider(
                  min: sliderMin,
                  max: sliderMax,
                  divisions: sliderDivisions,
                  label: "$sliderValue s.",
                  value: sliderValue.toDouble(),
                  onChangeEnd: (double value) {
                    _heaterStateStore.setAggregationInterval(sliderValue);
                  },
                  onChanged: (double value) {
                    bool toCeil = sliderValue.toDouble() < value;
                    setState(() {
                      sliderValue = toCeil ? value.ceil() : value.floor();
                    });
                  },
                ),
              ),
            ],
          ),
          Observer(
            builder: (context) {
              return Row(
                children: [
                  Text(
                    "DEFAULT: ",
                    style: TextTheme.of(context).labelLarge?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Spacer(),
                  _AggregationMethodDropddown<AggregationMethod>(
                    label: _heaterStateStore.defaultAggregationMethod.name,
                    entries: _dropdownEntriesForDefault,
                    onSelected: (AggregationMethod value) {
                      _heaterStateStore.setDefaultAggregationMethod(value);
                    },
                  ),
                ],
              );
            },
          ),

          ...HeaterControllerStateField.values.map((field) {
            return Observer(
              builder: (context) {
                return Row(
                  children: [
                    Text(
                      "${field.key}: ",
                      style: TextTheme.of(
                        context,
                      ).labelLarge?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Spacer(),
                    _AggregationMethodDropddown<AggregationMethod?>(
                      label: _heaterStateStore.aggregationMethodsByField[field]?.name ?? "DEFAULT",
                      entries: _dropdownEntries,
                      onSelected: (AggregationMethod? value) {
                        _heaterStateStore.setFieldAggregationMethod(field, value);
                      },
                    ),
                  ],
                );
              },
            );
          }),
        ],
      ),
    );
  }

  @override
  void dispose() {
    aggregationIntervalReactionDispose?.call();
    super.dispose();
  }
}

class _AggregationMethodDropddown<T> extends StatefulWidget {
  const _AggregationMethodDropddown({
    super.key,
    required this.label,
    required this.entries,
    required this.onSelected,
  });

  final String label;
  final List<_DropddownEntryData<T>> entries;
  final void Function(T value)? onSelected;

  @override
  State<_AggregationMethodDropddown<T>> createState() => _AggregationMethodDropddownState<T>();
}

class _AggregationMethodDropddownState<T> extends State<_AggregationMethodDropddown<T>> {
  final FocusNode _activatorFocusNode = FocusNode(debugLabel: 'Activator Focus Node');

  @override
  Widget build(BuildContext context) {
    final List<Widget> menuChildren =
        widget.entries.map((e) {
          void Function()? onPressed =
              widget.onSelected == null ? null : () => widget.onSelected!(e.value);

          return MenuItemButton(
            style: MenuItemButton.styleFrom(minimumSize: Size(56 * 2, 56)),
            onPressed: onPressed,
            child: Text(e.label),
          );
        }).toList();

    Widget menuAnchorBuilder(BuildContext context, MenuController controller, Widget? child) {
      return OutlinedButton.icon(
        focusNode: _activatorFocusNode,
        style: OutlinedButton.styleFrom(
          minimumSize: Size(0, 56),
          textStyle: TextTheme.of(context).labelLarge,
          foregroundColor: ColorScheme.of(context).onSurface,
          iconColor: ColorScheme.of(context).onSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
        ),
        onPressed: () {
          if (controller.isOpen) {
            controller.close();
          } else {
            controller.open();
          }
        },
        icon: AnimatedRotation(
          turns: !controller.isOpen ? 1.0 / 2.0 : 0,
          duration: Durations.medium1,
          curve: Curves.easeInOut,
          child: Icon(MdiIcons.arrowUp),
        ),
        iconAlignment: IconAlignment.end,
        label: child!,
      );
    }

    return MenuAnchor(
      childFocusNode: _activatorFocusNode,
      builder: menuAnchorBuilder,
      menuChildren: menuChildren,
      child: AnimatedSize(
        duration: Durations.short2,
        alignment: Alignment.center,
        child: Text(widget.label),
      ),
    );
  }

  @override
  void dispose() {
    _activatorFocusNode.dispose();
    super.dispose();
  }
}

class _DropddownEntryData<T> {
  final String label;
  final T value;

  const _DropddownEntryData({required this.label, required this.value});
}
