import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nexo/core/database/database_helper.dart';
import 'package:nexo/presentation/providers/completion_providers.dart';
import 'package:nexo/presentation/providers/habit_providers.dart';
import 'package:nexo/presentation/providers/theme_provider.dart';
import 'package:nexo/presentation/router/app_router.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  Future<void> _clearAllData() async {
    await DatabaseHelper.instance.clearAllData();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    ref.invalidate(habitsProvider);
    ref.invalidate(completionsProvider);
    context.goNamed(AppRoutes.home);
  }

  void _showClearDataDialog() {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Limpar todos os dados'),
        content: const Text(
          'Isso vai apagar todos os hábitos, histórico e configurações. '
          'Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Limpar tudo'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) _clearAllData();
    });
  }

  @override
  Widget build(BuildContext context) {
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
            subtitle: Text('1.0.1'),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Sobre o App'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.pushNamed(AppRoutes.about),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Política de Privacidade'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.pushNamed(AppRoutes.privacy),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text('DADOS',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text(
              'Limpar todos os dados',
              style: TextStyle(color: Colors.red),
            ),
            onTap: _showClearDataDialog,
          ),
        ],
      ),
    );
  }
}
