import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NotFound404Screen extends StatelessWidget {
  final Exception? error;

  const NotFound404Screen({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("Not Found 404"),

        Text("Error: ${error?.toString()}"),
        const SizedBox(height: 16),

        OutlinedButton(
          onPressed: () {
            GoRouter.of(context).pop();
          },
          child: const Text("Back"),
        ),
      ],
    );
  }
}
