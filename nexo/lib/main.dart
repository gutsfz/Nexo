import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexo/core/theme/app_theme.dart';
import 'package:nexo/presentation/providers/theme_provider.dart';
import 'package:nexo/presentation/router/app_router.dart';

void main() {
  runApp(const ProviderScope(child: NexoApp()));
}

class NexoApp extends ConsumerWidget {
  const NexoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Nexo',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: createLightTheme(),
      darkTheme: createDarkTheme(),
      routerConfig: appRouter,
    );
  }
}