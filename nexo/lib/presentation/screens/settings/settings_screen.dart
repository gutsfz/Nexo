import 'package:flutter/material.dart';

// tela para exibir as configurações do app
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ConfigSurações')),
      body: const Center(child: Text('Configurações')),
    );
  }
}