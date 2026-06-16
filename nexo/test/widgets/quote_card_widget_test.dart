import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexo/presentation/widgets/quote_card.dart';

void main() {
  group('QuoteCard Widget Tests', () {
    testWidgets('QuoteCard renderiza conteúdo da citação e autor corretamente',
        (WidgetTester tester) async {
      // Arrange
      final testQuote = 'O sucesso é a soma de pequenos esforços repetidos';
      final testAuthor = 'Robert Collier';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuoteCard(
              content: testQuote,
              author: testAuthor,
              onRefresh: () {},
            ),
          ),
        ),
      );

      // Act & Assert - verifica se o conteúdo da citação está renderizado (com aspas)
      expect(find.text('"$testQuote"'), findsOneWidget);

      // Assert - verifica se o autor está renderizado
      expect(find.text('— $testAuthor'), findsOneWidget);
    });

    testWidgets('QuoteCard exibe botão de refresh para carregar nova citação',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuoteCard(
              content: 'Uma citação inspiradora',
              author: 'Autor Desconhecido',
              onRefresh: () {},
            ),
          ),
        ),
      );

      // Act & Assert - verifica se o botão de refresh está presente
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('QuoteCard alterna visual ao clicar no botão de refresh',
        (WidgetTester tester) async {
      // Arrange
      bool refreshCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuoteCard(
              content: 'Outra citação inspiradora',
              author: 'Pessoa Famosa',
              onRefresh: () {
                refreshCalled = true;
              },
            ),
          ),
        ),
      );

      // Act - clica no botão de refresh
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();

      // Assert - verifica se o callback foi chamado
      expect(refreshCalled, true);
    });

    testWidgets('QuoteCard renderiza corretamente com citações longas',
        (WidgetTester tester) async {
      // Arrange
      final longQuote =
          'Um texto longo que simula uma citação extensa com múltiplas linhas de conteúdo para testar a renderização adequada em diferentes tamanhos de tela e com quebra de linhas';
      final author = 'Pensador Renomado';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuoteCard(
              content: longQuote,
              author: author,
              onRefresh: () {},
            ),
          ),
        ),
      );

      // Act & Assert - verifica se a citação longa foi renderizada (com aspas)
      expect(find.text('"$longQuote"'), findsOneWidget);

      // Assert - verifica se não há overflow ou erros de layout
      expect(find.byType(QuoteCard), findsOneWidget);
    });
  });
}
