import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nexo/core/theme/app_theme.dart';
import 'package:nexo/domain/entities/completion.dart';
import 'package:nexo/domain/entities/habit.dart';
import 'package:nexo/presentation/providers/completion_providers.dart';
import 'package:nexo/presentation/providers/habit_providers.dart';

const _filterKey = 'history_filter';

enum HistoryPeriod { week, month }

extension HistoryPeriodLabel on HistoryPeriod {
  String get label =>
      this == HistoryPeriod.week ? 'Últimos 7 dias' : 'Último mês';

  int get days => this == HistoryPeriod.week ? 7 : 30;
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
    if (saved == 'month' && mounted) {
      setState(() => _selectedPeriod = HistoryPeriod.month);
    }
  }

  Future<void> _saveFilter(HistoryPeriod period) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _filterKey, period == HistoryPeriod.week ? 'week' : 'month');
  }

  void _onPeriodChanged(HistoryPeriod period) {
    setState(() => _selectedPeriod = period);
    _saveFilter(period);
  }

  String _dayLabel(DateTime date, HistoryPeriod period) {
    if (period == HistoryPeriod.week) {
      const labels = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
      return labels[date.weekday - 1];
    }
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
  }

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
    }).reversed.toList(); // most recent first
  }

  int _computeBestStreak(List<(DateTime, int, int)> data) {
    // iterate chronologically (oldest first) to find the longest run of active days
    int maxStreak = 0;
    int current = 0;
    for (final (_, completed, total) in data.reversed) {
      if (total == 0) continue;
      if (completed > 0) {
        current++;
        if (current > maxStreak) maxStreak = current;
      } else {
        current = 0;
      }
    }
    return maxStreak;
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
                      style:
                          TextStyle(color: onSurface.withValues(alpha: 0.6)),
                    ),
                  ),
                );
              }

              final dailyData = _buildDailyData(habits, completions);
              final daysWithSchedule =
                  dailyData.where((d) => d.$3 > 0).toList();

              final avgRate = daysWithSchedule.isEmpty
                  ? 0
                  : (daysWithSchedule
                              .map((d) => d.$2 / d.$3)
                              .reduce((a, b) => a + b) /
                          daysWithSchedule.length *
                          100)
                      .round();

              final bestStreak = _computeBestStreak(dailyData);
              final activeDays = dailyData.where((d) => d.$2 > 0).length;

              // build list items, injecting week separators for month view
              final items = <Widget>[];
              for (int i = 0; i < dailyData.length; i++) {
                if (_selectedPeriod == HistoryPeriod.month && i % 7 == 0) {
                  items.add(_WeekSeparator(
                      label: 'Semana ${(i ~/ 7) + 1}', onSurface: onSurface));
                }
                final (date, completed, total) = dailyData[i];
                final progress = total == 0 ? 0.0 : completed / total;
                items.add(_DayRow(
                  label: _dayLabel(date, _selectedPeriod),
                  progress: progress,
                  pct: (progress * 100).round(),
                  isZebra: i.isEven,
                  onSurface: onSurface,
                ));
              }

              return ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  _SummaryCard(
                    avgRate: avgRate,
                    bestStreak: bestStreak,
                    activeDays: activeDays,
                  ),
                  const SizedBox(height: 8),
                  ...items,
                ],
              );
            },
          );
        },
      ),
    );
  }
}

// ── summary card ────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final int avgRate;
  final int bestStreak;
  final int activeDays;

  const _SummaryCard({
    required this.avgRate,
    required this.bestStreak,
    required this.activeDays,
  });

  @override
  Widget build(BuildContext context) {
    final dividerColor =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1);

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        child: Row(
          children: [
            Expanded(
              child: _MetricItem(
                value: '$avgRate%',
                label: 'Taxa Média',
                icon: Icons.show_chart,
                color: primaryColor,
              ),
            ),
            Container(width: 1, height: 48, color: dividerColor),
            Expanded(
              child: _MetricItem(
                value: '$bestStreak',
                label: 'Melhor Sequência',
                icon: Icons.local_fire_department,
                color: Colors.orange,
              ),
            ),
            Container(width: 1, height: 48, color: dividerColor),
            Expanded(
              child: _MetricItem(
                value: '$activeDays',
                label: 'Dias Ativos',
                icon: Icons.check_circle_outline,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _MetricItem({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
              color: color, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: onSurface.withValues(alpha: 0.55), fontSize: 11),
        ),
      ],
    );
  }
}

// ── week separator ───────────────────────────────────────────────────────────

class _WeekSeparator extends StatelessWidget {
  final String label;
  final Color onSurface;

  const _WeekSeparator({required this.label, required this.onSurface});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: onSurface.withValues(alpha: 0.4),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Divider(
                color: onSurface.withValues(alpha: 0.12), height: 1),
          ),
        ],
      ),
    );
  }
}

// ── daily row ────────────────────────────────────────────────────────────────

class _DayRow extends StatelessWidget {
  final String label;
  final double progress;
  final int pct;
  final bool isZebra;
  final Color onSurface;

  const _DayRow({
    required this.label,
    required this.progress,
    required this.pct,
    required this.isZebra,
    required this.onSurface,
  });

  @override
  Widget build(BuildContext context) {
    final isEmpty = progress == 0.0;
    final isFull = pct == 100;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      decoration: BoxDecoration(
        color: isZebra ? onSurface.withValues(alpha: 0.03) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            child: Text(
              label,
              style: TextStyle(
                color: onSurface,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: progress),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOut,
              builder: (context, value, _) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Stack(
                    children: [
                      Container(
                        height: 10,
                        color: onSurface.withValues(
                            alpha: isEmpty ? 0.05 : 0.12),
                      ),
                      if (value > 0)
                        FractionallySizedBox(
                          widthFactor: value,
                          child: Container(
                            height: 10,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  primaryColor.withValues(alpha: 0.7),
                                  primaryColor,
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 52,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '$pct%',
                  style: TextStyle(
                    color: isEmpty
                        ? onSurface.withValues(alpha: 0.3)
                        : onSurface.withValues(alpha: 0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (isFull) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.check_circle,
                      color: Colors.green, size: 14),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
