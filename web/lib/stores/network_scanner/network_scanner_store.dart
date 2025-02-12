import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:mobx/mobx.dart';
import 'package:multicast_dns/multicast_dns.dart';

part 'network_scanner_store.g.dart';

const String serviceName = '_brewkettle._tcp';
const int refreshPeriod = 5;

enum NetworkScannerState { idle, scanning, done, error }

// ignore: library_private_types_in_public_api
class NetworkScannerStore = _NetworkScannerStore with _$NetworkScannerStore;

abstract class _NetworkScannerStore with Store {
  final MDnsClient _client = MDnsClient();

  _NetworkScannerStore() {
    // _timer = Timer.periodic(const Duration(seconds: 1),
    //     (_) => _streamController.add(_random.nextInt(100)));
  }

  @computed
  List<RecordMDNS> get records => _records;

  @observable
  List<RecordMDNS> _records = [];

  @computed
  NetworkScannerState get state => _state;

  @observable
  NetworkScannerState _state = NetworkScannerState.idle;

  late final Timer _timer;

  @action
  Future start() async {
    if (kIsWeb) {
      log("Network scan isn't supported on web");
      return;
    }
    if (_state == NetworkScannerState.scanning) {
      return;
    }
    _state = NetworkScannerState.scanning;
    _records = await _scan();
    _state = NetworkScannerState.done;
  }

  /// Scans the network for mDNS services.
  ///
  /// Example:
  /// ```dart
  /// final List<RecordMDNS> results = await _scan();
  /// ```
  ///
  /// Retirns a list of [RecordMDNS] objects.
  Future<List<RecordMDNS>> _scan() async {
    // Start the client with default options.
    await _client.start();

    final List<RecordMDNS> results = [];

    String? hostname;
    int? port;
    InternetAddress? internetAddress;
    String? text;

    // Get the PTR record for the service.
    final ptrQuery = ResourceRecordQuery.serverPointer(serviceName);
    final ptrLookupStream = _client.lookup<PtrResourceRecord>(ptrQuery);

    await for (final PtrResourceRecord ptr in ptrLookupStream) {
      hostname = ptr.toString();

      final serviceQuery = ResourceRecordQuery.service(ptr.domainName);
      final serviceLookup = _client.lookup<SrvResourceRecord>(serviceQuery);
      await for (final SrvResourceRecord srv in serviceLookup) {
        hostname = srv.target;
        port = srv.port;

        final ipQuery = ResourceRecordQuery.addressIPv4(srv.target);
        final ipLookupStream = _client.lookup<IPAddressResourceRecord>(ipQuery);
        await for (final IPAddressResourceRecord ip in ipLookupStream) {
          internetAddress = ip.address;
        }
      }

      final textQuery = ResourceRecordQuery.text(ptr.domainName);
      final txtLookupStream = _client.lookup<TxtResourceRecord>(textQuery);
      await for (final TxtResourceRecord txt in txtLookupStream) {
        text = txt.text;
      }

      if ([hostname, port, internetAddress, text].nonNulls.length == 4) {
        results.add(RecordMDNS(
          hostname: hostname!,
          port: port!,
          internetAddress: internetAddress!,
          text: text!,
        ));
      }

      // Reset variables
      hostname = null;
      port = null;
      internetAddress = null;
      text = null;
    }

    _client.stop();

    return results;
  }

  // ignore: avoid_void_async
  void dispose() async {
    _timer.cancel();
  }
}

/// A record of mDNS service discovery.
class RecordMDNS {
  /// The hostname for this record.
  final String hostname;

  /// The port for this record.
  final int port;

  final InternetAddress internetAddress;

  String get ip => internetAddress.address;

  final String text;

  const RecordMDNS({
    required this.hostname,
    required this.port,
    required this.internetAddress,
    required this.text,
  });
}
