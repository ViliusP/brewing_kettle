import 'dart:developer';

import 'package:dio/dio.dart';

class KettleClient {
  final Dio _dio = Dio(
    BaseOptions(
      // validateStatus: (status) {
      //   return true;
      // },
      connectTimeout: Duration(seconds: 5),
      receiveTimeout: Duration(seconds: 5),
      headers: {'Content-Type': 'application/json; charset=utf-8'},
    ),
  );
  bool usable = false;

  KettleClient() {
    _dio.interceptors.add(LogInterceptor(logPrint: (o) => log(o.toString())));
  }
  // ..interceptors.add(PrettyDioLogger());

  void setBaseUrl(String? baseUrl) {
    if (baseUrl == null) {
      usable = false;
      return;
    }
    usable = true;
    _dio.options.baseUrl = baseUrl;
  }

  Future<Response> get(
    String uri, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    if (usable == false) {
      throw StateError('Base URL is not set');
    }
    try {
      return await _dio.get(
        uri,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> post(
    String uri, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    if (usable == false) {
      throw StateError('Base URL is not set');
    }
    try {
      Response response = await _dio.post(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> delete(
    String uri, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    if (usable == false) {
      throw StateError('Base URL is not set');
    }
    try {
      Response response = await _dio.delete(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> patch(
    String uri, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    if (usable == false) {
      throw StateError('Base URL is not set');
    }
    try {
      Response response = await _dio.patch(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
