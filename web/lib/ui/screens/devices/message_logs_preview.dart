import 'package:brew_kettle_dashboard/core/data/models/websocket/inbound_message.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessageLogsPreview extends StatelessWidget {
  final List<WsInboundMessageSimple> messages;

  const MessageLogsPreview({super.key, this.messages = const []});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...messages.map((e) {
              return Padding(
                padding: const EdgeInsets.all(8),
                child: RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyMedium,
                    children: [
                      TextSpan(
                        text: "${DateFormat("HH:mm:ss").format(e.time)}:\n",
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      TextSpan(text: "${e.data.replaceAll("\n", " ").substring(0, 150)}..."),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
