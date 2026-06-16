import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexo/presentation/widgets/habit_card.dart';

void main() {
  group('HabitCard Widget Tests', () {
    testWidgets('HabitCard renderiza emoji, nome e categoria corretamente',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HabitCard(
              emoji: '🏃',
              name: 'Exercício',
              category: 'Saúde',
              streak: 5,
              isCompleted: false,
              weekStatus: [true, true, false, true, true, false, false],
              onToggle: () {},
              onTap: () {},
            ),
          ),
        ),
      );

      // Act & Assert - verifica se o emoji está renderizado
      expect(find.text('🏃'), findsOneWidget);

      // Assert - verifica se o nome do hábito está presente
      expect(find.text('Exercício'), findsOneWidget);

      // Assert - verifica se a categoria está em maiúscula
      expect(find.text('SAÚDE'), findsOneWidget);
    });

    testWidgets('HabitCard exibe os dias da semana com status correto',
        (WidgetTester tester) async {
      // Arrange
      // weekStatus: [seg=true, ter=true, qua=false, qui=true, sex=true, sab=false, dom=false]
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HabitCard(
              emoji: '🧘',
              name: 'Meditação',
              category: 'Bem-estar',
              streak: 3,
              isCompleted: true,
              weekStatus: [true, true, false, true, true, false, false],
              onToggle: () {},
              onTap: () {},
            ),
          ),
        ),
      );

      // Act & Assert - verifica se os dias da semana estão renderizados
      expect(find.text('Seg'), findsOneWidget);
      expect(find.text('Ter'), findsOneWidget);
      expect(find.text('Qua'), findsOneWidget);
      expect(find.text('Qui'), findsOneWidget);
      expect(find.text('Sex'), findsOneWidget);
      expect(find.text('Sáb'), findsOneWidget);
      expect(find.text('Dom'), findsOneWidget);
    });

    testWidgets('HabitCard chama callbacks ao interagir com o card',
        (WidgetTester tester) async {
      // Arrange
      bool tapCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HabitCard(
              emoji: '📚',
              name: 'Leitura',
              category: 'Aprendizado',
              streak: 7,
              isCompleted: false,
              weekStatus: [true, false, true, false, true, false, true],
              onToggle: () {},
              onTap: () {
                tapCalled = true;
              },
            ),
          ),
        ),
      );

      // Act - tapa no card
      await tester.tap(find.byType(HabitCard));
      await tester.pumpAndSettle();

      // Assert - verifica se onTap foi chamado
      expect(tapCalled, true);
    });
  });
}
