import 'package:nexo/domain/entities/quote.dart';

abstract class QuoteRepository {
  // busca a citação do dia - tenta api, se falhar, pega do cache
  Future<Quote> getDailyQuote();

  //força buscar uma nova citação (botão de recarregar)
  Future<Quote> refreshQuote();
}