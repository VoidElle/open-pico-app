import 'package:open_pico_app/utils/constants/network_constants.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'global_providers.g.dart';

/// This class is responsible to expose global providers

// A provider for the global token
@Riverpod(keepAlive: true)
class GlobalToken extends _$GlobalToken {

  @override
  String build() => NetworkConstants.startingToken;

  void set(String newValue) => state = newValue;
  void reset() => state = NetworkConstants.startingToken;
}

// A provider for the global token
@Riverpod(keepAlive: true)
class GlobalUserEmail extends _$GlobalUserEmail {

  @override
  String? build() => null;

  void set(String newValue) => state = newValue;
  void reset() => state = null;
}