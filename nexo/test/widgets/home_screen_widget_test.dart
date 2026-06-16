import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexo/presentation/screens/home/home_screen.dart';
import 'package:nexo/presentation/providers/habit_providers.dart';
import 'package:nexo/presentation/providers/completion_providers.dart';
import 'package:nexo/presentation/providers/quote_providers.dart';
import 'package:nexo/domain/entities/quote.dart';
import 'package:nexo/domain/entities/habit.dart';
import 'package:nexo/domain/entities/completion.dart';

void main() {
  group('HomeScreen Widget Tests', () {
    testWidgets('HomeScreen renderiza título e botões de ação corretamente',
        (WidgetTester tester) async {
      // Arrange - mock dos providers
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            habitsProvider.overrideWith((_) async => []),
            completionsProvider.overrideWith((_) async => []),
            dailyQuoteProvider.overrideWith((_) async => Quote(
              content: 'Teste de citação',
              author: 'Autor de Teste',
            )),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Act & Assert - verifica se o título "Nexo" está presente
      expect(find.text('Nexo'), findsOneWidget);

      // Assert - verifica se os botões de ação estão presentes
      expect(find.byIcon(Icons.bar_chart), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('HomeScreen exibe FloatingActionButton para adicionar hábito',
        (WidgetTester tester) async {
      // Arrange - mock dos providers
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            habitsProvider.overrideWith((_) async => []),
            completionsProvider.overrideWith((_) async => []),
            dailyQuoteProvider.overrideWith((_) async => Quote(
              content: 'Teste de citação',
              author: 'Autor de Teste',
            )),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Act & Assert - verifica se o botão de adicionar está presente
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets(
        'HomeScreen exibe AppBar com título e ações quando carrega com sucesso',
        (WidgetTester tester) async {
      // Arrange - mock dos providers
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            habitsProvider.overrideWith((_) async => []),
            completionsProvider.overrideWith((_) async => []),
            dailyQuoteProvider.overrideWith((_) async => Quote(
              content: 'Teste de citação',
              author: 'Autor de Teste',
            )),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Act & Assert - verifica se AppBar está presente
      expect(find.byType(AppBar), findsOneWidget);

      // Assert - verifica se o RefreshIndicator está presente para pull-to-refresh
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });
  });
}
