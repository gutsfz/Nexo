import 'package:nexo/data/models/quote_model.dart';
import 'package:nexo/data/sources/quote_local_source.dart';
import 'package:nexo/data/sources/quote_remote_source.dart';
import 'package:nexo/domain/entities/quote.dart';
import 'package:nexo/domain/repositories/quote_repository.dart';

// implementação concreta do repositório de citações
// usa dois sources: remote (API) para dados frescos, local (cache) para modo offline
// lógica: se já existe citação de hoje no cache, usa ela direto (sem chamar a api)
// senão, tenta a api e cai para o cache se falhar
class QuoteRepositoryImpl implements QuoteRepository {
  final QuoteRemoteSource _quoteRemoteSource;
  final QuoteLocalSource _quoteLocalSource;

  QuoteRepositoryImpl(this._quoteRemoteSource, this._quoteLocalSource);

  @override
  Future<Quote> getDailyQuote() async {
    // RN: citação do dia — se já buscamos uma hoje, usa o cache
    // evita chamadas repetidas à api (rate limit) e carregamento lento
    final todayCache = await _quoteLocalSource.getCachedQuoteIfFromToday();
    if (todayCache != null) {
      return _modelToQuote(todayCache);
    }

    return _fetchAndCache();
  }

  @override
  Future<Quote> refreshQuote() async {
    // refresh manual sempre busca uma nova citação da api
    return _fetchAndCache();
  }

  static const _fallbackQuote = Quote(
    content: 'Cada dia é uma nova oportunidade de melhorar seus hábitos.',
    author: 'Nexo',
  );

  // busca uma nova citação da api e salva no cache
  // se falhar por qualquer motivo, cai para cache; sem cache, retorna fallback
  Future<Quote> _fetchAndCache() async {
    try {
      final model = await _quoteRemoteSource.getRandomQuote()
          .timeout(const Duration(seconds: 5));
      await _quoteLocalSource.cacheQuote(model);
      return _modelToQuote(model);
    } catch (_) {
      final cachedModel = await _quoteLocalSource.getCachedQuote();
      if (cachedModel != null) {
        return _modelToQuote(cachedModel);
      }
      return _fallbackQuote;
    }
  }

  // converte um modelo de dados QuoteModel para a entidade Quote
  Quote _modelToQuote(QuoteModel model) {
    return Quote(
      content: model.content,
      author: model.author,
    );
  }
}