import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexo/domain/entities/quote.dart';
import 'package:nexo/main.dart';
import 'package:nexo/presentation/providers/completion_providers.dart';
import 'package:nexo/presentation/providers/habit_providers.dart';
import 'package:nexo/presentation/providers/quote_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('NexoApp smoke test - app inicia corretamente',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

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

    // Avança além do Future.delayed(3000ms) da SplashScreen para que o timer não
    // fique pendente ao encerrar o teste
    await tester.pump(const Duration(milliseconds: 3100));
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
