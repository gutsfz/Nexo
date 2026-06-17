import 'package:sqflite/sqflite.dart';
import 'package:nexo/core/database/database_helper.dart';
import 'package:nexo/data/models/habit_model.dart';

// source local - só fala com o sqlite, sem regra de negócio
class HabitLocalSource {
  Future<Database> get _db async => await DatabaseHelper.instance.database;

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

  Future<int> deleteHabit(int id) async {
    final db = await _db;
    return await db.delete('habits', where: 'id = ?', whereArgs: [id]);
  }
}