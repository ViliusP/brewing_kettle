import 'package:brew_kettle_dashboard/constants/app.dart';
import 'package:brew_kettle_dashboard/localizations/localization.dart';
import 'package:brew_kettle_dashboard/ui/common/application_info/application_info.dart';
import 'package:brew_kettle_dashboard/ui/common/link_span/link_span.dart';
import 'package:brew_kettle_dashboard/ui/routing.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class InformationScreen extends StatelessWidget {
  const InformationScreen({super.key});

  void _goBack(BuildContext context) {
    final GoRouter router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop();
    } else {
      router.goNamed(AppRoute.connection.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = TextTheme.of(context);
    // ignore: unused_local_variable
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    // ignore: unused_local_variable
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final info = ApplicationInfo.maybeOf(context);
    final versionNum = info?.version ?? 'N/A';
    final buildNum = info?.buildNumber;
    final version = buildNum != null ? '$versionNum ($buildNum)' : versionNum;

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: SizedBox(
            width: 800,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: FilledButton.tonalIcon(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: colorScheme.primary,
                      textStyle: textTheme.labelLarge?.copyWith(height: 0.9, fontSize: 16.0),
                      iconSize: 18.0,
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    ),
                    onPressed: () => _goBack(context),
                    label: Text(localizations.generalGoBack),
                    icon: Icon(AppConstants.backIcon),
                  ),
                ),
                Padding(padding: EdgeInsets.symmetric(vertical: 4.0)),
                Card.outlined(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Text(
                          "Virtinis BrewKettle System Dashboard",
                          style: textTheme.headlineLarge,
                        ),
                        Text(version, style: textTheme.titleLarge),
                        Padding(padding: EdgeInsets.symmetric(vertical: 4.0)),
                        Text(
                          "Virtinis sistemos aplikacija naudojama stebėti ir valdyti virimo katilo temperatūrą.",
                          style: textTheme.bodyLarge,
                        ),

                        Padding(padding: EdgeInsets.symmetric(vertical: 4.0)),

                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(text: "Daugiau informacijos rasite tinklalapyje:\n"),
                              LinkSpan(
                                AppConstants.homepageUrl,
                                text: AppConstants.homepageUrl,
                                style: textTheme.bodyLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              TextSpan(),
                            ],
                            style: textTheme.bodyLarge,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(padding: EdgeInsets.symmetric(vertical: 12.0)),
                Card.outlined(
                  child: Padding(padding: const EdgeInsets.all(32.0), child: _FaqSection()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FaqSection extends StatelessWidget {
  const _FaqSection();

  List<_FaqQuestion> _faqQuestions(AppLocalizations localizations) {
    return [
      _FaqQuestion(question: localizations.faqQuestion1, answer: localizations.faqAnswer1),
      _FaqQuestion(question: localizations.faqQuestion2, answer: localizations.faqAnswer2),
      _FaqQuestion(question: localizations.faqQuestion3, answer: localizations.faqAnswer3),
      _FaqQuestion(question: localizations.faqQuestion4, answer: localizations.faqAnswer4),
      _FaqQuestion(question: localizations.faqQuestion5, answer: localizations.faqAnswer5),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    final TextTheme textTheme = TextTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(localizations.faqTitle, style: textTheme.headlineMedium),
        Padding(padding: EdgeInsets.symmetric(vertical: 4.0)),
        ..._faqQuestions(localizations).map(
          (q) => ListTile(
            title: Text(q.question, style: textTheme.titleLarge),
            subtitle: Text(q.answer, style: textTheme.bodyLarge),
          ),
        ),
      ],

      // body: Text("hello"),
    );
  }
}

class _FaqQuestion {
  final String question;
  final String answer;

  const _FaqQuestion({required this.question, required this.answer});
}
