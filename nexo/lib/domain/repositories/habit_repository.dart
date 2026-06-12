import 'package:nexo/domain/entities/habit.dart';

// contrato - define o que pode ser feito com hábitos, sem se preocupar com a implementação
abstract class HabitRepository {
  Future<List<Habit>> getHabits();
  Future<void> addHabit(Habit habit);
  Future<void> updateHabit(Habit habit);
  Future<void> deleteHabit(int id);
}