import 'package:freezed_annotation/freezed_annotation.dart';

part 'quote_model.freezed.dart';
part 'quote_model.g.dart';

// model da citação - vem da api quotable.io
@freezed
abstract class QuoteModel with _$QuoteModel {
  const factory QuoteModel({
  @JsonKey(name: '_id')
  required String id,
  required String content,
  required String author,
}) = _QuoteModel;

  factory QuoteModel.fromJson(Map<String, dynamic> json) =>
      _$QuoteModelFromJson(json);
}