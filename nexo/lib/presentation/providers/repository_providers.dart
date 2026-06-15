import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexo/data/repositories/habit_repository_impl.dart';
import 'package:nexo/data/repositories/completion_repository_impl.dart';
import 'package:nexo/data/repositories/quote_repository_impl.dart';
import 'package:nexo/domain/repositories/habit_repository.dart';
import 'package:nexo/domain/repositories/completion_repository.dart';
import 'package:nexo/domain/repositories/quote_repository.dart';
import 'source_providers.dart';

final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  final localSource = ref.watch(habitLocalSourceProvider);
  return HabitRepositoryImpl(localSource);
});

final completionRepositoryProvider = Provider<CompletionRepository>((ref) {
  final localSource = ref.watch(completionLocalSourceProvider);
  return CompletionRepositoryImpl(localSource);
});

final quoteRepositoryProvider = Provider<QuoteRepository>((ref) {
  final remoteSource = ref.watch(quoteRemoteSourceProvider);
  final localSource = ref.watch(quoteLocalSourceProvider);
  return QuoteRepositoryImpl(remoteSource, localSource);
});