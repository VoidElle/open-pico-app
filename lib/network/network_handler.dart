import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_pico_app/network/network_inteceptor.dart';
import 'package:open_pico_app/utils/constants/network_constants.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'dio_network_interceptor.dart';

part 'network_handler.g.dart';

class NetworkHandler {

  late final Dio dio;

  // Constructor for NetworkHandler
  /// This class is responsible for handling network requests and responses.
  /// It initializes the Dio instance with a base URL and sets up interceptors for logging.
  NetworkHandler() {

    dio = Dio();

    dio.options.baseUrl = NetworkConstants.baseUrl;

    // Timeouts
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);

    dio.interceptors.add(
      DioNetworkInterceptor(),
    );

    // Instantiate the logger for HTTP requests
    final PrettyDioLogger prettyDioLogger = PrettyDioLogger(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
      compact: true,
    );

    // Add the logger to the Dio instance
    dio.interceptors.add(prettyDioLogger);

    // Add the network interceptor
    final NetworkInterceptor networkInterceptor = NetworkInterceptor();
    dio.interceptors.add(networkInterceptor);

  }

}

// Expose the NetworkHandler instance as a provider
@Riverpod(keepAlive: true)
NetworkHandler networkHandler(Ref ref) => NetworkHandler();