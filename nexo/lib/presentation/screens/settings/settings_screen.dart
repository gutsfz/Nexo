import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexo/presentation/providers/theme_provider.dart';
import 'package:nexo/presentation/router/app_router.dart';
import 'package:go_router/go_router.dart';

// tela de configurações com opção de tema escuro e informações sobre o app
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text('APARÊNCIA',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          SwitchListTile(
            title: const Text('Tema escuro'),
            subtitle: Text(isDark ? 'Ativado' : 'Desativado'),
            value: isDark,
            onChanged: (_) {
              ref.read(themeProvider.notifier).toggleTheme();
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text('SOBRE',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          const ListTile(
            title: Text('Versão'),
            subtitle: Text('1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Sobre o App'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.pushNamed(AppRoutes.about),
          ),
        ],
      ),
    );
  }
}