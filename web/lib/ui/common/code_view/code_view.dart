import 'package:brew_kettle_dashboard/constants/theme.dart';
import 'package:brew_kettle_dashboard/ui/common/code_view/json/definition.dart';
import 'package:brew_kettle_dashboard/ui/common/code_view/json_highlighting_theme.dart';
import 'package:flutter/material.dart';

class CodeViewer extends StatefulWidget {
  final String? _data;
  final bool selectable;

  static const JsonHighlightingTheme _lightTheme = JsonHighlightingTheme.catpucinLatte();
  static const JsonHighlightingTheme _darkTheme = JsonHighlightingTheme.materialThemeDarker();

  const CodeViewer({super.key, String? data, this.selectable = true}) : _data = data;

  @override
  State<CodeViewer> createState() => _CodeViewerState();
}

class _CodeViewerState extends State<CodeViewer> {
  final FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final JsonHighlightingTheme theme = switch (Theme.of(context).colorScheme.brightness) {
      Brightness.light => CodeViewer._lightTheme,
      Brightness.dark => CodeViewer._darkTheme,
    };

    final jsonParser = JsonDefinition().build();
    var results = jsonParser.parse(widget._data ?? "").value;
    if (results is List<JsonToken>) {
      return SelectableText.rich(
        TextSpan(
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            height: theme.lineHeight,
            fontFamily: AppFontFamily.firaMono.name,
          ),
          children: _highlightedText(results, theme),
        ),
      );
    }
    return SelectionArea(child: Text(widget._data ?? ""));
  }

  List<TextSpan> _highlightedText(List<JsonToken> tokens, JsonHighlightingTheme theme) {
    List<TextSpan> text = [];
    for (var token in tokens) {
      final TextSpan textSpan = TextSpan(
        text: token.value,
        style: TextStyle(color: theme.tokenColors.tokenTypeToColor(token.type)),
      );

      text.add(textSpan);
    }

    return text;
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }
}
