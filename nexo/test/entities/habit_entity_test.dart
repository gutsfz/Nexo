import 'package:flutter_test/flutter_test.dart';
import 'package:nexo/domain/entities/habit.dart';

void main() {
  group('Habit Entity', () {
    test('isScheduledFor retorna true quando hábito está agendado para o dia', () {
      // Arrange - índices: 0=seg, 1=ter, 2=qua, 3=qui, 4=sex, 5=sab, 6=dom
      final habit = Habit(
        id: 1,
        name: 'Exercício',
        emoji: '🏃',
        category: 'Saúde',
        weekdays: [0, 2, 4], // segunda, quarta, sexta
        createdAt: DateTime(2024, 1, 15),
      );

      // Act & Assert - segunda-feira (weekday 1, índice 0)
      final mondayDate = DateTime(2024, 6, 17); // segunda-feira
      expect(habit.isScheduledFor(mondayDate), true);

      // Act & Assert - domingo (weekday 7, índice 6)
      final sundayDate = DateTime(2024, 6, 16); // domingo
      expect(habit.isScheduledFor(sundayDate), false);
    });

    test('isScheduledFor retorna false quando hábito não está agendado para o dia', () {
      // Arrange
      final habit = Habit(
        id: 2,
        name: 'Meditação',
        emoji: '🧘',
        category: 'Bem-estar',
        weekdays: [5, 6], // sábado(5) e domingo(6)
        createdAt: DateTime(2024, 2, 20),
      );

      // Act & Assert - segunda-feira (weekday 1)
      final mondayDate = DateTime(2024, 6, 17); // segunda-feira
      expect(habit.isScheduledFor(mondayDate), false);

      // Act & Assert - sábado (weekday 6)
      final saturdayDate = DateTime(2024, 6, 22); // sábado
      expect(habit.isScheduledFor(saturdayDate), true);
    });

    test('isScheduledFor verifica múltiplos dias da semana corretamente', () {
      // Arrange - índices: 0=seg, 1=ter, 2=qua, 3=qui, 4=sex, 5=sab, 6=dom
      final habit = Habit(
        id: 3,
        name: 'Leitura',
        emoji: '📚',
        category: 'Aprendizado',
        weekdays: [0, 1, 2, 3, 4], // segunda a sexta
        createdAt: DateTime(2024, 3, 10),
      );

      // Semana referência (junho 2024):
      // 16 = domingo(6), 17 = segunda(0), 18 = terça(1), 19 = quarta(2), 
      // 20 = quinta(3), 21 = sexta(4), 22 = sábado(5)

      // Act & Assert - todos os dias úteis devem retornar true
      expect(habit.isScheduledFor(DateTime(2024, 6, 17)), true); // segunda
      expect(habit.isScheduledFor(DateTime(2024, 6, 18)), true); // terça
      expect(habit.isScheduledFor(DateTime(2024, 6, 19)), true); // quarta
      expect(habit.isScheduledFor(DateTime(2024, 6, 20)), true); // quinta
      expect(habit.isScheduledFor(DateTime(2024, 6, 21)), true); // sexta
      expect(habit.isScheduledFor(DateTime(2024, 6, 22)), false); // sábado
      expect(habit.isScheduledFor(DateTime(2024, 6, 16)), false); // domingo
    });
  });
}
