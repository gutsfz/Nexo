import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nexo/core/theme/app_theme.dart';
import 'package:nexo/domain/entities/completion.dart';
import 'package:nexo/domain/entities/habit.dart';
import 'package:nexo/presentation/providers/completion_providers.dart';
import 'package:nexo/presentation/providers/habit_providers.dart';

const _filterKey = 'history_filter'; // RN-21

// opções de período disponíveis
enum HistoryPeriod { week, month }

extension HistoryPeriodLabel on HistoryPeriod {
  String get label =>
      this == HistoryPeriod.week ? 'Últimos 7 dias' : 'Último mês';

  int get days => this == HistoryPeriod.week ? 7 : 30;
}

// tela de histórico — completions por período (RN-20), conectada aos dados reais
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

  // RN-21: restaura o filtro salvo
  Future<void> _restoreFilter() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_filterKey);
    if (saved == 'month') {
      setState(() => _selectedPeriod = HistoryPeriod.month);
    }
  }

  // RN-21: salva o filtro escolhido
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

  // label do dia: "Seg", "Ter", etc para semana; "DD/MM" para mês
  String _dayLabel(DateTime date, HistoryPeriod period) {
    if (period == HistoryPeriod.week) {
      const labels = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
      return labels[date.weekday - 1];
    }
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
  }

  // para cada dia do período, calcula (data, concluídos, agendados)
  List<(DateTime, int, int)> _buildDailyData(
    List<Habit> habits,
    List<Completion> completions,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final days = _selectedPeriod.days;

    return List.generate(days, (i) {
      final date = today.subtract(Duration(days: days - 1 - i));

      final scheduled = habits.where((h) => h.isScheduledFor(date)).toList();

      final completed = scheduled.where((h) {
        return completions.any((c) => c.habitId == h.id && c.isSameDay(date));
      }).length;

      return (date, completed, scheduled.length);
    }).reversed.toList(); // mais recente primeiro
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final habitsAsync = ref.watch(habitsProvider);
    final completionsAsync = ref.watch(completionsProvider);

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
        error: (error, _) => Center(child: Text('Erro: $error')),
        data: (habits) {
          return completionsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('Erro: $error')),
            data: (completions) {
              if (habits.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      'Nenhum hábito criado ainda.\nO histórico aparecerá aqui.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: onSurface.withValues(alpha: 0.6)),
                    ),
                  ),
                );
              }

              final dailyData = _buildDailyData(habits, completions);

              // RN-23: taxa média — considera só dias com hábitos agendados
              final daysWithSchedule = dailyData
                  .where((d) => d.$3 > 0)
                  .toList();

              final avgRate = daysWithSchedule.isEmpty
                  ? 0
                  : (daysWithSchedule
                                .map((d) => d.$2 / d.$3)
                                .reduce((a, b) => a + b) /
                            daysWithSchedule.length *
                            100)
                        .round();

              // melhor dia — maior taxa de conclusão (entre dias com agenda)
              final best = daysWithSchedule.isEmpty
                  ? null
                  : daysWithSchedule.reduce(
                      (a, b) => (a.$2 / a.$3) >= (b.$2 / b.$3) ? a : b,
                    );

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // lista de dias com barra de progresso
                  ...dailyData.map((day) {
                    final (date, completed, total) = day;
                    final progress = total == 0 ? 0.0 : completed / total;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 48,
                            child: Text(
                              _dayLabel(date, _selectedPeriod),
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
                                backgroundColor: onSurface.withValues(
                                  alpha: 0.1,
                                ),
                                valueColor: AlwaysStoppedAnimation(
                                  primaryColor,
                                ),
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

                  // resumo — taxa média e melhor dia (RN-23)
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
                                    best == null
                                        ? '-'
                                        : ' ${best.$2}/${best.$3}',
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
          );
        },
      ),
    );
  }
}
