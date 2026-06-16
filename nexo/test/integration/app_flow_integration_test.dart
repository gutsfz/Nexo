import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexo/main.dart';
import 'package:nexo/presentation/providers/habit_providers.dart';
import 'package:nexo/presentation/providers/completion_providers.dart';
import 'package:nexo/presentation/providers/quote_providers.dart';
import 'package:nexo/domain/entities/quote.dart';

void main() {
  group('Integration Tests', () {
    testWidgets('App inicia com MaterialApp e MaterialApp.router',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            habitsProvider.overrideWith((_) async => []),
            completionsProvider.overrideWith((_) async => []),
            dailyQuoteProvider.overrideWith((_) async => Quote(
              content: 'Integração funcionando',
              author: 'Nexo Test',
            )),
          ],
          child: const NexoApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Assert - verifica se o app abriu corretamente
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('HomeScreen renderiza com providers mockados',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            habitsProvider.overrideWith((_) async => []),
            completionsProvider.overrideWith((_) async => []),
            dailyQuoteProvider.overrideWith((_) async => Quote(
              content: 'Integração funcionando',
              author: 'Nexo Test',
            )),
          ],
          child: const NexoApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Assert - verifica que a home foi renderizada
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('HomeScreen exibe AppBar com botões de ação',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            habitsProvider.overrideWith((_) async => []),
            completionsProvider.overrideWith((_) async => []),
            dailyQuoteProvider.overrideWith((_) async => Quote(
              content: 'Integração funcionando',
              author: 'Nexo Test',
            )),
          ],
          child: const NexoApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Assert - verifica que AppBar está presente com os botões
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byIcon(Icons.bar_chart), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('HomeScreen exibe FloatingActionButton para novo hábito',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            habitsProvider.overrideWith((_) async => []),
            completionsProvider.overrideWith((_) async => []),
            dailyQuoteProvider.overrideWith((_) async => Quote(
              content: 'Integração funcionando',
              author: 'Nexo Test',
            )),
          ],
          child: const NexoApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Assert - verifica que o FAB está presente
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });
}
