import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nexo/presentation/router/app_router.dart';
import 'package:nexo/presentation/widgets/habit_card.dart';
import 'package:nexo/presentation/widgets/progress_bar_card.dart';
import 'package:nexo/presentation/widgets/quote_card.dart';

// tela inicial — lista de hábitos do dia
// por enquanto com dados mockados, depois troca pelos providers
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // mock de hábitos — virá do provider depois
  final List<Map<String, dynamic>> _habits = [
    {
      'id': 1,
      'emoji': '🧘',
      'name': 'Vacuum Matinal',
      'category': 'Mindfulness',
      'streak': 14,
      'isCompleted': true,
      'week': [true, true, false, true, true, true, true],
    },
    {
      'id': 2,
      'emoji': '📖',
      'name': 'Leitura 30 minutos',
      'category': 'Aprendizado',
      'streak': 7,
      'isCompleted': false,
      'week': [true, false, true, true, false, true, false],
    },
    {
      'id': 3,
      'emoji': '🏃',
      'name': 'Corrida 5km',
      'category': 'Fitness',
      'streak': 21,
      'isCompleted': true,
      'week': [true, true, true, false, true, false, true],
    },
    {
      'id': 4,
      'emoji': '💧',
      'name': 'Beber 2L de água',
      'category': 'Saúde',
      'streak': 5,
      'isCompleted': false,
      'week': [true, true, true, true, false, false, true],
    },
  ];

  // mock da citação do dia
  final String _quoteContent =
      'Minha misericórdia prevalece sobre minha Ira.';
  final String _quoteAuthor = 'Rick Grimes';

  void _toggleHabit(int index) {
    setState(() {
      _habits[index]['isCompleted'] = !_habits[index]['isCompleted'];
    });
  }

  void _refreshQuote() {
    // por enquanto só um placeholder - vira chamada ao provider
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final completed = _habits.where((h) => h['isCompleted'] == true).length;
    final total = _habits.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nexo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () => context.pushNamed(AppRoutes.history),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.pushNamed(AppRoutes.settings),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.pushNamed(AppRoutes.addHabit),
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        children: [
          QuoteCard(
            content: _quoteContent,
            author: _quoteAuthor,
            onRefresh: _refreshQuote,
          ),
          ProgressBarCard(completed: completed, total: total),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text('HÁBITOS DE HOJE',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          ...List.generate(_habits.length, (index) {
            final habit = _habits[index];
            return HabitCard(
              emoji: habit['emoji'],
              name: habit['name'],
              category: habit['category'],
              streak: habit['streak'],
              isCompleted: habit['isCompleted'],
              weekStatus: List<bool>.from(habit['week']),
              onToggle: () => _toggleHabit(index),
              onTap: () => context.pushNamed(
                AppRoutes.habitDetail,
                pathParameters: {'id': habit['id'].toString()},
              ),
            );
          }),
        ],
      ),
    );
  }
}