import 'package:nexo/core/network/api_client.dart';
import 'package:nexo/data/models/quote_model.dart';

// source remoto - busca citações na api quotable.io
class QuoteRemoteSource {
  final _dio = ApiClient.instance.dio;

  // busca uma citação aleatória
  Future<QuoteModel> getRandomQuote() async {
    final response = await _dio.get('/random');
    return QuoteModel.fromJson(response.data);
  }
}