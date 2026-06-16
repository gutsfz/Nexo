import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexo/presentation/screens/add_habit/add_habit_screen.dart';

Widget _buildScreen() {
  return const ProviderScope(
    child: MaterialApp(
      home: AddHabitScreen(),
    ),
  );
}

void main() {
  group('AddHabitScreen Widget Tests', () {
    testWidgets('formulário renderiza campos obrigatórios',
        (WidgetTester tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Novo Hábito'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Nome do hábito'), findsOneWidget);
      expect(find.text('Emoji'), findsOneWidget);
      expect(find.text('Repetição semanal'), findsOneWidget);
      expect(find.text('Salvar'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);
    });

    testWidgets('exibe erro de validação quando nome está vazio',
        (WidgetTester tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      // Toca Salvar sem preencher o nome
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      expect(find.text('O nome é obrigatório'), findsOneWidget);
    });

    testWidgets('exibe erro de validação quando nome tem menos de 3 caracteres',
        (WidgetTester tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), 'AB');
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      expect(find.text('O nome deve ter no mínimo 3 caracteres'), findsOneWidget);
    });

    testWidgets('exibe erro quando nenhum dia da semana é selecionado',
        (WidgetTester tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      // Preenche o nome com valor válido
      await tester.enterText(find.byType(TextFormField), 'Meditação');
      // Toca Salvar sem selecionar nenhum dia
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      expect(
        find.text('Selecione pelo menos um dia da semana'),
        findsOneWidget,
      );
    });
  });
}
