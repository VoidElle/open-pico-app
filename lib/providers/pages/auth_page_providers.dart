import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_page_providers.g.dart';

/// This class is responsible to expose the providers for the auth page

/// A provider for the auth page form key, which is used to validate the form
@Riverpod()
GlobalKey<FormState> authPageFormKey(Ref ref) => GlobalKey<FormState>();

/// A provider for the auth page email controller, which is used to control the email text field
@Riverpod()
TextEditingController authPageEmailController(Ref ref) => TextEditingController();

/// A provider for the auth page password controller, which is used to control the password text field
@Riverpod()
TextEditingController authPagePasswordController(Ref ref) => TextEditingController();