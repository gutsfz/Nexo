import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexo/domain/entities/quote.dart';
import 'package:nexo/main.dart';
import 'package:nexo/presentation/providers/completion_providers.dart';
import 'package:nexo/presentation/providers/habit_providers.dart';
import 'package:nexo/presentation/providers/quote_providers.dart';

void main() {
  testWidgets('NexoApp smoke test - app inicia corretamente',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          habitsProvider.overrideWith((_) async => []),
          completionsProvider.overrideWith((_) async => []),
          dailyQuoteProvider.overrideWith((_) async => Quote(
                content: 'Test quote',
                author: 'Test',
              )),
        ],
        child: const NexoApp(),
      ),
    );

    // Avança além do Future.delayed(2500ms) da SplashScreen para que o timer não
    // fique pendente ao encerrar o teste
    await tester.pump(const Duration(milliseconds: 2600));
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
