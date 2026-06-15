import 'package:nexo/core/network/api_client.dart';
import 'package:nexo/data/models/quote_model.dart';

// source remoto - busca citações na api zenquotes.io
class QuoteRemoteSource {
  final _dio = ApiClient.instance.dio;

  // busca uma citação aleatória
  // zenquotes retorna uma lista com 1 item: [{"q": "...", "a": "...", "h": "..."}]
  Future<QuoteModel> getRandomQuote() async {
    final response = await _dio.get('/random');
    final list = response.data as List;
    return QuoteModel.fromJson(list.first as Map<String, dynamic>);
  }
}