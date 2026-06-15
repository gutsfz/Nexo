import 'package:dio/dio.dart';
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

  // busca uma nova citação da api e salva no cache
  // se falhar por conexão, cai para qualquer citação cacheada (mesmo antiga)
  Future<Quote> _fetchAndCache() async {
    try {
      final model = await _quoteRemoteSource.getRandomQuote();
      await _quoteLocalSource.cacheQuote(model);
      return _modelToQuote(model);
    } on DioException catch (e) {
      if (_isConnectionError(e)) {
        final cachedModel = await _quoteLocalSource.getCachedQuote();
        if (cachedModel != null) {
          return _modelToQuote(cachedModel);
        }
      }
      rethrow;
    }
  }

  // verifica se o erro é de conexão/indisponibilidade (sem internet, timeout, rate limit, etc)
  bool _isConnectionError(DioException exception) {
    if (exception.type == DioExceptionType.connectionTimeout ||
        exception.type == DioExceptionType.receiveTimeout ||
        exception.type == DioExceptionType.sendTimeout ||
        exception.type == DioExceptionType.unknown) {
      return true;
    }

    // 429 = rate limit (muitas requisições); 5xx = erro do servidor
    if (exception.type == DioExceptionType.badResponse) {
      final statusCode = exception.response?.statusCode;
      return statusCode == 429 || (statusCode != null && statusCode >= 500);
    }

    return false;
  }

  // converte um modelo de dados QuoteModel para a entidade Quote
  Quote _modelToQuote(QuoteModel model) {
    return Quote(
      content: model.content,
      author: model.author,
    );
  }
}