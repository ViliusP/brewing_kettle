import 'package:brew_kettle_dashboard/constants/app.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class InformationScreen extends StatelessWidget {
  const InformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            final GoRouter goRouter = GoRouter.of(context);
            if (goRouter.canPop()) {
              GoRouter.of(context).pop();
            }
          },
          icon: const Icon(AppConstants.backIcon),
        ),
      ),
      body: Text("hello"),
    );
  }
}
