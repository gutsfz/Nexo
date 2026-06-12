import 'package:sqflite/sqflite.dart';
import 'package:nexo/core/database/database_helper.dart';
import 'package:nexo/data/models/habit_model.dart';

// source local - só fala com o sqlite, sem regra de negócio
class HabitLocalSource {
  Future<Database> get _db async => await DatabaseHelper.instance.database;

  // busca todos os hábitos cadastrados
  Future<List<HabitModel>> getHabits() async {
    final db = await _db;
    final maps = await db.query('habits');
    return maps.map((map) => HabitModel(
      id: map['id'] as int,
      name: map['name'] as String,
      emoji: map['emoji'] as String,
      category: map['category'] as String,
      weekdays: map['weekdays'] as String,
      createdAt: map['created_at'] as String,
    )).toList();
  }

  // insere um novo hábito e retorna o id gerado
  Future<int> insertHabit(HabitModel habit) async {
    final db = await _db;
    return await db.insert('habits', {
      'name': habit.name,
      'emoji': habit.emoji,
      'category': habit.category,
      'weekdays': habit.weekdays,
      'created_at': habit.createdAt,
    });
  }

  // atualiza um hábito existente
  Future<int> updateHabit(HabitModel habit) async {
    final db = await _db;
    return await db.update(
      'habits',
      {
        'name': habit.name,
        'emoji': habit.emoji,
        'category': habit.category,
        'weekdays': habit.weekdays,
      },
      where: 'id = ?',
      whereArgs: [habit.id],
    );
  }

  // remove um hábito (completions somem em cascade)
  Future<int> deleteHabit(int id) async {
    final db = await _db;
    return await db.delete('habits', where: 'id = ?', whereArgs: [id]);
  }
}