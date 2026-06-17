import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:rooster/util/app_consts.dart';

/// {@template app_dio_configurator.class}
/// The base class with client configuration of [Dio].
/// {@endtemplate}
class AppDioConfigurator {
  /// {@macro app_dio_configurator.class}
  const AppDioConfigurator();

  /// Creating a client [Dio].
  Dio create({
    required Iterable<Interceptor> interceptors,
    required String url,
    String? proxyUrl,
  }) {
    const timeout = AppConsts.timeout;

    final dio = Dio();

    dio.options
      ..baseUrl = url
      ..connectTimeout = timeout
      ..receiveTimeout = timeout
      ..sendTimeout = timeout;

    final httpClient = dio.httpClientAdapter;

    if (httpClient is IOHttpClientAdapter) {
      httpClient.createHttpClient = () {
        final client = HttpClient();
        if (proxyUrl != null && proxyUrl.isNotEmpty) {
          client
            ..findProxy = (uri) {
              return 'PROXY $proxyUrl';
            }
            ..badCertificateCallback = (_, _, _) {
              return true;
            };
        }

        return client;
      };
    }

    dio.interceptors.addAll(interceptors);

    return dio;
  }
}
