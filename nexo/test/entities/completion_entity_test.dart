import 'package:flutter_test/flutter_test.dart';
import 'package:nexo/domain/entities/completion.dart';

void main() {
  group('Completion Entity', () {
    test('isSameDay retorna true quando completion foi feita no mesmo dia', () {
      // Arrange
      final completion = Completion(
        id: 1,
        habitId: 5,
        completedAt: DateTime(2024, 6, 15, 10, 30),
      );

      // Act & Assert - mesma data, horário diferente
      final sameDay = DateTime(2024, 6, 15, 14, 45);
      expect(completion.isSameDay(sameDay), true);
    });

    test('isSameDay retorna false quando completion foi feita em dia diferente', () {
      // Arrange
      final completion = Completion(
        id: 2,
        habitId: 3,
        completedAt: DateTime(2024, 6, 15, 10, 30),
      );

      // Act & Assert - dia anterior
      final previousDay = DateTime(2024, 6, 14, 10, 30);
      expect(completion.isSameDay(previousDay), false);

      // Act & Assert - dia seguinte
      final nextDay = DateTime(2024, 6, 16, 10, 30);
      expect(completion.isSameDay(nextDay), false);
    });

    test('isSameDay ignora hora, minuto e segundo', () {
      // Arrange
      final completion = Completion(
        id: 3,
        habitId: 7,
        completedAt: DateTime(2024, 6, 20, 0, 0, 0),
      );

      // Act & Assert - mesma data, horas diferentes
      expect(completion.isSameDay(DateTime(2024, 6, 20, 0, 0, 1)), true);
      expect(completion.isSameDay(DateTime(2024, 6, 20, 12, 30, 45)), true);
      expect(completion.isSameDay(DateTime(2024, 6, 20, 23, 59, 59)), true);
    });

    test('isSameDay verifica ano, mês e dia corretamente', () {
      // Arrange
      final completion = Completion(
        id: 4,
        habitId: 1,
        completedAt: DateTime(2024, 6, 15),
      );

      // Act & Assert - ano diferente
      expect(completion.isSameDay(DateTime(2025, 6, 15)), false);

      // Act & Assert - mês diferente
      expect(completion.isSameDay(DateTime(2024, 7, 15)), false);

      // Act & Assert - dia diferente
      expect(completion.isSameDay(DateTime(2024, 6, 16)), false);
    });
  });
}
