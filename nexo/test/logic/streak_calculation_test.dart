import 'package:flutter_test/flutter_test.dart';
import 'package:nexo/domain/entities/habit.dart';
import 'package:nexo/domain/entities/completion.dart';

void main() {
  group('Habit Business Logic', () {
    test('verifica agendamento de dias corretamente', () {
      // Arrange
      final habit = Habit(
        id: 1,
        name: 'Exercício',
        emoji: '🏃',
        category: 'Saúde',
        weekdays: [0, 2, 4, 6], // segunda, quarta, sexta, domingo
        createdAt: DateTime(2024, 1, 15),
      );

      // Act & Assert
      expect(habit.isScheduledFor(DateTime(2024, 6, 17)), true); // segunda
      expect(habit.isScheduledFor(DateTime(2024, 6, 18)), false); // terça
      expect(habit.isScheduledFor(DateTime(2024, 6, 19)), true); // quarta
      expect(habit.isScheduledFor(DateTime(2024, 6, 20)), false); // quinta
      expect(habit.isScheduledFor(DateTime(2024, 6, 21)), true); // sexta
      expect(habit.isScheduledFor(DateTime(2024, 6, 22)), false); // sábado
      expect(habit.isScheduledFor(DateTime(2024, 6, 16)), true); // domingo
    });

    test('calcula dias únicos de completions', () {
      // Arrange
      final completions = [
        Completion(id: 1, habitId: 1, completedAt: DateTime(2024, 6, 17)),
        Completion(id: 2, habitId: 1, completedAt: DateTime(2024, 6, 17, 14, 30)),
        Completion(id: 3, habitId: 1, completedAt: DateTime(2024, 6, 18)),
      ];

      // Act - contar dias únicos
      final uniqueDays = <DateTime>{};
      for (final completion in completions) {
        uniqueDays.add(DateTime(completion.completedAt.year,
            completion.completedAt.month, completion.completedAt.day));
      }

      // Assert
      expect(uniqueDays.length, 2); // apenas 2 dias diferentes
    });

    test('agrupa completions por hábito', () {
      // Arrange
      final completions = [
        Completion(id: 1, habitId: 1, completedAt: DateTime(2024, 6, 17)),
        Completion(id: 2, habitId: 2, completedAt: DateTime(2024, 6, 17)),
        Completion(id: 3, habitId: 1, completedAt: DateTime(2024, 6, 18)),
      ];

      // Act - filtra completions do hábito 1
      final habit1Completions =
          completions.where((c) => c.habitId == 1).toList();

      // Assert
      expect(habit1Completions.length, 2);
      expect(habit1Completions[0].id, 1);
      expect(habit1Completions[1].id, 3);
    });
  });
}
