import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexo/domain/entities/completion.dart';
import 'repository_providers.dart';

// todas as completions — usado no HistoryScreen
final completionsProvider = FutureProvider<List<Completion>>((ref) async {
  final repository = ref.watch(completionRepositoryProvider);
  return repository.getAllCompletions();
});

// completions de um hábito específico — usado no HabitDetailScreen
final completionsByHabitProvider =
    FutureProvider.family<List<Completion>, int>((ref, habitId) async {
  final repository = ref.watch(completionRepositoryProvider);
  return repository.getCompletionsForHabit(habitId);
});