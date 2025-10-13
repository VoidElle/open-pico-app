import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generated/global_providers.g.dart';

/// This class is responsible to expose global providers

// A provider for the global token
@Riverpod(keepAlive: true)
class GlobalUserEmail extends _$GlobalUserEmail {

  @override
  String? build() => null;

  void set(String newValue) => state = newValue;
  void reset() => state = null;
}

// A provider for the global Secure Storage repository
@Riverpod(keepAlive: true)
class GlobalSecureStorageRepository extends _$GlobalSecureStorageRepository {

  @override
  GlobalSecureStorageRepository build() => GlobalSecureStorageRepository();

}

@Riverpod(keepAlive: true)
class GlobalIdpCounterRepository extends _$GlobalIdpCounterRepository {

  @override
  int build() => 0;

  void set(int newValue) => state = newValue;
  void reset() => state = 0;
  void increment() => state++;
}