import 'package:nexo/data/models/quote_model.dart';
import 'package:nexo/data/sources/quote_local_source.dart';
import 'package:nexo/data/sources/quote_remote_source.dart';
import 'package:nexo/domain/entities/quote.dart';
import 'package:nexo/domain/repositories/quote_repository.dart';

// cache-first: usa citação de hoje do cache para evitar rate-limit da API;
// se não houver cache ou a API falhar, retorna fallback hardcoded
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
    return _fetchAndCache();
  }

  static const _fallbackQuote = Quote(
    content: 'Cada dia é uma nova oportunidade de melhorar seus hábitos.',
    author: 'Nexo',
  );

  // fallback para cache quando API falha; sem cache, retorna quote padrão
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

  Quote _modelToQuote(QuoteModel model) {
    return Quote(
      content: model.content,
      author: model.author,
    );
  }
}