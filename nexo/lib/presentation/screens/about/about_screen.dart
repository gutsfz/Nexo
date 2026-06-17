import 'package:flutter/material.dart';
import 'package:nexo/core/theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(title: const Text('Sobre o App')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // header do app
          Center(
            child: Column(
              children: [
                Image.asset('assets/images/icon.png', width: 100, height: 100),
                const SizedBox(height: 12),
                Text('Nexo',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Versão 1.0.0',
                    style: TextStyle(
                        color: onSurface.withValues(alpha: 0.5),
                        fontSize: 13)),
                const SizedBox(height: 12),
                Text(
                  '"Conecte seus hábitos, construa seu futuro."',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: primaryColor,
                      fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),

          // desenvolvido por
          Text('DESENVOLVIDO POR',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: onSurface.withValues(alpha: 0.6))),
          const SizedBox(height: 12),
          // coloque os nomes do grupo aqui
          _InfoTile(icon: Icons.person, label: 'João Rodriques'),
          _InfoTile(icon: Icons.person, label: 'Fernando Fernandes'),
          _InfoTile(icon: Icons.person, label: 'Gustavo Monteiro'),
          const SizedBox(height: 24),

          // tecnologias
          Text('TECNOLOGIAS',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: onSurface.withValues(alpha: 0.6))),
          const SizedBox(height: 12),
          _InfoTile(icon: Icons.flutter_dash, label: 'Flutter'),
          _InfoTile(icon: Icons.layers, label: 'Riverpod'),
          _InfoTile(icon: Icons.storage, label: 'SQLite'),
          _InfoTile(icon: Icons.route, label: 'GoRouter'),
          _InfoTile(icon: Icons.cloud, label: 'Dio'),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),
          Center(
            child: Text(
              '© 2026 Nexo. Todos os direitos reservados.',
              style: TextStyle(
                  fontSize: 12,
                  color: onSurface.withValues(alpha: 0.4)),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoTile({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: primaryColor),
          const SizedBox(width: 12),
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}