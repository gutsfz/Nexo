import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nexo/core/theme/app_theme.dart';
import 'package:nexo/domain/entities/habit.dart';
import 'package:nexo/domain/entities/completion.dart';
import 'package:nexo/presentation/providers/habit_providers.dart';
import 'package:nexo/presentation/providers/completion_providers.dart';

const _filterKey = 'history_filter';

enum HistoryPeriod { week, month }

extension HistoryPeriodLabel on HistoryPeriod {
  String get label =>
      this == HistoryPeriod.week ? 'Últimos 7 dias' : 'Último mês';
}

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  HistoryPeriod _selectedPeriod = HistoryPeriod.week;

  @override
  void initState() {
    super.initState();
    _restoreFilter();
  }

  Future<void> _restoreFilter() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_filterKey);
    if (saved == 'month') {
      setState(() => _selectedPeriod = HistoryPeriod.month);
    }
  }

  Future<void> _saveFilter(HistoryPeriod period) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _filterKey,
      period == HistoryPeriod.week ? 'week' : 'month',
    );
  }

  void _onPeriodChanged(HistoryPeriod period) {
    setState(() => _selectedPeriod = period);
    _saveFilter(period);
  }

  // Rótulo do dia baseado em DateTime
  String _dayLabel(DateTime date, int daysBack) {
    if (_selectedPeriod == HistoryPeriod.week) {
      const labels = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
      return labels[date.weekday % 7];
    }
    return 'Dia ${daysBack + 1}';
  }

  // Monta lista de (label, completed, total) usando dados reais
  List<(String, int, int)> _buildData(
    List<Habit> habits,
    List<Completion> completions,
  ) {
    final days = _selectedPeriod == HistoryPeriod.week ? 7 : 30;
    final today = DateTime.now();
    final result = <(String, int, int)>[];

    for (var i = 0; i < days; i++) {
      final date = today.subtract(Duration(days: i));
      final scheduled = habits.where((h) => h.isScheduledFor(date)).length;
      final completed = completions
          .where((c) => c.isSameDay(date))
          .map((c) => c.habitId)
          .toSet()
          .length;
      result.add((_dayLabel(date, i), completed, scheduled));
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final habitsAsync = ref.watch(habitsProvider);
    final completionsAsync = ref.watch(completionsProvider);
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico'),
        actions: [
          PopupMenuButton<HistoryPeriod>(
            initialValue: _selectedPeriod,
            onSelected: _onPeriodChanged,
            itemBuilder: (context) => HistoryPeriod.values
                .map((p) => PopupMenuItem(value: p, child: Text(p.label)))
                .toList(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(_selectedPeriod.label),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
      ),
      body: habitsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (habits) => completionsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Erro: $e')),
          data: (completions) {
            final data = _buildData(habits, completions);

            if (data.every((d) => d.$3 == 0)) {
              return const Center(
                child: Text('Nenhum hábito agendado neste período.'),
              );
            }

            final rates = data
                .where((d) => d.$3 > 0)
                .map((d) => d.$2 / d.$3)
                .toList();
            final avgRate = rates.isEmpty
                ? 0
                : (rates.reduce((a, b) => a + b) / rates.length * 100).round();
            final best = data.reduce(
              (a, b) => (a.$3 > 0 ? a.$2 / a.$3 : 0) >=
                      (b.$3 > 0 ? b.$2 / b.$3 : 0)
                  ? a
                  : b,
            );

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ...data.map((day) {
                  final (label, completed, total) = day;
                  final progress = total == 0 ? 0.0 : completed / total;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 48,
                          child: Text(
                            label,
                            style: TextStyle(color: onSurface, fontSize: 13),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 16,
                              backgroundColor: onSurface.withValues(alpha: 0.1),
                              valueColor:
                                  AlwaysStoppedAnimation(primaryColor),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 48,
                          child: Text(
                            '$completed/$total',
                            style: TextStyle(
                              color: onSurface.withValues(alpha: 0.7),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              '$avgRate%',
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text('Taxa média'),
                          ],
                        ),
                        Column(
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.local_fire_department,
                                  color: Colors.orange,
                                  size: 18,
                                ),
                                Text(
                                  ' ${best.$2}/${best.$3}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const Text('Melhor dia'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
