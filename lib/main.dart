import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:voz_amiga/infra/log/logger.dart';
import 'package:voz_amiga/shared/app.routes.dart';
import 'package:voz_amiga/shared/app_provider.dart';
import 'package:voz_amiga/shared/client.dart';

void main() {
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    logger.e('${record.level.name}: ${record.time}: ${record.message}');
  });
  if (kDebugMode) {
    HttpOverrides.global = BypassCertificateOverride();
  }
  GoRouter.optionURLReflectsImperativeAPIs = true;
  runApp(AppProvider.createAppWithProvider(const VozAmiga()));
}

class VozAmiga extends StatelessWidget {
  const VozAmiga({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Voz Amiga',
      debugShowCheckedModeBanner: false,
      onNavigationNotification: (notification) {
        return false;
      },
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      routerConfig: AppRouteConfig.getRouterConfig(),
    );
  }
}
