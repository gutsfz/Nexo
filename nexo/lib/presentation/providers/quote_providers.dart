import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexo/domain/entities/quote.dart';
import 'repository_providers.dart';

// citação do dia — usado na HomeScreen
final dailyQuoteProvider = FutureProvider<Quote>((ref) async {
  final repository = ref.watch(quoteRepositoryProvider);
  return repository.getDailyQuote();
});