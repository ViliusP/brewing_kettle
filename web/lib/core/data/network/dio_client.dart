import 'package:dio/dio.dart';

class NetworkConstants {
  NetworkConstants._();

  // base url
  static const String baseUrl = 'http://jsonplaceholder.typicode.com';

  // receiveTimeout
  static const int receiveTimeout = 15000;

  // connectTimeout
  static const int connectionTimeout = 30000;
}

const _kDefaultReceiveTimeout = 10000;
const _kDefaultConnectionTimeout = 10000;

class DioConfigs {
  final String baseUrl;
  final int receiveTimeout;
  final int connectionTimeout;

  const DioConfigs({
    required this.baseUrl,
    this.receiveTimeout = _kDefaultReceiveTimeout,
    this.connectionTimeout = _kDefaultConnectionTimeout,
  });
}

class DioClient {
  final DioConfigs dioConfigs;
  final Dio _dio;

  DioClient({required this.dioConfigs})
      : _dio = Dio()
          ..options.baseUrl = dioConfigs.baseUrl
          ..options.connectTimeout =
              Duration(milliseconds: dioConfigs.connectionTimeout)
          ..options.receiveTimeout =
              Duration(milliseconds: dioConfigs.receiveTimeout);

  Dio get dio => _dio;

  Dio addInterceptors(Iterable<Interceptor> interceptors) {
    return _dio..interceptors.addAll(interceptors);
  }
}
