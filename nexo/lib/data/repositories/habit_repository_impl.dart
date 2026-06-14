import 'package:nexo/data/models/habit_model.dart';
import 'package:nexo/data/sources/habit_local_source.dart';
import 'package:nexo/domain/entities/habit.dart';
import 'package:nexo/domain/repositories/habit_repository.dart';

// implementação concreta do repositório de hábitos
// responsável por converter entre HabitModel (data layer) e Habit (domain layer)
// e coordenar operações através do HabitLocalSource
class HabitRepositoryImpl implements HabitRepository {
  final HabitLocalSource _habitLocalSource;

  HabitRepositoryImpl(this._habitLocalSource);

  @override
  Future<List<Habit>> getHabits() async {
    final models = await _habitLocalSource.getHabits();
    return models.map(_modelToHabit).toList();
  }

  @override
  Future<void> addHabit(Habit habit) async {
    final model = _habitToModel(habit);
    await _habitLocalSource.insertHabit(model);
  }

  @override
  Future<void> updateHabit(Habit habit) async {
    final model = _habitToModel(habit);
    await _habitLocalSource.updateHabit(model);
  }

  @override
  Future<void> deleteHabit(int id) async {
    await _habitLocalSource.deleteHabit(id);
  }

  // converte uma entidade Habit para o modelo de dados HabitModel
  // transforma a lista de dias (List<int>) em string "0,1,3"
  // e o DateTime em string ISO
  HabitModel _habitToModel(Habit habit) {
    return HabitModel(
      id: habit.id,
      name: habit.name,
      emoji: habit.emoji,
      category: habit.category,
      weekdays: habit.weekdays.join(','),
      createdAt: habit.createdAt.toIso8601String(),
    );
  }

  // converte um modelo de dados HabitModel para a entidade Habit
  // transforma a string de dias "0,1,3" em lista [0, 1, 3]
  // e a string ISO em DateTime
  Habit _modelToHabit(HabitModel model) {
    final weekdaysList = model.weekdays.isEmpty
        ? <int>[]
        : model.weekdays.split(',').map(int.parse).toList();

    return Habit(
      id: model.id,
      name: model.name,
      emoji: model.emoji,
      category: model.category,
      weekdays: weekdaysList,
      createdAt: DateTime.parse(model.createdAt),
    );
  }
}
