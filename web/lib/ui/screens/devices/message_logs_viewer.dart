import 'package:brew_kettle_dashboard/core/data/models/websocket/inbound_message.dart';
import 'package:brew_kettle_dashboard/localizations/localization.dart';
import 'package:brew_kettle_dashboard/ui/common/code_view/code_view.dart';
import 'package:brew_kettle_dashboard/ui/common/pagination_control/pagination_control.dart';
import 'package:brew_kettle_dashboard/ui/screens/devices/one_sided_rounded_shape.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class MessageLogsViewer extends StatefulWidget {
  const MessageLogsViewer({super.key, this.messages = const []});

  final List<WsInboundMessageSimple> messages;

  @override
  State<MessageLogsViewer> createState() => _MessageLogsViewerState();
}

class _MessageLogsViewerState extends State<MessageLogsViewer> {
  int currentPage = 1;
  static const int itemsPerPage = 10;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    // final TextTheme textTheme = TextTheme.of(context);
    final ColorScheme colorScheme = ColorScheme.of(context);

    int sublistStart = (itemsPerPage * (currentPage - 1));
    int sublistEnd = sublistStart + itemsPerPage;
    if (sublistEnd > widget.messages.length) {
      sublistEnd = widget.messages.length;
    }

    return SingleChildScrollView(
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(8),
            child: IconButton.outlined(
              tooltip: localizations.generalExit,
              onPressed: () {
                if (context.canPop()) Navigator.pop(context);
              },
              icon: Icon(MdiIcons.windowClose),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 24, bottom: 16),
                  child: PaginationControl(
                    onChanged: (page) => setState(() => currentPage = page),
                    current: currentPage,
                    section: 5,
                    total: (widget.messages.length / itemsPerPage).ceil(),
                  ),
                ),
                Container(
                  constraints: BoxConstraints(minWidth: 400, maxWidth: 1060),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colorScheme.outline),
                  ),

                  child: _MessagesLogList(
                    messages: widget.messages.sublist(sublistStart, sublistEnd).toList(),
                  ),
                ),
                Padding(padding: EdgeInsets.only(bottom: 24)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class _MessagesLogList extends StatelessWidget {
  final List<WsInboundMessageSimple> messages;

  const _MessagesLogList({this.messages = const []});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = ColorScheme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children:
          messages.mapIndexed((index, e) {
            ShapeBorder? shape;
            ShapeBorder? collapsedShape;
            if (index == 0) {
              collapsedShape = OneSidedRoundedShape(roundedSide: AxisDirection.up, radius: 16);
              shape = OneSidedRoundedShape(
                roundedSide: AxisDirection.up,
                radius: 16,
                baseBorderSide: BorderSide(color: colorScheme.outlineVariant, width: 1),
              );
            } else if (index == messages.length - 1) {
              collapsedShape = OneSidedRoundedShape(roundedSide: AxisDirection.down, radius: 16);
              shape = OneSidedRoundedShape(
                roundedSide: AxisDirection.down,
                radius: 16,
                baseBorderSide: BorderSide(color: colorScheme.outlineVariant, width: 1),
              );
            } else {
              shape = Border(
                top: BorderSide(color: colorScheme.outlineVariant, width: 1),
                bottom: BorderSide(color: colorScheme.outlineVariant, width: 1),
              );
            }

            return ExpansionTile(
              title: Text(DateFormat("HH:mm:ss").format(e.time)),
              subtitle: Text("${e.data.replaceAll("\n", " ").substring(0, 60)}..."),
              trailing: Icon(MdiIcons.unfoldMoreHorizontal),
              shape: shape,
              collapsedShape: collapsedShape,
              expandedAlignment: Alignment.centerLeft,
              childrenPadding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              children: <Widget>[CodeViewer(data: e.data)],
            );
          }).toList(),
    );
  }
}

//  theme: JsonViewTheme(
//                         viewType: JsonViewType.base,
//                         openIcon: Icon(MdiIcons.plus, size: iconSize),
//                         closeIcon: Icon(MdiIcons.close, size: iconSize),
//                         separator: Text(": ", style: defaultTextStyle),
//                         backgroundColor: colorScheme.surface,
//                         defaultTextStyle: defaultTextStyle,
//                         keyStyle: TextStyle(color: colorScheme.primary),
//                         boolStyle: TextStyle(color: colorScheme.inverseSurface),
//                         intStyle: TextStyle(color: colorScheme.inverseSurface),
//                         stringStyle: TextStyle(color: colorScheme.inverseSurface),
//                         doubleStyle: TextStyle(color: colorScheme.inverseSurface),
//                       ),
