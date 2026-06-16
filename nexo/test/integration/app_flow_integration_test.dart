import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexo/domain/entities/habit.dart';
import 'package:nexo/domain/entities/quote.dart';
import 'package:nexo/domain/repositories/habit_repository.dart';
import 'package:nexo/main.dart';
import 'package:nexo/presentation/providers/completion_providers.dart';
import 'package:nexo/presentation/providers/habit_providers.dart';
import 'package:nexo/presentation/providers/quote_providers.dart';
import 'package:nexo/presentation/providers/repository_providers.dart';

// Repositório fake para evitar acesso ao SQLite nos testes de integração
class _FakeHabitRepository implements HabitRepository {
  @override
  Future<List<Habit>> getHabits() async => [];
  @override
  Future<void> addHabit(Habit habit) async {}
  @override
  Future<void> updateHabit(Habit habit) async {}
  @override
  Future<void> deleteHabit(int id) async {}
}

/// Monta o NexoApp com providers mockados e avança além do timer da SplashScreen (2500ms).
Future<void> _pumpApp(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        habitsProvider.overrideWith((_) async => []),
        completionsProvider.overrideWith((_) async => []),
        dailyQuoteProvider.overrideWith((_) async => Quote(
              content: 'Integração funcionando',
              author: 'Nexo Test',
            )),
        habitRepositoryProvider.overrideWith((_) => _FakeHabitRepository()),
      ],
      child: const NexoApp(),
    ),
  );

  // Avança além do Future.delayed(2500ms) da SplashScreen
  await tester.pump(const Duration(milliseconds: 2600));
  await tester.pumpAndSettle();
}

void main() {
  group('Integration Tests', () {
    testWidgets('App inicia e renderiza MaterialApp',
        (WidgetTester tester) async {
      await _pumpApp(tester);

      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('HomeScreen renderiza com providers mockados',
        (WidgetTester tester) async {
      await _pumpApp(tester);

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('HomeScreen exibe AppBar com botões de ação',
        (WidgetTester tester) async {
      await _pumpApp(tester);

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byIcon(Icons.bar_chart), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets(
        'Fluxo completo: HomeScreen → navega para AddHabit → preenche formulário → volta',
        (WidgetTester tester) async {
      await _pumpApp(tester);

      // Verifica que estamos na HomeScreen
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);

      // Navega para AddHabitScreen tocando no FAB
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Confirma que chegou na tela de formulário
      expect(find.text('Novo Hábito'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);

      // Preenche o nome do hábito
      await tester.enterText(find.byType(TextFormField), 'Meditação matinal');
      expect(find.text('Meditação matinal'), findsOneWidget);

      // Seleciona o primeiro dia da semana (SEG)
      await tester.tap(find.text('SEG'));
      await tester.pumpAndSettle();

      // Confirma que o botão Salvar está acessível
      expect(find.text('Salvar'), findsOneWidget);
    });
  });
}
