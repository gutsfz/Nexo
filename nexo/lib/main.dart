import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexo/core/theme/app_theme.dart';
import 'package:nexo/presentation/router/app_router.dart';

void main() {
  runApp(const ProviderScope(child: NexoApp()));
}

class NexoApp extends StatelessWidget {
  const NexoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Nexo',
      debugShowCheckedModeBanner: false,
      theme: createDarkTheme(),
      routerConfig: appRouter,
    );
  }
}