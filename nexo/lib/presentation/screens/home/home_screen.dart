import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

// tela inicial — lista de hábitos do dia, conectada aos providers reais
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  // calcula a streak (dias consecutivos concluídos) terminando hoje ou ontem
  int _calculateStreak(Habit habit, List<Completion> completions) {
    final habitCompletions =
        completions.where((c) => c.habitId == habit.id).toList();

    int streak = 0;
    var day = DateTime.now();

    // se hoje não foi concluído mas está agendado, começa a contar de ontem
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
      // limite de segurança para não rodar indefinidamente
      if (DateTime.now().difference(day).inDays > 365) break;
    }

    return streak;
  }

  // retorna o status dos últimos 7 dias (seg a dom da semana atual)
  List<bool> _weekStatus(Habit habit, List<Completion> completions) {
    final habitCompletions =
        completions.where((c) => c.habitId == habit.id).toList();

    final now = DateTime.now();
    // segunda-feira desta semana
    final monday = now.subtract(Duration(days: now.weekday - 1));

    return List.generate(7, (i) {
      final day = monday.add(Duration(days: i));
      return habitCompletions.any((c) => c.isSameDay(day));
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsProvider);
    final completionsAsync = ref.watch(completionsProvider);
    final quoteAsync = ref.watch(dailyQuoteProvider);

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
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(habitsProvider);
          ref.invalidate(completionsProvider);
        },
        child: habitsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Erro: $error')),
          data: (habits) {
            return completionsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Erro: $error')),
              data: (completions) {
                final now = DateTime.now();

                // hábitos agendados para hoje
                final todayHabits =
                    habits.where((h) => h.isScheduledFor(now)).toList();

                final completedCount = todayHabits.where((h) {
                  return completions.any(
                      (c) => c.habitId == h.id && c.isSameDay(now));
                }).length;

                return ListView(
                  padding: const EdgeInsets.only(top: 8, bottom: 24),
                  children: [
                    // citação do dia
                    quoteAsync.when(
                      loading: () => const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: SizedBox(
                              height: 60,
                              child:
                                  Center(child: CircularProgressIndicator()),
                            ),
                          ),
                        ),
                      ),
                      error: (_, _) => const SizedBox.shrink(),
                      data: (quote) => QuoteCard(
                        content: quote.content,
                        author: quote.author,
                        onRefresh: () async {
                        final repo = ref.read(quoteRepositoryProvider);
                        await repo.refreshQuote(); // busca nova citação e atualiza o cache
                        ref.invalidate(dailyQuoteProvider); // recarrega a tela com o novo cache
                        },
                      ),
                    ),

                    // progresso do dia
                    ProgressBarCard(
                      completed: completedCount,
                      total: todayHabits.length,
                    ),

                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text('HÁBITOS DE HOJE',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13)),
                    ),

                    // lista vazia
                    if (todayHabits.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 32),
                        child: Center(
                          child: Text(
                            'Nenhum hábito para hoje.\nToque em + para criar um novo hábito.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.6)),
                          ),
                        ),
                      ),

                    // lista de hábitos do dia
                    ...todayHabits.map((habit) {
                      final isCompleted = completions.any(
                          (c) => c.habitId == habit.id && c.isSameDay(now));
                      final streak = _calculateStreak(habit, completions);
                      final weekStatus = _weekStatus(habit, completions);

                      return HabitCard(
                        emoji: habit.emoji,
                        name: habit.name,
                        category: habit.category,
                        streak: streak,
                        isCompleted: isCompleted,
                        weekStatus: weekStatus,
                        onToggle: () async {
                          final repo = ref.read(completionRepositoryProvider);
                          if (isCompleted) {
                            await repo.unmarkCompleted(habit.id, now);
                          } else {
                            await repo.markCompleted(habit.id, now);
                          }
                          ref.invalidate(completionsProvider);
                        },
                        onTap: () => context.pushNamed(
                          AppRoutes.habitDetail,
                          pathParameters: {'id': habit.id.toString()},
                        ),
                      );
                    }),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}