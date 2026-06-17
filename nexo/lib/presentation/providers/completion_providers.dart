import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexo/domain/entities/completion.dart';
import 'repository_providers.dart';

final completionsProvider = FutureProvider<List<Completion>>((ref) async {
  final repository = ref.watch(completionRepositoryProvider);
  return repository.getAllCompletions();
});

final completionsByHabitProvider =
    FutureProvider.family<List<Completion>, int>((ref, habitId) async {
  final repository = ref.watch(completionRepositoryProvider);
  return repository.getCompletionsForHabit(habitId);
});