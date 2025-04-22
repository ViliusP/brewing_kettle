import 'package:brew_kettle_dashboard/constants/app.dart';
import 'package:brew_kettle_dashboard/constants/theme.dart';
import 'package:brew_kettle_dashboard/ui/screens/not_found_404/starry_background.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NotFound404Screen extends StatelessWidget {
  const NotFound404Screen({super.key});

  @override
  Widget build(BuildContext context) {
    MaterialTheme materialTheme = MaterialTheme(AppDefaults.font.name);
    ThemeData theme = materialTheme.theme(AppTheme.dark.colorScheme);

    return Theme(
      data: theme,
      child: Builder(
        builder: (innerContext) {
          return StarryBackground(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Not Found 404", style: TextTheme.of(innerContext).displayMedium),

                const SizedBox(height: 16),

                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Color.fromRGBO(205, 203, 231, 1),
                  ),
                  onPressed: () {
                    GoRouter.of(context).pop();
                  },
                  child: const Text("Back"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
