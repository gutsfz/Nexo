import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexo/presentation/screens/home/home_screen.dart';
import 'package:nexo/presentation/providers/habit_providers.dart';
import 'package:nexo/presentation/providers/completion_providers.dart';
import 'package:nexo/presentation/providers/quote_providers.dart';
import 'package:nexo/domain/entities/quote.dart';

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

      // Act & Assert - verifica se o FAB está presente e contém Icons.add
      // (Icons.add também aparece no botão do estado vazio, por isso buscamos
      // dentro do FloatingActionButton especificamente)
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(FloatingActionButton),
          matching: find.byIcon(Icons.add),
        ),
        findsOneWidget,
      );
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

    testWidgets('HomeScreen body está envolto em SafeArea',
        (WidgetTester tester) async {
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

      expect(find.byType(SafeArea), findsWidgets);
    });
  });
}
