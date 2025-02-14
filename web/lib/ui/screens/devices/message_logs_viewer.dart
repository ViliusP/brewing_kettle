import 'package:brew_kettle_dashboard/ui/common/pagination_control/pagination_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter_json_view/flutter_json_view.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:go_router/go_router.dart';

class MessageLogsViewer extends StatefulWidget {
  const MessageLogsViewer({super.key, this.data = "[]"});

  final String data;

  @override
  State<MessageLogsViewer> createState() => _MessageLogsViewerState();
}

class _MessageLogsViewerState extends State<MessageLogsViewer> {
  final focusNode = FocusNode();

  int currentPage = 1;
  static const int pages = 10;

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = TextTheme.of(context);
    ColorScheme colorScheme = ColorScheme.of(context);

    TextStyle defaultTextStyle = textTheme.bodySmall ??
        TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        );

    double iconSize = (defaultTextStyle.fontSize?.toInt() ?? 17) + 3;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: ElevatedButton(
              onPressed: () {
                if (context.canPop()) Navigator.pop(context);
              },
              child: Text("back"),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: PaginationControl(
              onChanged: (page) => setState(() => currentPage = page),
              current: currentPage,
              section: 3,
              total: pages,
            ),
          ),
          SizedBox(
            width: 960,
            child: JsonView.string(
              widget.data,
              theme: JsonViewTheme(
                viewType: JsonViewType.base,
                openIcon: Icon(MdiIcons.plus, size: iconSize),
                closeIcon: Icon(MdiIcons.close, size: iconSize),
                separator: Text(": ", style: defaultTextStyle),
                backgroundColor: colorScheme.surface,
                defaultTextStyle: defaultTextStyle,
                keyStyle: TextStyle(color: colorScheme.primary),
                boolStyle: TextStyle(color: colorScheme.inverseSurface),
                intStyle: TextStyle(color: colorScheme.inverseSurface),
                stringStyle: TextStyle(color: colorScheme.inverseSurface),
                doubleStyle: TextStyle(color: colorScheme.inverseSurface),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }
}
