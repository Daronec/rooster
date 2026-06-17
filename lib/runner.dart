import 'dart:async';

import 'package:flutter/material.dart';

import 'package:rooster/config/app_dotenv.dart';
import 'package:rooster/config/environment/environment.dart';
import 'package:rooster/features/app/app_flow.dart';
import 'package:rooster/features/app/di/app_scope_register.dart';
import 'package:rooster/util/system_chrome_util.dart';

/// App launch.
Future<void> run(Environment env) async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      SystemChromeUtil.setDefaultSystemUIOverlayStyle();

      await loadAppDotEnv();

      await _runApp(env);
    },
    (error, stacktrace) {
      debugPrint(error.toString());
    },
  );
}

Future<void> _runApp(Environment env) async {
  const scopeRegister = AppScopeRegister();
  final scope = await scopeRegister.createScope(env);

  runApp(AppFlow(appScope: scope));
}
