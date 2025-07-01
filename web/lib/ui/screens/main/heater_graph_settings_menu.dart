import 'package:brew_kettle_dashboard/constants/app.dart';
import 'package:brew_kettle_dashboard/core/data/models/common/temperature_scale.dart';
import 'package:brew_kettle_dashboard/core/data/models/timeseries/heater_session_statistics.dart';
import 'package:brew_kettle_dashboard/core/data/models/timeseries/timeseries.dart';
import 'package:brew_kettle_dashboard/core/service_locator.dart';
import 'package:brew_kettle_dashboard/localizations/localization.dart';
import 'package:brew_kettle_dashboard/stores/app_configuration/app_configuration_store.dart';
import 'package:brew_kettle_dashboard/stores/heater_controller_state/heater_controller_state_store.dart';
import 'package:brew_kettle_dashboard/stores/heater_controller_state/heater_state_data_values.dart';

import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:mobx/mobx.dart';

class HeaterGraphSettingsMenu extends StatelessWidget {
  final HeaterControllerStateStore _heaterStateStore = getIt<HeaterControllerStateStore>();
  final AppConfigurationStore _appConfigurationStore = getIt<AppConfigurationStore>();

  HeaterGraphSettingsMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    final TextTheme textTheme = TextTheme.of(context);

