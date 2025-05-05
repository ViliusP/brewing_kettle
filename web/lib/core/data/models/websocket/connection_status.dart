import 'dart:io';

enum WebSocketConnectionStatus {
  // Waiting for connection.
  idle,

  /// Connecting.
  connecting,

  // Ready for communication.
  connected,

  /// Error while connecting and now idling.
  error,

  /// Connection closed succesfully and now idling.
  finished,

  /// Connection with error and now idling.
  finishedWithError,

  /// Connection ended with no status and now idling.
  finishedNoStatus,

  undefined;

  static const _errorCloseCodes = [
    WebSocketStatus.protocolError,
    WebSocketStatus.goingAway,
    WebSocketStatus.unsupportedData,
    WebSocketStatus.abnormalClosure,
    WebSocketStatus.invalidFramePayloadData,
    WebSocketStatus.policyViolation,
    WebSocketStatus.messageTooBig,
    WebSocketStatus.missingMandatoryExtension,
    WebSocketStatus.internalServerError,
  ];

  static WebSocketConnectionStatus fromCloseCode(int value) {
    return switch (value) {
      WebSocketStatus.normalClosure || WebSocketStatus.goingAway => finished,
      WebSocketStatus.noStatusReceived => finishedNoStatus,
      WebSocketStatus.reserved1004 || WebSocketStatus.reserved1015 => undefined,
      _ when _errorCloseCodes.contains(value) => finishedWithError,
      _ => undefined,
    };
  }
}
