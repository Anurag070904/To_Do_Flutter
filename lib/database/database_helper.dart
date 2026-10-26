import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/task_model.dart';

class DatabaseHelper {
  DatabaseHelper._({DatabaseFactory? factory, String? databasePath})
    : _factory = factory ?? databaseFactory,
      _databasePath = databasePath;

  DatabaseHelper.forTesting({
    required DatabaseFactory factory,
    required String databasePath,
  }) : this._(factory: factory, databasePath: databasePath);

  static final DatabaseHelper instance = DatabaseHelper._();
  static const _databaseName = 'to_do.db';
  static const _databaseVersion = 2;
  final DatabaseFactory _factory;
  final String? _databasePath;
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    final path = _databasePath ?? join(await getDatabasesPath(), _databaseName);
    _database = await _factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: _databaseVersion,
        onCreate: (db, version) async {
          await db.execute('''CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        taskDate TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )''');
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            await db.execute(
              "ALTER TABLE tasks ADD COLUMN taskDate TEXT NOT NULL DEFAULT ''",
            );
            await db.execute(
              "UPDATE tasks SET taskDate = substr(createdAt, 1, 10)",
            );
          }
        },
      ),
    );
    return _database!;
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }

  Future<int> insertTask(Task task) async =>
      (await database).insert('tasks', task.toMap());

  Future<List<Task>> getAllTasks() async {
    final rows = await (await database).query(
      'tasks',
      orderBy: 'createdAt DESC, id DESC',
    );
    return rows.map(Task.fromMap).toList();
  }

  Future<List<Task>> getTasksForDate(DateTime date) async {
    final day =
        '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
    final rows = await (await database).query(
      'tasks',
      where: 'taskDate = ?',
      whereArgs: [day],
      orderBy: 'createdAt DESC, id DESC',
    );
    return rows.map(Task.fromMap).toList();
  }

  Future<Task?> getTaskById(int id) async {
    final rows = await (await database).query(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : Task.fromMap(rows.first);
  }

  Future<int> updateTask(Task task) async {
    if (task.id == null) {
      throw ArgumentError('Cannot update a task without an ID.');
    }
    return (await database).update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> updateTaskCompletion(int id, bool isCompleted) async =>
      (await database).update(
        'tasks',
        {
          'isCompleted': isCompleted ? 1 : 0,
          'updatedAt': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [id],
      );

  Future<int> deleteTask(int id) async =>
      (await database).delete('tasks', where: 'id = ?', whereArgs: [id]);
}
