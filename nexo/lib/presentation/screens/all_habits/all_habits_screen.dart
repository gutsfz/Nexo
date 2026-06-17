import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexo/core/theme/app_theme.dart';
import 'package:nexo/domain/entities/habit.dart';
import 'package:nexo/presentation/providers/habit_providers.dart';
import 'package:nexo/presentation/router/app_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AllHabitsScreen extends ConsumerStatefulWidget {
  const AllHabitsScreen({super.key});

  @override
  ConsumerState<AllHabitsScreen> createState() => _AllHabitsScreenState();
}

class _AllHabitsScreenState extends ConsumerState<AllHabitsScreen> {
  List<int> _habitOrder = [];

  @override
  void initState() {
    super.initState();
    _loadHabitOrder();
  }

  Future<void> _loadHabitOrder() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('habit_order') ?? [];
    if (mounted) {
      setState(() {
        _habitOrder = saved.map((s) => int.parse(s)).toList();
      });
    }
  }

  Future<void> _saveHabitOrder(List<int> order) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        'habit_order', order.map((id) => id.toString()).toList());
  }

  List<Habit> _sortHabits(List<Habit> habits) {
    if (_habitOrder.isEmpty) return habits;
    final ordered = <Habit>[];
    for (final id in _habitOrder) {
      final habit = habits.where((h) => h.id == id).firstOrNull;
      if (habit != null) ordered.add(habit);
    }
    for (final h in habits) {
      if (!ordered.any((o) => o.id == h.id)) ordered.add(h);
    }
    return ordered;
  }

  void _onReorder(int oldIndex, int newIndex, List<Habit> sorted) {
    if (newIndex > oldIndex) newIndex--;
    final reordered = List<Habit>.from(sorted);
    final moved = reordered.removeAt(oldIndex);
    reordered.insert(newIndex, moved);
    final newOrder = reordered.map((h) => h.id).toList();
    setState(() => _habitOrder = newOrder);
    _saveHabitOrder(newOrder);
  }

  @override
  Widget build(BuildContext context) {
    final habitsAsync = ref.watch(habitsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Todos os Hábitos')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.pushNamed(AppRoutes.addHabit),
        child: const Icon(Icons.add),
      ),
      body: habitsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Erro: $error')),
        data: (habits) {
          if (habits.isEmpty) {
            return _AllHabitsEmptyState(
              onCreateHabit: () => context.pushNamed(AppRoutes.addHabit),
            );
          }

          final sorted = _sortHabits(habits);

          return ReorderableListView.builder(
            buildDefaultDragHandles: false,
            padding: const EdgeInsets.only(top: 8, bottom: 88),
            proxyDecorator: (child, index, animation) {
              return Material(
                elevation: 6,
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: child,
              );
            },
            onReorder: (oldIndex, newIndex) =>
                _onReorder(oldIndex, newIndex, sorted),
            itemCount: sorted.length,
            itemBuilder: (context, i) {
              return _HabitListTile(
                key: ValueKey(sorted[i].id),
                habit: sorted[i],
                index: i,
                onTap: () => context.pushNamed(
                  AppRoutes.habitDetail,
                  pathParameters: {'id': sorted[i].id.toString()},
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _HabitListTile extends StatelessWidget {
  static const _weekdayLabels = [
    'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom',
  ];

  final Habit habit;
  final int index;
  final VoidCallback onTap;

  const _HabitListTile({
    required this.habit,
    required this.index,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ReorderableDragStartListener(
                index: index,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    Icons.drag_handle,
                    color: onSurface.withValues(alpha: 0.4),
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(habit.emoji,
                    style: const TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.category.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      habit.name,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: onSurface),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: List.generate(7, (i) {
                        final scheduled = habit.weekdays.contains(i);
                        return Container(
                          width: 30,
                          height: 22,
                          decoration: BoxDecoration(
                            color: scheduled
                                ? primaryColor.withValues(alpha: 0.2)
                                : onSurface.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _weekdayLabels[i],
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: scheduled
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: scheduled
                                  ? primaryColor
                                  : onSurface.withValues(alpha: 0.3),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: onSurface.withValues(alpha: 0.3),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AllHabitsEmptyState extends StatefulWidget {
  final VoidCallback onCreateHabit;

  const _AllHabitsEmptyState({required this.onCreateHabit});

  @override
  State<_AllHabitsEmptyState> createState() => _AllHabitsEmptyStateState();
}

class _AllHabitsEmptyStateState extends State<_AllHabitsEmptyState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return FadeTransition(
      opacity: _fade,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/icon.png', width: 120, height: 120),
              const SizedBox(height: 24),
              Text(
                'Nenhum hábito para hoje',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Que tal criar seu primeiro hábito e começar sua jornada?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: onSurface.withValues(alpha: 0.6),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: widget.onCreateHabit,
                icon: const Icon(Icons.add),
                label: const Text('Criar hábito'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
