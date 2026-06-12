import 'package:sqflite/sqflite.dart';
import 'package:nexo/core/database/database_helper.dart';
import 'package:nexo/data/models/quote_model.dart';

// cache local da última citação - usado quando não tem internet
class QuoteLocalSource {
  Future<Database> get _db async => await DatabaseHelper.instance.database;

  // salva a citação do dia (substitui a anterior)
  Future<void> cacheQuote(QuoteModel quote) async {
    final db = await _db;
    await db.delete('cached_quotes'); // limpa cache antigo
    await db.insert('cached_quotes', {
      'content': quote.content,
      'author': quote.author,
      'cached_at': DateTime.now().toIso8601String(),
    });
  }

  // busca a última citação salva
  Future<QuoteModel?> getCachedQuote() async {
    final db = await _db;
    final maps = await db.query('cached_quotes', limit: 1);
    if (maps.isEmpty) return null;
    final map = maps.first;
    return QuoteModel(
      id: 'cached',
      content: map['content'] as String,
      author: map['author'] as String,
    );
  }
}