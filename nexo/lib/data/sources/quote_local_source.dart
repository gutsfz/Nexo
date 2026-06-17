import 'package:sqflite/sqflite.dart';
import 'package:nexo/core/database/database_helper.dart';
import 'package:nexo/data/models/quote_model.dart';

// cache local da última citação - usado quando não tem internet
// ou para evitar chamadas repetidas à api (rate limit)
class QuoteLocalSource {
  Future<Database> get _db async => await DatabaseHelper.instance.database;

  Future<void> cacheQuote(QuoteModel quote) async {
    final db = await _db;
    await db.delete('cached_quotes'); // limpa cache antigo
    await db.insert('cached_quotes', {
      'content': quote.content,
      'author': quote.author,
      'cached_at': DateTime.now().toIso8601String(),
    });
  }

  Future<QuoteModel?> getCachedQuote() async {
    final db = await _db;
    final maps = await db.query('cached_quotes', limit: 1);
    if (maps.isEmpty) return null;
    final map = maps.first;
    return QuoteModel(
      content: map['content'] as String,
      author: map['author'] as String,
    );
  }

  // retorna null se não há cache ou se o cache é de outro dia
  Future<QuoteModel?> getCachedQuoteIfFromToday() async {
    final db = await _db;
    final maps = await db.query('cached_quotes', limit: 1);
    if (maps.isEmpty) return null;

    final map = maps.first;
    final cachedAt = DateTime.parse(map['cached_at'] as String);
    final now = DateTime.now();

    final isToday = cachedAt.year == now.year &&
        cachedAt.month == now.month &&
        cachedAt.day == now.day;

    if (!isToday) return null;

    return QuoteModel(
      content: map['content'] as String,
      author: map['author'] as String,
    );
  }
}