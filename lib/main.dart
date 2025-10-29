import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:open_pico_app/pages/auth_page.dart';
import 'package:open_pico_app/pages/offline/offline_devices_list_page.dart';
import 'package:open_pico_app/pages/pico_status_page.dart';
import 'package:open_pico_app/pages/plants_list_page.dart';
import 'package:open_pico_app/repositories/secure_storage_repository.dart';
import 'package:open_pico_app/repositories/shared_preferences_repository.dart';
import 'package:open_pico_app/utils/constants/translations_constants.dart';
import 'package:open_pico_app/utils/global_singleton.dart';
import 'package:easy_localization/easy_localization.dart';

import 'models/props/pico_status_page_props.dart';

Future<void> main() async {

  // Ensure that the widgets are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the localizations
  await EasyLocalization.ensureInitialized();

  // Dark icons on notifications top
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  // Initialize the secure storage repository
  SecureStorageRepository.initialize();

  // Initialize the shared preferences repository
  await SharedPreferencesRepository.initialize();

  // runApp with localization and Riverpod handling
  runApp(
    EasyLocalization(
        supportedLocales: TranslationsConstants.supportedLocales,
        path: TranslationsConstants.localizationPath,
        fallbackLocale: TranslationsConstants.fallbackLocale,
        child: ProviderScope(
          child: const OpenPico(),
        ),
    ),
  );
}

final GoRouter _router = GoRouter(
  navigatorKey: GlobalSingleton.navigatorKey,
  routes: [
    GoRoute(
      path: AuthPage.route,
      builder: (BuildContext _, GoRouterState _) => AuthPage(),
    ),
    GoRoute(
      path: PlantsListPage.route,
      builder: (BuildContext _, GoRouterState _) => PlantsListPage(),
    ),
    GoRoute(
      path: PicoStatusPage.route,
      builder: (BuildContext _, GoRouterState state) {
        final PicoStatusPageProps picoStatusPageProps = state.extra as PicoStatusPageProps;
        return PicoStatusPage(
          picoStatusPageProps: picoStatusPageProps,
        );
      },
    ),
    GoRoute(
      path: OfflineDevicesListPage.route,
      builder: (BuildContext _, GoRouterState _) => OfflineDevicesListPage(),
    ),
  ],
);

class OpenPico extends StatelessWidget {

  const OpenPico({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      title: 'Open Pico',
      routerConfig: _router,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: false,
        textTheme: TextTheme(
          titleLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        )
      ),
      // home: const AuthPage(),
    );
  }

}
