import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_pico_app/utils/constants.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'network_handler.g.dart';

class NetworkHandler {

  late final Dio dio;

  // Constructor for NetworkHandler
  /// This class is responsible for handling network requests and responses.
  /// It initializes the Dio instance with a base URL and sets up interceptors for logging.
  NetworkHandler() {

    dio = Dio();

    dio.options.baseUrl = Constants.baseUrl;

    // Timeouts
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);

    // Instantiate the logger for HTTP requests
    final PrettyDioLogger prettyDioLogger = PrettyDioLogger(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
      compact: false,
    );

    dio.interceptors.add(prettyDioLogger);
  }

}

// Expose the NetworkHandler instance as a provider
@Riverpod(keepAlive: true)
NetworkHandler networkHandler(Ref ref) => NetworkHandler();