    return Material(
      elevation: 8.0,
      child: Container(
        width: 350,
        color: Theme.of(context).canvasColor,
        child: CustomScrollView(
          primary: false,
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,

                  children: <Widget>[
                    Padding(padding: EdgeInsets.symmetric(vertical: 8)),
                    Observer(
                      builder: (context) {
                        return _GraphStatistics(
                          stats: _heaterStateStore.sessionStatistics,
                          temperatureScale: _appConfigurationStore.temperatureScale,
                        );
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(indent: 8, endIndent: 8),
                    ),
                    Text(
                      localizations.dataDurationSpanTitle,
                      style: TextTheme.of(context).headlineSmall,
                    ),
                    Padding(padding: EdgeInsets.symmetric(vertical: 4)),
                    _GraphRangeSelect(),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(indent: 8, endIndent: 8),
                    ),
                    Text(
                      localizations.dataAggregationTitle,
                      style: TextTheme.of(context).headlineSmall,
                    ),
                    Padding(padding: EdgeInsets.symmetric(vertical: 4)),
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
  final HeaterControllerStateStore _heaterStateStore = getIt<HeaterControllerStateStore>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;

    final int sliderDivisions =
        (HeaterStateHistoryValues.maxDataInterval.inMinutes -
                HeaterStateHistoryValues.minDataInterval.inMinutes)
            .toInt();

    return Column(
      children: [
        Observer(
          builder: (context) {
            final Duration currentDuration = _heaterStateStore.dataDuration;
            final String formattedDuration =
                "${currentDuration.inHours}h ${currentDuration.inMinutes.remainder(60)}m";

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "${localizations.dataDurationSpanInfo}$formattedDuration",
                  textAlign: TextAlign.left,
                ),
                SliderTheme(
                  data: SliderThemeData(
                    showValueIndicator: ShowValueIndicator.onlyForContinuous,
                    year2023: false,
                  ),
                  child: Slider(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    min: HeaterStateHistoryValues.minDataInterval.inMinutes.toDouble(),
                    max: HeaterStateHistoryValues.maxDataInterval.inMinutes.toDouble(),
                    divisions: sliderDivisions,
                    value: _heaterStateStore.dataDuration.inMinutes.toDouble(),
                    onChanged: (double value) {
                      _heaterStateStore.setDataInterval(Duration(minutes: value.round()));
                    },
                  ),
                ),
              ],
            );
          },
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

  static const defaultTypeKey = "default";

  static final _dropdownEntries = [
    ..._dropdownEntriesForDefault,
    _DropddownEntryData<AggregationMethod?>(label: defaultTypeKey, value: null),
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
    final AppLocalizations localizations = AppLocalizations.of(context)!;

    return Column(
      spacing: 8,
      children: [
        Observer(
          builder: (context) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  localizations.dataAggregationInfo("$sliderValue s."),
                  style: TextTheme.of(context).labelLarge,
                ),
                Padding(padding: EdgeInsets.symmetric(vertical: 4)),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: SliderTheme(
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
                          onChanged:
                              _heaterStateStore.toAggregateTimeSeries
                                  ? (double value) {
                                    bool toCeil = sliderValue.toDouble() < value;
                                    setState(() {
                                      sliderValue = toCeil ? value.ceil() : value.floor();
                                    });
                                  }
                                  : null,
                        ),
                      ),
                    ),
                    Tooltip(
                      message: localizations.dataAggregationSwitchLabel,
                      child: Checkbox(
                        value: _heaterStateStore.toAggregateTimeSeries,
                        semanticLabel: localizations.dataAggregationSwitchLabel,
                        onChanged: (bool? value) {
                          if (value == null) return;
                          // If the checkbox is unchecked, we reset the aggregation interval
                          _heaterStateStore.setToAggregateTimeSeries(value);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            localizations.aggregationByPropertyTitle,
            style: TextTheme.of(context).titleMedium?.copyWith(fontWeight: FontWeight.w300),
            textAlign: TextAlign.center,
          ),
        ),

        Observer(
          builder: (context) {
            return Row(
              children: [
                Text(
                  "${localizations.aggregationField(defaultTypeKey)}: ",
                  style: TextTheme.of(context).labelLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                Spacer(),
                _AggregationMethodDropddown<AggregationMethod>(
                  label: localizations.aggregationType(
                    _heaterStateStore.defaultAggregationMethod.name,
                  ),
                  entries:
                      _dropdownEntriesForDefault
                          .map(
                            (e) => _DropddownEntryData<AggregationMethod>(
                              label: localizations.aggregationType(e.label),
                              value: e.value,
                            ),
                          )
                          .toList(),
                  onSelected:
                      _heaterStateStore.toAggregateTimeSeries
                          ? (AggregationMethod value) {
                            _heaterStateStore.setDefaultAggregationMethod(value);
                          }
                          : null,
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
                    "${localizations.aggregationField(field.key)}: ",
                    style: TextTheme.of(context).labelLarge?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Spacer(),
                  _AggregationMethodDropddown<AggregationMethod?>(
                    label: localizations.aggregationType(
                      _heaterStateStore.aggregationMethodsByField[field]?.name ?? defaultTypeKey,
                    ),
                    entries:
                        _dropdownEntries.map((e) {
                          return _DropddownEntryData<AggregationMethod?>(
                            label: localizations.aggregationType(e.label),
                            value: e.value,
                          );
                        }).toList(),
                    onSelected:
                        _heaterStateStore.toAggregateTimeSeries
                            ? (AggregationMethod? value) {
                              _heaterStateStore.setFieldAggregationMethod(field, value);
                            }
                            : null,
                  ),
                ],
              );
            },
          );
        }),
      ],
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
        onPressed:
            widget.onSelected != null
                ? () {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                }
                : null,
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

/// Widget that displays the statistics of the heater session
class _GraphStatistics extends StatelessWidget {
  final TemperatureScale _temperatureScale;
  final HeaterSessionStatistics _stats;

  const _GraphStatistics({
    required HeaterSessionStatistics stats,
    required TemperatureScale temperatureScale,
  }) : _stats = stats,
       _temperatureScale = temperatureScale;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;

    final DateFormat sessionDateFormat = DateFormat('MM/dd HH:mm');
    final String sessionStart = sessionDateFormat.format(_stats.sessionStart);
    final String sessionEnd = sessionDateFormat.format(_stats.sessionEnd);

    durationFormat(Duration duration) {
      if (duration == Duration.zero) {
        return "0m";
      }
      if (duration.inMinutes > 0) {
        return "${duration.inHours}h ${duration.inMinutes.remainder(60)}m";
      }
      return localizations.sessionStatLessThanMinute;
    }

    formattedStatBuilder(String label, String value) {
      return RichText(
        textAlign: TextAlign.center,
        softWrap: true,
        text: TextSpan(
          children: [
            TextSpan(text: "$label: ", style: TextTheme.of(context).bodyLarge),
            TextSpan(
              text: value,
              style: TextTheme.of(
                context,
              ).bodyLarge?.copyWith(fontWeight: FontWeight.w600, overflow: TextOverflow.visible),
            ),
          ],
        ),
      );
    }

    final String temperatureScaleSymbol = _temperatureScale.symbol;
    final String averageTemperature = _temperatureScale
        .fromCelsius(_stats.averageTemperature)
        .toStringAsFixed(1);
    final String lowestTemperature = _temperatureScale
        .fromCelsius(_stats.lowestTemperature)
        .toStringAsFixed(1);
    final String highestTemperature = _temperatureScale
        .fromCelsius(_stats.highestTemperature)
        .toStringAsFixed(1);

    String averageNonIdlePower = _stats.averageNonIdlePower.toStringAsFixed(1);
    if (_stats.averageNonIdlePower == double.negativeInfinity) {
      averageNonIdlePower = "0.0";
    }
    String averagePower = _stats.averagePower.toStringAsFixed(1);
    if (_stats.averagePower == double.negativeInfinity) {
      averagePower = "0.0";
    }

    final String idleDuration = durationFormat(_stats.idleDuration);
    final String activeDuration = durationFormat(_stats.activeDuration);

    return Column(
      children: [
        Text(localizations.sessionStatisticsTitle, style: TextTheme.of(context).headlineSmall),
        Text("$sessionStart - $sessionEnd", style: TextTheme.of(context).labelLarge),
        Text("", style: TextTheme.of(context).bodyLarge),

        formattedStatBuilder(
          localizations.sessionStatLowestTemperature,
          "$lowestTemperature$temperatureScaleSymbol",
        ),
        formattedStatBuilder(
          localizations.sessionStatHighestTemperature,
          "$highestTemperature$temperatureScaleSymbol",
        ),
        formattedStatBuilder(
          localizations.sessionStatAverageTemperature,
          "$averageTemperature$temperatureScaleSymbol",
        ),

        Text("", style: TextTheme.of(context).bodyLarge),

        formattedStatBuilder(localizations.sessionStatNonIdleAveragePower, "$averageNonIdlePower%"),
        formattedStatBuilder(localizations.sessionStatAveragePower, "$averagePower%"),
        Text("", style: TextTheme.of(context).bodyLarge),

        formattedStatBuilder(localizations.sessionStatIdleTime, idleDuration),
        formattedStatBuilder(localizations.sessionStatActiveTime, activeDuration),
      ],
    );
  }
}

class _DropddownEntryData<T> {
  final String label;
  final T value;

  const _DropddownEntryData({required this.label, required this.value});
}
