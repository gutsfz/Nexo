import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexo/core/theme/app_theme.dart';
import 'package:nexo/domain/entities/completion.dart';
import 'package:nexo/domain/entities/habit.dart';
import 'package:nexo/presentation/providers/completion_providers.dart';
import 'package:nexo/presentation/providers/habit_providers.dart';
import 'package:nexo/presentation/providers/repository_providers.dart';

// tela de detalhe do hábito — conectada aos dados reais
// recebe o id via parâmetro de rota (go_router)
class HabitDetailScreen extends ConsumerWidget {
  final int habitId;

  const HabitDetailScreen({required this.habitId, super.key});

  // RN-06: taxa de conclusão = completions / dias agendados desde a criação até hoje
  int _completionRate(Habit habit, List<Completion> completions) {
    final habitCompletions =
        completions.where((c) => c.habitId == habit.id).toList();

    final today = DateTime.now();
    final createdAt = DateTime(
        habit.createdAt.year, habit.createdAt.month, habit.createdAt.day);
    final todayDate = DateTime(today.year, today.month, today.day);

    int scheduledCount = 0;
    int completedCount = 0;

    for (var day = createdAt;
        !day.isAfter(todayDate);
        day = day.add(const Duration(days: 1))) {
      if (habit.isScheduledFor(day)) {
        scheduledCount++;
        if (habitCompletions.any((c) => c.isSameDay(day))) {
          completedCount++;
        }
      }
    }

    if (scheduledCount == 0) return 0;
    return (completedCount / scheduledCount * 100).round();
  }

  // total de dias desde a criação do hábito (inclusive hoje)
  int _totalDays(Habit habit) {
    final today = DateTime.now();
    final createdAt = DateTime(
        habit.createdAt.year, habit.createdAt.month, habit.createdAt.day);
    final todayDate = DateTime(today.year, today.month, today.day);
    return todayDate.difference(createdAt).inDays + 1;
  }

  // streak — dias consecutivos agendados e concluídos, terminando hoje ou ontem
  int _calculateStreak(Habit habit, List<Completion> completions) {
    final habitCompletions =
        completions.where((c) => c.habitId == habit.id).toList();

    int streak = 0;
    var day = DateTime.now();

    final completedToday = habitCompletions.any((c) => c.isSameDay(day));
    if (!completedToday && habit.isScheduledFor(day)) {
      day = day.subtract(const Duration(days: 1));
    }

    while (true) {
      if (habit.isScheduledFor(day)) {
        final done = habitCompletions.any((c) => c.isSameDay(day));
        if (!done) break;
        streak++;
      }
      day = day.subtract(const Duration(days: 1));
      if (DateTime.now().difference(day).inDays > 365) break;
    }

    return streak;
  }

