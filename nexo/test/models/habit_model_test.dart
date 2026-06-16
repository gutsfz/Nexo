import 'package:flutter_test/flutter_test.dart';
import 'package:nexo/data/models/habit_model.dart';

void main() {
  group('HabitModel', () {
    test('fromJson converte JSON corretamente para HabitModel', () {
      // Arrange
      final json = {
        'id': 1,
        'name': 'Exercício',
        'emoji': '🏃',
        'category': 'Saúde',
        'weekdays': '0,1,2,3,4,5,6',
        'createdAt': '2024-01-15T10:30:00.000Z',
      };

      // Act
      final habit = HabitModel.fromJson(json);

      // Assert
      expect(habit.id, 1);
      expect(habit.name, 'Exercício');
      expect(habit.emoji, '🏃');
      expect(habit.category, 'Saúde');
      expect(habit.weekdays, '0,1,2,3,4,5,6');
      expect(habit.createdAt, '2024-01-15T10:30:00.000Z');
    });

    test('fromJson mantém valores corretamente com weekdays parcial', () {
      // Arrange
      final json = {
        'id': 2,
        'name': 'Meditação',
        'emoji': '🧘',
        'category': 'Bem-estar',
        'weekdays': '1,3,5', // apenas seg, qua, sex
        'createdAt': '2024-02-20T14:00:00.000Z',
      };

      // Act
      final habit = HabitModel.fromJson(json);

      // Assert
      expect(habit.name, 'Meditação');
      expect(habit.weekdays, '1,3,5');
    });
  });
}
