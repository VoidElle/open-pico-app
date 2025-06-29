import 'package:flutter/material.dart';

class GlobalSingleton {

  // Global Navigator state, injected into MaterialApp
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

}