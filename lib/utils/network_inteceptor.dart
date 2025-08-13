import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:open_pico_app/utils/global_singleton.dart';
import 'package:open_pico_app/widgets/dialogs/loading_dialog.dart';

class NetworkInterceptor extends InterceptorsWrapper {

  // List of paths that do not show a loader (polling, etc...)
  final List<String> _pathsNotShowingLoader = <String>[
    '/api/v1/GetPICOState',
  ];

  @override
  Future<dynamic> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {

    // Handling if the API request path does not have to show a loader
    final String path = options.path;
    if (_pathsNotShowingLoader.contains(path)) {
      return super.onRequest(options, handler);
    }

    // Retrieve the current context from the navigator key
    final BuildContext context = GlobalSingleton.navigatorKey.currentState!.context;

    // Show the loading dialog
    showDialog<LoadingDialog>(
      context: context,
      useSafeArea: false,
      barrierDismissible: false,
      builder: (BuildContext context) => const LoadingDialog(),
    );

    return super.onRequest(options, handler);
  }

  @override
  Future<dynamic> onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) async {

    // Handling if the API request path does not have to show a loader
    final String path = response.requestOptions.path;
    if (_pathsNotShowingLoader.contains(path)) {
      return super.onResponse(response, handler);
    }

    // Retrieve the current context from the navigator key
    final BuildContext context = GlobalSingleton.navigatorKey.currentState!.context;

    // Hide the loading dialog
    context.pop();

    return super.onResponse(response, handler);
  }

  @override
  Future<dynamic> onError(DioException err, ErrorInterceptorHandler handler) async {

    // Handling if the API request path does not have to show a loader
    final String path = err.requestOptions.path;
    if (_pathsNotShowingLoader.contains(path)) {
      return super.onError(err, handler);
    }

    // Retrieve the current context from the navigator key
    final BuildContext context = GlobalSingleton.navigatorKey.currentState!.context;

    // Hide the loading dialog
    context.pop();

    return super.onError(err, handler);
  }

}
