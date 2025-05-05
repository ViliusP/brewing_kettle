import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// A fake browser address bar widget that serves as a placeholder.
/// This widget is used to simulate a browser address bar in the UI.
///
/// Used with GoRouter to simulate a browser-like experience.
class FakeBrowserAddressBar extends StatefulWidget {
  final GoRouter router;

  const FakeBrowserAddressBar({super.key, required this.router});

  @override
  State<FakeBrowserAddressBar> createState() => _FakeBrowserAddressBarState();
}

class _FakeBrowserAddressBarState extends State<FakeBrowserAddressBar> {
  final TextEditingController controller = TextEditingController();

  void _onRouteChange() {
    if (mounted) {
      final uri = widget.router.routerDelegate.state.uri;
      controller.value = TextEditingValue(text: uri.toString());
    }
  }

  @override
  void initState() {
    widget.router.routerDelegate.addListener(_onRouteChange);
    _onRouteChange();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(border: OutlineInputBorder(), label: const Text("URL")),
        onFieldSubmitted: (value) => widget.router.push(value),
      ),
    );
  }

  @override
  void dispose() {
    widget.router.routerDelegate.removeListener(_onRouteChange);
    super.dispose();
  }
}
