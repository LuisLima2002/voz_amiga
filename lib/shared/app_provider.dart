import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voz_amiga/features/profissional/activity/services/activities.service.dart';
import 'package:voz_amiga/infra/services/login.service.dart';
import 'package:voz_amiga/infra/services/patients.service.dart';
import 'package:voz_amiga/shared/client.dart';

class AppProvider {
  static MultiProvider createAppWithProvider(Widget component) {
    return MultiProvider(
      providers: [
        Provider<ApiClient>(
          create: (_) => ApiClient(),
          key: const Key('apiClientProvider'),
        ),
        Provider<ActivitiesService>(
          create: (context) => ActivitiesService(),
          key: const Key('activitiesServiceProvider'),
        ),
        Provider<LoginService>(
          create: (_) => LoginService(),
          key: const Key('loginServiceProvider'),
        ),
        Provider<PatientsService>(
          create: (_) => PatientsService(),
          key: const Key('patientServiceProvider'),
        )
      ],
      child: component,
    );
  }
}
