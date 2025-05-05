import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

/// A custom TextSpan that creates a clickable link.
/// When tapped, it opens the specified URL in the default web browser.
/// The text displayed is either the provided text or the URL itself if no text is provided.
///
/// Example usage:
/// ```dart
/// RichText(
///  text: TextSpan(
///    children: [
///     LinkSpan('https://example.com', text: 'Example'),
///    ],
///   style: TextStyle(color: Colors.blue),
/// ///  ),
/// )
/// ```
class LinkSpan extends TextSpan {
  LinkSpan(String url, {String? text, super.style})
    : super(
        text: text ?? url,
        recognizer:
            TapGestureRecognizer()
              ..onTap = () async {
                final Uri uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
              },
      );
}
