import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// singleton para não abrir o banco várias vezes
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('nexo.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE habits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        emoji TEXT NOT NULL,
        category TEXT NOT NULL,
        weekdays TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // registra cada conclusão de hábito
    // cascade: se deletar o hábito, deleta as completions junto
    await db.execute('''
      CREATE TABLE completions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        habit_id INTEGER NOT NULL,
        completed_at TEXT NOT NULL,
        FOREIGN KEY (habit_id) REFERENCES habits(id) ON DELETE CASCADE
      )
    ''');

    // cache da última citação para funcionar offline
    await db.execute('''
      CREATE TABLE cached_quotes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        content TEXT NOT NULL,
        author TEXT NOT NULL,
        cached_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('completions');
    await db.delete('cached_quotes');
    await db.delete('habits');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}