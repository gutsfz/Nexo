import 'package:flutter_test/flutter_test.dart';
import 'package:nexo/data/models/completion_model.dart';

void main() {
  group('CompletionModel', () {
    test('fromJson converte JSON corretamente para CompletionModel', () {
      // Arrange
      final json = {
        'id': 1,
        'habitId': 5,
        'completedAt': '2024-06-15T09:30:00.000Z',
      };

      // Act
      final completion = CompletionModel.fromJson(json);

      // Assert
      expect(completion.id, 1);
      expect(completion.habitId, 5);
      expect(completion.completedAt, '2024-06-15T09:30:00.000Z');
    });

    test('fromJson múltiplos modelos com dados diferentes', () {
      // Arrange
      final json1 = {
        'id': 1,
        'habitId': 5,
        'completedAt': '2024-06-15T09:30:00.000Z',
      };

      final json2 = {
        'id': 2,
        'habitId': 3,
        'completedAt': '2024-06-16T14:15:00.000Z',
      };

      // Act
      final completion1 = CompletionModel.fromJson(json1);
      final completion2 = CompletionModel.fromJson(json2);

      // Assert
      expect(completion1.habitId, 5);
      expect(completion2.habitId, 3);
      expect(completion1.completedAt, '2024-06-15T09:30:00.000Z');
      expect(completion2.completedAt, '2024-06-16T14:15:00.000Z');
    });
  });
}
