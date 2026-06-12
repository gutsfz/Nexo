import 'package:freezed_annotation/freezed_annotation.dart';

part 'completion_model.freezed.dart';
part 'completion_model.g.dart';

// model de completion - registra que um hábito foi concluído em determinado dia
@freezed
abstract class CompletionModel with _$CompletionModel {
  const factory CompletionModel({
    required int id,
    required int habitId,
    required String completedAt, // data em iso8601
  }) = _CompletionModel;

  factory CompletionModel.fromJson(Map<String, dynamic> json) =>
      _$CompletionModelFromJson(json);
}