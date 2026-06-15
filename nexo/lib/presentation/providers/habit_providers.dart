import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexo/domain/entities/habit.dart';
import 'repository_providers.dart';

// lista de hábitos — usado na HomeScreen
final habitsProvider = FutureProvider<List<Habit>>((ref) async {
  final repository = ref.watch(habitRepositoryProvider);
  return repository.getHabits();
});