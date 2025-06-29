import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:open_pico_app/utils/global_singleton.dart';
import 'package:open_pico_app/widgets/dialogs/loading_dialog.dart';

class NetworkInterceptor extends InterceptorsWrapper {

  @override
  Future<dynamic> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {

    // Retrieve the current context from the navigator key
    final BuildContext context = GlobalSingleton.navigatorKey.currentState!.context;

    // Show the loading dialog
    showDialog<LoadingDialog>(
      context: context,
      useSafeArea: false,
      builder: (BuildContext context) => const LoadingDialog(),
    );

    return super.onRequest(options, handler);
  }

  @override
  Future<dynamic> onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) async {

    // Retrieve the current context from the navigator key
    final BuildContext context = GlobalSingleton.navigatorKey.currentState!.context;

    // Hide the loading dialog
    context.pop();

    return super.onResponse(response, handler);
  }

  @override
  Future<dynamic> onError(DioException err, ErrorInterceptorHandler handler) async {

    // Retrieve the current context from the navigator key
    final BuildContext context = GlobalSingleton.navigatorKey.currentState!.context;

    // Hide the loading dialog
    context.pop();

    return super.onError(err, handler);
  }

}
