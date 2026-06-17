import 'package:nexo/core/network/api_client.dart';
import 'package:nexo/data/models/quote_model.dart';

// source remoto - busca citações na api zenquotes.io
class QuoteRemoteSource {
  // busca uma citação aleatória com até 2 tentativas antes de falhar
  // zenquotes retorna uma lista com 1 item: [{"q": "...", "a": "...", "h": "..."}]
  Future<QuoteModel> getRandomQuote() async {
    final response = await ApiClient.instance.getWithRetry('/random');
    final list = response.data as List;
    return QuoteModel.fromJson(list.first as Map<String, dynamic>);
  }
}
