import 'package:dio/dio.dart';
import 'package:nexo/data/models/quote_model.dart';
import 'package:nexo/data/sources/quote_local_source.dart';
import 'package:nexo/data/sources/quote_remote_source.dart';
import 'package:nexo/domain/entities/quote.dart';
import 'package:nexo/domain/repositories/quote_repository.dart';

// implementação concreta do repositório de citações
// usa dois sources: remote (API) para dados frescos, local (cache) para modo offline
// estratégia: tenta remote primeiro, se falhar cai para local
class QuoteRepositoryImpl implements QuoteRepository {
  final QuoteRemoteSource _quoteRemoteSource;
  final QuoteLocalSource _quoteLocalSource;

  QuoteRepositoryImpl(this._quoteRemoteSource, this._quoteLocalSource);

  @override
  Future<Quote> getDailyQuote() async {
    try {
      // tenta buscar uma nova citação da API
      final model = await _quoteRemoteSource.getRandomQuote();
      // salva no cache para modo offline
      await _quoteLocalSource.cacheQuote(model);
      return _modelToQuote(model);
    } on DioException catch (e) {
      // se falhar por problemas de conexão, usa o cache
      if (_isConnectionError(e)) {
        final cachedModel = await _quoteLocalSource.getCachedQuote();
        if (cachedModel != null) {
          return _modelToQuote(cachedModel);
        }
      }
      // se não tem cache, relança o erro
      rethrow;
    }
  }

  @override
  Future<Quote> refreshQuote() async {
    try {
      // tenta buscar uma nova citação da API
      final model = await _quoteRemoteSource.getRandomQuote();
      // salva no cache para modo offline
      await _quoteLocalSource.cacheQuote(model);
      return _modelToQuote(model);
    } on DioException catch (e) {
      // se falhar por problemas de conexão, usa o cache
      if (_isConnectionError(e)) {
        final cachedModel = await _quoteLocalSource.getCachedQuote();
        if (cachedModel != null) {
          return _modelToQuote(cachedModel);
        }
      }
      // se não tem cache, relança o erro
      rethrow;
    }
  }

  // verifica se o erro é de conexão (sem internet, timeout, etc)
  bool _isConnectionError(DioException exception) {
    return exception.type == DioExceptionType.connectionTimeout ||
        exception.type == DioExceptionType.receiveTimeout ||
        exception.type == DioExceptionType.sendTimeout ||
        exception.type == DioExceptionType.unknown ||
        exception.type == DioExceptionType.badResponse && exception.response?.statusCode == 0;
  }

  // converte um modelo de dados QuoteModel para a entidade Quote
  Quote _modelToQuote(QuoteModel model) {
    return Quote(
      id: model.id,
      content: model.content,
      author: model.author,
    );
  }
}
