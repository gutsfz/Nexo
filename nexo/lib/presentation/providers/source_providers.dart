import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexo/data/sources/habit_local_source.dart';
import 'package:nexo/data/sources/completion_local_source.dart';
import 'package:nexo/data/sources/quote_local_source.dart';
import 'package:nexo/data/sources/quote_remote_source.dart';

final habitLocalSourceProvider = Provider<HabitLocalSource>((ref) {
  return HabitLocalSource();
});

final completionLocalSourceProvider = Provider<CompletionLocalSource>((ref) {
  return CompletionLocalSource();
});

final quoteLocalSourceProvider = Provider<QuoteLocalSource>((ref) {
  return QuoteLocalSource();
});

final quoteRemoteSourceProvider = Provider<QuoteRemoteSource>((ref) {
  return QuoteRemoteSource();
});