import 'package:flutter/material.dart';
  
// tela para adicionar um novo hábito
class AddHabitScreen extends StatelessWidget {
  const AddHabitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo Hábito')),
      body: const Center(child: Text('Adicionar Hábito')),
    );
  }
}