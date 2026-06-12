import 'package:nexo/domain/entities/completion.dart';

abstract class CompletionRepository {
  // busca todas as conclusões de um hábito específico
  Future<List<Completion>> getCompletionsForHabit(int habitId);

  // busca todas as conclusões de todos os hábitos - usado no histórico
  Future<List<Completion>> getAllCompletions();

  // marca um hábito como concluído em uma data
  Future<void> markCompleted(int habitId, DateTime date);

  // desmarca a conclusão de um hábito
  Future<void> unmarkCompleted(int habitId, DateTime date);
}