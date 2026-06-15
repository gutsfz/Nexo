import 'package:freezed_annotation/freezed_annotation.dart';

part 'quote_model.freezed.dart';
part 'quote_model.g.dart';

// model da citação - vem da api zenquotes.io
// resposta da api: [{"q": "...", "a": "...", "h": "..."}]
@freezed
abstract class QuoteModel with _$QuoteModel {
  const factory QuoteModel({
    @JsonKey(name: 'q') required String content,
    @JsonKey(name: 'a') required String author,
  }) = _QuoteModel;

  factory QuoteModel.fromJson(Map<String, dynamic> json) =>
      _$QuoteModelFromJson(json);
}