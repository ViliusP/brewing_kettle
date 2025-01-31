import 'package:brew_kettle_dashboard/ui/common/flags/country_flag.dart';
import 'package:brew_kettle_dashboard/ui/screens/settings/language_select_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _dialogBuilder(BuildContext context) {
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return LanguageSelectDialog();
        });
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = TextTheme.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 800),
        child: SingleChildScrollView(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: [
                  SettingsCard(
                    title: "General",
                    child: Column(
                      children: [
                        Card.outlined(
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            overlayColor:
                                WidgetStateProperty.resolveWith((states) {
                              if (states.contains(WidgetState.pressed)) {
                                return colorScheme.primary.withAlpha(26);
                              }
                              if (states.contains(WidgetState.hovered)) {
                                return colorScheme.primary.withAlpha(20);
                              }
                              if (states.contains(WidgetState.focused)) {
                                return colorScheme.primary.withAlpha(26);
                              }
                              return null;
                            }),
                            onTap: () => _dialogBuilder(context),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 12.0,
                              ),
                              child: Row(
                                children: [
                                  Icon(MdiIcons.earth),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 2,
                                    ),
                                  ),
                                  Text(
                                    "Language",
                                    style: textTheme.bodyLarge,
                                  ),
                                  Spacer(),
                                  SizedBox(
                                    height: 20,
                                    child: CountryFlag(code: CountryCode.lt),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        Text("world"),
                        Text("bye"),
                        Text("moon"),
                      ],
                    ),
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class SettingsCard extends StatelessWidget {
  final Widget child;

  final String title;

  const SettingsCard({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = TextTheme.of(context);

    return Material(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
      surfaceTintColor: colorScheme.primaryFixedDim,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style: textTheme.displaySmall,
                textAlign: TextAlign.left,
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}
