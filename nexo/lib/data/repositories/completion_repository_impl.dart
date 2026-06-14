import 'package:nexo/data/models/completion_model.dart';
import 'package:nexo/data/sources/completion_local_source.dart';
import 'package:nexo/domain/entities/completion.dart';
import 'package:nexo/domain/repositories/completion_repository.dart';

// implementação concreta do repositório de conclusões
// responsável por converter entre CompletionModel (data layer) e Completion (domain layer)
// e coordenar operações através do CompletionLocalSource
class CompletionRepositoryImpl implements CompletionRepository {
  final CompletionLocalSource _completionLocalSource;

  CompletionRepositoryImpl(this._completionLocalSource);

  @override
  Future<List<Completion>> getCompletionsForHabit(int habitId) async {
    final models = await _completionLocalSource.getCompletionsByHabit(habitId);
    return models.map(_modelToCompletion).toList();
  }

  @override
  Future<List<Completion>> getAllCompletions() async {
    final models = await _completionLocalSource.getAllCompletions();
    return models.map(_modelToCompletion).toList();
  }

  @override
  Future<void> markCompleted(int habitId, DateTime date) async {
    final dateString = date.toIso8601String();
    await _completionLocalSource.insertCompletion(habitId, dateString);
  }

  @override
  Future<void> unmarkCompleted(int habitId, DateTime date) async {
    final dateString = date.toIso8601String();
    await _completionLocalSource.deleteCompletion(habitId, dateString);
  }

  // converte um modelo de dados CompletionModel para a entidade Completion
  // transforma a string ISO em DateTime
  Completion _modelToCompletion(CompletionModel model) {
    return Completion(
      id: model.id,
      habitId: model.habitId,
      completedAt: DateTime.parse(model.completedAt),
    );
  }
}
