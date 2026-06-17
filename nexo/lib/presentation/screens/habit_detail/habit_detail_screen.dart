import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexo/core/theme/app_theme.dart';
import 'package:nexo/domain/entities/completion.dart';
import 'package:nexo/domain/entities/habit.dart';
import 'package:nexo/presentation/providers/completion_providers.dart';
import 'package:nexo/presentation/providers/habit_providers.dart';
import 'package:nexo/presentation/providers/repository_providers.dart';
import 'package:nexo/presentation/router/app_router.dart';

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

  int _totalDays(Habit habit) {
    final today = DateTime.now();
    final createdAt = DateTime(
        habit.createdAt.year, habit.createdAt.month, habit.createdAt.day);
    final todayDate = DateTime(today.year, today.month, today.day);
    return todayDate.difference(createdAt).inDays + 1;
  }

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

  // heatmap — 35 dias (5 semanas completas, Seg–Dom) começando 4 semanas atrás
  // status: -2=futuro, -1=não agendado, 0=pendente, 1=feito
  // armazenado em col-major: índice = col*7 + row (row 0=Seg … 6=Dom)
  List<(DateTime, int)> _heatmapData(Habit habit, List<Completion> completions) {
    final habitCompletions =
        completions.where((c) => c.habitId == habit.id).toList();
    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    final startMonday =
        todayDate.subtract(Duration(days: todayDate.weekday - 1 + 28));

    return List.generate(35, (i) {
      final day = startMonday.add(Duration(days: i));
      if (day.isAfter(todayDate)) return (day, -2);
      if (!habit.isScheduledFor(day)) return (day, -1);
      final done = habitCompletions.any((c) => c.isSameDay(day));
      return (day, done ? 1 : 0);
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
              final heatmap = _heatmapData(habit, completions);
              const weekLabels = ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
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

                  const Text('ÚLTIMAS 5 SEMANAS',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 12),
                  _HeatmapGrid(data: heatmap),
                  const SizedBox(height: 32),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => context.pushNamed(
                            AppRoutes.editHabit,
                            pathParameters: {'id': habit.id.toString()},
                          ),
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

class _HeatmapGrid extends StatelessWidget {
  final List<(DateTime, int)> data;

  const _HeatmapGrid({required this.data});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    const dayLabels = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    const monthNames = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez',
    ];
    const cellSize = 28.0;
    const gap = 4.0;
    const labelW = 32.0;

    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);

    // label de mês: col 0 sempre exibe; col 1–4 exibe quando o dia 1 cai na coluna
    final monthLabels = List<String?>.filled(5, null);
    final (firstDate, _) = data[0];
    monthLabels[0] = monthNames[firstDate.month - 1];
    for (int col = 1; col < 5; col++) {
      for (int row = 0; row < 7; row++) {
        final (date, _) = data[col * 7 + row];
        if (date.day == 1) {
          monthLabels[col] = monthNames[date.month - 1];
          break;
        }
      }
    }

    Color cellColor(int status) => switch (status) {
          -2 => Colors.transparent,
          -1 => onSurface.withValues(alpha: 0.06),
          0  => onSurface.withValues(alpha: 0.15),
          _  => primaryColor,
        };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const SizedBox(width: labelW + gap),
            ...List.generate(5, (col) => Padding(
              padding: EdgeInsets.only(right: col < 4 ? gap : 0),
              child: SizedBox(
                width: cellSize,
                child: Text(
                  monthLabels[col] ?? '',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                    color: onSurface.withValues(alpha: 0.55),
                  ),
                ),
              ),
            )),
          ],
        ),
        const SizedBox(height: 6),

        ...List.generate(7, (row) => Padding(
          padding: EdgeInsets.only(bottom: row < 6 ? gap : 0),
          child: Row(
            children: [
              SizedBox(
                width: labelW,
                child: Text(
                  dayLabels[row],
                  style: TextStyle(
                    fontSize: 10,
                    color: onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
              ...List.generate(5, (col) {
                final (date, status) = data[col * 7 + row];
                final isToday = date == todayDate;
                return Padding(
                  padding: EdgeInsets.only(right: col < 4 ? gap : 0),
                  child: Tooltip(
                    message:
                        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}',
                    child: Container(
                      width: cellSize,
                      height: cellSize,
                      decoration: BoxDecoration(
                        color: cellColor(status),
                        borderRadius: BorderRadius.circular(5),
                        border: isToday
                            ? Border.all(color: primaryColor, width: 1.5)
                            : null,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        )),

        const SizedBox(height: 10),

        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _LegendItem(color: onSurface.withValues(alpha: 0.06), label: 'Livre'),
            const SizedBox(width: 10),
            _LegendItem(color: onSurface.withValues(alpha: 0.15), label: 'Pendente'),
            const SizedBox(width: 10),
            _LegendItem(color: primaryColor, label: 'Feito'),
          ],
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 11,
          height: 11,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}