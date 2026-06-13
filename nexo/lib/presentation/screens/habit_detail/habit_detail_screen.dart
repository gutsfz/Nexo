import 'package:flutter/material.dart';

// tela para exibir detalhes de um hábito específico
class HabitDetailScreen extends StatelessWidget {
  final int habitId;

  const HabitDetailScreen({required this.habitId, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhe do Hábito')),
      body: Center(child: Text('Hábito #$habitId')),
    );
  }
}