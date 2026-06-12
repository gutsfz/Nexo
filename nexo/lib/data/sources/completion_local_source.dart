import 'package:sqflite/sqflite.dart';
import 'package:nexo/core/database/database_helper.dart';
import 'package:nexo/data/models/completion_model.dart';

class CompletionLocalSource {
  Future<Database> get _db async => await DatabaseHelper.instance.database;

  // busca todas as completions de um hábito
  Future<List<CompletionModel>> getCompletionsByHabit(int habitId) async {
    final db = await _db;
    final maps = await db.query(
      'completions',
      where: 'habit_id = ?',
      whereArgs: [habitId],
    );
    return maps.map((map) => CompletionModel(
      id: map['id'] as int,
      habitId: map['habit_id'] as int,
      completedAt: map['completed_at'] as String,
    )).toList();
  }

  // busca todas as completions - usado no histórico
  Future<List<CompletionModel>> getAllCompletions() async {
    final db = await _db;
    final maps = await db.query('completions');
    return maps.map((map) => CompletionModel(
      id: map['id'] as int,
      habitId: map['habit_id'] as int,
      completedAt: map['completed_at'] as String,
    )).toList();
  }

  // marca um hábito como concluído numa data
  Future<int> insertCompletion(int habitId, String date) async {
    final db = await _db;
    return await db.insert('completions', {
      'habit_id': habitId,
      'completed_at': date,
    });
  }

  // desmarca a conclusão - remove o registro daquele dia
  Future<int> deleteCompletion(int habitId, String date) async {
    final db = await _db;
    return await db.delete(
      'completions',
      where: 'habit_id = ? AND completed_at = ?',
      whereArgs: [habitId, date],
    );
  }
}