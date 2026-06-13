import 'package:flutter/material.dart';

// tela inicial do app, onde o usuário pode acessar as principais funcionalidades
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nexo')),
      body: const Center(child: Text('Home')),
    );
  }
}