import 'package:freezed_annotation/freezed_annotation.dart';

part 'habit_model.freezed.dart';
part 'habit_model.g.dart';

// model do hábito - representa um hábito criado pelo usuário
@freezed
abstract class HabitModel with _$HabitModel {
  const factory HabitModel({
    required int id,
    required String name,
    required String emoji,
    required String category,
    // weekdays salvo como string "0,1,3" - índices dos dias da semana
    required String weekdays,
    required String createdAt,
  }) = _HabitModel;

  factory HabitModel.fromJson(Map<String, dynamic> json) =>
      _$HabitModelFromJson(json);
}