  // status dos 7 dias da semana atual (seg a dom)
  List<bool> _weekStatus(Habit habit, List<Completion> completions) {
    final habitCompletions =
        completions.where((c) => c.habitId == habit.id).toList();

    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));

    return List.generate(7, (i) {
      final day = monday.add(Duration(days: i));
      return habitCompletions.any((c) => c.isSameDay(day));
    });
  }

  // heatmap dos últimos 30 dias — intensidade 0 (não feito) ou 1 (feito)
  // só considera dias em que o hábito estava agendado
  List<int> _heatmap(Habit habit, List<Completion> completions) {
    final habitCompletions =
        completions.where((c) => c.habitId == habit.id).toList();

    final today = DateTime.now();

    return List.generate(30, (i) {
      final day = today.subtract(Duration(days: 29 - i));
      if (!habit.isScheduledFor(day)) return -1; // não agendado
      final done = habitCompletions.any((c) => c.isSameDay(day));
      return done ? 1 : 0;
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final habitsAsync = ref.watch(habitsProvider);
    final completionsAsync = ref.watch(completionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhe do Hábito')),
      body: habitsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Erro: $error')),
        data: (habits) {
          final habit = habits.where((h) => h.id == habitId).firstOrNull;

          if (habit == null) {
            return const Center(child: Text('Hábito não encontrado.'));
          }

          return completionsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('Erro: $error')),
            data: (completions) {
              final streak = _calculateStreak(habit, completions);
              final completionRate = _completionRate(habit, completions);
              final totalDays = _totalDays(habit);
              final weekStatus = _weekStatus(habit, completions);
              final heatmap = _heatmap(habit, completions);
              const weekLabels = ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // emoji e nome
                  Center(
                    child: Column(
                      children: [
                        Text(habit.emoji, style: const TextStyle(fontSize: 48)),
                        const SizedBox(height: 8),
                        Text(habit.name,
                            style: Theme.of(context).textTheme.titleLarge),
                        Text('Categoria: ${habit.category}',
                            style: TextStyle(
                                color: onSurface.withValues(alpha: 0.6),
                                fontSize: 13)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // estatísticas: streak, taxa de conclusão, dias totais
                  Row(
                    children: [
                      _StatBox(
                        icon: Icons.local_fire_department,
                        iconColor: Colors.orange,
                        value: '$streak',
                        label: 'streak',
                      ),
                      const SizedBox(width: 12),
                      _StatBox(
                        icon: Icons.percent,
                        iconColor: primaryColor,
                        value: '$completionRate%',
                        label: 'concl.',
                      ),
                      const SizedBox(width: 12),
                      _StatBox(
                        icon: Icons.calendar_month,
                        iconColor: primaryColor,
                        value: '$totalDays',
                        label: 'dias',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // dias da semana agendados
                  const Text('DIAS DA SEMANA',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(7, (i) {
                      final isScheduled = habit.weekdays.contains(i);
                      return Column(
                        children: [
                          Text(weekLabels[i],
                              style: TextStyle(
                                  color: onSurface.withValues(alpha: 0.6),
                                  fontSize: 12)),
                          const SizedBox(height: 6),
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: !isScheduled
                                  ? onSurface.withValues(alpha: 0.05)
                                  : weekStatus[i]
                                      ? primaryColor
                                      : onSurface.withValues(alpha: 0.1),
                            ),
                            child: weekStatus[i]
                                ? const Icon(Icons.check,
                                    color: Colors.white, size: 18)
                                : null,
                          ),
                        ],
                      );
                    }),
                  ),
                  const SizedBox(height: 24),

                  // heatmap dos últimos 30 dias
                  const Text('ÚLTIMOS 30 DIAS',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: heatmap.map((status) {
                      Color color;
                      if (status == -1) {
                        color = onSurface.withValues(alpha: 0.04); // não agendado
                      } else if (status == 1) {
                        color = primaryColor; // concluído
                      } else {
                        color = onSurface.withValues(alpha: 0.12); // não concluído
                      }
                      return Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),

                  // botões de ação
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            // edição será implementada depois, se houver tempo
                          },
                          child: const Text('Editar'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _confirmDelete(context, ref, habit),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                          ),
                          child: const Text('Excluir'),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  // RN-07: pede confirmação antes de excluir
  void _confirmDelete(BuildContext context, WidgetRef ref, Habit habit) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir hábito'),
        content: const Text(
            'Tem certeza? Isso vai remover o hábito e todo o histórico.'),
        actions: [
          TextButton(
            onPressed: () => dialogContext.pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final repository = ref.read(habitRepositoryProvider);
              await repository.deleteHabit(habit.id);
              ref.invalidate(habitsProvider);
              ref.invalidate(completionsProvider);

              if (dialogContext.mounted) dialogContext.pop();
              if (context.mounted) context.pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}

// card pequeno para mostrar uma estatística
class _StatBox extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatBox({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(icon, color: iconColor),
              const SizedBox(height: 4),
              Text(value,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              Text(label,
                  style: TextStyle(
                      fontSize: 11, color: onSurface.withValues(alpha: 0.6))),
            ],
          ),
        ),
      ),
    );
  }
}