import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voz_amiga/pages/container.page.dart';
import 'package:voz_amiga/shared/client.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider<ClientHttp>(
          create: (_) => ClientHttp(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voz Amiga',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const ContainerPage(),
    );
  }
}
