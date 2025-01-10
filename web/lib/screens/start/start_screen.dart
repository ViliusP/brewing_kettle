import 'dart:async';
import 'dart:convert';

import 'package:brew_kettle_dashboard/core/service_locator.dart';
import 'package:brew_kettle_dashboard/stores/device_configuration/device_configuration_store.dart';
import 'package:brew_kettle_dashboard/stores/device_snapshot/device_snapshot_store.dart';
import 'package:brew_kettle_dashboard/stores/network_scanner/network_scanner_store.dart';
import 'package:brew_kettle_dashboard/stores/websocket_connection/websocket_connection_store.dart';
import 'package:brew_kettle_dashboard/utils/pixels.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'dart:ui' as ui;

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MyHomePage(title: "ABC");
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
  });

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // ------- STORES -------
  final NetworkScannerStore _networkScannerStore = getIt<NetworkScannerStore>();
  final WebSocketConnectionStore _wsConnectionStore =
      getIt<WebSocketConnectionStore>();

  final DeviceConfigurationStore _deviceConfigurationStore =
      getIt<DeviceConfigurationStore>();

  final DeviceSnapshotStore _deviceSnapshotStore = getIt<DeviceSnapshotStore>();

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Observer(builder: (context) {
              return Text(
                "Scan state: ${_networkScannerStore.state}",
              );
            }),
            Observer(builder: (context) {
              final maybeFirstRecord = _networkScannerStore.records.firstOrNull;
              if (maybeFirstRecord == null) {
                return Text("No records found");
              }
              return Text(
                "${maybeFirstRecord.hostname}:${maybeFirstRecord.port}\n${maybeFirstRecord.ip}:${maybeFirstRecord.port}",
              );
            }),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.pressed)) {
                      return Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.5);
                    }
                    return null; // Use the component's default.
                  },
                ),
              ),
              child: const Text('Connect'),
              onPressed: () {
                final maybeFirstRecord =
                    _networkScannerStore.records.firstOrNull;
                if (maybeFirstRecord == null) {
                  return;
                }
                String address =
                    "ws://${maybeFirstRecord.hostname}:${maybeFirstRecord.port}/ws";
                _wsConnectionStore.connect(address);
              },
            ),
            Padding(padding: EdgeInsets.symmetric(vertical: 5)),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.pressed)) {
                      return Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.5);
                    }
                    return null; // Use the component's default.
                  },
                ),
              ),
              child: const Text('Send'),
              onPressed: () {
                _wsConnectionStore.message("Hello There");
              },
            ),
            Padding(padding: EdgeInsets.symmetric(vertical: 5)),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.pressed)) {
                      return Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.5);
                    }
                    return null; // Use the component's default.
                  },
                ),
              ),
              child: const Text('Send'),
              onPressed: () {
                _deviceConfigurationStore.request();
              },
            ),
            Padding(padding: EdgeInsets.symmetric(vertical: 5)),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.pressed)) {
                      return Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.5);
                    }
                    return null; // Use the component's default.
                  },
                ),
              ),
              child: const Text('Send snapshot request'),
              onPressed: () {
                _deviceSnapshotStore.request();
              },
            ),
            Padding(padding: EdgeInsets.symmetric(vertical: 5)),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.pressed)) {
                      return Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.5);
                    }
                    return null; // Use the component's default.
                  },
                ),
              ),
              child: const Text('Show image'),
              onPressed: () {},
            ),
            Observer(builder: (context) {
              if (_deviceSnapshotStore.snapshot != null) {
                Uint8List imageBuffer = base64Decode(
                  _deviceSnapshotStore.snapshot!.buffer!,
                );
                return GrayscaleImage(
                  buffer: imageBuffer.rgb888ToRgba8888(
                    _deviceSnapshotStore.snapshot!.width!,
                    _deviceSnapshotStore.snapshot!.height!,
                  ),
                  width: _deviceSnapshotStore
                      .snapshot!.width!, // Number of pixels per row
                  height:
                      _deviceSnapshotStore.snapshot!.height!, // Number of rows
                );
              }
              return SizedBox.shrink();
            })
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startScan,
        tooltip: 'Send message',
        child: const Icon(Icons.refresh),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _startScan() {
    _networkScannerStore.start();
  }

  @override
  void dispose() {
    _wsConnectionStore.close();
    _controller.dispose();
    super.dispose();
  }
}

class GrayscaleImage extends StatelessWidget {
  final Uint8List buffer; // Pre-buffered ARGB pixel data
  final int width; // Image width in pixels
  final int height; // Image height in pixels

  const GrayscaleImage({
    required this.buffer,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ui.Image>(
      future: createImageFromBuffer(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        } else if (snapshot.hasData) {
          return CustomPaint(
            painter: ImagePainter(snapshot.data!),
          );
        } else {
          return Text("Unknown error");
        }
      },
    );
  }

  Future<ui.Image> createImageFromBuffer() async {
    // Ensure the buffer size matches the expected dimensions
    if (buffer.length != width * height * 4) {
      throw ArgumentError(
          "Pixel buffer size (${buffer.length}) does not match the image dimensions ${width * height * 4}.");
    }

    // Create an image from the ARGB buffer
    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      buffer,
      width,
      height,
      ui.PixelFormat.rgba8888,
      (ui.Image img) => completer.complete(img),
    );
    return completer.future;
  }
}

class ImagePainter extends CustomPainter {
  final ui.Image image;

  ImagePainter(this.image);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    canvas.drawImage(image, Offset.zero, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
