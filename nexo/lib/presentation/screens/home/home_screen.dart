import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexo/core/theme/app_theme.dart';
import 'package:nexo/domain/entities/completion.dart';
import 'package:nexo/domain/entities/habit.dart';
import 'package:nexo/presentation/providers/completion_providers.dart';
import 'package:nexo/presentation/providers/habit_providers.dart';
import 'package:nexo/presentation/providers/quote_providers.dart';
import 'package:nexo/presentation/providers/repository_providers.dart';
import 'package:nexo/presentation/router/app_router.dart';
import 'package:nexo/presentation/widgets/habit_card.dart';
import 'package:nexo/presentation/widgets/progress_bar_card.dart';
import 'package:nexo/presentation/widgets/quote_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
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

  void _onReorder(
    int oldIndex,
    int newIndex,
    List<Habit> todayHabits,
    List<Habit> allHabits,
  ) {
    if (newIndex > oldIndex) newIndex--;

    final reordered = List<Habit>.from(todayHabits);
    final moved = reordered.removeAt(oldIndex);
    reordered.insert(newIndex, moved);

    final baseOrder = _habitOrder.isNotEmpty
        ? List<int>.from(_habitOrder)
        : allHabits.map((h) => h.id).toList();

    final todayIdSet = Set<int>.from(todayHabits.map((h) => h.id));
    final newOrder = <int>[];
    int todayIdx = 0;

    for (final id in baseOrder) {
      if (todayIdSet.contains(id)) {
        if (todayIdx < reordered.length) {
          newOrder.add(reordered[todayIdx].id);
          todayIdx++;
        }
      } else {
        newOrder.add(id);
      }
    }
    while (todayIdx < reordered.length) {
      newOrder.add(reordered[todayIdx].id);
      todayIdx++;
    }

    setState(() => _habitOrder = newOrder);
    _saveHabitOrder(newOrder);
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 12) return 'Bom dia 🌅';
    if (hour >= 12 && hour < 18) return 'Boa tarde 🌤';
    return 'Boa noite 🌙';
  }

  String _formattedDate() {
    final now = DateTime.now();
    const weekdays = [
      'Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo',
    ];
    const months = [
      'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
      'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro',
    ];
    return '${weekdays[now.weekday - 1]}, ${now.day} de ${months[now.month - 1]}';
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
        if (!habitCompletions.any((c) => c.isSameDay(day))) break;
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

  @override
  Widget build(BuildContext context) {
    final habitsAsync = ref.watch(habitsProvider);
    final completionsAsync = ref.watch(completionsProvider);
    final quoteAsync = ref.watch(dailyQuoteProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                primaryColor.withValues(alpha: 0.1),
                Colors.transparent,
              ],
            ),
          ),
        ),
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
      body: SafeArea(child: habitsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Erro: $error')),
        data: (allHabits) {
          return completionsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Erro: $error')),
            data: (completions) {
              final now = DateTime.now();
              final todayHabits = _sortHabits(
                allHabits.where((h) => h.isScheduledFor(now)).toList(),
              );
              final completedCount = todayHabits.where((h) {
                return completions
                    .any((c) => c.habitId == h.id && c.isSameDay(now));
              }).length;

              // pre-compute to avoid redundant work inside itemBuilder
              final streaks = {
                for (final h in todayHabits)
                  h.id: _calculateStreak(h, completions),
              };
              final weekStatuses = {
                for (final h in todayHabits)
                  h.id: _weekStatus(h, completions),
              };

              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(habitsProvider);
                  ref.invalidate(completionsProvider);
                },
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.07),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _greeting(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _formattedDate(),
                                    style: TextStyle(
                                      color: colorScheme.onSurface
                                          .withValues(alpha: 0.55),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          quoteAsync.when(
                            loading: () => const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 6),
                              child: Card(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: SizedBox(
                                    height: 60,
                                    child: Center(
                                        child: CircularProgressIndicator()),
                                  ),
                                ),
                              ),
                            ),
                            error: (_, _) => QuoteCard(
                              content:
                                  'Cada dia é uma nova oportunidade de melhorar seus hábitos.',
                              author: 'Nexo',
                              onRefresh: () async {
                                final repo =
                                    ref.read(quoteRepositoryProvider);
                                await repo.refreshQuote();
                                ref.invalidate(dailyQuoteProvider);
                              },
                            ),
                            data: (quote) => QuoteCard(
                              content: quote.content,
                              author: quote.author,
                              onRefresh: () async {
                                final repo =
                                    ref.read(quoteRepositoryProvider);
                                await repo.refreshQuote();
                                ref.invalidate(dailyQuoteProvider);
                              },
                            ),
                          ),

                          ProgressBarCard(
                            completed: completedCount,
                            total: todayHabits.length,
                          ),

                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(16, 16, 8, 8),
                            child: Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    'HÁBITOS DE HOJE',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => context
                                      .pushNamed(AppRoutes.allHabits),
                                  child: const Text('Ver todos'),
                                ),
                              ],
                            ),
                          ),

                          if (todayHabits.isEmpty)
                            _EmptyState(
                              onCreateHabit: () =>
                                  context.pushNamed(AppRoutes.addHabit),
                            ),
                        ],
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.only(bottom: 88),
                      sliver: SliverReorderableList(
                        itemCount: todayHabits.length,
                        onReorder: (oldIndex, newIndex) => _onReorder(
                            oldIndex, newIndex, todayHabits, allHabits),
                        proxyDecorator: (child, index, animation) {
                          return Material(
                            elevation: 6,
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            child: child,
                          );
                        },
                        itemBuilder: (context, i) {
                          return Material(
                            key: ValueKey(todayHabits[i].id),
                            color: Colors.transparent,
                            child: HabitCard(
                              emoji: todayHabits[i].emoji,
                              name: todayHabits[i].name,
                              category: todayHabits[i].category,
                              streak: streaks[todayHabits[i].id]!,
                              isCompleted: completions.any((c) =>
                                  c.habitId == todayHabits[i].id &&
                                  c.isSameDay(now)),
                              weekStatus: weekStatuses[todayHabits[i].id]!,
                              dragHandle: ReorderableDragStartListener(
                                index: i,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4),
                                  child: Icon(
                                    Icons.drag_handle,
                                    color: colorScheme.onSurface
                                        .withValues(alpha: 0.4),
                                    size: 20,
                                  ),
                                ),
                              ),
                              onToggle: () async {
                                final repo =
                                    ref.read(completionRepositoryProvider);
                                final done = completions.any((c) =>
                                    c.habitId == todayHabits[i].id &&
                                    c.isSameDay(now));
                                if (done) {
                                  await repo.unmarkCompleted(
                                      todayHabits[i].id, now);
                                } else {
                                  await repo.markCompleted(
                                      todayHabits[i].id, now);
                                }
                                ref.invalidate(completionsProvider);
                              },
                              onTap: () => context.pushNamed(
                                AppRoutes.habitDetail,
                                pathParameters: {
                                  'id': todayHabits[i].id.toString(),
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      )),
    );
  }
}

class _EmptyState extends StatefulWidget {
  final VoidCallback onCreateHabit;

  const _EmptyState({required this.onCreateHabit});

  @override
  State<_EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<_EmptyState>
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
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
    );
  }
}
